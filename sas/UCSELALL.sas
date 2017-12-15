 /**********************************************************************
  * PROGRAM NAME: UCSELALL
  *
  *  DESCRIPTION:  Produce a report of specific ICD code counts and
  *                percents for a 4 year range, summing (and rolling up)
  *                the counts of 4 digit codes into 3 digit codes.
  *
  *                The counting algorithms sum 4 digit sublevels into 3
  *                digit toplevel ICD codes.  However, the 3 digit
  *                toplevel codes occasionally show up on their own so
  *                those lines are included in their summed total count
  *                as well.
  *
  *                This logic is different from the 113 report logic
  *                (and more complex due to the rollups).
  *
  *                This is the all states version of UCSELECT, it
  *                assumes a 4 yr report is desired.
  *
  *     CALLS TO:  nothing
  *    CALLED BY:  FCAST
  *
  *  INPUT MVARS:  FY4
  *
  *   PROGRAMMER:  bqh0
  * DATE WRITTEN:  2004-07-23
  *
  *   UPDATE LOG:                                              
  * 2004-07-28 (bqh0) Run a 2000-2003 version for dwj2
  * 2004-08-03 (bqh0) Adapt for use as an FCAST report
  * 2004-08-17 (bqh0) Adapt for MVDS instead of textfiles
  * 2004-08-31 (bqh0) Eliminate the need to determine which MVDS
  *                   datasets are available
  *********************************************************************/
 /* Use sgen selectively b/c SETSTMT below resolves to a huge string */
options notes source source2 filemsgs mlogic mprint NOsgen NOs99nomig;

title1; footnote1;

%macro Init(endyr);
  %global BYR PREVYR YR1 YR2 YR3 YR4 RPT CNT1 CNT2 CNT3 CNT4 CSV
          FNM SUBJECT
          ;

  /* Make sure we're receiving year 2000-2099 from FCAST. */
  %if not %index(&endyr, 20) %then
    %abort;

   /* Always want an ascending, #1 is oldest, 4 year rpt. */
  %let BYR=%eval(&endyr-3);
  %let PREVYR=%eval(&endyr-1);
   /* E.g. 2000 */
  %let YR1=%eval(&endyr-3);
   /* E.g. 2001 */
  %let YR2=%eval(&endyr-2);
   /* E.g. 2002 */
  %let YR3=%eval(&endyr-1);
   /* E.g. 2003 */
  %let YR4=%eval(&endyr-0);

  %do i=1 %to 4;
    libname MVDS&i "DWJ2.MED&&YR&i...MVDS.LIBRARY.NEW" DISP=SHR;
  %end;
%mend Init;

 /* Provided by FCAST */
%global EYR;
%Init(&EYR);


/* "Returns"
 * MVDS1.AKNEW (keep=acme_uc in=fr1) 
 * MVDS2.AKNEW (keep=acme_uc in=fr2) 
 * MVDS3.AKNEW (keep=acme_uc in=fr3) 
 * MVDS4.AKNEW (keep=acme_uc in=fr4) 
 * MVDS1.ALNEW (keep=acme_uc in=fr1) 
 * MVDS2.ALNEW (keep=acme_uc in=fr2) 
 * ... 
 */
%macro BuildSetStmt(s) ;
  %local i dsn;
  %global SETSTMT;

  %let i=1;
  %let dsn = %scan(&s, &i, ' ');

  %do %while (&dsn ne  );
    %let SETSTMT=&SETSTMT MVDS1.&dsn (keep=acme_uc in=from1) ;
    %let SETSTMT=&SETSTMT MVDS2.&dsn (keep=acme_uc in=from2) ;
    %let SETSTMT=&SETSTMT MVDS3.&dsn (keep=acme_uc in=from3) ;
    %let SETSTMT=&SETSTMT MVDS4.&dsn (keep=acme_uc in=from4) ;
    %let i=%eval(&i+1);
    %let dsn = %scan(&s, &i, ' ');
  %end;
%mend BuildSetStmt;

%BuildSetStmt(AKNEW ALNEW ARNEW ASNEW AZNEW CANEW CONEW CTNEW DCNEW
              DENEW FLNEW GANEW GUNEW HINEW IANEW IDNEW ILNEW INNEW
              KSNEW KYNEW LANEW MANEW MDNEW MENEW MINEW MNNEW MONEW
              MPNEW MSNEW MTNEW NCNEW NDNEW NENEW NHNEW NJNEW NMNEW
              NVNEW NYNEW OHNEW OKNEW ORNEW PANEW PRNEW RINEW SCNEW
              SDNEW TNNEW TXNEW UTNEW VANEW VINEW VTNEW WANEW WINEW
              WVNEW WYNEW YCNEW
             );


