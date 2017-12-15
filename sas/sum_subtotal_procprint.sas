options nosource;
  /****************************************************************/
  /*          SAS Sample Library                                  */
  /*                                                              */
  /*    Name: prtbook                                             */
  /*   Title: sas procedures guide examples for print             */
  /* Product: sas                                                 */
  /*  System: all                                                 */
  /*    Keys: sum, total, group by                                */
  /*   Procs: print                                               */
  /*    Data: --                                                  */
  /*                                                              */
  /*     Ref: sas procedures guide, version 6 edition (1985)      */
  /* Adapted: Wed May 28 10:07:29 2003 (Bob Heckel)               */
  /****************************************************************/
options source;

data a;
  input x y z @@;
  cards;
1 1 1 1 1 2 2 1 1 2 1 2 3 1 1 3 3 1 3 3 2 3 4 1
  ;
run;
proc print; run;

title 'Print with sums and subtotals for each by-group';
proc print;
  title2 'according to variable x by-groups';
  by x;
  sum z;
run;

proc print;
  title2 'according to variable x and y by-groups';
  by x y;
  sum z;
run;



title '~~~~~~~~~~~~~new demo starts~~~~~~~~~~~~~';
data branch;
  input region $ state $ month monyy5. headcnt expenses revenue;
  format month monyy5.;
  cards;
eastern  va feb78  10  7800 15500
southern fl mar78   9  9800 13500
southern ga jan78   5  2000  8000
northern ma mar78   3  1500  1000
southern fl feb78  10  8500 11000
northern ny mar78   5  6000  5000
eastern  va mar78  11  8200 16600
plains   nm mar78   2  1350   500
southern fl jan78  10  8000 10000
northern ny feb78   4  3000  4000
southern ga feb78   7  1200  6000
  ;
run;
proc print;
run;
proc sort;
  by region state month;
run;

proc print split='*';
  title '~~~revenue and expense totals (grouped by region and state)';
  label region='sales region'
        headcnt='sales*personnel';
  by region state;
  sum revenue expenses;
run;

proc print split='*';
  label region='sales region'
        headcnt='sales*personnel';
  by region state;
  id region state;  /* put each by variable in id */
  sum revenue expenses;
  var revenue expenses headcnt month;
  format headcnt 3. revenue expenses COMMA10.;
  title '~~~branch headcount, sales, expenses (BY and ID statement are same)';
run;
