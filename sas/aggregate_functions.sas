options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: aggregate_functions.sas
  *
  *  Summary: Compare SAS vs. SQL aggregate functions.
  *
  *           See also sas_vs_sql.html
  *
  *  Adapted: Mon 14 Jun 2004 12:42:36 (Bob Heckel -- SUGI 269-29)
  *---------------------------------------------------------------------------
  */
options source;

proc sort data=SASHELP.shoes out=tmp;
  by region;
run;

proc means data=tmp;
  by region;
  var sales;
  output out=tmp2 sum=mysum n=myn nmiss=mymiss;
run;

proc print data=_LAST_; run;


 /* compare */

proc sql;
  create table tmp3 as
  select region,
         sum(sales) as mysum,
         count(sales) as myn,
         nmiss(sales) as mymiss
  from SASHELP.shoes
  group by region  /* like 'by' in proc means */
  order by region  /* like proc sort */
  ;
quit;

proc print data=_LAST_; run;
