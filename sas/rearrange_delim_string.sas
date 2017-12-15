
data sample;
  length state $ 19; 
  input density  crimerate  state $  stabbrev $;
  cards;
264.3 3163.2 Pennsylvania       PA
51.2 4615.8  Minnesota          MN
55.2 4271.2  heckek,bob,s,MD    VT
9.1 2678.0   South,Dakota,bob   SD
102.4 3371.7 North, Carolina,xob NC
9.4 2833.0   North,Dakota       ND
120.4 4649.9 North,Carolina     NC
  ;
run;

data reorder;
  set sample;
  length w1-w4 $ 100;

  if countc(state, ',') > 4 then
    do;
      put "ERROR: cannot process more than 4 commas in prescriber string";
      abort abend;
    end;

  w1=scan(strip(state), 1, ',');
  w2=scan(strip(state), 2, ',');
  w3=scan(strip(state), 3, ',');
  w4=scan(strip(state), 4, ',');

  state=strip(w2)||' '||strip(w3)||' '||strip(w1)||' '||strip(w4);
  /* Avoid leading and multiple spaces if any element s1-s4 is missing */
  state=strip(compbl(state));
run;

proc print data=_LAST_(obs=max); var w1-w3 state; run;

