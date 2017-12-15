options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: merge_rightmost_default.sas
  *
  *  Summary: SAS uses the rightmost dataset in case of conflict
  *
  *  Adapted: Thu 09 Mar 2006 10:40:42 (Bob Heckel --
  *                              http://www.pharmasug.org/2005/TT14.pdf)
  * Modified: Fri 10 Jul 2009 10:39:36 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data fooA;
  infile cards;
  input pairno food $ animal $;
  cards;
 1      apple    aardvark
 2      avocado anteater
 ;
run;
proc print data=_LAST_(obs=max); run;

data fooB;
  infile cards;
  input pairno food $ town $;
  cards;
 1      banana    BocaRaton
 2      beans    Boston
 3      burrito    Barcelona
 ;
run;
proc print data=_LAST_(obs=max); run;


title '============='
      'ds AB by pairno - food from a is SILENTLY! overwritten by RIGHTMOST data set';
data ab;
  merge fooA fooB;
  by pairno;  /* there will be a conflict b/c FOOD is not in this by line */
run;
proc print data=_LAST_(obs=max); run;


 /* Winner, and no sorting or renaming required */
title 'SQL for comparison: food from a is overwritten by LEFTMOST! dataset (and we get a warning message)'
      '============';
proc sql;
  create table absql as
  /* TODO do i ever need coalesce if there's only 1 by var?? */
  select *
  from fooA a FULL JOIN fooB b ON a.pairno=b.pairno
  ;
quit;
proc print data=_LAST_(obs=max) width=minimum; run;



 /* Winner if not using '*' in the SQL SELECT */
title 'ds AB by pairno,food - but no foods match so multiple observations of pairno '
      'are created';
data ab;
  merge fooA fooB;
  by pairno food;
run;
proc print data=_LAST_(obs=max); run;

title 'SQL for comparison.  SAS merge is better in this case.';
proc sql;
  create table absql as
  /* Emulate a SAS merge */
  /*                                                           if use * here it gets messy */
  select coalesce(a.pairno,b.pairno), coalesce(a.food,b.food), animal, town
  from fooA a FULL JOIN fooB b ON a.pairno=b.pairno AND
                                  a.food=b.food
  ;
quit;
proc print data=_LAST_(obs=max) width=minimum; run;
