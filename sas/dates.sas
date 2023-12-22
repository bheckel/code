options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: dates.sas
  *
  *  Summary: Demo of miscellaneous date features.
  *
  *           See file:///C:/Bookshelf_SAS/lgref/z0245860.htm for all date
  *           functions
  *
  * Adapted: Wed Apr 16 15:49:00 2003 (Bob Heckel -- SUGI 28 Date Handling In
  *                                    the SAS System)
  * Modified: Tue 02 Jul 2013 16:11:50 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data t;
  input pt admit :MMDDYY6. discharge :MMDDYY8.;
  datalines;
1 081296 08201996
1 110796 11081996
1 110796 11      
2 070197 07041997
  ;
run;
data t2;
  set t;
  format discharge DATE9.;
run;
proc print data=_LAST_(obs=max) width=minimum; run;



 /* Simple date time stamp start to end */
%put &SYSDATE &SYSTIME;
data _null_;
   put "NOTE: Sleeping 90 seconds...";
   t = time();
   do while (time()-t < 90); 
     /* sleep */
   end;
   put '...done';
run;
%put %sysfunc(putn(%sysfunc(datetime()),DATETIME.));



data _NULL_;
  x=date();
  put x=;

  y=today();  /* same as date() */
  put y=;
  z=put(y, DATE9.);
  put z=;
  zz=put(datetime(), DATETIME16.);
  put zz=;

  dateconstant='07JUL2000'D;
  sasformatted=put(dateconstant, YYMMDD10.);
  put sasformatted=;
run;



data work.dates;
  input achar $  anum  thedate  nonconforming $CHAR7.;
  datalines;
abc 123 19980521 1960JAN
def 345 20000707 2003FEB
ghi 678 19600102 1960FEB
  ;
run;
proc print; run;
proc contents; run;


 /* If the numeric data conforms to the date informat YYMMDD8. */
data work.dates;
  set work.dates;
  /* To create a SAS date value from a numeric variable, first convert the
   * numeric to CHARACTER, using the standard 8 byte format (strange but true).
   */
  tmpchar = put(thedate, 8.);
  /* Then convert the char to a SAS date value. */
  realdate = input(tmpchar, YYMMDD8.);
  /* Could have said: */
  realdate2 = input(put(thedate, 8.), YYMMDD8.);
run;
proc print; run;
***proc contents; run;


 /* If the numeric data does NOT conform to a SAS date informat. */
data work.dates;
  set work.dates (keep= nonconforming);
  flipmon = substr(nonconforming, 5, 3);
  flipyr = substr(nonconforming, 1, 4);
  flipped = flipmon||flipyr;
  realdate3 = input(compress(flipped), MONYY7.);
run;
proc print; run;
***proc contents; run;


data _NULL_;
  set work.dates;
  /* Change filehandle from Log to List. */
  file PRINT;
  put 'unformatted: ' realdate3=;
  put 'formatted YYMMDD8.: ' realdate3= YYMMDD8.;
  put 'formatted YYMMDDN8.: ' realdate3= YYMMDDN8.;
  put;
run;



 /* API_Date_of_Manufacture is 17577 */
data tmp;
  input API_Date_of_Manufacture :DDMMYY8.  anum;
  datalines;
15.02.2008 136.2
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


data tmp;
  input API_Date_of_Manufacture :MONYY6.  anum;
  datalines;
jan-60 129.9
jul-90 130.4
sep-90 132.7
jul-91 136.2
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;



%put %sysfunc(putn('30OCT1965'd, 8.));

%put %sysfunc(putn(17325, DATE9.));

%put %sysfunc(putn(1440588139.7, DATETIME7.));



data _null_;
  format x DATETIME12.;
  x=1440588139.7;
  put x;
run;

data t;
  x=1440588139.7;
run;
proc print data=_LAST_(obs=max); format x DATETIME12.; run;



 /* Convert SAS style date to integer days since the epoch */
%let lodt=02JAN1960;
%let hidt=31JUL2005;

data _null_;
  call symput("LODTINT",put(input("&lodt",DATE9.),5.));
  call symput("HIDTINT",put(input("&hidt",DATE9.),5.));
run;

%put _USER_;
 /* Convert SAS style date to integer days since the epoch */
%let lodt=02JAN1960;
%let hidt=31JUL2005;

data _null_;
  call symput("LODTINT",put(input("&lodt",DATE9.),5.));
  call symput("HIDTINT",put(input("&hidt",DATE9.),5.));
run;



 /* Date format check */
data _null_;
  d1 = input('01-JAN-60', DATE9.);
  d2 = input('01/01/2009', MMDDYY10.);
  put _all_;
run;


  /*format actual_updated datetime27.3; */       /* -- this will create a timestamp type in ORACLE -- */
