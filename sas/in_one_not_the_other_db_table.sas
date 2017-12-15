
proc sql;
  /* In archive, not in regular table */
  select a.* 
  from medispan.archive_indgind a LEFT OUTER JOIN medispan.indgind b  ON (a.genericproductidentifier=b.genericproductidentifier)
  where b.genericproductidentifier IS NULL  
  ;
quit;
