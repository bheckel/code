//BQH0UNKN JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=20,CLASS=J,REGION=0M
//STEP1    EXEC SAS90,TIME=100,OPTIONS='MEMSIZE=0,ALTPRINT=OLST,
//                                                ALTLOG=OLOG'
//OLST     DD DISP=SHR,DSN=BQH0.INC.SASLST WAIT=10
//OLOG     DD DISP=SHR,DSN=BQH0.INC.SASLOG WAIT=10
//WORK     DD SPACE=(CYL,(100,100),,,ROUND)
//SYSIN    DD *

 /**********************************************************************
  * PROGRAM NAME: UKM04O (was UKM04OX and UKM04OW)
  *
  *  DESCRIPTION: Produces the mortality web version of the unknown 
  *               reports.  Looks at data that was updated by 
  *               natncweb.
  *
  *     CALLS TO: nothing
  *    CALLED BY: JobTrac
  *
  *  INPUT MVARS: BEGYR, EVT
  *
  *   PROGRAMMER: BQH0 (based on original by EKM2)
  * DATE WRITTEN: 2005-06-20
  *
  *   UPDATE LOG:                                              
  *********************************************************************/
%let START=%sysfunc(time());

options center mprint mlogic sgen fullstimer;

%let BEGYR=2002;
%let MIDYR=%eval(&BEGYR+1);
%let ENDYR=%eval(&BEGYR+2);
%let EVT=MOR;

libname L&BEGYR "DWJ2.&EVT.2002.MVDS.LIBRARY.NEW" DISP=SHR WAIT=30;
libname L&MIDYR "/u/dwj2/mvds/&EVT/2003";
libname L&ENDYR "/u/dwj2/mvds/&EVT/2004";
libname R&MIDYR "/u/dwj2/register/&EVT/&MIDYR";
libname R&ENDYR "/u/dwj2/register/&EVT/&ENDYR";

 /* Gather 2 char state abbreviations to be processed */
%global STLIST REVISERS&MIDYR REVISERS&ENDYR;
 /* All states */
proc sql NOPRINT;
  select distinct stabbrev into :STLIST separated by ' '
  from R&ENDYR..register
  ;
quit;
 /* Revisers only */
proc sql NOPRINT;
  select distinct stabbrev into :REVISERS&MIDYR separated by ' '
  from R&MIDYR..register
  where revising_status like '%N';
  ;
quit;
 /* Revisers only */
proc sql NOPRINT;
  select distinct stabbrev into :REVISERS&ENDYR separated by ' '
  from R&ENDYR..register
  where revising_status like '%N';
  ;
quit;
libname R&MIDYR clear;
libname R&ENDYR clear;

 /* debug */
***%let STLIST=AK AS CA;

 /* Builds SAS statements that will build the final dataset.  Accepts a
  * string containing state, year, varname, invalid value, label,
  * allowable percentages.
  */
%macro InsertRec(unparsed);
  %let s=%scan(&unparsed, 1, ':');  /* AK */
  %let y=%scan(&unparsed, 2, ':');  /* 2002 */
  %let v=%scan(&unparsed, 3, ':');  /* birthmo */
  %let u=%scan(&unparsed, 4, ':');  /* 99 */
  %let l=%scan(&unparsed, 5, ':');  /* MONTH OF BIRTH */
  %let mpcnt=%scan(&unparsed, 6, ':');
  %let stad=%scan(&unparsed, 7, ':');
  %let stand=%scan(&unparsed, 8, ':');
  %let stan=%scan(&unparsed, 9, ':');

  %if (&y eq 2002 )
       or
      (&y eq 2003 and not %sysfunc(indexw(&REVISERS2003, %bquote(&s))))
       or
      (&y eq 2004 and not %sysfunc(indexw(&REVISERS2004, %bquote(&s)))) %then
    %do;
      /* Get record counts */
      %let cntall=%sysfunc(attrn(%sysfunc(open(L&y..&s.OLD)),NLOBSF));  
      %let cntunk=
          %sysfunc(attrn(%sysfunc(open(L&y..&s.OLD(where=(&v="&u")))),NLOBSF));  
    %end;
  %else
    %do;
      %let cntall=0;  
      %let cntunk=0;
    %end;

  /* Division by zero protection. */
  %if (&cntunk ne 0) and (&cntall ne 0) %then
    %do;
      /* Calculate bad data percentages. */
      %let pct&s.&y=%sysevalf((&cntunk/&cntall)*100);
    %end;
  %else
    %do;
      %let pct&s.&y=0;
    %end;
  stname="&s";  /* 2 char */
  &v=&u;  /* override, e.g. sex=99 */
  pcnt&BEGYR=.;  /* default fill */
  pcnt&MIDYR=.;  /* default fill */
  pcnt&ENDYR=.;  /* default fill */
  pcnt&y=&&pct&s.&y;  /* override, e.g. pcnt2002=&pctAK2002 */
  morcat="&l";
  mpcnt=&mpcnt;
  stad=&stad;
  stand=&stand;
  stan=&stan;
