libname L 'd:/_TD3956';
data x ;
  set L.patient0 end=e;
  s+total_paid;
  if e then put s=;
run;
