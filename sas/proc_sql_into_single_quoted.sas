 /* CSV-style */
proc sql;
  select distinct "'"||left(trim(value))||"'" into: REPLACEME separated by ','
  from OUTW.b21_0002e_zebtestblst
  ;
quit;
