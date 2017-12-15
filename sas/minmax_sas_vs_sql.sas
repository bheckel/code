options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: minmax_sas_vs_sql.sas
  *
  *  Summary: Calculating minimum and maximums with SAS and SQL.
  *
  *  Adapted: Fri 30 Oct 2009 12:44:04 (Bob Heckel -- SUGI 185-2008)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /***************** SAS 1 *************************/
proc sort data=sashelp.shoes out=t; by region; run;
data t2(keep=region mins maxs cnt);
  retain mins maxs;
  set t;
  by region;

  /* Initialization: */
  if first.region then do;
    cnt = 0;
    salestmp = .;
    mins = .;
    maxs = .;
  end;

  /* Accumulation: */
  cnt+1;
  salestmp = sales;
  mins = min(of mins salestmp);
  maxs = max(of maxs salestmp);

  if last.region then output;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


 /***************** SAS 2 *************************/
 /* _FREQ_ a.k.a. count is implicitly thrown in for free */
proc summary data=t;  /* do not use proc means here, too verbose */
  by region;
  output min(sales)=mins max(sales)=maxs;
run;
proc print data=data1(obs=max) width=minimum; run;


 /***************** SQL *************************/
proc sql;
  select region, min(sales) as mins, max(sales) as maxs, count(*) as cnt
  from sashelp.shoes
  group by region
  ;
quit;


 /* Verify */
/***proc print data=sashelp.shoes(obs=max) width=minimum; var region sales; run;***/