data yearadded (rename=(acme_uc=cause));
  set &SETSTMT;

  if from1 then
    yyyy=&YR1;
  else if from2 then
    yyyy=&YR2;
  else if from3 then
    yyyy=&YR3;
  else if from4 then
    yyyy=&YR4;
run;
libname _ALL_ clear;


%macro SplitDSByYear;
  %local i y;

  /* We're producing a four year report so build 4 datasets. */
  %do i=1 %to 4;
    /* E.g. if EYR is 2003 and i is 1 then 2003-(4-1)=2000 */
    %let y=%eval(&EYR-(4-&i));
    data tmpyr&i (drop=yyyy);
      set yearadded;
      if yyyy eq "&y"; 
    run;
  %end;
%mend SplitDSByYear;
%SplitDSByYear


 /* Use single year dataset to calculate total summed count for the current
  * year.
  */
%macro CountYear(cntyr);
  %local dsid lines rc yfour;

  /* Build a 4 digit year out of the year sequence number cntyr */
  /* The 4 in this line is how many years of data we report, not '4 digit
   * year'.  E.g. if EYR is 2003 and cntyr is 1 then 2003-(4-1)=2000
   */
  %let yfour=%eval(&EYR-(4-&cntyr));

  %let dsid=%sysfunc(open(WORK.tmpyr&cntyr));
  %let lines=%sysfunc(attrn(&dsid, nobs));
  %let rc=%sysfunc(close(&dsid));

  %let CNT&cntyr=&lines;

  proc sort data=tmpyr&cntyr;
    by cause;
  run;

  data prefixorsub;
    retain prefix;
    /* e.g.  A04       A047   */
    length prefix $ 4  sub $ 4;
    set tmpyr&cntyr;
    /* If we have a new cluster. */
    if length(cause) eq 3 then
      prefix = cause;
    /* If we have a sub-code. */
    else if substr(cause, 1, 3) = prefix then
      sub = cause;
    /* If we have a 4 digit without a toplevel 3 parent.  Can't create a
     * parent here b/c it will inflate the total incorrectly.
     */
    else
      prefix = cause;
  run;

   /* Create parents for orphans, if any. */
  data fours;
    set prefixorsub (keep= cause);
    if length(cause) eq 4;
  run;

  data parented;
    set fours;
    artificial = substr(cause, 1, 3);
  run;

   /* Raw pre-count. */
  proc sql;
    create table tmpx as
    select prefix, count(prefix) as cp, sub, count(sub) as cs
    from prefixorsub
    group by prefix, sub
    order by prefix
    ;
  quit;

   /* Count the sublevels. */
  proc sql;
    create table subleveltot as
    select sub as icd, cs as totcnt
    from tmpx
    where cs ne 0
    ;
  quit;

   /* Count the toplevels. */
  proc sql;
    create table topleveltot as
    select prefix as icd, sum(cp) as totcnt
    from tmpx
    group by prefix
    order by prefix
    ;
  quit;

  data rawfinished;
    merge topleveltot subleveltot;
    by icd;
  run;
  proc sort data=rawfinished;
    by icd;
  run;

   /* Now must create parents if needed. */
  data addparents (drop=cause);
    merge parented (rename=(artificial=icd)) rawfinished;
    by icd;
    /* We have a 4 digit sublevel that has no 3 digit parent. */
    if totcnt eq . then
      do;
        newparent+1;
      end;
    else newparent=0;
  run;
  proc sort data=addparents;
    by icd;
  run;

  data addparents;
    set addparents;
    if newparent ne 0 then
      totcnt = newparent;
    datayr = &yfour;
  run;

  data subtotalled (drop= newparent);
    set addparents;
    by icd;
    if last.icd;
  run;

  data subtotalled;
    set subtotalled;
    pct = (totcnt/&lines)*100;
  run;

  proc append base=allyrs data=subtotalled;
  run;
%mend CountYear;


%macro Main;
  %local i;

  /* Four year report. */
  %do i=1 %to 4;
    %CountYear(&i);
  %end;
%mend Main;
%Main;


proc sort data=allyrs;
  by icd;
run;


