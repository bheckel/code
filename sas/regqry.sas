 /**********************************************************************
  * PROGRAM NAME: BQH0.SAS.INTRNET.PDS(REGQRY)
  *
  *  DESCRIPTION: Display historical changes to the LMIT Register.
  *
  *     CALLS TO: nothing
  *    CALLED BY: http://mainframe.cdc.gov/sasweb/nchs/registers/register.html
  *
  *  INPUT MVARS: the_st the_evt the_yr (from IntrNet)
  *
  *   PROGRAMMER: BQH0
  * DATE WRITTEN: 08 JUN 2004
  *
  *   UPDATE LOG:                                              
  *********************************************************************/
options NOsource NOsource2 mlogic mprint symbolgen;

libname REGLIB "DWJ2.REGISTER.&the_evt.20&the_yr" DISP=OLD WAIT=20;

 /*   Accepts: the temp SAS dataset built by this application
  * "Returns": the count of observations
  */
%macro CountObs(ds);
  %local dsid rc;
  %global numobs;

  %let dsid=%sysfunc(open(&ds));
  %let numobs=%sysfunc(attrn(&dsid, nobs));
  %let rc=%sysfunc(close(&dsid));
  %if &rc ne 0 %then
    %put ERROR: &rc in CountObs macro;
%mend CountObs;


 /*   Accepts: nothing, uses global mvars
  * "Returns": nothing, just spews a warning to user
  */
%macro Ck4NoRecsRet;
  %CountObs(WORK.qryresults);
  %if &numobs eq 0 %then
    %do;
      data _NULL_;
        file _WEBOUT;
        put '<BR>Sorry, no matching records were found for this query.<BR><BR>';
        put '<INPUT TYPE="button" VALUE="<Back" onClick="history.go(-1)"><BR>';
        put "<BR>&SYSDATE &SYSTIME";
      run;
    %end;
%mend Ck4NoRecsRet;


 /*   Accepts: nothing, uses global mvars
  * "Returns": a dynamic SAS 'IF' statement
  */
%macro BuildIfStmt;
  %local b;

  %let b=0;

  /* Since the history datasets are in several libraries, I've disallowed
   * 'ALL' on event and year for now to minimize the complexity of this code.
   * If those restrictions change in the future, the code below will be usable
   * without changes.  But for right now, the logic is more complicated than
   * it needs to be.
   */

  /******* Set coded bit *******/
  %if &the_st ne ALL %then
    %let b=%eval(&b+1);
  
  %if &the_yr ne ALL %then
    %let b=%eval(&b+2);
    
  %if &the_evt ne ALL %then
    %let b=%eval(&b+4);
  /****************************/

  %if &b lt 0 or &b gt 7 %then
    %do;
      %put ERROR: cannot determine query parameters;
      %goto mexiterr;
    %end;

  %if &b eq 1 %then
    %do;
      if stabbrev eq "&the_st";
    %end;

  %if &b eq 2 %then
    %do;
      if yr eq "&the_yr";
    %end;

  %if &b eq 3 %then
    %do;
      if stabbrev eq "&the_st" and yr eq "&the_yr";
    %end;

  %if &b eq 4 %then
    %do;
      if evt eq "&the_evt";
    %end;

  %if &b eq 5 %then
    %do;
      if stabbrev eq "&the_st" and evt eq "&the_evt";
    %end;

  %if &b eq 6 %then
    %do;
      if yr eq "&the_yr" and evt eq "&the_evt";
    %end;

  %if &b eq 7 %then
    %do;
      if stabbrev eq "&the_st" and yr eq "&the_yr" and evt eq "&the_evt";
    %end;

  %mexiterr:
%mend BuildIfStmt;


data qryresults (keep= mergefile rec_count stabbrev userid date_update);
  set REGLIB.history;
  yr = substr(mergefile, 9, 2);
  evt = substr(mergefile, 14, 3);

  %BuildIfStmt
run;

libname REGLIB clear;


 /* We're displaying seconds in this query because it will be more useful as
  * history information than it is when browsing the Register changes.
  */
proc format;                                                                    
  picture f_date OTHER = '%Y-%0m-%0d %0H:%0M:%0S'(datatype=datetime);               
run;                                                                            

%macro bobh;
data _null_;
  file _webout;
  put 'Content-type: text/html';
  put '';
  put '';
  put "Set-Cookie: EVT=&the_evt; path=/;"
      " expires=Tuesday, 02-Dec-2008 12:00:00 GMT";
  put '';
  put '';
run;
%mend bobh;

%let FDATE=%sysfunc(date(), YYMMDD10.);

ods html body=_WEBOUT (dynamic title='Register History Query Results') 
         style=statdoc rs=none;
title "<H3>Register History for &the_st &the_yr &the_evt as of &FDATE<H3>";
title2 "DWJ2.REGISTER.&the_evt.20&the_yr";
proc report data=WORK.qryresults nowd;
 column stabbrev mergefile rec_count userid date_update;

 define stabbrev    / order;
 define date_update / order descending format=f_date.;
 define rec_count   / format=COMMA8.;
 define userid      / width=8;

 /* Stripe for readability. */
 compute rec_count;
   row+1;
   if mod(row, 2) then do;
     call define(_ROW_, "style", "style=[background=#eeeeee]");
   end;
 endcomp;
run;
ods html close;

 /* Handle (very rare) unsuccessful queries. */
%Ck4NoRecsRet;
