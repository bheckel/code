 /* Exactly 1M */
data a;
  do _n_=1 to 1e+6;
     date = ceil(rannor(1)*1e+4);
     time = ceil(ranuni(1)*86400);
     output;
  end;
run; 
proc print data=_LAST_(obs=10) width=minimum; run;
