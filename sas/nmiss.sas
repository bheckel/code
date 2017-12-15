options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: nmiss.sas
  *
  *  Summary: Demo of counting missing variables using the nmiss function.
  *
  *  Created: Sun 01 Jun 2003 10:33:51 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;


data work.sample;
   input Density CrimeRate State $ 14-27 PostalCode $ 29-30  x1-x3;
   cards;
264.3 3163.2 Pennsylvania   PA 1 2 3
51.2 4615.8  Minnesota      MN . 2 3
55.2 4271.2  Vermont        VT 1 2 3
9.1 .        South Dakota   SD 1 2 3
9.4 2833.0   North Dakota   ND . . .
 .        .  New Hampshire  NH 1 2 3
120.4 4649.9 North Carolina NC 1 2 3
  ;
run;


data work.tmp;
  set work.sample;
  /* Requires numeric values */
  ***miss = nmiss(Density, CrimeRate);
  xmiss = nmiss(of x1-x3);
run;
proc print; run;
