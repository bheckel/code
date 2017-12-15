proc sql NOPRINT;
  select distinct name into :thevars separated by ' '
  from dictionary.columns
  where memname eq 'GAOLD' and name like 'A%'
  ;
quit;
proc print; var &thevars; run;
