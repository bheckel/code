options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: file_gt_0_obs.sas
  *
  *  Summary: Check for existence of at least one record in a file.
  *
  *  Created: Fri 02 Jul 2004 11:07:19 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

***filename F 'DWJ2.FL2004.NAT.LOG' DISP=SHR;
filename F 'BQH0.PGM.LIB(t)' DISP=SHR;

%macro IsEmpty;
  %local count;

  data _NULL_;
    infile F;
    input;
    cnt+1;
    call symput('count', cnt);
  run;
  %if &count le 0 %then
    %do;
      %put !!! yes;
    %end;
  %else
    %do;
      %put !!! no;
    %end;
%mend IsEmpty;
%IsEmpty;

