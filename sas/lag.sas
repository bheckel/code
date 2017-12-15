options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: lag.sas lag2, lag3...
  *
  *  Summary: Look behind you.
  *
  *           Be careful if you execute a LAG function conditionally.
  *
  *  Created: Thu 10 Sep 2009 12:20:18 (Bob Heckel -- SUGI 354-2009)
  * Modified: Mon 19 Dec 2016 11:27:15 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* Simple */

data one;
  input foo;
  cards;
1
2
3
3
4
3
4
4
  ;
run;

 /* Eliminate (consecutive only) duplicates without proc sort */
data two;
  set one;
  prev=lag(foo);
  put '!!!' _all_;
  if lag(foo) eq foo then put 'dup!' _all_;
  /* Write if previous value of foo was the same as current value */
  if lag(foo) eq foo then output;
run;



 /* Complex */
data sales;
  input company $ month_end :mmddyy8. sales;
  format month_end mmddyy10.;
  datalines;
abc 01312008 10000
abc 02282008 25000
abc 05312008 15000
abc 10312008 12000
abc 12312008 20500
xyz 02282008 30000
xyz 03312008 10000
xyz 07312008 12500
xyz 10312008 15000
xyz 11302008 20000
xyz 12312008 11000
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

data totals(drop= lookbehind lookahead);
  set sales;
  by company;

  lookbehind=lag(sales);

  if not first.company then do;
    last_mo=lookbehind;
  end;

  if not last.company then do;
    next=_N_+1;
    set sales(keep=sales rename=(sales=lookahead)) point=next;
    next_mo=lookahead;
  end;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
/*
Obs    company    month_end     sales    last_mo    next_mo

  1      abc      01/31/2008    10000         .      25000 
  2      abc      02/28/2008    25000     10000      15000 
  3      abc      05/31/2008    15000     25000      12000 
  4      abc      10/31/2008    12000     15000      20500 
  5      abc      12/31/2008    20500     12000          . 
  6      xyz      02/28/2008    30000         .      10000 
  7      xyz      03/31/2008    10000     30000      12500 
  8      xyz      07/31/2008    12500     10000      15000 
  9      xyz      10/31/2008    15000     12500      20000 
 10      xyz      11/30/2008    20000     15000      11000 
 11      xyz      12/31/2008    11000     20000          . 
*/ 
                                                                                                                                                                                                                                                                
 
 /* Long to wide */
data totals(keep=company months:);
  set sales;
  by company;
/***  array months[12] months1-months12;***/
  /* same, obfuscated but works because the subscript is not a '*' */
  array months[12];
  retain months:;
  monnum=month(month_end);
  if first.company then do;
  /* V9 */
  ***  call missing(of months(*));
    /* V8 */
    do i=1 to dim(months);
      months[i]=.;
    end;
  end;
  months[monnum]=sales;
  if last.company then output;
run;
 /*
Obs    company    months1    months2    months3    months4    months5    months6    months7    months8    months9    months10    months11    months12

 1       abc       10000      25000          .        .        15000        .            .        .          .         12000           .       20500 
 2       xyz           .      30000      10000        .            .        .        12500        .          .         15000       20000       11000 
 */
proc print data=_LAST_(obs=max) width=minimum; run;


 /* The correct definition of the LAG function is that it returns the value of its argument the last time the LAG function executed */
data laggard;
  input x @@;
  if X ge 5 then Last_x = lag(x);
  datalines;
9 8 7 1 2 12
  ;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;



 /* Also see dif() */
data diff;
  input Time Temperature;
  Diff_temp = Temperature - lag(Temperature);
  Diff_temp2 = dif(Temperature);
  datalines;
1 60
2 62
3 65
4 70
  ;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;
