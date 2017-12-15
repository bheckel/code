 /**********************************************************************
  * PROGRAM NAME:  UC3ALL.sas
  *
  *  DESCRIPTION:  Produce a report of specific ICD code counts and
  *                percents for a 4 year range
  *
  *                Based on UCSELALL.sas but does not do any rollup, per
  *                Donna Glenn.
  *
  *     CALLS TO:  nothing
  *    CALLED BY:  FCAST
  *
  *  INPUT MVARS:  FY4
  *
  *   PROGRAMMER:  bqh0
  * DATE WRITTEN:  2004-09-15
  *
  *   UPDATE LOG:                                              
  *********************************************************************/
 /* Use sgen selectively b/c SETSTMT below resolves to a huge string */
options notes source source2 filemsgs mlogic mprint sgen NOs99nomig;

title1; footnote1;

%macro Init(endyr);
  %global BYR PREVYR YR1 YR2 YR3 YR4 RPT CNT1 CNT2 CNT3 CNT4 CSV
          FNM SUBJECT
          ;

  /* Make sure we're receiving year 2000-2099 (usually from FCAST). */
  %if not %index(&endyr, 20) %then
    %abort;

   /* Always want an ascending 4 yr. report with YR1 as oldest. */
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


data yearadded;
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
libname MVDS1 clear;
libname MVDS2 clear;
libname MVDS3 clear;
libname MVDS4 clear;


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
  %local yfour dsid lines rc;

  /* Build a 4 digit year out of the year sequence number cntyr */
  /* The 4 in this line is how many years of data we report, not '4 digit
   * year'.  E.g. if EYR is 2003 and cntyr is 1 then 2003-(4-1)=2000
   */
  %let yfour=%eval(&EYR-(4-&cntyr));
  %let dsid=%sysfunc(open(WORK.tmpyr&cntyr));
  %let lines=%sysfunc(attrn(&dsid, nobs));
  %let rc=%sysfunc(close(&dsid));

  %let CNT&cntyr=&lines;

  proc sql;
    create table counted as
    select acme_uc, count(acme_uc) as acme_uc_cnt
    from tmpyr&cntyr
    group by acme_uc
    order by acme_uc
    ;
  quit;

  data subtotalled;
    set counted;
    datayr = "&yfour";
    acme_uc_pct = (acme_uc_cnt/&lines)*100;
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

 /* There's probably a better way to do this but I adapted UCSELALL
  * logic instead of starting from scratch. 
  */

proc sort data=allyrs;
  by acme_uc;
run;


proc transpose data=allyrs out=allyrsfinalN (drop=_NAME_) prefix=nYr_;
  by acme_uc;
  /* The new variable (former observation). */
  id datayr;
  var acme_uc_cnt;
run;


proc transpose data=allyrs out=allyrsfinalP (drop=_NAME_) prefix=pYr_;
  by acme_uc;
  /* The new variable (former observation). */
  id datayr;
  var acme_uc_pct;
run;


data allyrspctandcnt;
  merge allyrsfinalN allyrsfinalP;
  by acme_uc;
run;


data allyrspctandcnt;
  set allyrspctandcnt;

  label acme_uc  = 'ICD Code';
  label diff     = "% DIFF*&YR4/&YR3";
  label pYr_&YR1 = "&YR1*RPTD*%";
  label pYr_&YR2 = "&YR2*RPTD*%";
  label pYr_&YR3 = "&YR3*RPTD*%";
  label pYr_&YR4 = "&YR4*RPTD*%";
  label nYr_&YR1 = "&YR1*CNT*N";
  label nYr_&YR2 = "&YR2*CNT*N";
  label nYr_&YR3 = "&YR3*CNT*N";
  label nYr_&YR4 = "&YR4*CNT*N";

  /* The %DIFF column only compare latest 2 yrs. */
  if pYr_&YR3 > 0 then
    do;
      /* ICD113 uses this bizzarre logic but we're not going to */
      ***diff=((pYr_&YR4 - pYr_&YR3) / pYr_&YR3) * 100;
      diff=((nYr_&YR4 - nYr_&YR3) / nYr_&YR3) * 100;
    end;
  else
    diff = 0;
run;


 /* All 3 digit ICD10 codes of interest per Donna Glenn.  Assumed to be sorted on
  * cause.  Sample lines (text has been mixcased to avoid confusion with the
  * 113 UC report): 
  * A00 Cholera
  * A01 Typhoid and paratyphoid fevers
  * A02 Other salmonella infections
  */
filename ICDS 'DWJ2.UCLIST3D.TXT' DISP=SHR;

data wantedcodes;
  infile ICDS TRUNCOVER END=lastobs;
  input acme_uc $  descr $ 1-80;
  label descr = 'ICD10 Three Digit Code - Description';
  if lastobs then
    call symput('NUMCODES', compress(_N_));
run;


 /* Left join to get only the codes that Donna G. wants. */
data combined;
  merge wantedcodes (in=in_want) allyrspctandcnt (in=in_last);
  by acme_uc;
  if in_want;
  /* Replace blanks with zeros (for presentation purposes only): */
  array nums _NUMERIC_;
  do over nums;
    if nums = . then
      nums = 0;
  end;
run;


 /**** For PREMAIL if user chooses FCAST 'printer dest' MAIL ****/
%global FILEOUT;
%let SUBJECT=&EYR ALL STATES &NUMCODES SELECTED CAUSES OF DEATH;
%let FNM=&SYSUID..&EYR..UC3digit.PDF;
%let USER = %sysfunc(lowcase(&SYSUID));
 /***************************************************************/

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
proc report data=combined SPLIT='*' HEADSKIP;
  column descr diff pYr_&YR4 pYr_&YR3 pYr_&YR2 pYr_&YR1
                    nYr_&YR4 nYr_&YR3 nYr_&YR2 nYr_&YR1
                    ;
  define descr    / width=65;
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
