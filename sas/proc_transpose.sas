options nosource;
 /*---------------------------------------------------------------------------
  *     Name: proc_transpose.sas
  *
  *  Summary: Demo of transposing observations into variables (or less
  *           frequently, vars into obs).
  *
  *  ---
  *     proc transpose data=t prefix=sex out=t2 (drop= _NAME_ _LABEL_);
  *       by st;
  *       id sex;   <--the categorical row data that turns into new column(s):
  *       var tot;  <--the continuous, usually numerics
  *       copy comment1 comment2;  <--drag along other vars
  *     run;
  *  ---
  *     proc transpose data=wide out=long(where=(COL1 ne .));
  *       by id;
  *       var s1-s4;
  *     run;
  *  ---
  *
  * BY-group variable(s), e.g. the NAME column
  * ID variable - values of this variable will be used as column names in the transposed table, e.g. SUBJECT column is an ID variable.
  * VAR variable - values of this variable will be transposed, e.g. the VALUE column
  *
  * NAME SUBJECT VALUE
  * Jack id_num 101
  * Jack new_patient 1
  * Jack expense 65.20
  * Lisa id_num 102
  * Lisa new_patient 0
  * Lisa expense 27.35
  *
  *  Created: Thu 11 Apr 2002 14:41:23 (Bob Heckel)
  * Modified: Thu 11 Aug 2016 10:11:29 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data t;
  set sashelp.class(obs=4)end=e;
  if e then do;
    name='Alice';sex='M';age=29;height=10;weight=100;
  end;
  n = _N_;  /* further disambiguate Alices */
run;
proc print data=_LAST_(obs=max) width=minimum; run;
/*
Obs     Name      Sex    Age    Height    Weight    n

 1     Alfred      M      14     69.0      112.5    1
 2     Alice       F      13     56.5       84.0    2
 3     Barbara     F      13     65.3       98.0    3
 4     Alice       M      29     10.0      100.0    4
*/

 /* Expand single obs into multiple obs */

title 'without ID';
proc transpose data=t OUT=ttp;
  by n name;
  var sex age height weight;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
/*
Obs    n     Name      _NAME_        COL1

  1    1    Alfred     Sex       M           
  2    1    Alfred     Age                 14
  3    1    Alfred     Height              69
  4    1    Alfred     Weight           112.5
  5    2    Alice      Sex       F           
  6    2    Alice      Age                 13
  7    2    Alice      Height            56.5
  8    2    Alice      Weight              84
  9    3    Barbara    Sex       F           
 10    3    Barbara    Age                 13
 11    3    Barbara    Height            65.3
 12    3    Barbara    Weight              98
 13    4    Alice      Sex       M           
 14    4    Alice      Age                 29
 15    4    Alice      Height              10
 16    4    Alice      Weight             100
*/
 
                                                                                                                                                                                                                                                                
title 'with ID';
proc transpose data=t;
  by n name;
  id sex;
  var age height weight;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
/* 
with ID

Obs    n     Name      _NAME_      M        F

  1    1    Alfred     Age        14.0      . 
  2    1    Alfred     Height     69.0      . 
  3    1    Alfred     Weight    112.5      . 
  4    2    Alice      Age          .     13.0
  5    2    Alice      Height       .     56.5
  6    2    Alice      Weight       .     84.0
  7    3    Barbara    Age          .     13.0
  8    3    Barbara    Height       .     65.3
  9    3    Barbara    Weight       .     98.0
 10    4    Alice      Age        29.0      . 
 11    4    Alice      Height     10.0      . 
 12    4    Alice      Weight    100.0      . 
*/



