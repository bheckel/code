options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: transpose_using_proc_sql.sas
  *
  *  Summary: Use proc sql to transform instead of proc transpose
  *
  *           var gets _NAME_s
  *
  *           See long2wide.mcr.sas for cases where VISITs is huge
  *
  *  Adapted: Wed 13 Aug 2014 11:30:02 (Bob Heckel--SUGI 1266-2014)
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

title 'proc sql';
proc sql noprint;
  create table ttp as
    select subject, 
           /* max is 1-required by the GROUP BY  2-required to remove the '.'s  Could also use sum() */
           max(case when visit=1 then ldl else . end) as ldl_1,
           max(case when visit=2 then ldl else . end) as ldl_2,
           max(case when visit=1 then hdl else . end) as hdl_1,
           max(case when visit=2 then hdl else . end) as hdl_2
    from t
    group by subject
    ;
  quit;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
/*
Obs    subject    ldl_1    ldl_2    hdl_1    hdl_2

 1        1        115      112       33       43 
 2        2        136      121       51       50 
 3        3         99      100       57       59 
*/


 /* Compare 1: */

title 'proc transpose is not enough';
proc transpose data=t out=ttp2;
  by subject;
  var ldl hdl;
  id visit;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
/*
Obs    subject    _NAME_     _1     _2

 1        1        ldl      115    112
 2        1        hdl       33     43
 3        2        ldl      136    121
 4        2        hdl       51     50
 5        3        ldl       99    100
 6        3        hdl       57     59
*/

title 'proc transpose & self merge';
data ttp3(drop=_NAME_);
  merge ttp2(where=(_NAME_ eq 'ldl') rename=(_1=ldl_1 _2=ldl_2))
        ttp2(where=(_NAME_ eq 'hdl') rename=(_1=hdl_1 _2=hdl_2))
        ;
  by subject;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
/*
Obs    subject    ldl_1    ldl_2    hdl_1    hdl_2

 1        1        115      112       33       43 
 2        2        136      121       51       50 
 3        3         99      100       57       59 
*/


 /* Compare 2: */
 /* SAS 9.2+ only! */
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

proc transpose data=ttp4 out=ttp5(/*drop=_NAME_*/;
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
