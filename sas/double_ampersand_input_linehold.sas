
 /* NOTE: SAS went to a new line when INPUT statement reached past the end of a line. */
data IceCreamStudy;
  input Grade StudyGroup Spending Weight @@;
  datalines; 
7  34  7 76.0     7  34  7 76.0    7 412  4 76.0    9  27 14 80.6 
7  34  2 76.0     9 230 15 80.6    9  27 15 80.6    7 501  2 76.0
9 230  8 80.6     9 230  7 80.6    7 501  3 76.0    8  59 20 84.0
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
