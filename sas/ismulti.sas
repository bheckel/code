options nosource;
 /*---------------------------------------------------------------------
  *     Name: ismulti.sas
  *
  *  Summary: Detect if a natmer or mormer merged file is using multi-race.
  *
  *           See ishisp.cmdl.sas for better version
  *
  *           For now, must edit the bottom of this file to change merge file
  *           name.
  *           
  *           Sample call:
  *           %CkMulti(&HOME/projects/BF19.MRX0342.MORMER)
  *
  *           TODO can't handle full revisors.
  *           TODO enable commandline calls like isfips
  *
  *  Created: Thu 05 Jun 2003 08:37:01 (Bob Heckel)
  * Modified: Thu 19 Jun 2003 15:07:43 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options source;

 /* Accepts merge filename e.g. BF19.CAX0301.NATMER
  * "Returns" an input statement based on detected filetype. 
  */
%macro CkMulti(fn);
  %global INP;

  %if %index(%scan(&fn,3,.), MORMER) %then
    %do;
      /* TODO use this on Windows. */
      ***filename IN "&fn" lrecl=420 blksize=14700;
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


data _NULL_;
  /* No quotes! */
  %CkMulti(BF19.MEX0401.MORMER);
run;
