options nosource;
 /*---------------------------------------------------------------------------
  *     Name: truncover.sas
  *
  *  Summary: Demo of the TRUNCOVER infile option.
  *
  *  Created: Mon 05 May 2003 09:04:24 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* TRUNCOVER
  * overrides the default behavior of the INPUT statement when an input data
  * record is shorter than the INPUT statement expects. By default, the INPUT
  * statement automatically reads the next input data record. TRUNCOVER enables
  * you to read variable-length records when some records are shorter than the
  * INPUT statement expects. Variables without any values assigned are set to
  * missing
  */

 /* Assume infile 'junk' looks like this: 
1
22
333
4444
55555
 */

data bad;
  ***infile 'junk' FLOWOVER;
  /* Same */
  infile 'junk';
  input num 5.;
run;
title 'Used FLOWOVER, should have used TRUNCOVER';
proc print; run;

 /* Summary: 
  OBS  FLOWOVER  MISSOVER  TRUNCOVER
  1    22         .        1
  2    4444       .        22
  3    55555      .        333
  4               .        4444
  5               55555    55555
 */

data ok;
  ***infile 'junk' FLOWOVER;
  /* Same */
  infile 'junk' TRUNCOVER;
  input num 5.;
run;
title 'Properly used TRUNCOVER';
proc print; run;