/*
final1.sas7bdat:
         Obs    sid    name                                 stateprov        chrongroup        cntchron

           1    11     Lewis Drug #11                          SD        2 Chronic Diseases        2   
           2    2      Lewis Drug #2                           SD        2 Chronic Diseases        1   
           3    4      Lewis Drug #4                           SD        2 Chronic Diseases        2   
           4    55     Lewis Family Drug #55                   IA        2 Chronic Diseases        2   
           5    55     Lewis Family Drug #55                   IA        3 Chronic Diseases        1   
           6    56     Lewis Family Drug #56                   MN        2 Chronic Diseases        3   
           7    62     Long Term Care: Rock Rapids (#62)       IA        2 Chronic Diseases        4   
           8    68     Lewis Family Drug #68                   SD        2 Chronic Diseases        1   
           9    68     Lewis Family Drug #68                   SD        3 Chronic Diseases        1   
          10    70     Lewis Family Drug #70                   SD        2 Chronic Diseases        2   
          11    70     Lewis Family Drug #70                   SD        4 Chronic Diseases        1   
*/
  proc sort data=final1;  by sid name stateprov; run;
  proc transpose data=final1;
    by sid name stateprov;
    id chrongroup;
    var cntchron;
  run;
/*
                                                                                  2           3           4
                                                                               Chronic     Chronic     Chronic
  Obs    sid    name                                 stateprov     _NAME_     Diseases    Diseases    Diseases

    1    11     Lewis Drug #11                          SD        cntchron        2           .           .   
    2    2      Lewis Drug #2                           SD        cntchron        1           .           .   
    3    4      Lewis Drug #4                           SD        cntchron        2           .           .   
    4    55     Lewis Family Drug #55                   IA        cntchron        2           1           .   
    5    56     Lewis Family Drug #56                   MN        cntchron        3           .           .   
    6    62     Long Term Care: Rock Rapids (#62)       IA        cntchron        4           .           .   
    7    68     Lewis Family Drug #68                   SD        cntchron        1           1           .   
    8    70     Lewis Family Drug #70                   SD        cntchron        2           .           1   
*/



 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
 /* Adapted from SUGI-082-2013 */
title 'DAT1 in the Original Form (1 obs per subject)';
data dat1;
  input name $ e1-e3;
  datalines;
John 89 90 92
Mary 92 . 81
  ;
run;
proc print data=dat1; run;
/*
Obs    name    e1    e2    e3

 1     John    89    90    92
 2     Mary    92     .    81
*/

 
 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
title 'Transposing DAT1 Using PROC TRANSPOSE';
proc transpose data=dat1 out=dat1_t1(/*drop=_NAME_*/);
  /* no BY because 1 obs per subject */
  var e1-e3;
  id name;
run;
proc print data=dat1_t1; run;
/*
Obs    _NAME_    John    Mary

 1       e1       89      92 
 2       e2       90       . 
 3       e3       92      81 
*/

title 'Transposing DAT1 Using Array Processing';
data dat1_t2(/*keep= John Mary*/);
  set dat1 end=e;

  array score[3] e1-e3;
  array newscore[2] John Mary;
  array all[2,3] _temporary_;

  i+1;
  do j=1 to dim(score);
    all[i,j]=score[j];
    put all[i,j]=;
  end;

  if e then do;
    do j=1 to dim(score);
      do i=1 to 2;
        newscore[i]=all[i,j];
      end;
      output;
    end;
  end;
run;
proc print data=dat1_t2; run;
/*
Obs    name    e1    e2    e3    John    Mary    i    j

 1     Mary    92     .    81     89      92     3    1
 2     Mary    92     .    81     90       .     3    2
 3     Mary    92     .    81     92      81     3    3
*/
 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
title 'Transposing By-groups (1 obs per subject) by Using PROC TRANSPOSE';
proc sort data=dat1 out=dat1_sort; by name; run;
proc transpose data=dat1_sort out=dat1_bygrp1 name=test;
  by name;
  var e1-e3;
run;
proc print data=dat1_bygrp1; run;
/*
Obs    name     test    COL1

 1     John     e1      89 
 2     John     e2      90 
 3     John     e3      92 
 4     Mary     e1      92 
 5     Mary     e2       . 
 6     Mary     e3      81 
*/

title 'Transposing By-groups (1 obs per subject) by Using Array Processing';
data dat1_bygrp2(/*keep= name test score*/);
  set dat1;

/***  array e[3];***/
  /* same */
  array e[3] e1-e3;
  do i=1 to 3;
    test='e'||left(i);
    score=e[i];
    put e[i]=;
/***    if not missing(score) then output;***/
    output;
  end;
