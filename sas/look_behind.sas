options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: look_behind.sas (see also look_ahead.sas) s/b symlinked as
  *           lag.sas
  *
  *  Summary: Demo of using lag to read previous values of a variable.
  *
  *           lag() maintains a stack of values. Each time the lag function is
  *           called, it returns the value off of the top of the stack, and
  *           puts the current value of the specified variable to the bottom
  *           of the stack. If the function is called in non-conditional code,
  *           it will have the result that it will always return the value of
  *           the variable from the previous row. But if it's used in
  *           conditional code, it won't put a value from every row onto the
  *           stack, hence some values will never be retrieved from the stack. 
  *
  *  Warning: consider this code:
  *
  * if x/2 eq int(x/2) then y=lag(x);
  *
  *  Looks simple: if x is an even number, put the preceding value of x into
  *  y.  But remember, it only returns what has previously been put into the
  *  stack.  And, values get put into the stack only when the function is
  *  called.  In this case, the function only gets called when x is an even
  *  number.  So, instead of getting the "last" value of x each time you call
  *  it, you get the last *even* value of x.
  *
  *  Adapted: Fri 15 Aug 2003 11:25:30 (Bob Heckel --
  *                             file:///C:/bookshelf_sas/lgref/z0212547.htm)
  * Modified: Thu 14 Jul 2016 13:38:24 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* Assumes sorted by region */
data x;
  set sashelp.shoes;
  switched=0;
  x=lag(region);
  if region ne x then switched=1;
run;
proc print data=_LAST_ width=minimum; run;
endsas;


 /* LAG1 returns one missing value and the values of X (lagged once). LAG2
  * returns two missing values and the values of X (lagged twice).
  */
data one;
  input foo @@;
  y=lag1(foo);
  z=lag2(foo);
  datalines;
1 2 3 4 5 6
  ;
run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;
