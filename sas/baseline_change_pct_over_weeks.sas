
data bp;
  input subject $ week test $ value;
  datalines;
101 0 DBP 160
101 0 SBP 90
101 1 DBP 140
101 1 SBP 87
101 2 DBP 130
101 2 SBP 85
101 3 DBP 120
101 3 SBP 80
202 0 DBP 141
202 0 SBP 75
202 1 DBP 161
202 1 SBP 80
202 2 DBP 171
202 2 SBP 85
202 3 DBP 181
202 3 SBP 90
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

proc sort; by subject test week; run;

data bp;
  set bp;
  by subject test week;
  retain baseline;

  if first.test then baseline eq .;

  if week eq 0 then do;
    baseline = value;
  end;
  else if week > 0 then do;
    change = value - baseline;
    pct_chg = ((value - baseline) /baseline )*100;
  end;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
