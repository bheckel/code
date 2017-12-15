data t;
  infile 't2.txt' dlm='|' lrecl=8300;
  input (a1-a916) ($);
run;
proc print data=_LAST_(obs=max) width=minimum; ;run;
