options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sql_inline_view_find_max_count.sas
  *
  *  Summary: Determine the max count value
  *
  *  Created: Mon 04 Mar 2013 14:13:41 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

options NOlabel;

title 'all';
proc sql;
  select count(subsidiary) as c, region
  from sashelp.shoes
  group by region
  ;
quit;


 /* NOTE: "...remerging summary statistics..." is ok */
title 'the region with the most subsidiaries';
proc sql;
  /* ...2nd find max */
  select *
  from (  /* this inline view can retrieve multiple columns, subquery only one */
    /* 1st find count... */
    select count(subsidiary) as c, region
    from sashelp.shoes
    group by region
  )
  having c eq max(c)
  ;
quit;