run;
proc print data=dat1_bygrp2; run;
/*
Obs    name    e1    e2    e3    i    test    score

 1     John    89    90    92    1     e1       89 
 2     John    89    90    92    2     e2       90 
 3     John    89    90    92    3     e3       92 
 4     Mary    92     .    81    1     e1       92 
 5     Mary    92     .    81    2     e2        . 
 6     Mary    92     .    81    3     e3       81 
*/
 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
title 'DAT2 in the Original Form (multiple obs per subject)';
data dat2;
  input name $ exam score;
  datalines;
John 1 89
John 2 90
John 3 92
Mary 1 92
Mary 3 81
  ;
run;
proc print data=dat2; run;
/*
Obs    name    exam    score

 1     John      1       89 
 2     John      2       90 
 3     John      3       92 
 4     Mary      1       92 
 5     Mary      3       81 
*/

proc sort data=dat2 out=dat2_sort; by name; run;

 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
title 'Transposing DAT2 By-groups (multiple obs per subject) Using PROC TRANSPOSE';
proc transpose data=dat2_sort out=dat2_t1 prefix=Test;  /* prefix should probably be score instead */
  var score;
  id exam;
  by name;
run;
proc print data=dat2_t1; run;
/*
Obs    name    _NAME_    Test1    Test2    Test3

 1     John    score       89       90       92 
 2     Mary    score       92        .       81 
*/

title 'Transposing DAT2 By-groups (multiple obs per subject) Using Array Processing';
data dat2_t2(/*drop= exam score i*/);
  retain atest1-atest3;
  set dat2_sort;
  by name;

  array atest[3] atest1-atest3;

  if first.name then do;
    do i=1 to 3; atest[i]=.; end;
  end;

  atest[exam]=score;

  if last.name then output;
run;
proc print data=dat2_t2; run;
/*
Obs    atest1    atest2    atest3    name    exam    score    i

 1       89        90        92      John      3       92     .
 2       92         .        81      Mary      3       81     .
*/


 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
title 'DAT3 in the Original Form';
data dat3;
  input name $ exam score;
  datalines;
John 1 89
John 2 90
John 2 89
John 3 92
John 3 95
Mary 1 92
Mary 3 81
Mary 3 85
  ;
run;
proc sort data=dat3 out=dat3_sort1; by name exam score; run;
proc print data=dat3_sort1; run;

title 'DAT3 handling duplicates via LET'; proc print data=dat3_t1; run;
proc transpose data=dat3_sort1 out=dat3_t1 (drop=_name_) prefix=test let;
  var score;
  by name;
  id exam;
run;
/*
Obs    name    test1    test2    test3

 1     John      89       90       95 
 2     Mary      92        .       85 
*/
 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
 /* Array approach would be required if you wanted something like mean */
title 'DAT3 handling duplicates via array'; proc print data=dat3_t2; run;
data dat3_t2(/*keep= name test1-test3*/);
/***  retain test1 test2 test3;***/
  set dat3_sort1;
  by name exam;
  array test[3];
  /* Same as above RETAIN, just retain the array */
  retain test;

  if first.name then do;
    do i=1 to 3; test[i]=.; end;
  end;

  if first.exam then do;
    score_hi = score;
  end;
  if not first.exam then do;
    if score gt score_hi then score_hi=score;
  end;

  if last.exam then do;
    test[exam]=score_hi;
  end;

  if last.name then output;
run;
/*
Obs    name    exam    score    test1    test2    test3    i    score_hi

 1     John      3       95       89       90       95     .       95   
 2     Mary      3       85       92        .       85     .       85   
*/
 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
title 'DAT4 in the Original Form'; proc print; run;
data dat4;
  input name $ e1-e3 m1-m3;
  cards;
John 89 90 92 78 89 90
Mary 92 . 81 76 91 89
  ;
run;
proc sort data=dat4 out=dat4_sort1; by name; run;
/*
Obs    name    e1    e2    e3    m1    m2    m3

 1     John    89    90    92    78    89    90
 2     Mary    92     .    81    76    91    89
*/

title 'First use of PROC TRANSPOSE for dat4'; proc print data=dat4_out1; run;
proc transpose data=dat4_sort1 out=dat4_out1;
  by name;
