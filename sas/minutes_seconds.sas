data _null_;
  t = time();
  hrprint = hour(t);
  put hrprint Z2. ':' t MMSS5.;
run;
