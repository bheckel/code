options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: yesterday.sas
  *
  *  Summary: Compute yesterday's date programmatically.
  *
  *  Created: Tue 17 Aug 2010 12:16:26 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data _null_;
  call symput('YESTERDAY', put("&SYSDATE9"D-1, DATE9.));
run;
%put &YESTERDAY;

data _null_;
  call symput('YESTERDAY2', put(date()-1, DATE9.));
run;
%put &YESTERDAY2;

data _null_;
  call symput('YESTERDAY3', put(datetime()-(24*60*60), DATETIME.));
run;
%put &YESTERDAY3;