run;
/*
Obs    name    _NAME_    COL1

  1    John      e1       89 
  2    John      e2       90 
  3    John      e3       92 
  4    John      m1       78 
  5    John      m2       89 
  6    John      m3       90 
  7    Mary      e1       92 
  8    Mary      e2        . 
  9    Mary      e3       81 
 10    Mary      m1       76 
 11    Mary      m2       91 
 12    Mary      m3       89 
*/

title 're-transformed back to Original'; proc print data=_LAST_(obs=max) width=minimum; run;
proc transpose;
  by name;
  id _NAME_;
  var COL1;  /* optional */
run;
/*
Obs    name    _NAME_    e1    e2    e3    m1    m2    m3

 1     John     COL1     89    90    92    78    89    90
 2     Mary     COL1     92     .    81    76    91    89
*/
 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
data dat5;
  input name $ ignore $ score $ test_num $ test_ltr $;
  cards;
John e1 89 1 e
John m1 78 1 m
Mary e1 92 1 e
Mary m1 76 1 m
John e2 90 2 e
John m2 89 2 m
Mary e2 . 2 e
Mary m2 91 2 m
John e3 92 3 e
John m3 90 3 m
Mary e3 81 3 e
Mary m3 89 3 m
  ;
run;
proc sort data=dat5 out=dat5_sort1; by test_num test_ltr; run;

 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/



 /* ~~~~~~~~~Column to rows (long to wide) ~~~~~~~~~ */
data canonical;
  input cause $  cnt  yr $;
  cards;
A04 5 2003
A049 6 2003
A048 3 2003
A048 2 2002
B041 1 2002
  ;
run;
proc sort; by cause yr; run;

proc transpose prefix=Yr_;
  /* Row */
  by cause;
  /* Column.  The new variable (former observation). */
  id yr;
  /* The numbers you're most interested in */
  var cnt;
run;
 /*
Obs    cause    cnt     yr

 1     A04       5     2003
 2     A048      2     2002
 3     A048      3     2003
 4     A049      6     2003
 5     B041      1     2002
 
Obs    cause    _NAME_    Yr_2003    Yr_2002

 1     A04       cnt         5          .   
 2     A048      cnt         3          2   
 3     A049      cnt         6          .   
 4     B041      cnt         .          1   
 */



 /* ~~~~~~~~~Rows to column (wide to long) ~~~~~~~~~ */
data t;
  infile cards;
  input lnm $ q1 q2 q3 q4;
  cards;
aa 1 2 3 4
bb 11 22 33 44
cc 111 222 333 444
  ;
run;

proc transpose;
  by lnm;
  var q1-q4;
run;
 /*
Obs    lnm     q1     q2     q3     q4

 1     aa       1      2      3      4
 2     bb      11     22     33     44
 3     cc     111    222    333    444
 
Obs    lnm    _NAME_    COL1

  1    aa       q1         1
  2    aa       q2         2
  3    aa       q3         3
  4    aa       q4         4
  5    bb       q1        11
  6    bb       q2        22
  7    bb       q3        33
  8    bb       q4        44
  9    cc       q1       111
 10    cc       q2       222
 11    cc       q3       333
 12    cc       q4       444
  */



/*
        Batch
        Data_      Area_                                Batch_                   Characteristic_                                        Value_     is
Obs    ORDINAL    ORDINAL            areanm             ORDINAL      Handle          ORDINAL        name                    instance    ORDINAL    UTC    Value

 1        1          1       arMDIMfg-pcAerosolLine8       1       ZEBDEV.118           1           End Time                   1           1       -1     2009-02-17T14:18:51
 2        1          1       arMDIMfg-pcAerosolLine8       1       ZEBDEV.118           2           Start Time                 1           2       -1     2009-02-17T14:18:00
 3        1          1       arMDIMfg-pcAerosolLine8       1       ZEBDEV.118           3           Process Order Number       1           3        .     2000763769         
 4        1          1       arMDIMfg-pcAerosolLine8       2       ZEBDEV.119           4           End Time                   1           4       -1     2009-02-20T18:01:07
 5        1          1       arMDIMfg-pcAerosolLine8       2       ZEBDEV.119           5           Start Time                 1           5       -1     2009-02-19T04:18:12
 6        1          1       arMDIMfg-pcAerosolLine8       2       ZEBDEV.119           6           Process Order Number       1           6        .     2000763768         
*/ 
proc transpose data=charistvalue out=flipcharistvalue(drop=_:);
  by handle batch_ordinal;
  id name;
  var value;
