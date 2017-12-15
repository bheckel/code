options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: how_many_numeric_vars.sas
  *
  *  Summary: Determine how many numeric variables exist in a dataset.
  *
  *  Created: Tue 11 Mar 2003 09:01:00 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;


data work.sample;
   input Density CrimeRate State $ 14-27 PostalCode $ 29-30;
   cards;
264.3 3163.2 Pennsylvania   PA
102.4 3371.7 New Hampshire  NH
120.4 4649.9 North Carolina NC
;

data _NULL_ ;
  set work.sample;
  array num _numeric_ ;
  call symput('VARCNT', dim(num)) ;
  put _all_;
run;

%put !!! &VARCNT;