%mend InsertRec;

%macro RunInsertRec;
  %local y i s;

  %do y=&BEGYR %to &ENDYR;  /* outer year loop begin */
    %let i=1;
    %let s=%scan(&STLIST, &i, ' '); 
    %do %while ( %bquote(&s) ne  );  /* inner state loop begin */
      %let i=%eval(&i+1);
      /* E.g. %InsertRec(AK:2002:birthmo:99:MONTH OF BIRTH...); */
      %InsertRec(&s:&y:birthmo:99:MONTH OF BIRTH:0.02:1.00:1:1:1.00);
      output;
      %InsertRec(&s:&y:birthdy:99:DAY OF BIRTH:0.03:1.00:1:1.00);
      output;
      %InsertRec(&s:&y:birthyr:9999:YEAR OF BIRTH:0.00:1.00:1:1.00);
      output;
      %InsertRec(&s:&y:sex:9:SEX:0.00:1.00:1:1.00);
      output;
      %InsertRec(&s:&y:month:99:MONTH:0.00:1.00:1:1.00);
      output;
      %InsertRec(&s:&y:day:99:DAY OF DEATH:0.00:1.00:1:1.00);
      output;
      %InsertRec(&s:&y:yeard:99:YEAR OF DEATH:0.00:1.00:1:1.00);
      output;
      %InsertRec(&s:&y:age:999:AGE OF DECEDENT:0.01:1.00:1:1.00);
      output;
      %InsertRec(&s:&y:statbth:99:BIRTHPLACE OF DECEDENT:0.41:1.00:1:1.00);
      output;
      %InsertRec(&s:&y:typ_plac:9:TYPE OF PLACE OF DEATH:0.00:1.00:1:1.00);
      output;
      %InsertRec(&s:&y:marital:9:MARITAL STATUS:0.24:1.00:1:1.00);
      output;
      %InsertRec(&s:&y:hispanic:9:HISPANIC ORIGIN OF DECEDENT:0.12:1.00:1:1.00);
      output;
      %InsertRec(&s:&y:race:9:RACE OF DECEDENT:0.02:1.00:1:1.00);
      output;
      %InsertRec(&s:&y:educ:99:EDUCATION OF DECEDENT:3.19:6.38:4.79:4.79);
      output;
      %let s=%scan(&STLIST, &i, ' '); 
    %end;  /* inner loop end */
  %end; /* outer loop end */
%mend RunInsertRec;

data mornc;
  length stname $ 3 morcat $ 30 pcnt&BEGYR 8 pcnt&MIDYR 8 pcnt&ENDYR 8;

  %RunInsertRec
run;

proc format;
  PICTURE dash (ROUND) 100 = '-----' (NOEDIT)
                     OTHER = '001.11'
                     ;
run;

data mornc;
  set mornc;
  if stname eq 'AS' then
    stname = 'AS~';
  if stname eq 'IL' then
    stname = 'IL~';

run;

