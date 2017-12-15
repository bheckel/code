options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: exchange_dataset_names.sas
  *
  *  Summary: Swap two dataset names without resorting to the OS.
  *
  *  Created: Fri 11 Mar 2011 10:10:34 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

title 'before';
data t t2;
  set SASHELP.shoes(obs=5);
run;

data t3 t4;
  set SASHELP.steel(obs=5);
run;

proc print data=t(obs=max) width=minimum; run;
proc print data=t2(obs=max) width=minimum; run;


title 'after';
proc datasets library=WORK NOlist;
  exchange t=t3
           t2=t4
           ;
  run;
quit;

proc print data=t(obs=max) width=minimum; run;
proc print data=t2(obs=max) width=minimum; run;
