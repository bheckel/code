
data t;
  input x @@;
  moving_avg = mean(x, lag(x), lag2(x));
  cards;
50 40 30 20 100
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
