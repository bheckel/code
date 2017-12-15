 /*----------------------------------------------------------------------------
  *     Name: merge.sas
  *
  *  Summary: Demo of merge statement.  Use PROC APPEND instead of merge if you
  *           DON'T want to discard identical records.
  *
  *           IMPORTANT:
  *           The MERGE statement has an implied RETAIN statement associated
  *           with it. This means when there is a match on a value of the BY
  *           variable(s), all values in the program data vector are RETAINED
  *           until they are overwritten by a new value.
  *
  *           Once all the observations for a particular BY-group have been
  *           processed (and a new group is coming up next as determined by
  *           SAS' magical "look ahead"), then, and only then, are all the
  *           variable values in the PDV re-initialized back to MISSING.
  *           See illustration below.
  *
  *           See also sql_union.sas, coalesce.sas (SQL's "merge")
  *
  *           If a merge fails to merge, check for FORMAT statements hiding
  *           the rightmost part of the BY value's string.
  *
  *           If get Log "INFO:...will be overwritten by data set..." try
  *           reducing the vars to the minimum number possible.
  *
  *           Caution: for identically named variables, SAS uses the descriptor
  *           info (length, etc.) and the data from the *first* ds if they are
  *           not the same for both ds.  So you'll need to use the RENAME= ds
  *           option if e.g.  mydatevar on 1st ds means 'DOB' and mydatevar on
  *           2nd ds means 'date of service'.
  *
  *
  *           The BY variables should form a primary key (identify down to the
  *           row level) in all, but at least one, of the incoming ds - if BY
  *           vars don't form a primary key, a one-to-one merge will take place
  *           within that BY group.
  *
  *
  *           For a given combination of BY variables if a corresponding
  *           observation does not exist within a data set, the variables
  *           contributed by that data set will be MISSING.
  *
  *           When two or more observations have the same combination of BY
  *           variables in one data set and there is only one matching
  *           observation in the other data set the row in that data set will
  *           be DUPLICATED.
  *
  *  Created: Mon Jun 21 1999 16:00:01 (Bob Heckel)
  * Modified: Mon 18 Nov 2013 10:09:03 (Bob Heckel)
  *----------------------------------------------------------------------------
  */

title 'Useful one-to-one merge';
data a (drop=i);
  do i=7 to 18;
    a = ranuni(i);
    output;
  end;
run;
data b (drop=i);
  do i=8 to 18;
    b = ranuni(i);
    output;
  end;
run;
data c (drop=i);
  do i=9 to 18;
    c = ranuni(i);
    output;
  end;
run;

data d;
  merge a b c;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

/***proc sgscatter data = d;***/
/***  plot a*b a*c / markerattrs = (size = 1);***/
/***run;***/



data workers;
  infile cards MISSOVER;
  input name $  occup $;
  cards;
Rearden architect
Taggart engineer
Galt builder
Toohey strawman
  ;
run;
proc sort data=workers; by name; run;
proc print; run;

data scores;
  infile cards;
  input name $  qtr1-qtr3;
  cards;
Rearden 10 11 12 13
Rearden 4 3 2 1
Rearden 20 25 25 21
Taggart . . 10 10
Taggart 5 5 8 2
Galt 10 20 30 40
  ;
run;
proc sort data=scores; by name; run;
proc print; run;


***options mergenoby=error;
/* Without a BY statement it doesn't appear to be of much value if there are
 * different number of obs on the 2 ds.  Effectively, the observation numbers
 * are used to do the matching.  "Blind merge".
 */
title 'Useless one-to-one merge';
data merged;
  /* If variables on the 2 tables have the same name, the one on the left is
   * used to determine length (if they differ).  Consider yourself warned.
   */
  merge workers scores;
run;
proc print; run;
***options mergenoby=nowarn;

 /* But semi useful if same num of obs */
data x;
  a=1; b=2; output;
  a=2; b=4; output;
  a=3; b=8; output;
run;
title '*************x'; proc print noobs; run;

data y;
  a=1; c=9; output;
  a=2; c=7; output;
  a=3; c=5; output;
run;
title '*************y'; proc print noobs; run;
data z;
  merge x y;
run;
title '*************semi-useful merge'; proc print noobs; run;
title '*************sql comparison';
proc sql;
  select x.a, x.b, y.c
  from x inner join y  on x.a=y.a
  ;
quit;



title 'Simple many-to-many match-merge';
 /* This works ok as long as there are not repeats of NAMEs in workers.  So
  * this isn't really many-to-many... If there are multiple, we will get SAS
  * NOTE: "MERGE statement has more than one data set with repeats of BY
  * values".  See many_to_many.sas
  */
data merged2;
  /* Info from workers is repeated WHERE NECESSARY to match up with scores */
  merge workers scores;
  /* A MERGE with a BY statement is called a match-merge. */
  by name;
run;
proc print; run;


title 'Simple match merge BY name (but switched the datasets):';
data merged3;
  /* Other direction.  Appears only to change sort order. occup comes last*/
  merge scores workers;
  by name;
run;
proc print; run;



 /********************/


title 'Bad';
/* Sum series of numbers for each obs (not total scores for the worker).   Not
 * very useful except to see what needs correction in the next datastep. 
 */
data merged4 (drop= qtr1-qtr3) NODUP;
  merge workers (keep=name) scores;
  by name;
  totl = sum(of qtr1-qtr3);
run;
proc print; run;

title 'Good';
title2 'Match-Merge workers against scores then sum SINGLE ENTRY per person';
/* Allows multiple rows full of multiple columnar data to be summed
 * under a single name from the first table to be merged.
 */
data merged5 (drop= qtr1-qtr3) NODUP;
  merge workers(keep=name)  scores(in=onscores);
  by name;
  if onscores;
  if first.name then 
    totl = 0;
  totl + sum(of qtr1-qtr3);
  if last.name;
