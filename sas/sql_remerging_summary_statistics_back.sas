options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sql_remerging_summary_statistics_back.sas
  *
  *  Summary: Diagnose and adapt to a common SAS NOTE:
  *
  *  Created: Mon 04 Mar 2013 14:13:41 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

options NOlabel;

 /* NOTE: The query requires remerging summary statistics back with the original data. */
title 'remerging is wrong';
proc sql;
  /* We also want information about subsidiary for regions having the max sales */
  select subsidiary,  /* tricky because this is not in GROUP BY or a summary function */
         region,
         sales,
         max(sales) as maxsales
  from sashelp.shoes
  group by region
  ;
quit;

 /* NOTE: The query requires remerging summary statistics back with the original data. */
title 'remerging is correct';
proc sql;
  /* We also want information about subsidiary for regions having the max sales */
  select subsidiary,  /* tricky because this is not in GROUP BY or a summary function */
         region,
         sales,
         max(sales) as maxsales,
         case
           when sales = max(sales) then 'maxi'
           else '????'
         end as minmax
  from sashelp.shoes
  group by region
  having minmax in('maxi')
  ;
quit;
