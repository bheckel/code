options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sql_count_allobs.sas
  *
  *  Summary: Demo of counting all obs.
  *
  *  Created: Tue 07 Jun 2005 14:26:18 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

proc sql;
  select count(*) as rowcount
  from SASHELP.shoes
  ;
quit;

 /* Append a missing record to the dataset. */
data foo;
  set SASHELP.shoes (keep= Region Product) end=e;
  output;  /* the original record */
  if e then
    do;
      Region = '';
      Product = '';
      output;  /* the new record */
    end;
run;
proc print data=_LAST_(obs=max); run;

title 'prove that count includes missings';
proc sql;
  select count(*) as rowcount
  from foo
  ;
quit;

