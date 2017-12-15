 /*---------------------------------------------------------------------------
  *     Name: proc_means.sas
  *
  *  Summary: Demo of proc means.  Descriptive statistics.
  *
  *           CHARTYPE option forces 010 style for the _TYPE_ auto var.
  *
  *           See also proc_summary.sas
  *
  *  Created: Thu 04 Mar 2004 14:01:53 (Bob Heckel -- SUGI proc means paper
  *                  http://www2.sas.com/proceedings/sugi25/25/btu/25p068.pdf)
  * Modified: Fri 18 Dec 2015 14:21:52 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options linesize=180 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=5 nostimer number serror merror
        noreplace datastmtchk=allkeywords;

title "&SYSDSN";proc print data=sashelp.cars(obs=10) width=minimum heading=H;run;
 /* Q1=lower 25% quartile range Q3=upper 25% quartile range QRANGE=interquartile range */
proc means data=sashelp.cars maxdec=2 MEAN MEDIAN MODE VARIANCE RANGE Q1 Q3 QRANGE CLM;
  class make;  /* grouping */
  var mpg_city;  /* numeric analysis variable */
run;

proc means data=sashelp.cars maxdec=0;
  output out=t MEDIAN=;
  class make;
  var mpg_city;
run;
title "&SYSDSN";proc print data=t(obs=10) width=minimum heading=H;run;title;
endsas;

proc means data=sashelp.cars maxdec=0 MEDIAN;
  output out=t median=;
/***  class make;***/
  var mpg_city;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;


endsas;

 /* NOprint makes proc means the same as proc summary except automatic DATA1.sas7bdat */
proc means data=sashelp.shoes /*NOprint*/;
  output out=t std= mystdsales mystdinventory;
  class region;  /* no sorting required, usually a small number of discrete items */
  var sales inventory;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
 /* Compare CLASS vs. BY: */
proc means data=sashelp.shoes /*NOprint*/;
  output out=t std= mystdsales mystdinventory;  /* t won't include a total 0 _TYPE_ */
  by region;  /* prints separate tables for each region, must be sorted by region */
  var sales inventory;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


data tmp;
  infile cards TRUNCOVER;
  input orderid $  sku $  store $  yr  month  quarter  storetype $
        quantity  totdol;
   cards;
001 232 abc 2002 05 01 big 150 5000
010 232 abc 2002 05 01 big 150 
002 232 abc 2003 05 01 big 150 6000
003 2z2 abc 2004 05 01 big 150 400
004 932 abc 2004 05 01 big 150 2000
005 222 abd 2004 03 01 small 150 3000
006 2q0 abe 2004 01 01 small 150 800
  ;
run;
proc print; run;

proc sort; by store; run;
proc means;
  output out=tmp2;
  by store;  /* gives separate table output, use CLASS for a single table */
  var totdol;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


title 'Simple MIN MAX MEAN using a flip';
proc transpose data=foo(where=(_TYPE_ eq 1 and _STAT_ ne 'STD'));
  by store;
  id _STAT_;
  var totdol;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


title 'Total ordered dollar amount for each store';
 /*  auto-generated columns  created when using OUTPUT OUT=...        */
 /*     ______                                                        */
title2 '_FREQ_ is count of detail rows that make up a summarized grouping';
title3 '_TYPE_ is the level of the grouping';
proc means data=tmp nway chartype noprint;
  /* Classification, categorical, discrete, variable(s) */
  class store;
  /* Analysis, continuous, variable(s).  Numerics. */
  var totdol;
  /* sum= refers to totdol (could rename it sum=sumthing) */
  output out=myds sum=;
run;
 /* _TYPE_ is a binary identifier when CHARTYPE is set.  So in a 3 variable
  * class statement, there will be 9 -- 000, 001, 010, 011, 100, 101, 110, 111 
  *
  * Using the CHARTYPE option makes it much easier to take advantage of PROC
  * MEANS ability to create multiple output data sets than if you had to
  * figure out the default numeric value.
  */
proc print; run;

title 'Total ordered dollar amount BY STORE BY YEAR';
proc means data=tmp nway chartype noprint;
  output out=myds2 sum=;
  class store yr;
  var totdol;
run;
proc print; run;

title '(ways 1) Show total ordered dollar amount 1-by store and then 2-by year';
proc means data=tmp nway chartype noprint;
  class store yr;
  var totdol;
  /* This will give same results as the previous proc means. */
  ***ways 2;
  ways 1;
  /* Drag along data that is not to be used as classification or analysis
   * variables.  Use with caution.  E.g. this wouldn't work if the summary
   * level was sku instead of storetype since it would contain the last value
   * of storetype the procedure came across in summarizing the data by sku.
   */
  ***id storetype;
  output out=myds3 sum=;
run;
proc print; run;


 
 /* New example -- preloadfmt */

data cake;
   input LastName $ 1-12 Age 13-14 PresentScore 16-17 
         TasteScore 19-20 Flavor $ 23-32 Layers 34 ;
   datalines;
Orlando     27 93 80  Vanilla    1
Ramey       32 84 72  Rum        2
Goldston    46 68 75  Vanilla    1
Roe         38 79 73  Vanilla    2
Larsen      23 77 84  Chocolate  .
Davis       51 86 91  Spice      3
Strickland  19 82 79  Chocolate  1
Nguyen      57 77 84  Vanilla    .
Hildenbrand 33 81 83  Chocolate  1
Byron       62 72 87  Vanilla    2
Sanders     26 56 79  Chocolate  1
Jaeger      43 66 74             1
Davis       28 69 75  Chocolate  2
Conrad      69 85 94  Vanilla    1
Walters     55 67 72  Chocolate  2
Rossburger  28 78 81  Spice      2
Matthew     42 81 92  Chocolate  2
Becker      36 62 83  Spice      2
Anderson    27 87 85  Chocolate  1
Merritt     62 73 84  Chocolate  1
;
run;

proc format;
  value layerfmt 1   = 'single layer'
                 2-3 = 'multi-layer'
                 .   = 'unknown'
                 ;
  value $flvrfmt (NOTSORTED) 'Vanilla'             = 'Vanilla'
                             'Orange','Lemon'      = 'Citrus'
                             'Spice'               = 'Spice'
                             'Rum','Mint','Almond' = 'Other Flavor'
                             ;
run;

proc means data=cake fw=7 COMPLETETYPES MISSING NOnobs N /*NOprint*/;
   class flavor layers / PRELOADFMT EXCLUSIVE ORDER=data;
   ways 1 2;
   var TasteScore;  /* analysis variable, usually numeric */
   format layers layerfmt. flavor $flvrfmt.;
   title 'Taste Score For Number of Layers and Cake Flavors';
   output out=t;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


 /* Always use MISSING if your class has holes */
data t;
  set SASHELP.shoes;
  if _N_ eq 5 then region='';
run;

proc means data=t;
  class region / MISSING;
  var stores;
  output out=t2;
run;
proc print data=t2(obs=max) width=minimum; where _stat_ eq 'N'; run;
