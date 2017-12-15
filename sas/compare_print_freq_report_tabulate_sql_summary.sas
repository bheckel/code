options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: compare_print_freq_report_tabulate_sql_summary.sas
  *
  *  Summary: Comparison of multiple approaches.  Choose best proc for simple
  *           statistics.
  *
  *  Adapted: Wed 11 Jun 2014 13:00:50 (Bob Heckel -- http://blogs.sas.com/content/sgf/2014/05/09/which-base-procedure-is-best-for-simple-statistics)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

title '~~~~~~~~~~~~~~~~~proc print';
proc print data=sashelp.class(obs=max) width=minimum; run;


title '~~~~~~~~~~~~~~~~~proc print complex';
proc sort data=sashelp.class out=class; by sex; run;
proc print data=class noobs;
  by sex;
  var name age height weight;
  sum height weight;
run;


title '~~~~~~~~~~~~~~~~~proc report';
proc report data=sashelp.class nowd;
  column sex age height weight bmi;
  define sex / group;
  define age / group;
  define height / sum;
  define weight / sum;
  define bmi / computed format=8.2;

  compute bmi;
    bmi=(weight.sum/(height.sum)**2)*703;
  endcomp;
run;


title '~~~~~~~~~~~~~~~~~proc freq';
proc freq data=sashelp.class;
  tables age*sex / out=new outpct;
run;
proc print data=new; run;


title '~~~~~~~~~~~~~~~~~proc tabulate';
proc tabulate data=sashelp.class;
  class age;
  var height weight;
  table age, (height weight)*(sum mean min max);
run;


title '~~~~~~~~~~~~~~~~~proc summary';
proc summary data=sashelp.class;
  class age;
  var height weight;
  output out=stats sum= mean= min= max= / autoname;
run;
proc print data=stats; run;


title '~~~~~~~~~~~~~~~~~proc freq nlevels';
proc freq data=sashelp.class nlevels;
  tables age;
run;


title '~~~~~~~~~~~~~~~~~proc sql';
proc sql;
  select distinct age
  from sashelp.class
  ;
quit;
