
data scores;
   input (name score1-score5) ($10. 5*4.);
   datalines;
Whittaker 121 114 137 156 142
Smythe    111 97  122 143 127
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
