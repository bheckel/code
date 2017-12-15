
 /* Dynamically determine varnames */

proc contents data=SASHELP.shoes out=t(keep= name type) NOprint; run;
proc print data=_LAST_(obs=max) width=minimum; run;

proc sql NOprint;
  select name into :vnms separated by ','
  from t
  ;
quit;
%put !!!&vnms;

proc sql NOprint;
  select name into :numericONLYvnms separated by ' '
  from t
  where type eq 1
  ;
quit;
%put !!!&numericONLYvnms;
