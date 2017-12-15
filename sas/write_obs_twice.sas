options nosource;
 /*---------------------------------------------------------------------
  *     Name: write_obs_twice.sas
  *
  *  Summary: Demo of writing each input line twice in a new ds.
  *
  *  Adapted: Fri 25 Oct 2002 15:21:05 (Bob Heckel -- Aster Programming
  *                                     Shortcuts)
  *---------------------------------------------------------------------
  */
options source;

***data work.double;
 /* Better */
data work.double (drop=i);
  infile datalines;
  input fname $1-10  lname $15-25  @30 numb 3.;
  do i=0,1;
    ***output;
    output;
  end;
  datalines;
mario         lemieux        123
ron           francis        123
jerry         garcia         123
larry         wall           345
richard       dawkins        345
richard       feynman        678
  ;
run;
proc print; run;
