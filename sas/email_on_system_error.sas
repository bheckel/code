
data _null_;
  rc1=system("chmod 777 ~/t.csv");
  if rc1 eq 0 then do; put 'NOTE: chmod successful'; end; else do; put 'ERROR: chmod fail'; to='obb.heckel@ateb.com'; file dummy email filevar=to subject="Error during %sysfunc(getoption(SYSIN))"; end;
run;
