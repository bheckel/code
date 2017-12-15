options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: subset.sas
  *
  *  Summary: Demo of selecting specfic obs.
  *
  *           Subsetting IFs cannot be used in proc steps.
  *
  *  Created: Thu 15 May 2003 12:39:02 (Bob Heckel)
  * Modified: Tue 12 Nov 2013 15:13:14 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data t;
   input Density CrimeRate State $ 14-27 PostalCode $ 29-30;
   cards;
264.3 3163.2 Pennsylvania   PA
51.2 4615.8  Minnesota      MN
9.1 2678.0   South Dakota   SD
9.4 2833.0   North Dakota   ND
102.4 3371.7 New Hampshire  NH
120.4 4649.9 North Carolina NC
121.4 4649.9 North Carolina NC
122.4 4649.9 North Carolina NC
123.4 4649.9 North Carolina NC
124.4 4649.9 North Carolina NC
  ;
run;

data t2;
  set t;
  /* If you use a positive seed, you can always replicate the stream of random
   * numbers by using the same DATA step. If you use zero as the seed, the
   * computer clock initializes the stream, and the stream of random numbers
   * cannot be replicated. */
  if uniform(0) lt .10;  /* select about 10% */
run;
proc print data=_LAST_(obs=max) width=minimum; run;


data t;
  set work.sample;
  where Density > 100;
  if PostalCode in ('NH', 'NC');
run;
proc print; run;

 /* Better */
data t;
  set work.sample;
  if Density > 100 & PostalCode in ('NH', 'NC');
run;
proc print; run;


data t;
  do i=1 to 6 by 2;
    set work.sample point=i;
    output;
  end;
  stop;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