options orientation=landscape;
ODS LISTING close;
***ODS pdf file  ='I:\CABINETS\TSB\EXCEL\DAEBPG\REPORTS\MorWeb.pdf' NOTOC; 
ODS PDF file  ='/u/bqh0/public_html/bob/junk.pdf' NOTOC; 
***ODS PDF file  ='/u/bqh0/public_html/bob/MorWeb.pdf' NOTOC; 

%macro Loop;
  proc report LS=66 PS=200 DATA=mornc NOWD STYLE(HEADER)={FONT_SIZE=2} 
              STYLE(COLUMN)={FONT_SIZE=.1}; 
    title H=1 "MORTALITY NOT CLASSIFIABLE AND UNKNOWN DATA FOR &BEGYR TO "
              "&ENDYR";

    column morcat mpcnt stad stand stan stname, (pcnt&BEGYR-pcnt&ENDYR); 
    define stname / ACROSS ' '; 
    define morcat / ORDER=FREQ ID GROUP 'ITEM'; 
    define mpcnt  / ORDER=FREQ MIN ID '1998/MED(%)' FORMAT=6.2; 
    define stad   / ORDER=FREQ MIN ID "&BEGYR*/STAND" ANALYSIS FORMAT=5.2; 
    define stand  / ORDER=FREQ MIN ID "&MIDYR**/STAND" ANALYSIS FORMAT=5.2;
    define stan   / ORDER=FREQ MIN ID "&ENDYR***/STAND" ANALYSIS FORMAT=5.2; 
    define pcnt&BEGYR / ANALYSIS SUM FORMAT=dash. "&BEGYR";
    define pcnt&MIDYR / ANALYSIS SUM FORMAT=dash. "&MIDYR";
    define pcnt&ENDYR / ANALYSIS SUM FORMAT=dash. "&ENDYR";

    footnote1 H=1 "-----ITEM NOT REPORTED";
    footnote2 H=1 "~NO DATA REPORTED FOR 2004";
    footnote3 H=1 "*STANDARD IS 2X THE MEDIAN FOR 1998 AND ABOVE 1%. "
                  "PINK/LIGHT GRAY SHADED AREAS EXCEED THE STANDARD";
    footnote4 H=1 "**STANDARD IS 1.5X THE MEDIAN FOR 1998 AND ABOVE 1%. "
                  "PINK/LIGHT GRAY SHADED AREAS EXCEED THE STANDARD";
    footnote5 H=1 "***STANDARD IS 1.5X THE MEDIAN FOR 1998 AND ABOVE 1%. "
                  "PINK/LIGHT GRAY SHADED AREAS EXCEED THE STANDARD";
    footnote6 H=1 "DARK GRAY SHADED AREAS HAVE IMPLEMENTED FIPS AND/OR "
                  "MULTI-RACE CATEGORIES";
    footnote7 H=1 "BLACK SHADED AREAS HAVE IMPLEMENTED THE REVISED "
                  "STANDARD CERTIFICATE";
    footnote8 H=1 "THEREFORE,THE TOLERANCE LEVELS BASED ON THE ITEMS ON "
                  "THE 1989 CERTIFICATE DO NOT APPLY TO THESE STATES";

    compute pcnt&BEGYR;
       %do i=6 %to 174 %by 3;
      /* debug */
      /***       %do i=6 %to 14 %by 3; ***/
        /*                   avoid the dashed cells */
        if (_C3_ < _C&i._) and (_C&i._ ne 100) then
          call define("_C&i._","STYLE","style={BACKGROUND=pink}");
      %end;
    endcomp;

    compute pcnt&MIDYR;
       %do i=7 %to 175 %by 3; 
      /* debug */
      /***       %do i=7 %to 15 %by 3;  ***/
        if (_C4_ < _C&i._) and (_C&i._ ne 100) then
          call define("_C&i._","STYLE","style={BACKGROUND=pink}");
      %end;

      /* The following compute statements have to be changed each time a
       * data yr is added 
       */

      if _C1_ eq 'BIRTHPLACE OF DECEDENT' then
        call define("_C70_","STYLE","style={BACKGROUND=gray}"); *MA;

      if _C1_ eq 'BIRTHPLACE OF DECEDENT' then
        call define("_C148_","STYLE","style={BACKGROUND=gray}"); *TX;

      if _C1_ eq 'RACE OF DECEDENT' then
        call define("_C46_","STYLE","style={BACKGROUND=gray}"); *HI;

      if _C1_ eq 'RACE OF DECEDENT' then
        call define("_C76_","STYLE","style={BACKGROUND=gray}"); *ME;

      if _C1_ eq 'RACE OF DECEDENT' then
        call define("_C166_","STYLE","style={BACKGROUND=gray}"); *WI;

      /* Make the &MIDYR column black for the revisers  */
      call define("_C22_","STYLE","style={BACKGROUND=black}");  
      call define("_C52_","STYLE","style={BACKGROUND=black}");  
      call define("_C94_","STYLE","style={BACKGROUND=black}");  
      call define("_C175_","STYLE","style={BACKGROUND=black}"); 
      call define("_C118_","STYLE","style={BACKGROUND=black}"); 
    endcomp;

    compute pcnt&ENDYR;
      %do i=8 %to 176 %by 3;
      /* debug */
       /***        %do i=8 %to 16 %by 3;  ***/
        if (_C5_ < _C&i._) and (_C&i._ ne 100) then
          call define("_C&i._","STYLE","style={BACKGROUND=pink}");
      %end;
      if _C1_ eq 'BIRTHPLACE OF DECEDENT' then
        call define("_C71_","STYLE","style={BACKGROUND=gray}"); *MA;

      if _C1_ eq 'BIRTHPLACE OF DECEDENT' then
        call define("_C86_","STYLE","style={BACKGROUND=gray}"); *MO;

      if _C1_ eq 'BIRTHPLACE OF DECEDENT' then
        call define("_C149_","STYLE","style={BACKGROUND=gray}"); *TX;

      if _C1_ eq 'RACE OF DECEDENT' then
        call define("_C47_","STYLE","style={BACKGROUND=gray}"); *HI;

      if _C1_ eq 'RACE OF DECEDENT' then
        call define("_C77_","STYLE","style={BACKGROUND=gray}"); *ME;

      if _C1_ eq 'RACE OF DECEDENT' then
        call define("_C83_","STYLE","style={BACKGROUND=gray}"); *MN;

      if _C1_ eq 'RACE OF DECEDENT' then
        call define("_C167_","STYLE","style={BACKGROUND=gray}"); *WI;

      if _C1_ eq 'HISPANIC ORIGIN OF DECEDENT' then
        call define("_C83_","STYLE","style={BACKGROUND=gray}"); *MN;

      call define("_C23_","STYLE","style={BACKGROUND=black}"); *CA;;
      call define("_C53_","STYLE","style={BACKGROUND=black}"); *ID;
      call define("_C80_","STYLE","style={BACKGROUND=black}"); *MI;
      call define("_C95_","STYLE","style={BACKGROUND=black}"); *MT;
      call define("_C107_","STYLE","style={BACKGROUND=black}"); *NH;
      call define("_C110_","STYLE","style={BACKGROUND=black}"); *NJ;
      call define("_C119_","STYLE","style={BACKGROUND=black}"); *NY;
      call define("_C125_","STYLE","style={BACKGROUND=black}"); *OK;
      call define("_C143_","STYLE","style={BACKGROUND=black}"); *SD;
      call define("_C164_","STYLE","style={BACKGROUND=black}"); *WA;
      call define("_C173_","STYLE","style={BACKGROUND=black}"); *WY;
      call define("_C176_","STYLE","style={BACKGROUND=black}"); *YC;
      /* debug */
      /*** call define("_C11_","STYLE","style={BACKGROUND=black}"); ***/
    endcomp;
  run;  /* end proc report */
%mend;
%Loop

ODS PDF close; 
ODS LISTING;

%put !!!(&SYSCC &SYSTIME) Mins: %sysevalf((%sysfunc(time())-&START)/60);
