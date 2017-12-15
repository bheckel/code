options nosource;
 /*---------------------------------------------------------------------------
  *     Name: proc_summary.sas
  *
  *  Summary: Demo of proc summary, mostly same as proc means but less
  *           verbose (and SAS' online help doesn't give much info for SUMMARY,
  *           so see MEANS).  proc summary dumps into WORK.DATA1 by default.
  *
  *           See also proc_means.sas
  *
  * E.g.
  * _TYPE_ = 0  is the grand analysis without regard to the values of the
  *             classification variables.  
  *
  * _TYPE_ = 1  gives the analysis by RATE_SCHEDULE without regard to REGION
  *
  * _TYPE_ = 2  gives the analysis by REGION without regard to RATE_SCHEDULE
  *
  * _TYPE_ = 3  is the analyses at all possible combinations of the values of
  *             both REGION and RATE_SCHEDULE.
  * 
  * With just one classification variable you will have two values of _TYPE_
  * (zero and one). When you have two classification variables you get four
  * values, and with three you will have eight values. By now you've probably
  * figured out that the number of values of _TYPE_ in your output data set is
  * equal to 2N, where N is the number of classification variables.
  *
  * Use NWAY=3 to just see _TYPE_ eq 3 in the output ds
  *
  *
  *  Adapted: Tue 29 Oct 2002 15:43:03 (Bob Heckel--Rick Aster SAS Programming
  *                                     Shortcuts)
  * Modified: Mon 07 Jan 2013 14:25:52 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

proc sort data=SASHELP.class out=c; by sex age; run;
proc print data=c; run;
 /*        display binary for _TYPE_        */
 /*                 ________                */
proc summary data=c CHARTYPE COMPLETETYPES;
  /* Categorical, discrete */
  class sex age;
  /* Analysis, continuous */
  var height;
  output out=t mean=hgt_mean / WAYS LEVELS;
run;
proc sort data=t; by _TYPE_; run;
proc print data=_LAST_(obs=max) width=minimum; run;



%macro bobh0701130051; /* {{{ */
data temperatures;
  input temper days place $;
  datalines;
20  14 abc
30   3 ABD
35   3 ABD
.     16 xxx
12.5        1 abc
40  8 abc
50 10 abc
47.0 6 ABD
  ;
run;
proc print data=_LAST_(obs=max); run;

 /* Temperature numcalc by place (VAR by CLASS) */
proc summary data=temperatures NWAY;
  /* Analysis, continuous, variable(s).  Numerics. */
  var temper;
  /* Classification, categorical, discrete, variable(s).  Non-numerics. */
  class place;
  /* TODO how to avoid temp ds? */
  output out=t N=aN mean=bMean std=cStd median=dMedian min=eMin max=fMax;
run;
proc print data=_LAST_(obs=max); run;

endsas;
                                                                   d
Obs    place    _TYPE_    _FREQ_    aN     bMean       cStd     Median    eMin    fMax

 1      ABD        1         3       3    37.3333     8.7369      35      30.0     47 
 2      abc        1         4       4    30.6250    17.3656      30      12.5     50 
 3      xxx        1         1       0      .          .           .        .       . 
%mend bobh0701130051; /* }}} */



%macro bobh0701135856; /* {{{ */
data work.temperatures;
  input t days foo $;
  datalines;
20  14 abc
30   3 abd
35   3 abd
.     16 abe
12.5        1 abc
40  8 abc
50 10 abc
47.0 6 abd
  ;
run;
proc print data=_LAST_(obs=max); run;

proc summary data=temperatures;
  var t days;
  output out=tempout
  /* Reverse assignment */
  /* ---->              */
  N(t)=ttot
  SUM(t)=tsum
  ;
run;
proc print data=tempout(obs=max); run;

 /* Results differ when printed vs. sent to new dataset */

title 'to a new dataset';
proc summary data=temperatures;
  var t days;
  output out=tempout;
run;
proc print data=tempout(obs=max); run;


title 'print (with class)';
proc summary data=temperatures PRINT;
  class foo;
  var days;
run;

proc summary data=temperatures N MEAN MAXDEC=0 PRINT;
  /* Analysis, continuous, variable(s).  Numerics. */
  var t;
  /* Classification, categorical, discrete, variable(s) */
  class foo;
  label foo = 'my foo';
  ***output out=tmpds MEAN(t)=themean;
  /* same */
  output out=tmpds MEAN=themean;
run;
proc print data=_LAST_(obs=max); run;


/***proc format;***/
/***  value f_freez   LOW-32 = 'Freezing'***/
/***                32<-HIGH = 'Above Freezing';***/
/***run;***/


proc sort data=temperatures; by foo; run;
 /* _TYPE_ 0 refers to all data, can be suppressed with NWAY on data stmt. */
title 'primitive frequency table';
***proc summary data=work.temperatures PRINT MEAN MIN MAX NWAY MISSING;
proc summary data=temperatures PRINT MISSING NWAY;
  by foo;
  class t;
  /* TODO how to format the Means, etc. that are output?  For now just use
   * proc sql, see minmax_date.sas 
   */
/***  format t f_freez.;***/
  ***var days;
run;

%mend bobh0701135856; /* }}} */



endsas;
proc summary data=sashelp.shoes;
  by region;
  output out=sumout
  min(sales)=mymin
  max(sales)=mymax
  std(sales)=mystandarddeviation
  sum(sales)=mytotal
  ;
run;
proc print data=_LAST_(obs=max); run;
/***proc print data=sashelp.shoes(obs=max); where region='Asia'; run;***/


endsas;
libname k 'X:\SQL_Loader\SiteWide';

proc summary data=k.sumlotronex01a_2005 MEAN PRINT;
  where samp_id=163814 and specname='AM0823ASSAYCUHPLC' and 
        varname='RSDSAMPLES';
  var resnumval;
  class samp_id;
run;

