 /* Demo of losing precision in date variables that are sized too small.  TODO
  * why no pattern as to a cutoff date beyond which dates are wrong?  It seems
  * to change.
  */

data t;
  input dt;
  cards;
50000000000
780000000
500000000
50000000
5000000
50000
500
  ;
run;

title '8 bytes';
data u;
  length dt 8;
  set t;
run;
proc print data=_LAST_(obs=max); format dt datetime22.; run;

title '4 bytes';
data v;
  length dt 4;
  set t;
run;
proc print data=_LAST_(obs=max); format dt datetime22.; run;

title '3 bytes';
data v;
  length dt 3;
  set t;
run;
proc print data=_LAST_(obs=max); format dt datetime22.; run;
