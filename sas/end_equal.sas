options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: end_equal.sas
  *
  *  Summary: Demo of using set statement END= to do something after the 
  *           last observation.
  *
  *           Put it on the SET statement, not the DATA statement!
  *
  *           No parenthesis!
  *
  *  Created: Wed 16 Apr 2003 09:03:31 (Bob Heckel)
  * Modified: Wed 12 May 2010 13:46:20 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data work.sample;
   /* This works if you're using a real file and not cards. */
   ***infile cards end=lastobs;
   input Density CrimeRate State $ 14-27 PostalCode $ 29-30;
   cards;
264.3 3163.2 Pennsylvania   PA
51.2 4615.8  Minnesota      MN
55.2 4271.2  Vermont        VT
100.0 3371.7 New Hampshire  NH
9.1 2678.0   South Dakota   SD
9.4 2833.0   North Dakota   ND
102.4 3371.7 New Hampshire  NH
120.4 4649.9 North Carolina NC
100.0 3371.7 New Hampshire  NH
  ;
run;

data _NULL_; 
  set work.sample END=lastobswasread;
  if lastobswasread then
    call symput('NUMBEROBS', _N_);
run; 

 /* For a small ds we don't need the end=... */
data _NULL_;
  set sample nobs=numbo;
  call symput('NUMBEROBS2', numbo);
run;
%put _all_;


 /* Danger - if the 'if eof' comes *after* the SET stmt, the subsetting code causes
  * the last NH record, 100.0, to be ignored in the total!!! Yikes.
  */
data _NULL_; 
  set sample end=eof;

  if eof then 
    put total=;

  if State eq 'New Hampshire';

  total+Density;
run;

 /* Fixed */
data _NULL_; 
  if eof then 
    put total=;

  set sample end=eof;

  if State eq 'New Hampshire';

  total+Density;
run;
