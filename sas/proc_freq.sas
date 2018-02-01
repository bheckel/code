options nosource;
 /*----------------------------------------------------------------------------
  *     Name: proc_freq.sas
  *
  *  Summary: Best used to create tables showing the distribution of 
  *           CATEGORICAL (not continuous or unique) data values.  Also good
  *           for revealing irregularities in your data.
  *
  *           Answers questions like 'How many times does the value "CA" occur
  *           for variable STATE?' and 'How are individual values of SCORE
  *           distributed'
  *
  *            Does not need to be sorted on TABLE var!
  *
  *  Adapted: Thu 11 Apr 2002 14:41:23 (Bob Heckel - Little SAS Book sect 4.11)
  * Modified: Fri 08 Apr 2016 15:43:02 (Bob Heckel)
  *----------------------------------------------------------------------------
  */
options source replace;

/* PROC FREQ with only top 5 (highest) levels produced */
proc freq data=sashelp.cars order=freq;
  tables make / maxlevels=5;
run;



 /* V9+ */
ods output nlevels=NLevels_out;
data t;
  set sashelp.class;
  if age eq 13 then age=.;
run;
proc freq data=t nlevels;
  tables age / noprint;
run;
proc print data=NLevels_out(obs=max) width=minimum; run;



data work.orders;
  infile cards;
  ***length coffee $5;
  input coffee $  windowtyp $  empid $  @@;
  /* Case matters to proc freq, so use lowercase. */
  coffee = lowcase(coffee);
  label coffee = 'Black Gold';  /* can't use in the proc freq, use it here */
  cards;
esp w A cap d A cap w A kon w B ice w A kon d A esp d A kon w A ice d A esp d A
cap w A esp d A Cap d A Kon d A .   d A kon w A esp d A cap w A ice w B kon w A
kon w A kon w B ice d B esp d A kon w A esp d A esp w B Kon w A cap w A kon w A
  ;
run;
title 'raw';
proc print data=_LAST_(obs=max) width=minimum; run;


title 'two separate tables';
proc freq;
  tables coffee windowtyp;
run;


title 'Two-Way Crosstabulation -- Window Type By Coffee';
proc freq data=work.orders(where=(coffee ne 'kon'));
  /*                2-way freq tbl                          */
  /*     ___Row___ _Col__                                   */
  tables windowtyp*coffee;
run;


title 'N-Way Crosstabulation (two tables are printed)';
proc freq data=work.orders(where=(coffee ne 'kon'));
  /* The OUT= statement goes on the TABLES line, not the PROC FREQ line!! */
  /*     _Level___Row___ _Col__                                                   */
  tables empid*windowtyp*coffee;
run;

title 'N-Way Crosstabulation (cleaner version)';
proc freq data=work.orders(where=(coffee ne 'kon'));
  /* The OUT= statement goes on the TABLES line, not the PROC FREQ line!! */
  /*     _Level___Row___ _Col__                                                   */
  tables empid*windowtyp*coffee / LIST /* NOCUM NOCOL NOROW NOPERCENT out=bobh.freaky*/;
run;



 /* Compare with: */
proc tabulate data=work.orders;
  title 'Proc Tabulate';
  class windowtyp coffee;
  ***tables windowtyp, n;
  tables windowtyp, coffee;
  ***table windowtyp*coffee, n / rtspace=23;
run;


 /* Compare with: */
proc sql;
  title 'Proc SQL';
  select windowtyp, coffee, COUNT(*) as n from work.orders
  group by windowtyp, coffee;
quit;


title 'blank so show all';
proc freq order=freq; run;

title 'or almost all if you know it is an analysis variable';
proc freq data=foo (drop= certno); run;

