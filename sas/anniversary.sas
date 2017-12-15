
data happy20thanniversary;
  set employees;

  years = intck('year', hireddt, today());

  if years eq 20 and month(hireddt) eq month(today()) then
    put 'happy 20th year in servitude! ' wageslave;
run;

