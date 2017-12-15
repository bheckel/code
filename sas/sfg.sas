options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sfg.sas (based on proc_upload.sas)
  *
  *  Summary: Transfer text file without FTP.
  *
  *           Sample call:
  *           sr sfp.sas 'junkpc bqh0.pgm.trash(junkmf)'
  *
  *  Created: Tue 05 Oct 2004 12:22:15 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source mlogic mprint sgen;

 /* TODO make unique with epoch time like bfg */
filename LOCAL "junk";

%include "&HOME/code/sas/connect_setup.sas";
signon cdcjes2;
 /* Pass info from user (in this case, a command-line param on localhost) to
  * MF via an intermediate variable, CHICKENPARM.  Must go before RSUBMIT;
  */
%global CHICKENPARM;
%syslput CHICKENPARM=&SYSPARM;
rsubmit;

  filename REMOTE "&CHICKENPARM";

  proc download infile=REMOTE outfile=LOCAL;
  run;

   /* Capture remote macrovariable. */
  %sysrput rc=&SYSINFO;

endrsubmit;
signoff cdcjes2;


%macro Checkrc;
  %if &rc ne 0 %then 
    %put !!!transfer failure!!!;
%mend Checkrc;
%Checkrc;
