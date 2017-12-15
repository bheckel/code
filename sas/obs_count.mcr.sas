options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: obs_count.mcr.sas
  *
  *  Summary: Count number of observations efficiently
  *
  *           See also print_last_10_obs.sas
  *
  *           %put %obscnt(sashelp.shoes);
  *
  * Modified: Wed 24 Jul 2013 14:49:28 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

%macro obscnt(dsn);
  %let dsid=%sysfunc(open(&dsn));
  %let cntobs=%sysfunc(attrn(&dsid, NLOBS));
  %let dsid=%sysfunc(close(&dsid));

  &cntobs
%mend;


title 'print only the last 10 obs';
data t;
  set sashelp.shoes(firstobs=%eval(%obscnt(sashelp.shoes)-9));
run;
proc print data=_LAST_(obs=max) width=minimum; run;

