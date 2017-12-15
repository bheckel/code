options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: where.sas
  *
  *  Summary: Demo of multiple uses of WHERE statement.  WHERE is more
  *           efficient -- it subsets the data *before* entering it into
  *           the PDV.  IF subsets the data *after* inputting the entire
  *           dataset.
  *
  *           The thrust of a "where-expression" is to create a binary result.
  *
  *           Using 2 WHERE statements in a step or proc causes the 1st to be
  *           ignored by SAS.
  *
  *           Canonical:   ... set myds(where=(myvar like 'AS_CI%')); ...
  *
  *  Created: Wed 11 Jun 2003 09:05:38 (Bob Heckel)
  * Modified: Thu 20 Nov 2008 09:41:17 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data sample;
  input density  crimerate  state $ 14-27  stabbrev $ 29-30;
  /* Won't work here. */
  ***where stabbrev eq 'NC';
  cards;
264.3 3163.2 Pennsylvania   PA
51.2 4615.8  Minnesota      MN
55.2 4271.2  Vermont        VT
9.1 .        South Dakota   SD
9.4 2833.0   North Dakota   ND
102.4 3371.7 North Carolina   
120.4 4649.9 North Carolina NC
  ;
run;

title 'All 3 methods are the same:';

title2 'In the data step:';
data sample2;
  set sample;
  where stabbrev eq 'NC';
run;
proc print; run;

title2 'As a procedure statement:';
proc print data=sample;
  where stabbrev eq 'NC';
run;

title2 'As dataset option:';
***proc print data=sample (where=(stabbrev eq 'NC'));
proc print data=sample (where=(stabbrev in ('NC','MN')));
 /* Negation */
***proc print data=sample (where=(NOT(stabbrev in ('NC','MN'))));
run;

title 'Using all WHERE statement "operators"';
proc print data=sample;
  /* Can use NOT with any of these: */
  where state contains 'ot' and          /* could use '?' instead */
        crimerate is not missing and
        state like '%th%' and
        state =* 'north dakoter' and     /* soundex */
        density between 1 and 1000
        ;
run;
title;


title 'set sample(where=(crimerate and stabbrev))';
data notmissing;
  ***if crimerate and stabbrev;
  /* Same */
  ***set sample(where=(crimerate^=. and stabbrev^=''));
  set sample(where=(crimerate and stabbrev));
run;
proc print; run;


title 'set sample(where=(density gt 2 and crimerate lt 4000))';
data anded;
  set sample(where=(density gt 2 and crimerate lt 4000));
run;
proc print; run;
