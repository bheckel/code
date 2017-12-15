options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: between.sas
  *
  *  Summary: Demo of the between operator.
  *
  *  Created: Mon 23 Jun 2003 15:10:26 (Bob Heckel)
  * Modified: Tue 14 Sep 2004 14:21:25 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data sample;
   input density  crimerate  state $ 14-27  stabbrev $ 29-30;
   cards;
264.3 3163.2 Pennsylvania   PA
51.2 4615.8  Minnesota      MN
55.2 4271.2  Vermont        VT
9.1 2678.0   South Dakota   SD
102.4 3371.7 North Carolina NC
100 3371.7   North Carolina NC
9.4 2833.0   North Dakota   ND
120.4 4649.9 North Carolina NC
200   4649.9 North Carolina NC
  ;
run;

data betw;
  set sample;
  /* Doesn't work. */
  ***if density between 100 and 200;
  /* Inclusive */
  where density between 100 and 200;
run;
proc print; run;

 
 /* Good for error checking */
%macro NotBetweenMacro(n, minval, maxval);
  %if ( %eval(&n)>&maxval or %eval(&n)<&minval ) %then
    %put !!! out of range;
  %else
    %put !!! ok;
%mend NotBetweenMacro;
%NotBetweenMacro(15, 1, 9);
