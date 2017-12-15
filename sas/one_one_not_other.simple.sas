
data potential_new_items;
  infile cards;
  input itm :8.;
  cards;
123
456
999
  ;
run;

data existing_items;
  infile cards;
  input itm :8.;
  cards;
123
456
789
 ;
run;

proc sql;
  create table t as
  select a.* 
  from potential_new_items a 
  where itm not in (select distinct itm from existing_items)
  ;
quit;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;
