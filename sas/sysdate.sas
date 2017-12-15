
data _NULL_;
  /* Force macro text into a date constant */
  full=put("&SYSDATE"D, WEEKDATE.);
  medium=put("&SYSDATE"D, WEEKDATE15.);
  dayonly=put("&SYSDATE"D, WEEKDATE3.);
  noDOW=put("&SYSDATE"D, WORDDATE.);
  moonly=put("&SYSDATE"D, WORDDATE3.);
  put (_all_)(=);
run;

 /* DT 2015-08-28
  * DT2 20150828
  */
%macro m;
  %let dt=%sysfunc(putn("&SYSDATE"d, YYMMDD10.));
  %let dt2=%sysfunc(compress(&dt,'-'));
  %put _all_;
%mend;
%m;
