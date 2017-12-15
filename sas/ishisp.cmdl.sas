options nosource;
 /*---------------------------------------------------------------------
  *     Name: ishisp.cmdl.sas
  *
  *  Summary: Detect if a merged file is using multi-hispanic codes.
  *
  *           sr ishisp.cmdl.sas 'BQH0.CAX0403.NATMER'
  *           or
  *           sr ishisp.cmdl.sas `lb me 04 nat |tail -n1`
  *
  *           TODO only looks at natmer oldstyle with hisp revision
  *
  *           See also loop_filenames_in_ds.sas to check all states.
  *
  *  Created: Tue 24 Feb 2004 13:31:12 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options source;

 /******* We're on the PC: *******/
%include "&HOME/code/sas/connect_setup.sas";
signon cdcjes2;
%global CHICKENPARM;
 /* Received from the commandline e.g. BF19.CAX0301.NATMER */
%syslput CHICKENPARM=&SYSPARM;
rsubmit;


 /******* We're on the mf: *******/
%global FN;
 /* If this job bombs with a LOST CARD error, it probably means the lrecl is
  * too high.
  */
%let FN=&CHICKENPARM;

filename IN "&FN" WAIT=30;

%macro BldInputStmt;
  %global INP;
  %local TMP;
  %let TMP=%substr(%scan(%upcase(&FN), 3, '.'), 1, 6);
  %if &TMP eq MORMER %then
    %do;
      /*** %let INP=%nrstr(stateold 77-78  statenew $ 147-148); ***/
    %end;
  %else %if &TMP eq NATMER %then
    %do;
      %let INP=%nrstr(hisp1Old $ 899  hisp2Old $ 900);
    %end;
  %else
    %put !!! ERROR ishisp.cmdl.sas: unknown mergefile extension !!!;
%mend BldInputStmt;
%BldInputStmt


data _NULL_;                                                                    
  /* Only want to test a single line, hoping it's not an invalid format. */
  infile IN OBS=5;
  input &INP;

  file PRINT;

  put hisp1Old= hisp2Old=;
run;


endrsubmit;
signoff cdcjes2;
