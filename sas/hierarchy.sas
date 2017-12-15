
data nonlost;
  input acct control;
  cards;
6471906 9999661
6471907 9999661
6471908 9999661
6471909 9999661
  ;
run;

data lost;
  input acct control;
  cards;
6471908 9999999
  ;
run;

data rollup;
  retain _control;
  set nonlost lost;
  by acct;
/***put (_all_)(=);***/
  if first.acct then _control=control;

  currentcontrol=_control;
  drop _control;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
endsas;
Obs      acct     control    currentcontrol

 1     6471906    9999661        9999661   
 2     6471907    9999661        9999661   
 3     6471908    9999661        9999661   
 4     6471908    9999999        9999661   
 5     6471909    9999661        9999661   
