options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: two_set_statements_one-to-one.sas
  *
  *  Summary: One-to-One Reading.  Useless?
  *
  *           Contains variables from each contributing ds.  Obs are
  *           combined based on their relative position in each ds.
  *
  *           _N_ is the size of the smaller ds.  The second ds obs overwrites
  *           the first in case of conflict.
  *
  *  Created: Fri 11 Jun 2010 12:55:56 (Bob Heckel)
  * Modified: Tue 15 Dec 2015 13:44:37 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;


data dsa;
  a=2; x=2; output;
  a=4; x=4; output;
  a=6; x=6; output;
  a=8; x=8; output;
run;
title 'dsa'; proc print NOobs; run;

data dsb;
  b=3; x=3; output;
  b=5; x=5; output;
  b=7; x=7; output;
run;
title 'dsb'; proc print NOobs; run;

title 'two SET "one-to-one reading" tot obs will be governed by the smaller ds';
data twosets;
  put _ALL_;  /* for PDV viewing only */
  set dsa;
  set dsb;
  put _ALL_;
run;
proc print NOobs; run;

title 'compare - one SET "concatenating"'; 
data one2onemerge;
  put _ALL_;
  set dsa dsb;
  put _ALL_;
run;
proc print NOobs; run;

