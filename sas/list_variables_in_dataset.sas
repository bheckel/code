
proc sql;
  select name 
  from dictionary.columns
  where libname eq 'L' and memname eq 'FOODS'
  ;
quit;
