options nosource;
 /*---------------------------------------------------------------------
  *     Name: missing.sas (see missing_function.sas)
  *
  *  Summary: Demo of how SAS handles missing data.
  *
  *  Created: Tue 03 Jun 2003 09:07:15 (Bob Heckel)
  * Modified: Wed 22 Jun 2016 13:36:50 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options source;

proc sql;
  select count(case when pharmacypatientid eq '' then . else 1 end) as notfound,
         count(case when pharmacypatientid ne '' then . else 1 end) as found,
         count(case when pharmacypatientid ne '' then . else 1 end) / count(case when pharmacypatientid eq '' then . else 1 end) as pctnotfound
  from l.Publix_pharmacydata
quit;



data tmp;
  /* Missing can be indicated by any of these codes (optionally preceded by a
   * dot).  E.g. a indicates 'refused to answer'.  Case insensitive.
   */
  missing a B c;
  /* Suppress the intentional error (Errorline) in SAS Log. */
  ***input name $8.  Answer1  Answer2  Answer3 ??;
  input name $8.  Answer1  Answer2  Answer3;
  datalines;
Smith    . 5 9
Jones    4 b 8
Carter   .a 4 7
Reed     3 5 c
Deed      9 9 9
AllZ    . . . .
Errorline 2 5 d
  ;
run;
title 'a B c codes';
proc print; run;

title 'want specific type of missing (.a)';
proc print; 
  /* Won't work since there are no non-a missings for Answer1: */
  ***where Answer1 eq .;
  /* So use: */
/***  where Answer1 eq .a;***/  /* Answer1-3 are still numerics but this comparison works since .A is a kind of keyword */
  where Answer1 <= .a;  /* Answer1-3 are still numerics but this comparison works since .A is a kind of keyword */
run;

title 'is not missing';
proc print; 
  /* Won't work since there are no non-a missings for Answer1. */
  ***where Answer1 eq .;
  where Answer1 IS NOT MISSING;
run;


data t;
  set tmp;
  x = Answer1 + Answer2 + Answer3;        /* if ANY argument is missing, x = . */
  y = sum(Answer1, Answer2, Answer3);     /* y is sum of nonmissings */
  z = sum(Answer1, Answer2, Answer3, 0);  /* if a1,a2,a3 are missing, result will be zero */
  /* Same applies to calculations e.g. use mean() if you don't want propagation */
run;
title 'missing propagates'; proc print data=_LAST_(obs=max) width=minimum; run;

data t2;
  set tmp;
  Answer2=.;
  call missing(Answer1, Answer3);
run;
title 'force to missing'; proc print data=_LAST_(obs=max) width=minimum; run;
proc contents data=t;run;



data t;
  input test $ 1-8 sex $ 18 year 20-23 score 25-27;
  cards;
verbal           m 1967
verbal           f 1967
verbal           m 1970
verbal           f 1970 9
math             m 1967
math             f 1967
math             m 1970 80
math             f 1970
 ;
run;

options missing='x';
proc print data=_LAST_(obs=max); run;
proc contents; run;

proc freq;
  table score / missing;
run;

proc means n nmiss;
  var score;
run;

proc sql;
  select myall-notmis as mis
  from (select count(score) as notmis, count(*) as myall
        from t)
  ;
quit;

proc sql;
  select nmiss(score) as missingcnt, n(score) as notmissingcnt
  from t
  ;
quit;



data t;
  x=1; y='a'; output;
  x=2; y='b'; output;
  x=.; y=''; output;
  x=3; y='c'; output;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;

options missing='';  /* mandatory */
 /* Delete obs if everything is missing */
data t2;
  set t;
  if missing(cats(of _all_)) then delete;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;
