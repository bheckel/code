/***options ls=180;proc contents data=SASHELP._all_;***/
 /* Canonical age calculation */

data _null_;
  DOB = '31OCT65'd;
  Age = int((intck('YEAR', today(), DOB)))*-1;
  put Age=;
run;


data _null_;
  DOB = '31JAN11'd;
  EventDate = '15JAN12'd;
  /*                                           day-earlier-in-month-fix    */
  Age = int((intck('MONTH', DOB, EventDate) - (day(DOB)>day(EventDate)))/12) ;
  /* Age when event occurred, "0" here */
  put Age=;
run;



%macro calc_age(dsin=, dsout=, varin=);
  data &dsout;
    set &dsin;
    age = int((intck('YEAR', today(), &varin)))*-1;
  run;
%mend;
