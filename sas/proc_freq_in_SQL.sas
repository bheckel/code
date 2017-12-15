
proc freq data=sashelp.shoes;
  tables region / nocum;
run;

proc sql;
  select *, (100*rcnt)/sum(rcnt) as pct format=8.2
  from (select region, count(region) as rcnt
        from sashelp.shoes
        group by region)
  ;
quit;
