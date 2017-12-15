options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sfp.sas (based on proc_upload.sas)
  *
  *  Summary: Transfer text file without FTP for those days when 
  *           FTP is not available on the mf.
  *
  *           Sample call (can't put this code in ~/bin):
  *           sr sfp.sas 'junkonpc bqh0.pgm.trash(junkonmf)'
  *           sr ~/code/sas/sfp.sas 'RECSBYMM.sas bqh0.pgm.lib(recsbymm)'
  *
  *  Created: Tue 05 Oct 2004 12:22:15 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source mlogic mprint sgen;

%global here there;
%let here=%scan(&SYSPARM, 1, ' ');
%let there=%scan(&SYSPARM, 2, ' ');

filename LOCAL "&here";

%include "&HOME/code/sas/connect_setup.sas";
signon cdcjes2;
 /* Pass info from user (in this case, a command-line param on localhost) to
  * MF via an intermediate variable, CHICKENPARM.  Must go before RSUBMIT;
  */
%global CHICKENPARM;
%syslput CHICKENPARM=&there;
rsubmit;

  filename REMOTE "&CHICKENPARM";

  proc upload infile=LOCAL outfile=REMOTE; 
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
