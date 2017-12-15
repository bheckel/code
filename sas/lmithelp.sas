options NOsource;/*{{{*/
 /*---------------------------------------------------------------------------
  *     Name: lmithelp.sas
  *
  *  Summary: Compare raw mergefiles to SAS MVDS.
  *
  *           See iterate_textfiles.sas to verify one or more states if you
  *           know the BF19 filename, loopallfiles.sas to rely on Register for
  *           the BF19 filename, loopallmvds.singleyr.sas to use MVDS.
  *
  *           ___CHECK SINGLE STATE SINGLE VAR (OPTIONAL FORMATTED)___
  *
  *  Created: Thu 16 Dec 2004 15:46:01 (Bob Heckel)
  * Modified: Mon 09 May 2005 13:43:40 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter mlogic mprint sgen NOs99nomig;

%include 'BQH0.PGM.LIB(TABDELIM)';
%global EVT REMOVEALIAS REMOVEVOIDS;/*}}}*/

 /* Also see ckformat.step1.sas / ckformat.step2.sas to apply a Structure
  * format.
  */

%macro fmt;  /* 	{{{1 */
  proc format;
    value $f_bob '0001'-'1159' = 'am'
                 '1200'        = 'noon'
                 '1201'-'2359' = 'pm'
                 '9999'        = 'notclass'
                 ;
  run;
  proc format;
    value $f_time
       '0000' = '0000'
       '0001'-'0059' =  '0001-1159'                                               
       '0100'-'0159' =  '0001-1159'                                               
       '0200'-'0259' =  '0001-1159'                                               
       '0300'-'0359' =  '0001-1159'                                               
       '0400'-'0459' =  '0001-1159'                                               
       '0500'-'0559' =  '0001-1159'                                               
       '0600'-'0659' =  '0001-1159'                                               
       '0700'-'0759' =  '0001-1159'                                               
       '0800'-'0859' =  '0001-1159'                                               
       '0900'-'0959' =  '0001-1159'                                               
       '1000'-'1059' =  '0001-1159'                                               
       '1100'-'1159' =  '0001-1159'                                               
       '1200'      = '1200'                                                       
       '1201'-'1259' ='1201-2359'                                               
       '1300'-'1359' ='1201-2359'                                               
       '1400'-'1459' ='1201-2359'                                               
       '1500'-'1559' ='1201-2359'                                               
       '1600'-'1659' ='1201-2359'                                               
       '1700'-'1759' ='1201-2359'                                               
       '1800'-'1859' ='1201-2359'                                               
       '1900'-'1959' ='1201-2359'                                               
       '2000'-'2059' ='1201-2359'                                               
       '2100'-'2159' ='1201-2359'                                               
       '2200'-'2259' ='1201-2359'                                               
       '2300'-'2359' ='1201-2359'                                               
       '9999' = '9999'                                           
       OTHER='inval'
       ;
  run;

  /* Reported age */
  proc format;
    value $f_age (NOTSORTED)
               '120'-'199' = 'YR 120+(COND. EDIT)'
               '110'-'119' = 'YR 110-119'
               '100'-'109' = 'YR 100-109'
               '095'-'099' = 'YR 95-99'
               '090'-'094' = 'YR 90-94'
               '085'-'089' = 'YR 85-89'
               '080'-'084' = 'YR 80-84'
               '075'-'079' = 'YR 75-79'
               '070'-'074' = 'YR 70-74'
               '065'-'069' = 'YR 65-69'
               '060'-'064' = 'YR 60-64'
               '055'-'059' = 'YR 55-59'
               '050'-'054' = 'YR 50-54'
               '045'-'049' = 'YR 45-49'
               '040'-'044' = 'YR 40-44'
               '035'-'039' = 'YR 35-39'
               '030'-'034' = 'YR 30-34'
               '025'-'029' = 'YR 25-29'
               '020'-'024' = 'YR 20-24'
               '015'-'019' = 'YR 15-19'
               '010'-'014' = 'YR 10-14'
               '005'-'009' = 'YR 5-9'
               '001'-'004' = 'YR 1-4'
                      '000' = '4YR 00'
                      '200' = '5MO 00'
               '200'-'211' = 'MO 00-11'
               '212'-'223' = 'MO 12-23'
               '224'-'298' = 'MO 24+(COND. EDIT)'
                     '299' = 'MO UNKNOWN'
                     '300' = 'WK 00'
               '301'-'304' = 'WK 01-04'
               '305'-'352' = 'WK 05-52'
               '353'-'398' = 'WK 53+(COND. EDIT)'
                     '399' = 'WK UNKNOWN'
                     '400' = 'DY 00'
               '401'-'427' = 'DY 01-27'
               '428'-'460' = 'DY 28-60'
               '461'-'498' = 'DY 61+(COND. EDIT)'
                     '499' = 'DY UNKNOWN'
                     '500' = 'HR 00'
               '501'-'523' = 'HR 01-23'
               '524'-'572' = 'HR 24-72'
               '573'-'598' = 'HR 73+(COND. EDIT)'
                     '599' = 'HR UNKNOWN'
                     '600' = 'MN 00'
               '600'-'659' = 'MN 00-59'
               '660'-'695' = 'MN 60-95'
               '695'-'698' = 'MN 95+(COND. EDIT)'
                     '699' = 'MN UNKNOWN'
                     '999' = 'NOT CLASS'
                     OTHER = 'OTHER'
                     'AAA' = 'ABS EDT:REP/CMP DIF>5'
                     'BBB' = 'ABS EDT:INF DOB/AGE'
                       ;
  run;
