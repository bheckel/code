options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: cntlin.sas
  *
  *  Summary: Create a dynamic temporary SAS format using a dataset.
  *
  *           See also read_ds_create_sasformat.sas and key_value_hash.sas
  *
  *  Created: Sun 22 Jun 2003 11:19:15 (Bob Heckel)
  * Modified: Thu 26 Apr 2012 11:00:56 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data scaleds;
  input begin $ 1-2 finish $ 5-8 amount $ 10-15;
  datalines;
0   3    0to3
4   6    4to6
7   8    7to8
9   10   9to10
11  16   11to16
  ;
run;
proc print data=_LAST_(obs=max); run;


 /* Must rename to SAS keywords START, END(optional if no up rng) and LABEL */
 /*                 ___________________________________   */
data fmtbldr (rename= (begin=START finish=END amount=LABEL));
  set scaleds end=e;
  /*  Mandatory to name the format here */
  retain fmtname 'f_pts';  /* or e.g. '$f_pts' if it want character fmt */
  if _N_ eq 1 then
    hlo='l';  /* keyword HLO holding l indicates LOW */
  else if e then 
    hlo='h';  /* keyword HLO holding h indicates HIGH */
  else 
    hlo=' ';
run;
proc print; run;
 	

 /* Use the dataset to build the temporary format */
proc format library=work cntlin=fmtbldr; run;

title 'Print the format just created in WORK';
/*
---------------------------------------------------------------------------+
|       FORMAT NAME: F_PTS    LENGTH:    3   NUMBER OF VALUES:    5        |
|   MIN LENGTH:   1  MAX LENGTH:  40  DEFAULT LENGTH   3  FUZZ: STD        |
+----------------+----------------+----------------------------------------+
|START           |END             |LABEL  (VER. 8.2     31MAR2009:14:37:12)|
+----------------+----------------+----------------------------------------+
|LOW             |               3|0to3                                    |
|               4|               6|4to6                                    |
|               7|               8|7to8                                    |
|               9|              10|9to10                                   |
|              11|HIGH            |11to16                                  |
+----------------+----------------+----------------------------------------+
*/
proc format library=work FMTLIB; run;


 /* Now test format */
title;
data sales;
  input acctnum $  num  descr $;
  cards;
123  3 widget
124  16 widbot
125  6 widnot
126  23 widwhatnot
  ;
run;

 /* Use the temporary format: */
data new;
  set sales;
  newvar = put(num, f_pts10.);
run;
proc print data=_LAST_(obs=max) width=minimum; run;

proc report data=sales NOWD COLWIDTH=12;
  /* Keep original var untouched (unlike previous e.g.) */
  column acctnum num num=pctage;
  define pctage / format=f_pts10. 'in words';
run;

