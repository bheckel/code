 /* see ~/code/sas/proc_presenv.restore.sas */

options presenv;

options ls=64 sgen;
%let mv_day=Thursday;

data t; set sashelp.shoes(obs=5); run;


 /* PERMDIR: preserve work data sets created by the code
  * SASCODE: used to recover options, macro variables and macros
  */
libname l '~/bob/tmp';  /* WARNING: all existing datasets will be deleted!!! */
filename f '~/bob/tmp/proc_presenv.sas';

proc presenv PERMDIR=l SASCODE=f SHOW_COMMENTS; run;
options NOpresenv;
