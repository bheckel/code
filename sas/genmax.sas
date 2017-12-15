options nosource;
 /*---------------------------------------------------------------------------
  *     Name: genmax.sas
  *
  *  Summary: Demo of rotating archived datasets.  Run repetitively to test.
  *
  *  Created: Tue 07 Jan 2003 15:16:30 (Bob Heckel)
  * Modified: Tue 30 Nov 2010 12:36:36 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source replace;

libname BOBH 'c:/temp';

 /* Keep two old datasets and the current one.  E.g. samplemax#005.sas7bdat
  * The genmax maximum is 999.
  */
data BOBH.samplemax (genmax=3);
  input fname $1-10  lname $15-25  @30 numb 3.;
  datalines;
mario         lemieux        123
ron           francis        123
jerry         garciaa        123
richard       dawkins        345
richard       feynman        678
  ;
run;


 /* GENNUM=-1 refers to the youngest version. GENNUM=0 refers to the current
  * version. */

 /* Print current (base) version. */
proc print data=BOBH.samplemax (gennum=0); run;
 /* Print version two generations back. */
proc print data=BOBH.samplemax (gennum=-2); run;
