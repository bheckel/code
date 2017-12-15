options nosource;
 /*---------------------------------------------------------------------------
  *     Name: proctabulate.sas
  *
  *  Summary: Demo of proc tabulate.  Used to create tables showing summary
  *           statistics.
  *
  *           See PAPRENA2 for a better example.
  *           See MIMARR for the best example.
  *
  *  Adapted: Thu 11 Apr 2002 14:41:23 (Bob Heckel - Little SAS Book sect 4.12)
  * Modified: Wed 27 Sep 2006 12:31:56 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data work.boats;
  infile cards TRUNCOVER;
  length boattyp $9;
  input name $13.  ft  locomotion $  @25 boattyp $  fees $;
  Port = 'Maalea';
  cards;
Silent Lady    64 sail  schooner Yes
America II     65 sail  yacht Yes
Ocean Spirit   65 power catamaran No
Lavengro       52 sail  schooner No
Pride of Maui 110 power catamaran Yes
Leilani        45 power yacht Yes
Kalakaua       70 power catamaran No
Blue Dolphin   65 sail  catamaran Yes
  ;
run;
proc print; run;


 /* TABLE page-expression, row-expression, column-expression. */
 
 /* Operators: * for nesting (e.g. jobcode*salary*max the '*' means 'within', 
  *                           reading right to left, max within salary...)
  *                           TODO need a demo
  *              (space) for concatenation
  *            , for normal
  */

 /* Class variables (or ALL) with CLASS keyword.
  * Analysis variables with VAR keyword.
  * See ~/code/misccode/oneliners for explanation of class/analysis.
  */

title 'one-dimensional tables i.e. just columns';

 /* Bare-bones SUM. */
proc tabulate;
  /* Use ft as the analysis variable. */
  var ft;
  table ft;
run;


 /* Like proc means. */
proc tabulate;
  /* Use ft as the analysis variable. */
  var ft;
  /* Space ' ' creates a new column. */
  ***table ft*MEAN ft*N;
  /* Better, spreads 'ft' title across the 2 cols. */
  table ft*(MEAN N);
run;


 /* Better than proc means. */
proc tabulate;
  /* Identify data subgroup means based on this category. */
  class boattyp;
  /* Use the numeric variable ft (feet) as the analysis variable. */
  var ft;
  /* Space ' ' creates a new column. */
  ***table ft*MEAN ft*N;
  /* Better, spreads 'ft' title across the 2 cols. */
  table ft*MEAN*boattyp;
run;


title 'two-dimensional tables i.e. columns and rows';

proc tabulate;
  var ft;
  /* Mandatory for two-dimensionals. */
  class boattyp;
  table boattyp, ft*MEAN ft*N;
run;


proc tabulate;
  var ft;
  class boattyp locomotion;
  table boattyp, ft*locomotion*MEAN;
run;


title 'two stacked two-dimensional mini-tables inside a single table';
proc tabulate;
  var ft;
  class boattyp locomotion fees;
  table boattyp fees, ft*locomotion*MEAN;
run;


title '1- nested categories within the row headings';
proc tabulate;
  var ft;
  class boattyp locomotion fees;
  table boattyp*fees, ft*locomotion*MEAN;
run;


title '2- nested categories within the row headings';
proc tabulate;
  var ft;
  class boattyp locomotion fees;
  table fees*boattyp, ft*locomotion*MEAN;
run;


title 'totals with variable ALL (total counts in a column)';
proc tabulate;
  var ft;
  class boattyp locomotion;
  table boattyp, (locomotion ALL)*N;
run;


title 'totals with variable ALL (total counts in a row)';
proc tabulate;
  var ft;
  class boattyp locomotion;
  table boattyp ALL, locomotion*N;
run;


title 'three-dimensional tables i.e. columns and rows and pages (ugly)';
proc tabulate;
  var ft;
  class boattyp locomotion fees;
  /* fees (Yes, No) on 2 separate pages. */
  table fees,
        boattyp, (locomotion ALL)*ft*MEAN;
run;


title 'three-dimensional tables i.e. columns and rows and pages (pretty)';
ods html file='junk.html' style=Minimal;
proc tabulate format=F4.;
  var ft;
  class boattyp locomotion fees;
  /* fees (Yes, No) on 2 separate pages. */
  table fees=' ', 
        boattyp=' ', (locomotion=' ' ALL='My Tot')*ft=' '*MEAN=' '
        / RTS=20 BOX='Average Size of Boat in feet';  /* (R)ow (T)itle (S)pace */
run;
ods html close;


 /***********/
title 'Jelly Bean Production in 2001';
title2 'Millions of Pounds';
data production;
  input Flavor $ Factory $ Date MMDDYY8. MPounds;
  cards;
M A 12/17/01 0
M A 12/18/01 1
P A 12/19/01 2
P B 01/02/01 3
P B 01/06/01 4
C B 01/07/01 5
M B 01/08/01 6
  ;
run;
proc print data=_LAST_(obs=max); run;

proc format;
  value $flav
  'P' = 'Pecan Pie'
  'B' = 'Banana Bash'
  'A' = 'Apple Spice'
  'M' = 'Mango'
  'C' = 'Choco Mint';
run;

proc tabulate data=production /*format=4.1*/;
  class Factory Flavor;
  var MPounds;
  format Flavor $flav.;
  table Flavor ALL, Factory*SUM=''*MPounds='' ALL*SUM=''*MPounds='';
run;
 /***********/


endsas;
 /* Tabulations with three dimensions: */
proc tabulate data=work.boats format=BEST.;
  class Port locomotion boattyp;
  table Port, locomotion, boattyp / RTS=10 BOX='out of the box';
  title 'Number of Boats by Port, Locomotion, and Type';
run;

/* Output:
Port Maalea
                          Type
  Locomotion    catamaran  schooner  yacht
    power          3        .         1
    sail           1        2         1
*/


title 'Save output to a dataset:';
proc tabulate data=sashelp.prdsale out=test ;
  class country region ;
  var actual predict ;
  table country all, region*(actual*(sum mean) predict*(min median max)) ;
run ;
proc print data=test; run;
