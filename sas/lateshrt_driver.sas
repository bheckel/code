options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: lateshrt_driver.sas
  *
  *  Summary: Demo the features of a callable LATEBF19.  Named LATEDRVR on
  *           the MF.
  *
  *  Created: Fri 30 May 2003 15:48:02 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

%include "&HOME/code/sas/connect_setup.sas";
signon cdcjes2;
rsubmit;


%global BYR EYR MERGETYPE RPT;
%let BYR=2001;
%let EYR=2001;
%let MERGETYPE=MORMER;
%let RPT=0;
%include 'BQH0.PGM.LIB(LATESHRT)';


 /* Count the number of merge files for all of the years requested. */
data _NULL_;
  /* Provided by the include'd LATEBF19 logic. */
  set allyears END=the_end;
  if yr eq '01' then
    yr1 + 1;
  /* ...etc... */
  if the_end then
    do;
      call symput('NSTATES', _N_);
      call symput('NSTATES01', yr1);
      /* ...etc... */
    end;
run;


 /* Create a dataset out of the final Alaska merge file. */
options obs=10;
data alaskaoneyr;
  length wholeline $ 80;
  /* Implicit 'filename AK20001 ...;' statement provided by LATEBF19 logic. */
  infile AK2001;
  input wholeline $;
run;
options obs=max;


 /* Concatenate all final merge files into a dataset. */
data allinone;
  set allyears;
  /* Get new input filename each time variable fn (on allyears) changes. */
  infile TMPIN FILEVAR=fn TRUNCOVER END=done;

  do while ( not done );
    /* Read all input records from the currently opened input file. */
    input @1 block $char142.;
    output;
  end;
run;


endrsubmit;
signoff cdcjes2;
