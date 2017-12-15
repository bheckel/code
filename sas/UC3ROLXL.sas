//BQH0UROL JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=20,CLASS=J,REGION=0M
//STEP1    EXEC SAS90,TIME=100,OPTIONS='MEMSIZE=0,ALTPRINT=OLST,
//                                                ALTLOG=OLOG'                              
//OLST     DD DISP=SHR,DSN=BQH0.INC.SASLST
//OLOG     DD DISP=SHR,DSN=BQH0.INC.SASLOG
//WORK     DD SPACE=(CYL,(100,100),,,ROUND)
//SYSIN    DD *

 /**********************************************************************
  * PROGRAM NAME:  UC3ROLXL.sas
  *
  *  DESCRIPTION:  Produce a report of specific ICD code counts and
  *                percents for a 4 year range, summing (and rolling up)
  *                the counts of 4 digit codes into 3 digit codes.
  *
  *                This is the all states version of UCSELECT, it
  *                assumes a 4 yr report is desired.
  *
  *                Cannot run via Connect except when debugging just a few
  *                states (out of mem error).
  *
  *                Should run ok w/o edits.
  *
  *     CALLS TO:  nothing
  *    CALLED BY:  FCAST
  *
  *  INPUT MVARS:  EYR
  *
  *   PROGRAMMER:  bqh0
  * DATE WRITTEN:  2004-09-21
  *
  *   UPDATE LOG:                                              
  * 2004-11-19 (bqh0) rerun for Donna w/ no changes, ignoring split
  *                   states - don't think any med data is split 
  * 2005-03-03 (bqh0) rerun for Donna but use a temporary med 2002 since 
  *                   mvds doesn't hold the correct acme_uc codes yet
  * 2005-06-30 (bqh0) adapt for a 2004 run per dwj2
  *********************************************************************/
options notes source source2 filemsgs mlogic mprint sgen NOs99nomig;

%let START=%sysfunc(time());
title1; footnote1;
%include 'BQH0.PGM.LIB(TABDELIM)';

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

  libname MVDS1 "/u/dwj2/mvds/MED/2001";
  libname MVDS2 "/u/dwj2/mvds/MED/2002";
  libname MVDS3 "/u/dwj2/mvds/MED/2003";
  libname MVDS4 "/u/dwj2/mvds/MED/2004";
%mend Init;

 /* Provided by FCAST */
%global EYR;
 /* DEBUG */
%let EYR=2004;
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

 /***/
%BuildSetStmt(AKNEW ALNEW ARNEW ASNEW AZNEW CANEW CONEW CTNEW DCNEW
              DENEW FLNEW GANEW GUNEW HINEW IANEW IDNEW ILNEW INNEW
              KSNEW KYNEW LANEW MANEW MDNEW MENEW MINEW MNNEW MONEW
              MPNEW MSNEW MTNEW NCNEW NDNEW NENEW NHNEW NJNEW NMNEW
              NVNEW NYNEW OHNEW OKNEW ORNEW PANEW PRNEW RINEW SCNEW
              SDNEW TNNEW TXNEW UTNEW VANEW VINEW VTNEW WANEW WINEW
              WVNEW WYNEW YCNEW
             );
 /***/
 /* DEBUG */
 /***
%BuildSetStmt(AKNEW ALNEW );
 ***/


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

   /* We don't care what comes after the 3rd char. */
  data tmpyr&cntyr;
    set tmpyr&cntyr (rename=(acme_uc=icd));
    icd = substr(icd, 1, 3);
  run;

  proc sql;
    create table rolledintothrees as
    select icd, count(icd) as totcnt
    from tmpyr&cntyr
    group by icd
    ;
  quit;

  data subtotalled;
    set rolledintothrees;
    datayr = &yfour;
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

proc print data=_LAST_(obs=max); run;
proc transpose data=allyrs out=allyrsfinalN (drop=_NAME_) prefix=nYr_;
  by icd;
  /* The new variable (former observation). */
  id datayr;
  var totcnt;
run;


proc transpose data=allyrs out=allyrsfinalP (drop=_NAME_) prefix=pYr_;
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
filename ICDS 'DWJ2.UCLIST3D.TXT' DISP=SHR;

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
 /***
%global FILEOUT;
%let SUBJECT=&EYR ALL STATES &NUMCODES SELECTED CAUSES OF DEATH;
%let FNM=&SYSUID..&EYR..UC3ROLLUP.PDF;
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
footnote "Based on the ICD10 code list located at 'DWJ2.UCLIST3D.TXT', "
         "this report rolls up all 4 character codes to a 3 character level.";
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
 ***/

data tmp;
  retain desc diff pYr: nYr:;
  set combined (keep=desc diff pYr: nYr:);
run;

%Tabdelim(work.tmp, 'BQH0.TMPTRAN2');

%put !!!(&SYSCC) Elapsed minutes: %sysevalf((%sysfunc(time())-&START)/60);
