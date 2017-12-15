   /* Determine largest number of observations for any MYNAME */
  proc freq data=t order=FREQ;
    tables myname / NOprint out=tmp;
  run;
  proc print data=_LAST_(obs=max) width=minimum; run;
  data _null_;
    set tmp;
    call symput('N', compress(put(COUNT,8.)));
    stop;
  run;