run;
proc print data=merged5;
  ***format totl DOLLAR6.2;
  ***format totl BEST6.2;
  format totl COMMA6.2;
run;


 /********************/


 /* Merge if not missing on transaction ds */
data master;
  input item $ price;
  format price dollar5.2;
  datalines;
apple  1.99
apple  2.89
apple  1.49
grapes 1.69
grapes 2.46
mango .
orange 2.29
orange 1.89
orange 2.19
  ;
run;
title 'master';proc print data=_LAST_(obs=max) width=minimum; run;

data trans;
  input item $ price;
  format price dollar5.2;
  datalines;
banana 1.05
grapes 2.75
mango 1.12
orange 1.49
orange   .
orange 2.39
  ;
run;
title 'trans';proc print data=_LAST_(obs=max) width=minimum; run;

data combine(drop=newprice);
  merge master trans(rename=(price=newprice));
  by item;
  if newprice ne . then price=newprice;
  format price dollar5.2;
run;
title 'new prices after applying transaction dataset to master dataset';
proc print data=_LAST_(obs=max) width=minimum; run;



 /********************/


title 'merging data sets that contain duplicate observations for a BY-group in both data sets';
data d1;
  input id fruit $;
  cards;
1 apple
2 banana
2 lime
2 mango
  ;
run;
proc print data=_LAST_(obs=max) width=minimum NOobs; run;
data d2;
  input id color $;
  cards;
1 blue
1 green
2 purple
2 yellow
  ;
run;
proc print data=_LAST_(obs=max) width=minimum NOobs; run;

/*
Readin 1st obs from d1:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ID     |    Fruit     |   Color  |  ERROR ... N
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   1     |   apple      |          |
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Readin 1st obs of the same BY-group from d2:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ID     |    Fruit     |   Color  |  ...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   1     |   apple      |  blue    |
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OUTPUT


SAS does "look-ahead" for more obs in either ds for the same BY-group

There are none in d1 but there is another in d2.

So, somewhat surprisingly, RETAIN d1 vars and merge with 2nd obs in d2.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ID     |    Fruit     |   Color  |  ...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   1     |   apple      |  green   |
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OUTPUT


SAS does "look-ahead" for more obs in either ds for the same BY-group

There are no more obs for BY-group '1' in either ds.

So SAS resets PDV to MISSING.

Read 2nd BY-group, '2'.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ID     |    Fruit     |   Color  |  ...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   2     |   banana     |          |
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Read 1st obs of BY-group '2' from d2.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ID     |    Fruit     |   Color  |  ...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   2     |   banana     |  purple  |
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OUTPUT


SAS does "look-ahead" for more obs in either ds for the same BY-group.

There are more obs in BOTH d1 & d2 for BY-group 2.  Does NOT do a Cartesian!

So read next obs from d1

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ID     |    Fruit     |   Color  |  ...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   2     |   lime       |  purple  |
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Read next obs from d2

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ID     |    Fruit     |   Color  |  ...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   2     |   lime       |  yellow  |
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OUTPUT


SAS does "look-ahead" for more obs in either ds for the same BY-group.

Yes for d1, a '2-mango', no for d2

So RETAIN d2 vars and merge with 4th obs in d1, '2-mango'.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ID     |    Fruit     |   Color  |  ...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   2     |   mango      |  yellow  |
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OUTPUT                                                       
                                                             data d1;
                                                               input id fruit $;
No more obs to read from either ds.                            cards;
                                                             1 apple
So we're done:                                               2 banana
                                                             2 lime
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    2 mango
  ID     |    Fruit     |   Color  |  ...                      ;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    run;
   1     |   apple      |  blue    |                         
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    data d2;
   1     |   apple      |  green   |                           input id color $;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~      cards;
   2     |   banana     |  purple  |                         1 blue
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    1 green
   2     |   lime       |  yellow  |                         2 purple
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    2 yellow
   2     |   mango      |  yellow  |                           ;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    run;

 */
data m;
  put _ALL_;  /* print PDV to Log */
  merge d1 d2;
  by id;
  put _ALL_;  /* print PDV to Log */
  put;
run;
proc print data=_LAST_(obs=max) width=minimum NOobs; run;



endsas;
data work.budget;
  infile cards MISSOVER;
  input name $  lineitem $  budget;
  /* Must be in order by name and lineitem. */
  cards;
Balk food 300
Balk travel 400
Haan ammunition 250
Haan food 400
Haan hotel 850
Potter food 350
  ;
run;

data work.actuals;
  infile cards missover;
  input name $  lineitem $  actual;
  cards;
Haan food 200
Haan food 150
Potter food 350
Potter booze 1000
Balk travel 200
Balk travel 100
Balk travel 101
  ;
run;

proc sort data=work.actuals out=work.actuals2;
  by name lineitem;
run;

data work.compared(drop= actual) work.notbudgeted(keep= name lineitem actual);
  merge work.budget(in= inbud) work.actuals2(in= inact);
  by name lineitem;    /* <------ TWO BY varis */
  /* If expense is not budgeted, add obs to new ds. */
  if inact and not inbud then output work.notbudgeted;
  else
    do;
      if first.lineitem then expend=0;
      expend + actual;
      if last.lineitem;
      remain = budget - expend;
      output work.compared;
    end;
run;

title 'NON-BUDGETED EXPENSES!';
proc print data=work.notbudgeted;
run;

title 'Comparison -- actuals to budget';
proc print data=work.compared;
run;

title 'Actuals to budget status summary report';
proc print data=work.compared;
  format budget expend remain DOLLAR6.;
  by name;
  /* Improve formatting by using the id statement. */
  id name;
  sum budget expend remain;
run;