run;
/*
                                                                                                    Process_
                     Batch_                                                                          Order_
Obs      Handle      ORDINAL    _NAME_    _LABEL_         End_Time              Start_Time           Number

 1     ZEBDEV.118       1       Value      Value     2009-02-17T14:18:51    2009-02-17T14:18:00    2000763769
 2     ZEBDEV.119       2       Value      Value     2009-02-20T18:01:07    2009-02-19T04:18:12    2000763768
*/



data singlelines;
  input t1-t15 quarter;
  cards;
11482 485 81 2 7 7 1 4 1 35 2 1 0 0 2 1
 5461 218 28 3 3 0 1 1 0 12 0 0 0 0 0 2
 5461 218 28 3 3 0 1 1 0 11 0 0 0 0 0 3
 5461 218 28 3 3 0 1 1 0 11 0 0 0 0 0 4
  ;
run;
proc print; run;
 /*
Obs      t1      t2    t3    t4    t5    t6    t7    t8    t9    t10    t11    t12    t13    t14    t15    quarter

 1     11482    485    81     2     7     7     1     4     1     35     2      1      0      0      2        1   
 2      5461    218    28     3     3     0     1     1     0     12     0      0      0      0      0        2   
 3      5461    218    28     3     3     0     1     1     0     11     0      0      0      0      0        3   
 4      5461    218    28     3     3     0     1     1     0     11     0      0      0      0      0        4   
*/

 /*                                       Avoid _NAME_ and _2 _3 ... defaults  */  
 /*                                            __________________________      */
proc transpose data=singlelines out=transposed name=Counts prefix=Quarter;
  id quarter;
run;
/* 
Obs    Counts    Quarter1    Quarter2    Quarter3    Quarter4

  1     t1         11482       5461        5461        5461  
  2     t2           485        218         218         218  
  3     t3            81         28          28          28  
  4     t4             2          3           3           3  
  5     t5             7          3           3           3  
  6     t6             7          0           0           0  
  7     t7             1          1           1           1  
  8     t8             4          1           1           1  
  9     t9             1          0           0           0  
 10     t10           35         12          11          11  
 11     t11            2          0           0           0  
 12     t12            1          0           0           0  
 13     t13            0          0           0           0  
 14     t14            0          0           0           0  
 15     t15            2          0           0           0  
  */
 /* Required for the 'compute after' block to display a title > 8 chars. */
data transposed;
  length Counts $20;
  set transposed;
run;
proc print; run;

 /* This has nothing to do with proc transpose but it's a good demo. */
%let Q1RECCNT=100000;
%let Q2RECCNT=100000;
%let Q3RECCNT=100000;
%let Q4RECCNT=150000;
proc report data=transposed;
  /*                  doesn't yet exist...                                  */
  column Counts Quarter1 q1pct Quarter2 q2pct Quarter3 q3pct Quarter4 q4pct;
  /*                     ^^^^^          ^^^^^          ^^^^^          ^^^^^ */

  define Counts / group width=20 order=data 'Valid Records Only';
  define Quarter1 / spacing=1 center format=COMMA8. 'Q1';
  define Quarter2 / spacing=1 center format=COMMA8. 'Q2';
  define Quarter3 / spacing=1 center format=COMMA8. 'Q3';
  define Quarter4 / spacing=1 center format=COMMA8. 'Q4';
  define q1pct / spacing=1 computed center format=PERCENT8.1 'Race ÷ Q1 Recs';
  define q2pct / spacing=1 computed center format=PERCENT8.1 'Race ÷ Q2 Recs';
  define q3pct / spacing=1 computed center format=PERCENT8.1 'Race ÷ Q3 Recs';
  define q4pct / spacing=1 computed center format=PERCENT8.1 'Race ÷ Q4 Recs';

  rbreak before / SKIP UL;

  /* ...until now */
  compute q1pct;
    q1pct = _C2_/&Q1RECCNT;
  endcompute;
  compute q2pct;
    q2pct = _C4_/&Q2RECCNT;
  endcompute;
  compute q3pct;
    q3pct = _C6_/&Q3RECCNT;
  endcompute;
  compute q4pct;
    q4pct = _C8_/&Q4RECCNT;
  endcompute;

  rbreak after / SKIP OL SUMMARIZE;

  /* TODO not working */
  ***compute before;
    ***Counts = 'foo';
  ***endcomp;

  compute after;
    Counts = 'Total Y Checkboxes';
  endcomp;
