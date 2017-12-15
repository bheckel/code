options nosource;
 /*---------------------------------------------------------------------
  *     Name: every3rd_obs.sas
  *
  *  Summary: Demo of the POINT dataset option and the mod() function.
  *
  *  Adapted: Wed 02 Oct 2002 10:48:29 (Bob Heckel--Patridge website)
  * Modified: Thu 12 Jun 2003 11:27:48 (Bob Heckel)
  *---------------------------------------------------------------------
  */

data work.sample1;
  input fname $1-10  lname $15-25  @30 storeno 3.;
  datalines;
ayn           rand           123
mario         lemieux        123
ron           francis        123
jerry         garcia         123
lola          rennt          345
larry         wall           345
richard       stallman       345
richard       dawkins        345
charlton      heston         678
richard       feynman        678
  ;
run;


data work.everythird; 
  do i=1 to totalobs by 3; 
    set work.sample1 POINT=i NOBS=totalobs; 
    put 'DEBUG: ' i=;
    output; 
  end; 
  if _ERROR_ then stop;  /* just in case */
  /* No EOF when using POINT, this is required to avoid infinite loop. */
  stop;  

run; 
proc print; run;


 /* Probably the easiest: */
data keep_every_third_obs;
  input var1;
  /* Tests if the reminder value of obs # _N_ divided by 3 equals 0. */
  if mod(_N_, 3) = 0;
  cards;
1
2
3
4
5
6
8
9
  ;
run; 
proc print; run;
