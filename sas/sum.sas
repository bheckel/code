options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sum.sas
  *
  *  Summary: sum() function and the sum accumulator improve on SAS' 
  *           "missing propagates" default/feature/problem.
  *
  *  Created: Tue 03 Jun 2003 09:05:01 (Bob Heckel)
  * Modified: Fri 11 May 2012 14:35:08 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data t1;
  a=.; b=5; output;
  /* Missings propagate using simple addition (probably not what you want)... */
  c = a+b;
  put c=;
  if c gt 4 then 
    put "TRUE";
  else 
    put "FALSE";  /* <---prints */
run;
proc print; run;


data t2;
  a=.; b=5; output;
  /* ...but not using the function. */
  c=sum(a, b);
  put c=;
  if c gt 4 then 
    put "TRUE";     /* <---prints */
  else 
    put "FALSE";
run;
proc print; run;


data t3;
  a=.; b=5; output;
  a+b;
  /* ...nor when using the accumulator sum statement (i.e. a = a+b). */
  put a=;
  if a gt 4 then 
    put "TRUE";    /* <---prints */
  else 
    put "FALSE";
run;
proc print; run;


data t4;
  x1=.; x2=2; x3=.;
  /* Sum a range */
  tot=sum(x1--x3);  /* wrong - gets 1st & last only */
  totright=sum(of x1--x3);
run;
title 'must use OF with the range operator';proc print; run;
