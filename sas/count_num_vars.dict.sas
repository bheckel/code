/* See vars_startwith.sas */

libname MVDS "/u/dwj2/mvds/MOR/2004";
proc sql;
  select memname, nvar
  from dictionary.tables
  where memname eq 'MTNEW'  /* uppercased dataset name */
  ;
quit;
