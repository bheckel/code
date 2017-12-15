options presenv;

 /* see ~/code/sas/proc_presenv.restore.sas */

options ls=150;
%let mv_day=Thursday;

data t; set sashelp.shoes(obs=5); run;


 /* PERMDIR: preserve work data sets created by the code
  * SASCODE: used to recover options, macro variables and macros
  */
libname l '~/bob/tmp'; proc presenv PERMDIR=l SASCODE='~/bob/tmp/proc_presenv.sas' SHOW_COMMENTS; run;
options NOpresenv;