%mend fmt;  /* }}} */

 /**************** Begin Edit *********************/

 /* 1 for for raw textfile, 0 for dataset */
%let RAW=1;       /* 0 == mvds  1 == raw */
%let YR=2004;
%let WANTFREQ=1;  /* 0 == print, 1 == freq */
%let WANTTABDELIM=0;

  /* Toggle -- items are ignored for the opposite condition */

  /*--------- Use dataset if RAW=0 ----------*/ /*{{{*/
  /* void removed for nat/fet, void & alias for mor */
  %let EVT=%upcase(fet);  /* NAT FET MOR MED case sensitive! */
  %let DS=akold;
  %let MVDSVAR=mothyr;  /* for proc freq.  Case insensitive */
  ***%let MVDSVAR=revtype*fsex;
  %let SPLITWANTNEW=0; /* 0 == oldstyle or n/a, 1 == use REVTYPE var for NEW */
  /*-----------------------------------------*/ /*}}}*/

  /*--------- Use flatfile if RAW=1 ---------*//*{{{*/
  %let DSN=BF19.WAX0402.FETMERZ;
  %let BYTPOS=428;  /* use ~/bin/bytepos for NAT or MOR */
  %let WIDTH=4;
  %let REMOVEALIAS=0;  /* mor raw only, mor mvds has already removed them */
  %let REMOVEVOID=0;   /* raw only, mvds has already removed them */ 
  %let WANTCERT=0;  /* nat only TODO do others */
  /*-----------------------------------------*//*}}}*/

 /**************** End Edit *********************/


%macro Raw;  /* 	{{{1 */
  %if &WANTCERT eq 1 %then
    %do;
      %let C=%str(@7 cert $CHAR6.);
    %end;
  %else
    %do;
      %let C=;
    %end;
  data work.tmp;
    infile "&DSN";
    %if %substr(%scan(&DSN, 3, '.'), 1, 3) eq MOR and &REMOVEALIAS eq 1 %then
      %do;
        input @&BYTPOS block $CHAR&WIDTH..  @47 alias $CHAR1.;
        if alias eq '1' then delete;
        drop alias;
      %end;
    %else
      %do;
        if substr(reverse("&DSN"),1,1) eq 'Z' and &REMOVEVOID eq 1 then
          do;
            input @&BYTPOS block $CHAR&WIDTH..  @13 void $CHAR1.  &C;
            if void eq '1' then delete;
            drop void;
          end;
        else
          input @&BYTPOS block $CHAR&WIDTH..  &C;
    %end;
  run;
%mend Raw; /* }}} */

%macro Dataset;  /* 	{{{1 */
  %local CNT;
  %let CNT=0;

  %include 'dwj2.util.library(getly)';
  %if %eval(&YR+0) le %eval(&LY+2000) %then
    %do;
 /***       libname L "DWJ2.&EVT.&YR..MVDS.LIBRARY.NEW" DISP=SHR WAIT=5; ***/
      libname L "/u/dwj2/mvds/&EVT/&YR";
    %end;
  %else
    %do;
      libname L "/u/dwj2/mvds/&EVT/&YR";
    %end;

  data work.tmp;
    set L.&DS (obs=max) end=e;
    if void ne '1';
    %if &SPLITWANTNEW eq 1 %then
      %do;
        if revtype eq 'NEW';
      %end;
    %if &EVT eq MOR %then
      %do;
 /***         if alias ne '1';  ***/
      %end;
    if e then
      call symput ('CNT', _N_);
  run;
  data _null_;                                             
    memlabel = attrc(open("L.&DS"),"label");         
    file PRINT;
    put memlabel=;                          
    put "%left(&CNT) non-void records (%upcase(&DS))";
  run;
%mend Dataset; /* }}} */

%macro Freq;  /* 	{{{1 */
  %macro ApplyFormat;
    /* Manual adjustments required in freq below if using this hack.  Only
     * working for MVDS not raw right now.
     */
    options FMTSEARCH=(FMTLIB); 
    libname FMTLIB 'DWJ2.NAT2003R.FMTLIB' DISP=SHR; 
    data tmp;
      set tmp;
      fmtd=put(&MVDSVAR, $V007A.);
    run;
  %mend;
  ***%ApplyFormat;
  proc freq data=tmp;
    %if &RAW eq 0 %then
      %do;
        table &MVDSVAR / nocum missing;
        ***table fmtd / nocum missing;
      %end;
    %else
      %do;
        table block / nocum missing;
        ***table fmtd / nocum nopct missing;
        ***table block*mo / nocum nopct;
      %end;
  run;
%mend Freq; /* }}} */

%macro RunMe;  /* 	{{{1 */
  %if &RAW eq 1 %then
    %do;
      %Raw;
    %end;
  %else
    %do;
      %Dataset;
    %end;

  %if &WANTFREQ eq 1 %then
    %do;
      %Freq;
    %end;
  %else
    %do;
      proc print data=_LAST_(where=(block ne '')) noobs; run;
    %end;

  %if &WANTTABDELIM eq 1 %then
    %do;
      %Tabdelim(work.mergefile, 'BQH0.TMPTRAN1');
    %end;
%mend RunMe;
%RunMe


  /* vim: set foldmethod=marker: */ 
