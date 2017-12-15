
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  PROGRAM NAME:     DataPost_Extract.sas
 *
 *  CREATED BY:       Bob Heckel (rshXXXXX)
 *                                                                            
 *  DATE CREATED:     19-Oct-10
 *                                                                            
 *  SAS VERSION:      8.2
 *
 *  PURPOSE:          Extract raw data from disparate GSK systems (DPv2 engine)
 *
 *  INPUT:            SYSPARM, XML configuration file
 *
 *  PROCESSING:       Read control files, query, extract, translate, load
 *
 *  OUTPUT:           None
 *------------------------------------------------------------------------------
 *                     HISTORY OF CHANGE
 *-------------+---------+--------------------+---------------------------------
 *     Date    | Version | Modification By    | Nature of Modification
 *-------------+---------+--------------------+---------------------------------
 *  19-Oct-10  |    1.0  | Bob Heckel         | Original. CCF XXXXX.
 *-------------+---------+--------------------+---------------------------------
 *  16-Nov-10  |    2.0  | Bob Heckel         | New S95 directory structure.
 *             |         |                    | CCF XXXXX.
 *-------------+---------+--------------------+---------------------------------
 *  03-Jan-11  |    3.0  | Bob Heckel         | Add ODS for Diskus.  CCF XXXXX.
 *-------------+---------+--------------------+---------------------------------
 *  09-Mar-11  |    4.0  | Bob Heckel         | Add ODS for Solid Dose.
 *             |         |                    | CCF XXXXX.
 *-------------+---------+--------------------+---------------------------------
 *  23-Mar-13  |    5.0  | Bob Heckel         | Add ODS for Serevent Diskus and
 *             |         |                    | Advair Diskus ED.  CCF XXXXX.
 *-------------+---------+--------------------+---------------------------------
 *  19-Apr-14  |    6.0  | Bob Heckel         | Extract-enabled flag now accepts 
 *             |         |                    | 1 or higher. >1 is hidden in
 *             |         |                    | XSLT as an alternative to 
 *             |         |                    | HideInGUI tag.
 *             |         |                    | 
 *             |         |                    | Disable old Advair Diskus 
 *             |         |                    | sections.
 *             |         |                    | 
 *             |         |                    | Add Saturday to isWeekday to 
 *             |         |                    | protect long Friday runs.
 *             |         |                    | 
 *             |         |                    | CCF XXXXX.
 *-------------+---------+--------------------+---------------------------------
 *******************************************************************************
 */
options source mprint sgen ls=max ps=max fmtsearch=(MYFMTLIB);

 /* Per QA5157: */
options NOnumber;
DM 'clear log'; DM 'clear output'; proc datasets library=WORK kill NOlist; run;
proc sql NOprint;
  select '%let
   '||compress(name)||' =;'
   into :resetmv separated by ' '
   from dictionary.macros
   where scope='GLOBAL';
quit;
&resetmv; title; footnote;

options NOsource NOsgen;
%put NOTE: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;
%let _start=%sysfunc(datetime()); %put NOTE: %sysfunc(getoption(SYSIN)) started: %sysfunc(putn(%sysfunc(datetime()),DATETIME.)), SYSPARM: &SYSPARM;
%put NOTE: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;
options source sgen;

 /* Each source query formats time slightly differently e.g. ip21 is 28-AUG-10 13:29:57, 
  * b21 is 2010-02-04T10:59:00, fw is 2009-05-21 15:46:59.727
  * We can't build the format in the dynamic macro code due to compiletime/runtime issues
  * so formats.sas7bcat  must be built and stored.
  */
libname MYFMTLIB "&SYSPARM\code";


