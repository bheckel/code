options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: use_formatted_data_instead_raw.sas
  *
  *  Summary: Work with formatted groups rather than individuals
  *
  *  Created: Thu 30 Jul 2015 08:20:22 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

libname l '~';

title "ds:&SYSDSN";proc print data=l.ageHistory(obs=20) width=minimum; run;title;

  proc format;
    value cntgrp 0-18 = '0-18'
                 19-29 = '19-29'
                 30-39 = '30-39'
                 40-49 = '40-49'
                 50-64 = '50-64'
                 65-74 = '65-74'
                 75-HIGH = '75+'
                 ;
  run;

proc sql;
  select sum(upid) into :cntagehist
  from l.ageHistory
  ;

  create table t as
  select put(age,cntgrp.) as agef, upid as upidc 
  from l.ageHistory
  ;

  create table t2 as
  select sum(upidc) as cu, agef
  from t
  group by agef
  ;

  select cu/&cntagehist as pctagehist, agef
  from t2
  ;

quit;
%put _USER_;


endsas;
ds:        _NULL_                          

Obs    age    UPID

  1      0    1917
  2      1    3289
  3      2    3070
  4      3    2765
  5      4    2834
  6      5    3251
  7      6    3082
  8      7    3149
  9      8    2985
 10      9    2904
 11     10    3096
 12     11    2900
 13     12    2807
 14     13    2993
 15     14    3731
 16     15    3556
 17     16    3451
 18     17    3530
 19     18    3714
 20     19    3867
 
        
--------
  367432
 
 
pctagehist  agef
-----------------
  0.160639  0-18 
  0.112579  19-29
  0.099194  30-39
   0.12537  40-49
  0.255593  50-64
   0.12574  65-74
  0.120885  75+  
