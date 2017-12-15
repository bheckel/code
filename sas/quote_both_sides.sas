 /* Protect from a missing global breaking the code by quoting both sides of
  * the IF statement.
  */
%global STCODE;
%let STCODE=R;

%macro Protect;
  %if "&STCODE" eq "R" %then
    %put !!! found &STCODE;
  %else
    %put !!! did not find &STCODE;
%mend Protect;
%Protect
