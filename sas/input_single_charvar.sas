
filename F 'junk';
data t;
  infile F;
  input nm $80.;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
