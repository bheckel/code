options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sql_set_operations.sas
  *
  *  Summary: Whereas join operations combine tables horizontally, set
  *           operations combine tables vertically, returning whole rows.
  *
  *           See http://support.sas.com/documentation/cdl/en/sqlproc/62086/HTML/default/viewer.htm#a001361224.htm
  *
  *  Created: Wed 08 May 2013 13:49:19 (Bob Heckel)
  * Modified: Mon 09 Dec 2013 14:08:03 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data a;
  input x y $;
  cards;
1 one
2 two
2 two
3 three
  ;
run;
/***proc print data=_LAST_(obs=max) width=minimum; run;***/

data b;
  input x z $;
  cards;
1 one
2 two
4 four
  ;
run;
/***proc print data=_LAST_(obs=max) width=minimum; run;***/

 /*****************UNIQUE ROWS**************************/
title 'UNION ALL - not unique seems useless';
proc sql;
  select * from a
  UNION ALL
  select * from b
  ;
quit;

title 'UNION w/o ALL does what you mean but is less efficient';
proc sql;
  /* Uses the var names from the first dataset (x & y here) */
  select * from a
  UNION
  select * from b
  ;
quit;
 /*************************************************/

 /*****************STACK ROWS***************************/
title 'OUTER UNION seems useless';
proc sql;
  select * from a
  OUTER UNION
  select * from b
  ;
quit;

title 'OUTER UNION CORRESPONDING - CORR suppresses vars not in both';
proc sql;
  select * from a
  OUTER UNION CORR
  select * from b
  ;
quit;

title 'same';data t; set a b; run; proc print data=_LAST_(obs=max) width=minimum; run;
 /*************************************************/

 /******************ROWS IN BOTH***********************/
title 'INTERSECT';
proc sql;
  select * from a
  INTERSECT
  select * from b
  ;
quit;
 /************************************************/

 /***************ROWS NOT IN BOTH***********************/
title 'EXCLUSIVE UNION - same as bare UNION here - seems useless';
proc sql;
  select * from a
  EXCLUSIVE UNION
  select * from b
  ;
quit;

title 'EXCEPT UNION - returns the rows from the first table not in the second table';
proc sql;
  select * from a
  EXCEPT
  select * from b
  ;
quit;
 /* There doesn't seem to be a way to proc sql CREATE TABLE AS... so might need
  * this if you need dataset output.
  */
title 'Compare SAS approach - returns the rows from the first table not in the second table';
data t;
  merge a(in=ina) b(in=inb);
  by x;  /* downside: sorting is required */
  if ina and not inb;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

 /* Probably not as useful as previous since you don't know where the differences are */
title 'EXCLUSIVE UNIONs - returns the rows from either table that are not in the other table';
proc sql;
  (select * from a
  EXCEPT
  select * from b)
  UNION
  (select * from b
  EXCEPT
  select * from a)
  ;
quit;

 /*************************************************/
