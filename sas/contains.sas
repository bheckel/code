options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: contains.sas
  *
  *  Summary: Demo of specifying criteria like SQL's 'like'.
  *
  *  Created: Sat 31 May 2003 22:32:10 (Bob Heckel)
  * Modified: Wed 02 Jun 2010 12:11:05 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data work.sample;
   input Density CrimeRate State $ 14-27 PostalCode $ 29-30;
   cards;
264.3 3163.2 Pennsylvania   PA
51.2 4615.8  Minnesota      MN
55.2 4271.2  Vermont        VT
9.1 2678.0   South Dakota   SD
9.4 2833.0   North Dakota   ND
102.4 3371.7 New Hampshire  NH
120.4 4649.9 North Carolina NC
  ;
run;

proc print;
  ***where State contains 'Dak';
  where State NOT contains 'akot';
run;

 /* Using the contains operator.  Doesn't work on IF statements. */
proc print;
  where State ? 'akot';
run;


 /* Alternatives */
proc print;
  where State like '%akot%';
run;

 /* Equal colon only does 'starts with' */
proc print;
  where State =: 'North';
run;
