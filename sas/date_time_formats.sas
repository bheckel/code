options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: date_time_formats.sas
  *
  *  Summary: Demo of user created SAS "picture" formats
  *
  *  Created: Wed 23 Jun 2009 15:39:29 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* As a format */
proc format ;
  PICTURE myfmt
    low-high='%0d-%0m-%0y %0H:%0M:%0S' (datatype=datetime)
    ;
run;
data one;
  input sasdate ;
  format sasdate myfmt.;
  put sasdate=;
  cards;
  999999999
  90
  3636363636
  252363
  ;
run;
proc print data=_LAST_(obs=max); run;


 /* As a function */
data date;
  infile datalines ;
  input mon $ 1-3 day $ 5-6 year $ 8-11 @13 time TIME8.;
  date=input(day||mon||year,DATE9.);
  datalines;
SEP 09 1991 01:46:39
JUL 17 1996 08:54:36
MAR 25 1975 13:00:36
JAN 03 1960 22:06:03
  ;
run;
proc print data=_LAST_(obs=max); run;
