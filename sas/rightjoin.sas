options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: rightjoin.sas
  *
  *  Summary: Demo of a right join and comparison to SAS merge.
  *
  *  Created: Fri 10 Jul 2009 12:31:54 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /***************************************************/

title 'to this table...';
data budtbl;
  input year qtr budget;
  cards;
2001 3 500
2001 4 400
2002 1 700
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

title '...add SALES numbers';
data saltbl;
  input year qtr sales;
  cards;
2001 4 300
2002 1 600
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

 /***************************************************/

title 'useless SELECT * with RIGHT JOIN';
proc sql;
  select *
  from budtbl right join saltbl  ON budtbl.year=saltbl.year
  ;
quit;


title 'not what you want';
proc sql;
  select saltbl.*, budtbl.budget
  from budtbl right join saltbl  ON budtbl.year=saltbl.year
  ;
quit;

title 'not what you want - datastep alternative';
data;
  merge budtbl saltbl;
  by year;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


title 'what you want';
proc sql;
  select budtbl.*, sales
  from budtbl right join saltbl  ON budtbl.year=saltbl.year
  ;
quit;

 /* Would expect a NATURAL JOIN to not work but it does somehow */
title 'what you want - surprising datastep alternative';
data;
  merge saltbl budtbl;
  by year;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

title 'what you want - clearer (and expected) datastep alternative';
data;
  merge saltbl(in=ina) budtbl(in=inb);
  by year;
  if inb;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


title 'what you want - somewhat clearer LEFT JOIN alternative';
proc sql;
  select budtbl.*, saltbl.sales
  from saltbl left join budtbl  ON budtbl.year=saltbl.year
  ;
quit;


title "BUT all the above is academic-can't imagine a case where you would want to create a Q3 sales (300) that didn't exist";
proc sql;
  select saltbl.*, budtbl.budget
  from saltbl left join budtbl  ON saltbl.year=budtbl.year AND saltbl.qtr=budtbl.qtr
  ;
quit;
