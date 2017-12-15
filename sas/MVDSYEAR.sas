 /**********************************************************************
  * PROGRAM NAME: MVDSYEAR.sas
  *
  *  DESCRIPTION: Create WORK datasets for use in annual report 
  *               processing.
  *
  *     CALLS TO:  
  *    CALLED BY:  
  *
  *  INPUT MVARS: EYR EVT
  *
  *   PROGRAMMER: bqh0
  * DATE WRITTEN: 2004-10-08
  *
  *   UPDATE LOG:                                              
  *********************************************************************/
%let EYR=2004;  /* DEBUG */
%let EVT=MOR;  /* DEBUG */

 /* Use sgen selectively b/c SETSTMT below resolves to a huge string */
options notes source source2 filemsgs mlogic mprint sgen NOs99nomig
        NOcenter ls=max
        ;

title1; footnote1;

%macro Init(endyr, event);
  %global BYR PREVYR YR1 YR2 YR3 YR4 YR5 YR6;

   /* Always want an ascending 6 yr. report with YR1 as oldest. */
  %let BYR=%eval(&endyr-3);
  %let PREVYR=%eval(&endyr-1);

   /* E.g. 1999 */
  %let YR1=%eval(&endyr-5);
   /* E.g. 2000 */
  %let YR2=%eval(&endyr-4);
  %let YR3=%eval(&endyr-3);
  %let YR4=%eval(&endyr-2);
  %let YR5=%eval(&endyr-1);
  %let YR6=%eval(&endyr-0);

  %do i=1 %to 6;
    libname MVDS&i "/u/dwj2/mvds/&event/&&YR&i";
  %end;
%mend Init;


 /* "Returns"
  * MVDS1.AKNEW (in=fr1) 
  * MVDS2.AKNEW (in=fr2) 
  * ... 
  */
%macro BuildSetStmt(s);
  %local i dsn;
  %global SETSTMT;

  %let i=1;
  %let dsn = %scan(&s, &i, ' ');

  %do %while (&dsn ne  );
    %let SETSTMT=&SETSTMT MVDS1.&dsn (in=from1) ;
    %let SETSTMT=&SETSTMT MVDS2.&dsn (in=from2) ;
    %let SETSTMT=&SETSTMT MVDS3.&dsn (in=from3) ;
    %let SETSTMT=&SETSTMT MVDS4.&dsn (in=from4) ;
    %let SETSTMT=&SETSTMT MVDS5.&dsn (in=from5) ;
    %let SETSTMT=&SETSTMT MVDS6.&dsn (in=from6) ;
    %let i=%eval(&i+1);
    %let dsn = %scan(&s, &i, ' ');
  %end;
%mend BuildSetStmt;


%macro AddPeriods;
  data all;
    set &SETSTMT;

    if from1 then
      yyyy=&YR1;
    else if from2 then
      yyyy=&YR2;
    else if from3 then
      yyyy=&YR3;
    else if from4 then
      yyyy=&YR4;
    else if from5 then
      yyyy=&YR5;
    else if from6 then
      yyyy=&YR6;
  run;
  libname MVDS1 clear;
  libname MVDS2 clear;
  libname MVDS3 clear;
  libname MVDS4 clear;
  libname MVDS5 clear;
  libname MVDS6 clear;
%mend AddPeriods;


%macro SplitDSByPeriod;
  %local i y;

  %do i=1 %to 6;
    /* E.g. if EYR is 2003 and i is 1 then 2003-(6-1)=1999 */
    %let y=%eval(&EYR-(6-&i));
    data period&i (drop=yyyy);
      set all;
      if yyyy eq "&y"; 
    run;
  %end;
%mend SplitDSByPeriod;


%macro Main(endyr, event);
  %Init(&endyr, &event);
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
  %BuildSetStmt(IDNEW MTNEW SDNEW );  /* DEBUG */
  %AddPeriods;
  %SplitDSByPeriod;
%mend Main;
%Main(&EYR, &EVT);
