options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: report_using_order.sas
  *
  *  Summary: Demo of proc report that uses the horrible order and order=
  *
  *  Adapted: Tue 09 Sep 2003 13:22:34 (Bob Heckel --
  *  http://groups.google.com/groups?hl=en&lr=&ie=UTF-8&selm=sd3ff09f.017%40firsthealth.com&rnum=5)
  *---------------------------------------------------------------------------
  */
options source;

data xx;
  input pid $1-5 test $6-22 date $23-31 course $32-49 result 50-55;
  daten=input(date,date.);
  format daten date.;
  cards;
03   AST/SGOT         25JUL00  SCREENING             63
03   AST/SGOT         19SEP00  POST-TX WEEK 4       241
03   Alkaline Phosph  25JUL00  SCREENING            452
03   Alkaline Phosph  08AUG00  CRS 1 DAY 8          660
03   Alkaline Phosph  22AUG00  CRS 2 DAY 1          649
03   Alkaline Phosph  12SEP00  DISCONTINUATION      662
03   Total Bilirubin  25JUL00  SCREENING              1
03   Total Bilirubin  19SEP00  POST-TX WEEK 4       5.2
15   Potassium (Low)  04DEC00  SCREENING              5
15   Potassium (Low)  07FEB01  POST-TX WEEK 4       2.9
15   Sodium (Low)     04DEC00  SCREENING            128
15   Sodium (Low)     04DEC00  CRS 1 DAY 1          128
15   Sodium (Low)     08JAN01  CRS 2 DAY 1          128
  ;
run;

proc print; run;
options nocenter;

proc report headline split='~' nowd;
  column pid test daten course result;

  /* Two utterly different meanings of ORDER! */
  define pid      / width=3 order order=data;
  define test     / width=15 order order=data;
  define daten    / width=7 order order=data;
  define course   / width=16;
  define result   / width=6;

  break after pid / skip;
run;