%macro DataPost_Extract;
  %put; %put; %put; %put ===============================; %put ===============================; %put DataPost_Extract; %put;

  /* Modified V2: for new paths */
  %global DPPATH; %let DPPATH=%bquote(&SYSPARM);
  %global DLIPATH; %let DLIPATH=&DPPATH\code\;  /* used by SCL COM */

  options ls=180 NOcenter mautosource sasautos=("&DPPATH\code") NOxwait NOovp;

  filename MAP "&DPPATH\cfg\DataPost_Configuration.map";
  libname XLIB XML "&DPPATH\cfg\DataPost_Configuration.xml" xmlmap=MAP access=READONLY;

  data xconnection; set XLIB.connection; run;
  proc sort data=xconnection; by connectionID; run;
  %put; %put; %put; %put ==========================; %put Connections; %put;
  data _null_; set xconnection; put (_all_)(=); put; run;  /* for UTC */

  data xextract; set XLIB.extract; run;
  proc sort data=xextract; by connectionID; run;
  %put; %put; %put; %put ==========================; %put Extracts; %put;
  data _null_; set xextract; put (_all_)(=); put; run;  /* for UTC */

  data conqry;
    merge xconnection xextract;
    by connectionID;
  run;
  %put; %put; %put; %put ==========================; %put Joined (ConQry); %put;
  data _null_; set conqry; put (_all_)(=); put; run;  /* DEBUG */

  proc contents data=conqry out=contents_conqry NOprint; run;
  proc sql NOprint;
    select name into :vnms separated by ' '
    from contents_conqry
    ;
  quit;

  /*********************************************************************************************************/
  /* Update the chunking datasets used to maintain state - "know" the last large (usually sunday) run date.
   * Note - a product uses a single dataset, potentially across macros/extractids.
   */

  /* MAXTS is used by ip21_0001e.sas */
  libname OUTPCODE "&DPPATH/code";
  data _null_;
    set OUTPCODE.ip21_0001e;
    call symput('MAXTS', maxts);
    call symput('MAXTSDEBUG', put(maxts, DATETIME18.));
  run;

  /* Added: V4 */
  /* MAXTS3 is used by Solid Dose e.g. ods0002e.sas, etc. (solid dose is treated as a single product) */
  data _null_;
    set OUTPCODE.ods_0002e;
    call symput('MAXTS3', maxts3);
    call symput('MAXTS3DEBUG', put(maxts3, DATETIME18.));
  run;
  /*********************************************************************************************************/

  data _NULL_;
    /* Macros accept globals instead of parameters due to potentially long query strings */
    set conqry;

    %let i=1;
    %do %until (%qscan(&vnms, &i)=  );
      %let f=%qscan(&vnms, &i);
        call symput("&f",left(trim(&f)));
      %let i=%eval(&i+1);
    %end;

    if weekday(today()) in(1) then
      isSunday=1;
    else
      isSunday=0;

    if weekday(today()) in(7) then
      isSaturday=1;
    else
      isSaturday=0;

    if weekday(today()) in(2, 4, 6) then
      isMWF=1;
    else
      isMWF=0;

    if weekday(today()) in(3, 5) then
      isTR=1;
    else
      isTR=0;

    /* Modified V6: Saturday is included to accomodate runs that start late Friday and overflow into the next day.
     * For Extracts that would never happen in current state (April 2012) unless a future module executes prior to it.
     */
    if weekday(today()) in(2, 3, 4, 5, 6, 7) then
      isWeekday=1;
    else
      isWeekday=0;

    if weekday(today()) in(1, 7) then
      isWeekend=1;
    else
      isWeekend=0;

    if executefrequency eq 'weekdays' and isWeekday then
      dateok=1;
    else if executefrequency eq 'weekends' and isWeekend then
      dateok=1;
    else if executefrequency eq 'sunday' and isSunday then
      dateok=1;
    else if executefrequency eq 'saturday' and isSaturday then
      dateok=1;
    else if executefrequency eq 'MWF' and isMWF then
      dateok=1;
    else if executefrequency eq 'TR' and isTR then
      dateok=1;
    else if executefrequency eq 'daily' then
      dateok=1;
    else
      dateok=0;

    /* Modified V6: extractenabled eq 2 indicates 'hide me' from web xslt display */
    if connectionenabled eq 1 and extractenabled ge 1 and dateok eq 1 then do;
      s1='%'||executemacro;
      put '!!!  running: ' extractid= s1= connectionID= executemacro= connectionenabled= extractenabled= dateok=;
      call execute(s1);  /* 2010-08-06 SAS v8.2 unable to suppress incorrect SAS Log WARNING 32-169 */
    end;
    else do;
      put '!!! skipping: ' extractid= connectionID= executemacro=  connectionenabled= extractenabled= dateok=;
    end;
  run;
%mend DataPost_Extract;
%DataPost_Extract;

options NOsource NOsgen;
%put NOTE: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;
%put NOTE: SYSCC: &SYSCC;
%put NOTE: %sysfunc(getoption(SYSIN)) ended: %sysfunc(putn(%sysfunc(datetime()),DATETIME.)) / minutes elapsed: %sysevalf((%sysfunc(datetime())-&_start)/60);
%put NOTE: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;
options source sgen;