proc transpose data=allyrs out=allyrsfinalN (drop=_NAME_)
               prefix=nYr_;
  by icd;
  /* The new variable (former observation). */
  id datayr;
  var totcnt;
run;


proc transpose data=allyrs out=allyrsfinalP (drop=_NAME_)
               prefix=pYr_;
  by icd;
  /* The new variable (former observation). */
  id datayr;
  var pct;
run;


data allyrspctandcnt;
  merge allyrsfinalN allyrsfinalP;
  by icd;
run;


data allyrspctandcnt;
  set allyrspctandcnt;

  label icd = 'ICD Code';
  label diff = "% DIFF*&YR4/&YR3";
  label pYr_&YR1 = "&YR1*RPTD*%";
  label pYr_&YR2 = "&YR2*RPTD*%";
  label pYr_&YR3 = "&YR3*RPTD*%";
  label pYr_&YR4 = "&YR4*RPTD*%";
  label nYr_&YR1 = "&YR1*CNT*N";
  label nYr_&YR2 = "&YR2*CNT*N";
  label nYr_&YR3 = "&YR3*CNT*N";
  label nYr_&YR4 = "&YR4*CNT*N";

  /* Diff column only compare latest 2 yrs. */
  if pYr_&YR3 > 0 then
    diff=((pYr_&YR4 - pYr_&YR3) / pYr_&YR3) * 100;
  else
    diff = 0;
run;


 /* Selected ICD10 codes of interest per dwj2.  Assumed to be sorted on
  * cause.  Sample lines (text has been mixcased to avoid confusion with the
  * 113 UC report): 
  * A04  - Other bacterial intestinal infections
  * A047 - Enterocolitis due to Clostridium difficile
  */
filename ICDS 'DWJ2.SPECICD.TXT' DISP=SHR;

data wantedcodes;
  infile ICDS TRUNCOVER END=lastobs;
  input icd $  desc $ 1-80;
  label desc = 'ICD10*Code - Description';
  if lastobs then
    call symput('NUMCODES', compress(_N_));
run;


 /* Left join to get only the 56 codes that dwj2 wants. */
data combined;
  merge wantedcodes (in=in_want) allyrspctandcnt (in=in_last);
  by icd;
  if in_want;
  /* Replace blanks with zeros (for presentation purposes only): */
  array nums _NUMERIC_;
  do over nums;
    if nums = . then
      nums = 0;
  end;
run;


/* For PREMAIL when user chooses FCAST 'printer dest' MAIL */
%global FILEOUT;
%let SUBJECT=&EYR ALL STATES &NUMCODES SELECTED CAUSES OF DEATH;
%let FNM=&SYSUID..&EYR..56UC.PDF;
%let USER = %sysfunc(lowcase(&SYSUID));

%include 'DWJ2.UTIL.LIBRARY(PREMAIL)';
%PREODS(%str(&SUBJECT), %str(&FNM));
title1 "&SUBJECT";
title2 'TIME SERIES ANALYSIS REPORT';
title3 '(COUNTS    '
       "&YR4: %sysfunc(putn(&CNT4, COMMA10.))     "
       "&YR3: %sysfunc(putn(&CNT3, COMMA10.))     "
       "&YR2: %sysfunc(putn(&CNT2, COMMA10.))     "
       "&YR1: %sysfunc(putn(&CNT1, COMMA10.))"
       ')'
       ;
options linesize=133;
proc report data=combined split='*' headskip;
  column desc diff pYr_&YR4 pYr_&YR3 pYr_&YR2 pYr_&YR1
                   nYr_&YR4 nYr_&YR3 nYr_&YR2 nYr_&YR1;
  define desc     / width=65;
  define diff     / format=8.0 width=6 style={cellwidth=45pt just=right};
  define pYr_&YR1 / format=8.2 width=4 style={cellwidth=39pt just=right};
  define pYr_&YR2 / format=8.2 width=4 style={cellwidth=39pt just=right};
  define pYr_&YR3 / format=8.2 width=4 style={cellwidth=39pt just=right};
  define pYr_&YR4 / format=8.2 width=4 style={cellwidth=39pt just=right};
  define nYr_&YR1 / format=COMMA8. width=7 style={cellwidth=50pt just=right};
  define nYr_&YR2 / format=COMMA8. width=7 style={cellwidth=50pt just=right};
  define nYr_&YR3 / format=COMMA8. width=7 style={cellwidth=50pt just=right};
  define nYr_&YR4 / format=COMMA8. width=7 style={cellwidth=50pt just=right};
run;
