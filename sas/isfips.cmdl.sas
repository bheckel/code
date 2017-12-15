options nosource;
 /*---------------------------------------------------------------------
  *     Name: isfips.sas
  *
  *  Summary: Detect if a merged file is using FIPS codes.
  *
  *           See ishisp.cmdl.sas for better version
  *
  *  Created: Fri 07 Feb 2003 09:46:26 (Bob Heckel)
  * Modified: Wed 04 Jun 2003 13:56:58 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options source;

%include "&HOME/code/sas/connect_setup.sas";
signon cdcjes2;
%global CHICKENPARM;
%syslput CHICKENPARM=&SYSPARM;
rsubmit;


%global FN;
 /* If this job bombs with a LOST CARD error, it is NOT a FIPS state since the
  * 142 byte files were pre-revisor.  It is probably a 2002 or earlier file.
  */
***%let FN=BF19.NJX0301.MORMER;
***%let FN=BF19.TXX0317.NATMER;
***%let FN=BF19.CAX0301.NATMER;
%let FN=&CHICKENPARM;

filename IN "&FN" WAIT=30;

%macro BldInputStmt;
  %global INP;
  %local TMP;
  %let TMP=%substr(%scan(%upcase(&FN), 3, '.'), 1, 6);
  %if &TMP eq MORMER %then
    %do;
      %let INP=%nrstr(stateold 77-78  statenew $ 147-148);
    %end;
  %else %if &TMP eq NATMER %then
    %do;
      %let INP=%nrstr(stateold 16-17  statenew $ 256-257);
    %end;
  %else
    %put !!! ERROR isfips.sas: unknown mergefile extension !!!;
%mend BldInputStmt;
%BldInputStmt


data _NULL_;                                                                    
  /* Only want to test a single line. */
  infile IN OBS=1;
  input &INP;

  file PRINT;

  /* If state is NOT using fips, it will have numbers in the old state field.
   * and it will NOT hold an alpha string like 'AL'. 
   */
  if stateold ge 1 and stateold le 99 and statenew eq "" then
    put 'not using fips';
  else if stateold eq . and statenew ne "" then
    put 'is using fips';
  else
    put 'unknown due to invalid data';
run;


endrsubmit;
signoff cdcjes2;
