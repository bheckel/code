options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: interleave_unsorted.sql.sas
  *
  *  Summary: Compare SQL and SAS interleaving of data that is unsorted.  SAS
  *           would have been better if data was sorted.
  *
  *  Adapted: Sat 14 Jan 2006 21:35:59 (Bob Heckel -- Combining and Modifying
  *                                     Book)
  * Modified: Thu 29 Nov 2007 08:46:48 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter fullstimer;

data one;
  format date date7. depart time5.;
  input date:date7. flight depart:time5.;
  cards;
01jan93 114 7:10
01jan93 202 10:43
01jan93 439 12:16
02jan93 114 7:10
02jan93 202 10:45
  ;
run;

data two;
  format date date7. depart time5.;
  input date:date7. flight depart:time5.;
  cards;
01jan93 176 8:21
02jan93 176 9:10
03jan93 176 8:21
04jan93 176 9:31
05jan93 176 8:13
  ;
run;


proc sql;
  select *
  from one
  OUTER UNION CORR  /* need CORR b/c varnames are same on one & two */
  select *
  from two
  order by date, depart
  ;
quit;

 /* compare */

proc sort data=one; by date depart; run;
proc sort data=two; by date depart; run;
data sasway;
  set one two;
  by date depart;
run;
proc print data=_LAST_(obs=max); run;
