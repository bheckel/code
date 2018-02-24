 /*----------------------------------------------------------------------------
  *     Name: sql_vs_merge.sas
  *
  *  Summary: Compare a many-to-many merge with proc sql.  See also sql_union.sas
  *
  *           Match-merging produces the same results in sql or sas
  *
  *           Merge - must sort first, need common variable, duplicate matching
  *           column is automatically overlaid, cartesian is difficult
  *
  *           SQL - duplicate matching column is not automatically overlaid
  *
  *  Created: Wed, 03 Nov 1999 12:14:11 (Bob Heckel)
  * Modified: Mon 22 Jan 2018 15:37:57 (Bob Heckel)
  *----------------------------------------------------------------------------
  */
options linesize=80 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=5 nostimer nonumber serror merror
        noreplace;

/******** Example 1 (http://www.lexjansen.com/pharmasug/2008/cc/cc07.pdf) ****************/

data A;
  x=1; y=10; output;
  x=1; y=15; output;
  x=1; y=18; output;
  x=3; y=20; output;
run;
data B;
  x=1; z=15; output;
  x=1; z=12; output;
  x=3; z=30; output;
run;
proc sort data=a; by x; run;
proc sort data=b; by x; run;
data c1;
  merge a(in=aa) b(in=bb);
  by x;
  /* neither matters */
  /* if aa; */
  /* if aa and bb; */
run; 
/* proc print data=_LAST_(obs=max) width=minimum; run; */
/*
Obs    x     y     z

 1     1    10    15
 2     1    15    12
 3     1    18    12
 4     3    20    30
*/ 

 /* Probably closer to what you meant: */
proc sql;
  create table c2 as
  select a.x, a.y, b.z
  from a, b
  where a.x=b.x;
quit; 
/* proc print data=_LAST_(obs=max) width=minimum; run; */
/*
Obs    x     y     z

 1     1    10    15
 2     1    15    15
 3     1    18    15
 4     1    10    12
 5     1    15    12
 6     1    18    12
 7     3    20    30
*/



/******** Example 2 ****************/


 /**********************************************/
 /* Lookup table has no duplicate acct numbers */
data one;
  input acct $  rate;
  cards;
A 1
B 5
C 8
;
run;
/* title 'original one'; proc print data=_LAST_(obs=max); run; */

 /* Data table has duplicate account numbers */
data two;
  input acct $  balance;
  cards;
A 10
A 20
A 30
D 40
;
run;
/* title 'original two'; proc print data=_LAST_(obs=max); run; */
 /*                                            */
 /**********************************************/


/************/
/*** NORMAL SAS - MERGE ***/
title;data _null_;file PRINT;
put '************* match merge / coalesce full join ************';run;
 /* "sort-sort-merge" */
proc sort data=one; by acct; run;
proc sort data=two; by acct; run;
data work.both1;
  merge one two;
  by acct;
run;
/* proc print data=_LAST_(obs=max) noobs; run; */
/*
                            acct    rate    balance

                             A        1        10  
                             A        1        20  
                             A        1        30  
                             B        5         .  
                             C        8         .  
                             D        .        40  
*/

data work.both1;
  merge one(in=ina) two(in=inb);
  by acct;
  if ina or inb;
run;
/* title 'same';proc print data=_LAST_(obs=max) noobs; run; */
/*
                                      same

                            acct    rate    balance

                             A        1        10  
                             A        1        20  
                             A        1        30  
                             B        5         .  
                             C        8         .  
                             D        .        40  
*/

proc sql noprint;
  select coalesce(one.acct, two.acct) as a, rate, balance
  /* [INNER] JOIN won't work */
  from one FULL JOIN two  ON one.acct=two.acct
  ;
quit;
title;
/*
                                      same

                          a             rate   balance
                          ----------------------------
                          A                1        10
                          A                1        20
                          A                1        30
                          B                5         .
                          C                8         .
                          D                .        40
*/
/************/


/************/
/*** NORMAL SQL - JOIN ***/
title;data _null_;file PRINT;
put '************* match merge / inner join ************';run;
 /* "sort-sort-merge" */
proc sort data=one; by acct; run;
proc sort data=two; by acct; run;
data work.both1;
  merge one(in=ina) two(in=inb);
  by acct;
  if ina & inb;
run;
/* proc print data=_LAST_(obs=max) noobs; run; */

title 'same';
proc sql noprint;
  select a.acct, a.rate, b.balance
  from one a JOIN two b  ON one.acct=two.acct
  ;
quit;
title;
/*
                            acct    rate    balance

                             A        1        10  
                             A        1        20  
                             A        1        30  
                                      same

                          acct          rate   balance
                          ----------------------------
                          A                1        10
                          A                1        20
                          A                1        30
*/
/************/


/************/
title;data _null_;file PRINT;
put '************* match merge if onone / left join ************';run;
proc sort data=one; by acct; run;
proc sort data=two; by acct; run;
data work.both1;
  merge one(in=onone) two(in=ontwo);
  by acct;
  if onone;
run;
proc print data=_LAST_(obs=max) noobs; run;

proc sql;
  select a.acct, a.rate, b.balance
  from work.one as a LEFT JOIN work.two as b  ON a.acct=b.acct;
quit;
/************/


/************/
title;data _null_;file PRINT;
put '************* match merge if onone and not ontwo / where only onone ************';run;
proc sort data=one; by acct; run;
proc sort data=two; by acct; run;
data work.both1;
  merge one(in=onone) two(in=ontwo);
  by acct;
  if onone and not ontwo;
run;
proc print data=_LAST_(obs=max) noobs; run;

title 'same';
proc sql;
  select a.acct, a.rate
  from one a
  where not (a.acct in(select acct from two))
  ;
quit;
 /* or better */
title 'same';
proc sql;
  select a.acct, a.rate
  from one a LEFT JOIN two b  ON a.acct=b.acct
  where b.acct is null
  ;
quit;
/************/
