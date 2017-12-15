options nosource;
 /*---------------------------------------------------------------------
  *     Name: ismulti.cmdline.sas
  *
  *  Summary: Detect if a merged file is using multi-race.
  *
  *  Created: Thu 05 Jun 2003 08:37:01 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options source;

%include "&HOME/code/sas/connect_setup.sas";

signon cdcjes2;
%global CHICKENPARM;
%syslput CHICKENPARM=&SYSPARM;
rsubmit;

options NOerrorabend mlogic symbolgen;

 /******* Start pasted in from multi.sas.  Do not edit. ******/
 /* If this job bombs with a LOST CARD error, it is NOT a multi state since
  * the 142 byte files were pre-revisor.  It is probably a 2002 or earlier
  * file.
  */

 /* Accepts merge filename e.g. BF19.CAX0301.NATMER
  * "Returns" an input statement based on detected filetype. 
  */
%macro CkMulti(fn);
  %global INP;

  %if %index(%scan(&fn,3,.), MORMER) %then
    %do;
      /* TODO use this on Windows. */
      filename IN "&fn" DISP=SHR;
      %let INP=input %nrstr(raceold $ 95  racenew $ 166-180);
    %end;
  %else %if %index(%scan(&fn,3,.), NATMER) %then
    %do;
      /* TODO use this on Windows. */
      ***filename IN "&fn" lrecl=786 blksize=27510;
      filename IN "&fn" DISP=SHR;
      /* Only checking mother race for now.  Hopefully representative. */
      %let INP=input %nrstr(raceold $ 44-45  racenew $ 277-291);
    %end;
  %else
    %do;
      %put ERROR: ismulti.sas: unknown mergefile extension !!!;
    %end;


  data _NULL_;                                                                    
    /* Only want to test a single line. */
    infile IN OBS=1;
    &INP;

    file PRINT;

    /* 1 if variable contains an X. */
    oldx = index(raceold, 'X');
    /* 1 if variable contains Y or N. */
    ckboxes = (NOT verify(racenew, 'YN'));

    if not oldx and not ckboxes then
      put 'not multi';
    else if oldx and ckboxes then
      put 'yes multi';
    else if not oldx and ckboxes then
      put 'probably yes but no "X" in raceold';
    else if oldx and not ckboxes then
      put 'probably yes but no ckboxes in racenew';
    else
      put 'unknown due to invalid data';
  run;
%mend CkMulti;
 /******* End pasted in from multi.sas.  Do not edit. ******/

%CkMulti(&CHICKENPARM);


endrsubmit;
signoff cdcjes2;
