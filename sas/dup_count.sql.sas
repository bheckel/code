 /* You must include all of the columns in your table in the GROUP BY clause to
  * find exact duplicates.
  */
title 'duplicate rows exist';
proc sql;
  select *, count(*)
  from sashelp.shoes
  group by region, stores
  having count(*)>1
  ;
quit;

title 'duplicate stores exist';
proc sql;
  select region, count(stores)
  from sashelp.shoes
  group by region, stores
  having count(stores)>1
  ;
quit;


endsas;
proc freq data=sashelp.shoes;
  table stores / out=foo(where=(count>7));
  by region;
run;
proc print data=_LAST_(obs=max); run;
