
%macro m;
  %put DEBUG: Creating new directories ...;
  %let y=%sysfunc(putn(%sysfunc(inputn(&SYSDATE, DATE9.)), YEAR.));
  %let m=%sysfunc(putn(%sysfunc(inputn(&SYSDATE, DATE9.)), YYMMN6.));
  %let d=%sysfunc(putn(%sysfunc(inputn(&SYSDATE, DATE9.)), YYMMDDN8.));
  %let rc1=%sysfunc(dcreate(&y, /sasreports/Reporting/TMM/Weekly));
  %let rc2=%sysfunc(dcreate(&m, /sasreports/Reporting/TMM/Weekly/&y));
  %let rc3=%sysfunc(dcreate(&d, /sasreports/Reporting/TMM/Weekly/&y/&m));
  %put &=rc1 &=rc2 &=rc3;
%mend; %m;
