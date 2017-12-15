options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: concat_datasets.sql.sas (s/b symlinked as stack.sas)
  *
  *  Summary: Stack two datasets on top of each other.  Compare with 
  *           proc_append.sas
  *
  *  Adapted: Thu 10 Jun 2004 16:01:22 (Bob Heckel -- SUGI 269-29
  *                                     proc sql vs. the datastep)
  * Modified: Wed 24 Jun 2009 09:21:27 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;


data t1;
  input density  crimerate  state $ 14-27  stabbrev $ 29-30;
  cards;
264.3 3163.2 Pennsylvania   PA
51.2 4615.8  Minnesota      MN
55.2 4271.2  Vermont        VT
120.4 4649.9 North Carolina NC
  ;
run;

data t2;
  input density  crimerate  statex $ 14-27;
  cards;
264.3 3163.2 PXnnsylvania
55.2 4271.2  VXrmont
9.1 2678.0   SXuth Dakota
102.4 3371.7 NXrth Carolina
9.4 2833.0   NXrth Dakota
120.4 4649.9 NXrth Carolina
  ;
run;

title 'datastep stacking';
data t3;
  set t1 t2;
run;
proc print data=t3; run;

title 'sql stacking';
proc sql;
  create table t4 as
  select * 
  from t1
  OUTER UNION CORRESPONDING
  select * 
  from t2
  ;
quit;
proc print data=t4; run;

