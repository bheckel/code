options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: coalesce.sum.sql.sas
  *
  *  Summary: Sum numbers from all rows even if row only exists on one table.
  *           For this example, two 6 obs ds (each having one record the other
  *           doesn't have) produce a 7 obs result ds.
  *
  *  Created: Fri 21 Jan 2005 17:29:21 (Bob Heckel)
  * Modified: Mon 17 Apr 2006 10:44:04 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data one;
  input x $ y z $;
  cards;
1.0000     10001       a
2.0000     20002       b
3.0000     30003       c
4.0000     40004       d
5.0000     50005       e
7.0000     70007       g
  ;
run;
proc print data=_LAST_(obs=max) noobs; run;

data two;
  input x $ y z $;
  cards;
1.0000     1       a
2.0000     2       b
3.0000     3       c
4.0000     4       d
5.0000     5       e
6.0000     6       f
  ;
run;
proc print data=_LAST_(obs=max) noobs; run;


proc sql;
  select coalesce(A.x, B.x) as coalXs, 
         sum(A.y,B.y) as sumYs,
         coalesce(A.z, B.z) as coalZs
  from one as A FULL JOIN two as B  on A.x=B.x and A.z=B.z
  ;
quit;

title 'wrong, needs FULL JOIN';
proc sql;
  select coalesce(A.x, B.x) as coalXs, 
         sum(A.y,B.y) as sumYs,
         coalesce(A.z, B.z) as coalZs
  from one as A INNER JOIN two as B  on A.x=B.x and A.z=B.z
  ;
quit;
