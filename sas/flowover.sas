options nosource;
 /*---------------------------------------------------------------------------
  *     Name: flowover.sas
  *
  *  Summary: Demo of the default infile option, FLOWOVER.
  *
  *  Created: Sat 25 Jan 2003 17:14:29 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* Assume 'junk' looks like this: 
    1
    22
    333
    4444
    55555
 */
data numbers;
  /* Won't work with  datalines;  */
  ***infile 'junk' FLOWOVER;
  /* Same */
  infile 'junk';
  input num 5.;
run;

 /* Should have used TRUNCOVER. */
proc print; run;

 /* Summary: 
  OBS  FLOWOVER  MISSOVER  TRUNCOVER
  1    22         .        1
  2    4444       .        22
  3    55555      .        333
  4               .        4444
  5               55555    55555
 */

