data t;
  input yr2000 yr2001 yr2002;
  cards;
1 2 3
0 0 9
0 0 0
4 5 6
  ;
run;
data u;
  set t;
  /* If *all* vars are zero */
  if yr2000--yr2002 eq 0 then 
    delete;
run;
proc print data=_LAST_(obs=max); run;
