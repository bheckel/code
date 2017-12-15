options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: coalesce_fulljoin.sas
  *
  *  Summary: Demo of using coalesce and SQL instead of a merge or UNION 
  *           statement.
  *
  *           See more general example in sql_coalesce.sas
  *
  *           See also sql_union.sas
  *
  *           See also merge_rightmost_default.sas
  *
  *           See also fuzzy_within_5minutes.sas
  *
  *  Adapted: Fri 16 May 2003 09:02:10 (Bob Heckel -- SAS Certification
  *                                     questions support.sas.com)
  * Modified: Mon 05 Jun 2017 12:00:25 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data one;
  input num ch1 $;
  cards;
1 A
2 B
4 D
  ;
run;

data two;
  input num ch2 $;
  cards;
2 X
3 Y
5 V
  ;
run;


title 'merge';
data three;
  merge one two;
  by num;
run;
proc print NOobs; run;
/*
num    ch1    ch2

 1      A        
 2      B      X 
 3             Y 
 4      D        
 5             V 
*/


 /* same */
title 'coalesce full join';
proc sql;
  create table three as
  select coalesce(one.num, two.num) as num, ch1, ch2
  /* [INNER] JOIN won't work */
  /* from one JOIN two  ON one.num=two.num */
  from one FULL JOIN two  ON one.num=two.num
  ;
quit;
proc print NOobs; run;

/*
num    ch1    ch2

1      A        
2      B      X 
3             Y 
4      D        
5             V 
*/
