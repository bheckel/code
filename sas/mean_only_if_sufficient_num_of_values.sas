
data t;
  input x1-x5;

  sum1 = sum(of x1-x5);

  /* Compute Mean1 only if there are 4 or more non-missing values */
  if n(of x1-x5) ge 4 then
    mean1 = mean(of x1-x5);

  /* Compute Mean2 only if there are 3 or fewer missing values */
  if nmiss(of x1-x5) le 3 then
    mean2 = mean(of x1-x5);

  datalines;
1 2 . 3 4
. . . 8 9 
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
