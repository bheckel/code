options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: double_proc_transpose.sas
  *
  *  Summary: Yet another transpose approach
  *
  *  Adapted: Wed 13 Aug 2014 13:48:51 (Bob Heckel--SUGI 1266-2014)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data t;
  infile cards;
  input subject visit ldl hdl;
  cards;
1 1 115 33
1 2 112 43
2 1 136 51
2 2 121 50
3 1 99 57
3 2 100 59
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
/*
Obs    subject    visit    ldl    hdl

 1        1         1      115     33
 2        1         2      112     43
 3        2         1      136     51
 4        2         2      121     50
 5        3         1       99     57
 6        3         2      100     59
*/
 /* SAS 9.2+ only!  Earlier versions require a temporary id (e.g. idvar=_N_) be
  * built in an intermediate datastep as the id (e.g. id idvar; instead of id
  * _NAME_ visit;)
  */
title 'double proc transpose';
proc transpose data=t out=ttp4;
  by subject visit;
  var ldl hdl;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
/*
Obs    subject    visit    _NAME_    COL1

  1       1         1       ldl       115
  2       1         1       hdl        33
  3       1         2       ldl       112
  4       1         2       hdl        43
  5       2         1       ldl       136
  6       2         1       hdl        51
  7       2         2       ldl       121
  8       2         2       hdl        50
  9       3         1       ldl        99
 10       3         1       hdl        57
 11       3         2       ldl       100
 12       3         2       hdl        59
*/

proc transpose data=ttp4 out=ttp5;
  by subject;
  var COL1;
  id _NAME_ visit;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
/*
Obs    subject    _NAME_    ldl1    hdl1    ldl2    hdl2

 1        1        COL1      115     33      112     43 
 2        2        COL1      136     51      121     50 
 3        3        COL1       99     57      100     59 
*/
