%let _START=%sysfunc(time());

data _null_;
  put "NOTE: Sleeping 10 seconds...";
  t = time();
  do while (time()-t < 10); 
    /* sleep */
  end;
  put '...done';
run;

%put minutes elapsed: %sysevalf((%sysfunc(time())-&_START)/60);

