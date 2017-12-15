 /*----------------------------------------------------------------------------
  *   Name: sql_union.sas
  *
  * Summary: Demo of SQL union join.  And replicate/compare with SAS' merge.
  *
  *  Adapted: Mon 04 Mar 2013 15:47:32 (Bob Heckel--SESUG 2012 HW-06.pdf)
  * Modified: Mon 19 Dec 2016 15:29:50 (Bob Heckel)
  *----------------------------------------------------------------------------
  */
options linesize=100 pagesize=32767;

 /* UNION match by column POSITION
  * UNION CORRESPONDING match by column NAME (safer)
  *
  * using ALL in either causes dups to not be dropped (rare since the dup
  * records are then ambiguous but sometimes useful for stacking datasets like
  * SAS' SET t1 t2)
  */

data existing;
  input gender $ name $ dob;
  cards;
F Ostermeir 1000
M Brown 1001
F Stern 5000
M Friedman 5001 
  ;
run;

data new;
  input dob gender $ name $;
  cards;
5002 M Chien
1001 M Brown
  ;
run;

data both;
  set existing new;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;

proc sql;
  create table both2 as
  select * from existing
  UNION ALL CORRESPONDING
  select * from new
  ;
quit;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;

 /* Won't work due to data types, but would have silently, and probably wrongly,
  * worked if the data types were the same on both tables
  */
 /*
ERROR: Column 1 from the first contributor of UNION is not the same type as its counterpart from 
       the second.
ERROR: Column 3 from the first contributor of UNION is not the same type as its counterpart from 
       the second.
  */
proc sql;
  create table both3 as
  select * from existing
  UNION ALL
  select * from new
  ;
quit;


endsas;
 /*************************************************/
data t1;
  input x y;
  cards;
1    11
2    22
3    33
4    44
;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
data t2;
  input  x z;
  cards;
1    111
2    222
5    555
6    666
;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
 /*************************************************/

 /*******************MERGE*************************/
title 'merge';
 /*
                             Obs    x     y     z

                              1     1    11    111
                              2     2    22    222
                              3     3    33      .
                              4     4    44      .
                              5     5     .    555
                              6     6     .    666
  */
data foo;
  merge t1 t2;
  by x;
run;
proc print data=_LAST_(obs=max); run;


title 'IN1 OR IN2 merge (same)';
 /*
                             Obs    x     y     z

                              1     1    11    111
                              2     2    22    222
                              3     3    33      .
                              4     4    44      .
                              5     5     .    555
                              6     6     .    666
  */
data foo;
  merge t1(in=in1) t2(in=in2);
  by x;
  if (in1=1 or in2=1);
run;
proc print data=_LAST_(obs=max); run;


title 'LEFT & RIGHT JOINs with UNION to replicate merge';
 /*
                                 x         y         z
                                 1        11       111
                                 2        22       222
                                 3        33         .
                                 4        44         .
                                 5         .       555
                                 6         .       666
  */
 /* Same - but not possible to just do normal SQL joins to replicate (see below). */
proc sql;
  select t1.x, t1.y, t2.z
  from t1 LEFT JOIN t2 ON t1.x=t2.x

  /* The UNION set operator concatenates the query results that are produced
   * by the two SELECT clauses.
   *
   * CORRESPONDING (CORR) overlays columns that have the same name in both
   * tables. When used with EXCEPT, INTERSECT, and UNION, CORR suppresses
   * columns that are not in both tables.
   */
  UNION CORRESPONDING

  select t2.x, t1.y, t2.z
  from t1 RIGHT JOIN t2 ON t1.x=t2.x
  ;
quit;


title 'FULL JOIN with COALESCE ("new" ANSI style syntax) to replicate SAS merge';
 /*
                                 x         y         z
                                 1        11       111
                                 2        22       222
                                 3        33         .
                                 4        44         .
                                 5         .       555
                                 6         .       666
  */
proc sql;
  select coalesce(t1.x, t2.x) as x, y, z
  /* Must be FULL */
  from t1 FULL JOIN t2 ON t1.x=t2.x
  ;
quit;
 /*************************************************/



 /******************INNER JOIN*********************/
title 'Not same as above (comparison only)';
title2 'INNER JOIN';
 /*
                                 x         y         z
                                 1        11       111
                                 2        22       222
  */
proc sql;
  select t1.x, t1.y, t2.z
  from t1 INNER JOIN t2  ON t1.x=t2.x
  ;
quit;

title 'same';
title2 'WHERE';
 /*
                                 x         y         z
                                 1        11       111
                                 2        22       222
  */
proc sql;
  select t1.x, t1.y, t2.z
  from t1, t2 
  where t1.x=t2.x
  ;
quit;

title 'same';
title2 'IN1 AND IN2 merge';
 /*
                             Obs    x     y     z

                              1     1    11    111
                              2     2    22    222
  */
data foo;
  merge t1(in=in1) t2(in=in2);
  by x;
  if (in1=1 and in2=1);
run;
proc print data=_LAST_(obs=max); run;
 /*************************************************/
