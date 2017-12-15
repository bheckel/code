options nosource;
 /*---------------------------------------------------------------------
  *     Name: count_specific_obs.sas
  *
  *  Summary: Demo of counting specific types of observations.
  *
  *  Created: Thu 13 Jun 2002 15:41:54 (Bob Heckel)
  * Modified: Thu 20 May 2010 13:36:34 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options source;


data work.sample;
  input fname $1-10  lname $15-25  @30 storeno 3.;
  put _ALL_;  * DEBUG;
  ***put fname=;  * DEBUG;
  datalines;
mario         lemieux        331
ron           francis        331
larry         wall           332
richard       dawkins        332
jerry         garcia         331
charlton      heston         313
richard       feynman        313
  ;
run;

data work.counter;
  set work.sample end=e;

  * count is initialized to zero and auto-retained;
  if storeno = 331 then
    count+1;

  if e then
    put count=;
run;


data work.counter;
  set work.sample;

  if storeno = 331 then
    count+1;

  call symput('tot', left(trim(count)));
run;
%put Total "331" obs: &tot;
