 /* Cannot use CARDS; in a macro.  Use this instead. */
%macro m;
  %let x=foo,bar;
  %let x=&x,more,here;
  %put _all_;
  data x;
    f=13;output;
    f=14;output;
    f=15;output;
  run;
  proc print data=_LAST_(obs=max); run;
%mend;
%m
