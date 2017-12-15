options NOsource;
 /*---------------------------------------------------------------------
  *     Name: mod.sas
  *
  *  Summary: Demo of keeping every fourth observation using modulus.
  *
  *  %let zerowhenreached=%sysfunc(mod(&i,100));  when mvar is 0, &i has hit 100
  *
  *  Adapted: Thu 26 Sep 2002 12:13:24 (Bob Heckel ~/code/sas/sasquickref)
  * Modified: Tue 28 Feb 2017 15:55:05 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options source;

 /* Split a dataset into 3 groups: */
data rxfilldata2;
  set l2.rxfilldata;
  if mod(_n_, 1) eq 0 then grp = 1;
  if mod(_n_, 2) eq 0 then grp = 2;
  if mod(_n_, 3) eq 0 then grp = 3;
run;



data work.tmp;
  input @1 fname $CHAR7.  @15 lname $CHAR10.  @30 storeno 3.;
  
  /* We're testing whether the value of x is a multiple of y: foo=mod(x, y); */
  foo=mod(2, 3);
  bar=mod(3, 2);
  put foo= / bar=;

  /* Get every 4th obs */
  if mod(_N_, 4) eq 0;
  datalines;
ayn           rand           111    # mod(1, 4) i.e. 4/1 so remainder is 1   
mario         lemieux        222    # mod(2, 4) i.e. 4/2 so remainder is 2   
ron           francis        333    # mod(3, 4) i.e. 4/3 so remainder is 3   
jerry         garcia         444    # mod(4, 4) i.e. 4/4 so remainder is 0   
lola          rennt          555    # mod(5, 4) i.e. 4/5 so remainder is 1   
larry         wall           666    # mod(6, 4) i.e. 4/6 so remainder is 2   
richard       dawkins        777    # mod(7, 4) i.e. 4/7 so remainder is 3   
charlton      heston         888    # mod(8, 4) i.e. 4/8 so remainder is 0   
  ;
run;
proc print; run;



data _null_;
  x=mod(5, 2);
  put '!!! ' x;  /* 1 */

  y=mod(5.1, 2);
  put '!!! ' y;  /* 1.1 */

  z=mod(200107, 100);
  put '!!! ' z;  /* 7, a good way to extract month from a nonstandard date */
run;
