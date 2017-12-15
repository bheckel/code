
%macro calculateyearsback;
  %let thisyr = %sysfunc(year("&SYSDATE"d));
  %let minyr = %eval(&thisyr-3);
  %put _all_;
%mend;
%calculateyearsback;
