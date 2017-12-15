options nosource;
 /*---------------------------------------------------------------------------
  *     Name: obs.sas
  *
  *  Summary: Demo of controlling number of observations used in a set
  *           statement.  Result is not representative unless the order of the
  *           obs is random; but it is an efficient sample.
  *
  *           See point.sas if want a single obs e.g. firstobs=66 obs=66
  *
  *           See also infile.oneobs.sas for controlling number of obs on 
  *           the infile statement.
  *
  *           This won't work!  Must be on the set stmt.
  *           data work.empty (obs=10);
  *             set work.sample;
  *           run;
  *
  *  Created: Tue 29 Oct 2002 10:12:46 (Bob Heckel)
  * Modified: Sat 23 Apr 2005 14:10:22 (Bob Heckel)
  *---------------------------------------------------------------------------
  */

 /* Only read 7 datalines. */
options source obs=7;

title 'using obs via options';
data work.sample;
  input fname $1-10  lname $15-25  @30 numb 3.;
  datalines;
mario         lemie1x        123
ron           franc2s        123
jerry         garci3         123
richard       dawki4s        345
richard       feynm5n        679
richard       feynm6n        680
richard       feynm7n        681
richard       feynm8n        682
  ;
run;
proc print; run;

options obs=max;

title 'using firstobs= & obs= via a dataset option';
data work.small;
  /* Gives obs 2, 3, 4, 5 */
  /*    note: not 'lastobs'    ___ */
  set work.sample (firstobs= 2 obs= 5);
  /* Default is firstobs= 1 obs= max */
run;
proc print; run;

title 'using obs to create an empty dataset';
 /* Could have used a stop; statement after the set statement instead. */
data work.empty;
  set work.sample (obs=0);
run;
proc contents; run;