run;



 /* Want two rows InputL2_BAT_NUM collapsed to one, by batch/mat */
 /*
                             Output_           InputL2_BAT_     InputL2_
   Obs    Output_MAT_COD     BAT_NUM            MOV_POST_DT      BAT_NUM

  1441    '10000000094124    '3ZP9171                     .               
  1442    '10000000094124    '3ZP9171                     .               
  1443    '10000000094124    '3ZP9171    22APR2013:00:00:00    'Z601964   
  1444    '10000000094124    '3ZP9171    22APR2013:00:00:00    '0000511583
 */
proc transpose data=t out=t2(drop=COL3-COL1182);
  by output_bat_num Output_MAT_COD inputl2_bat_mov_post_dt;
  var InputL2_BAT_NUM;
run;
 /*
        Output_                              InputL2_BAT_
 Obs    BAT_NUM     Output_MAT_COD            MOV_POST_DT        _NAME_           COL1         COL2

  68    '3ZP9171    '10000000094124                     .    InputL2_BAT_NUM                           
  69    '3ZP9171    '10000000094124    22APR2013:00:00:00    InputL2_BAT_NUM    'Z601964    '0000511583
  */


 /* Compare - use PO instead of date */
 /*
                           Output_       InputL1_            InputL2_BAT_     InputL2_
 Obs    Output_MAT_COD     BAT_NUM     PRCS_ORD_NUM           MOV_POST_DT      BAT_NUM

1453    '10000000094130    '3ZP9175                                     .               
1454    '10000000094130    '3ZP9175                                     .               
1455    '10000000094130    '3ZP9175    002001268403    29APR2013:00:00:00    '0000505132
1456    '10000000094130    '3ZP9175    002001268403    29APR2013:00:00:00    '0000505121
1457    '10000000094130    '3ZP9175    002001268403    29APR2013:00:00:00    '3ZM8939   
1458    '10000000094130    '3ZP9175                                     .               
...
1471    '10000000094130    '3ZP9175                                     .               
1484    '10000000094124    '3ZP9171    002001266870    22APR2013:00:00:00    'Z601964   
1485    '10000000094124    '3ZP9171    002001266870    22APR2013:00:00:00    '0000511583
1486    '10000000094124    '3ZP9171                                     .               
 */
proc transpose data=t out=t2(where=(inputl1_prcs_ord_num ne '' and _NAME_ ne '') drop=COL3-COL1182 rename=(COL1=FP_Micronised_Batch_Number COL2=SX_Micronised_Batch_Number inputl2_bat_mov_post_dt=BLENDLGRDate));
  by Output_BAT_NUM Output_MAT_COD inputl1_prcs_ord_num;
  var InputL2_BAT_NUM;
  copy inputl2_bat_mov_post_dt;
run;
proc print data=_LAST_(where=(Output_BAT_NUM in("'3ZP9175","'3ZP9171","'3ZM8939"))) width=minimum; run;
 /*
        Output_                          InputL1_                                               FP_Micronised_    SX_Micronised_
 Obs    BAT_NUM     Output_MAT_COD     PRCS_ORD_NUM       BLENDLGRDate           _NAME_          Batch_Number      Batch_Number

1209    '3ZP9171    '10000000094124    002001266870    22APR2013:00:00:00    InputL2_BAT_NUM     'Z601964          '0000511583  
1213    '3ZP9175    '10000000094130    002001268403    29APR2013:00:00:00    InputL2_BAT_NUM     '0000505132       '0000505121  
 */
