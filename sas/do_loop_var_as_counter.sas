options NOsource;
 /*--------------------------------------------------------------------------- 
  *     Name: do_loop_var_as_counter.sas
  *
  *  Summary: Demo of using a SAS variable as a STOP value in a DO loop.
  *
  *  Adapted: Wed 16 Jun 2010 09:52:06 (Bob Heckel--SAS9 Certification Prep Book)
  *---------------------------------------------------------------------------
  */
options source NOcenter;


data t;
  infile cards;
  input bank :$10. rate yrs;
  invest = 5000;
  /* Unconditional loop */
  do i=1 to yrs;  /* yrs is used as the stop value */
    invest+(rate*invest);
  end;
  cards;
MBNA 0.0817 5
Crapmerica 0.0814 4
Pacific 0.0806 4
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


 /* Combine unconditional with conditional DO loop */
data t;
  infile cards;
  input bank :$10. rate yrs;
  invest = 5000;
  /* Either exit after looping 10 times (years) or exit if invest gets to a threshold */
  do i=1 to 10  until (invest>=50000);  /* UNTIL evals at bottom, WHILE at top */
    invest+(rate*invest);
  end;
  cards;
MBNA 0.0817 5
Crapmerica 0.0814 4
Pacific 0.0806 4
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
