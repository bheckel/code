 /* see logparse_test.sas */

%include '~/code/sas/passinfo.sas';
%passinfo;

data _null_;
  x=sleep(5000);
run;

proc print data=sashelp.cars(obs=10) width=minimum heading=H;run;title;
