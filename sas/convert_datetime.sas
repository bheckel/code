
data _null_;
/***  y=put(1599121256.858, DATETIME18.);***/
  y=put(1635772919, DATETIME18.);
  put y=;

  z=input('21FEB09:00:15:05', DATETIME19.);
  put z=;

  z2=input('01NOV11 00:15:05', DATETIME19.);
  put z2=;

  /* Only reads datetime values in the form ddmmmyy hh:mm:ss.ss or ddmmmyyyy hh:mm:ss.ss */
  z3=input('2011-03-25 00:15:05', DATETIME19.);
  put z3=; /* so it fails */

  /* Undocumented for v8 SAS (picture format won't work) */
  z4=input('2011-03-25 00:15:05', YMDDTTM19.);
  put z4=;

  z5=datepart('2011-03-25 00:15:05'dt);
  put z5=;
  z6=put(z5, DATE9.);
  put z6=;

  /* SAS datetime to date */
  z7=put(datepart('2011-03-25 00:15:05'dt), DATE9.);
  put z7=;
run;



endsas;
/***libname MYXML XML "U:\projects\dpv2\output_compiled_data\DP_index.xml" access=READONLY;***/
/***      data _table;***/
/***        set MYXML.timestamp;***/
/***      run;***/
/***proc print data=MYXML.timestamp(obs=max) width=minimum; run;      ***/

%let enddt=05-OCT-10 11:06:13;
data t;
  a=input("05-OCT-10 11:06:13", DATETIME18.);
  b=put(1601377424, DATETIME18.);
run;
proc print data=_LAST_(obs=max) width=minimum; run;

%macro m;
  %put converted to human %sysfunc(putn(1601377424, DATETIME18.));
%mend;
%m;


endsas;
proc sql;
  create table t as
  select input("&enddt", DATETIME18.) as maxts
  from sashelp.shoes
  ;
quit;
proc print data=_LAST_(obs=max) width=minimum; run;
