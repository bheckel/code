options notes NOcenter source source2 filemsgs mlogic mprint NOsgen NOs99nomig;

%global EYR NYR MED;
 /* Usually provided by FCAST */
%let EYR=2003;
%let NYR=4;
%let EVT=MED;


 /* Create globals, check valid dates, setup year ranges, setup libname
  * statements.
  */
%macro Init(validstartyr, validendyr);
  /* Make sure we're receiving year 2000-2099 (usually from FCAST). */
  %if ( %eval(&EYR)>&validendyr or %eval(&EYR)<&validstartyr ) %then
    %do;
      %put ERROR: year &EYR is out of range &validstartyr &validendyr;
      %abort;
    %end;

  %macro MkG;
    %do i=1 %to &NYR;
      %global YR&i CNT&i;
    %end;
  %mend MkG;
  %MkG

  %global BYR PREVYR RPT CSV FNM SUBJECT;

   /* Always want an ascending 4 yr. report with YR1 as oldest. */
  %let BYR=%eval(&EYR-3);
  %let PREVYR=%eval(&EYR-1);

  %do i=1 %to &NYR;
    /* E.g. &YR1 resolves to 2000 when i is 1, 2001 when i is 2... */
    %let YR&i=%eval(&EYR-%eval(&NYR-&i));
    libname MVDS&i "DWJ2.&EVT.&&YR&i...MVDS.LIBRARY.NEW" DISP=SHR;
  %end;
%mend Init;
%Init(1994, 2099);


 /* "Returns"
  * MVDS1.AKNEW (keep=acme_uc in=fr1) 
  * MVDS2.AKNEW (keep=acme_uc in=fr2) 
  * MVDS3.AKNEW (keep=acme_uc in=fr3) 
  * MVDS4.AKNEW (keep=acme_uc in=fr4) 
  * MVDS1.ALNEW (keep=acme_uc in=fr1) 
  * MVDS2.ALNEW (keep=acme_uc in=fr2) 
  * ... 
  */
%macro BuildSetStmt(s);
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

 /***
%BuildSetStmt(AKNEW ALNEW ARNEW ASNEW AZNEW CANEW CONEW CTNEW DCNEW
              DENEW FLNEW GANEW GUNEW HINEW IANEW IDNEW ILNEW INNEW
              KSNEW KYNEW LANEW MANEW MDNEW MENEW MINEW MNNEW MONEW
              MPNEW MSNEW MTNEW NCNEW NDNEW NENEW NHNEW NJNEW NMNEW
              NVNEW NYNEW OHNEW OKNEW ORNEW PANEW PRNEW RINEW SCNEW
              SDNEW TNNEW TXNEW UTNEW VANEW VINEW VTNEW WANEW WINEW
              WVNEW WYNEW YCNEW
             );
 ***/
%BuildSetStmt(AKNEW ALNEW ARNEW);


%macro AddYears;
  %local i;
    data yearadded (rename=(acme_uc=cause));
      set &SETSTMT;

      %do i=1 %to &NYR;
        if from&i then
          yyyy=&&YR&i;
      %end;
    run;
  libname _ALL_ clear;
%mend AddYears;
%AddYears;


%macro SplitDSByYear;
  %local i y;

  /* We're producing a four year report so build 4 datasets. */
  %do i=1 %to &NYR;
    /* E.g. if EYR is 2003 and i is 1 then 2003-(4-1)=2000 */
    %let y=%eval(&EYR-(&NYR-&i));
    data tmpyr&i (drop=yyyy);
      set yearadded;
      if yyyy eq "&y"; 
    run;
  %end;
%mend SplitDSByYear;
%SplitDSByYear


%macro Main;
  %local i;

  title 'everything';
  proc freq data=yearadded;
    table cause / nocum;
  run;

  title 'by year';
  %do i=1 %to &NYR;
    proc freq data=tmpyr&i;
      table cause / nocum;
    run;
  %end;
%mend Main;
%Main;
