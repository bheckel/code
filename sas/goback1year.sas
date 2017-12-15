
%let thisyr = %sysfunc(year("&SYSDATE"d));
%let minyr = %eval(&thisyr-2);  /* go back N years */
%put _all_;


/* or */

data t;
  dt = '04feb08'd;
  tdt = "&SYSDATE"d;
  yrago = tdt - 365;
  put _all_;
run;
proc contents;run;
