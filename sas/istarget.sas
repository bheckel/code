
options ps=max;

libname funcdata '/Drugs/FunctionalData';
proc sql;
  select clid, long_client_name, projected_build_date
  from funcdata.tmm_targeted_list_refresh
  order by 3
  ;
quit;

