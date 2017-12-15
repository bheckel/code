options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: firstobs.sas
  *
  *  Summary: Demo of firstobs statement
  *
  *  Created: Mon 04 Aug 2014 15:07:02 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

proc print data=sashelp.shoes(obs=20) width=minimum; run;

data t;
  set sashelp.shoes(firstobs=5 obs=6);
run;
proc print data=_LAST_(obs=max) width=minimum; run;



data t2;
  input ptid sex $ age height weight;
  cards;
 689574     M      15     80.0      115.5
 423698     F      14     65.5       90.0
 758964     F      12     60.3       87.0
 653347     F      14     62.8       98.5
 493847     M      14     63.5      102.5
 500029     M      12     57.3       83.0
 513842     F      12     59.8       84.5
 515151     F      15     62.5      112.5
 522396     M      13     62.5       84.0
 534787     M      12     59.0       99.5
 875642     F      11     51.3       50.5
 879653     F      15     75.3      105.0
 542369     F      12     56.3       77.0
 698754     F      11     50.5       70.0
 656423     M      16     72.0      150.0
 785412     M      12     67.8      121.0
 785698     M      16     72.0      110.0
 763284     M      11     57.5       85.0
 968743     M      14     60.5       85.0
 457826     M      18     74.0      165.0
 ;
run;
proc print data=_LAST_ width=minimum;
  where sex eq 'M';
run;
/*
Obs     ptid     sex    age    height    weight

  1    689574     M      15     80.0      115.5
  5    493847     M      14     63.5      102.5
  6    500029     M      12     57.3       83.0
  9    522396     M      13     62.5       84.0
 10    534787     M      12     59.0       99.5 <---5
 15    656423     M      16     72.0      150.0 <---6
 16    785412     M      12     67.8      121.0 <---7
 17    785698     M      16     72.0      110.0 <---8
 18    763284     M      11     57.5       85.0 <---9
 19    968743     M      14     60.5       85.0 <---10
 20    457826     M      18     74.0      165.0
*/

 /* Obs counting happens AFTER grouping so this prints 6 obs, not 10 */
proc print data=_LAST_(firstobs=5 obs=10) width=minimum;
  where sex eq 'M';
run;
/*
Obs     ptid     sex    age    height    weight

 10    534787     M      12     59.0       99.5
 15    656423     M      16     72.0      150.0
 16    785412     M      12     67.8      121.0
 17    785698     M      16     72.0      110.0
 18    763284     M      11     57.5       85.0
 19    968743     M      14     60.5       85.0
*/
