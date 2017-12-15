 /* Time a job */
%local _start; %let _start=%sysfunc(time()); %put NOTE: DLI %sysfunc(getoption(SYSIN)) started: &SYSDATE %sysfunc(putn(&_start,DATETIME.));

  proc print data=sashelp.shoes(obs=max) width=minimum; run;

%put NOTE: DLI SYSCC: &SYSCC (%sysfunc(getoption(SYSIN)) ended: %sysfunc(putn(%sysfunc(datetime()),DATETIME.)) / minutes elapsed: %sysevalf((%sysfunc(time())-&_start)/60));
