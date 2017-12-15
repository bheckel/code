options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sql_sasformat.sas
  *
  *  Summary: Demo of format and informat SAS version and SQL version.
  *
  *  Adapted: Mon 12 May 2008 15:34:54 (Bob Heckel -- SUGI paper 235-29)
  * Modified: Wed 26 May 2010 10:18:10 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data bad_data;
  date = '20040510';
  amt = '$123,456.78';
  time = '08:34';
  postal = '10r 1t0';
run;
proc contents; run;
proc print data=_LAST_(obs=max) width=minimum; run;


data good_sas_data(keep=new:);
  format newdate DATE9.;
  set bad_data;
  /* Must use new names or will stay as CHAR */
  newdate = input(date, YYMMDD8.);
  newamt = input(amt, DOLLAR14.2);
  newtime = input(time, TIME5.);
  newpostal = input(postal, $UPCASE.);
run;
proc contents; run;
proc print data=_LAST_(obs=max) width=minimum; run;


 /* SQL alternative - better b/c don't need temp variables */
proc sql;
  select input(date, YYMMDD8.)       as date format=YYMMDD10.,
         input(amt, COMMA12.2)       as amt format=DOLLARX12.2,
         input(time, TIME5.)         as time format=HOUR4.1,
         put(upcase(postal), $20.-R) as postal
  from bad_data
  ;
quit;


 /* Simple */
proc sql;
  select newdate format=DATE9.
  from good_sas_data
  ;
quit;
