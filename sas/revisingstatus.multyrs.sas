options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: revisingstatus.multyrs.sas
  *
  *  Summary: For multiple years, determine revising status using the
  *           Register.  There is no single year version, just use same BEGYR
  *           and ENDYR.
  *
  *          ___CHECK REVISING STATUS___
  *
  *  Created: Thu 02 Jun 2005 15:31:46 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

/* ADJUST */
%let BEGYR=2005;
%let ENDYR=2005;
%let EVT=NAT;

%macro BuildNonRevStList;
  %local y i;

  %let i=%eval(&ENDYR-&BEGYR+1);

  %do y=&BEGYR %to &ENDYR;
    %global STATES&y;
    libname R "/u/dwj2/register/&EVT/&ENDYR/";

    %if &y ge 2003 %then
      %do;
        %let i=%eval(&i-1);
        proc sql NOprint;
          select stabbrev into :STATES&y separated by ' '
          from R.register
          /* ADJUST */
          where substr(reverse(trim(revising_status)),&i,1) 
                in('O','R','F','B')
          ;
        quit;
      %end;
    %else
      %do;
        proc sql NOprint;
          select stabbrev into :STATES&y separated by ' '
          from R.register
          ;
        quit;
      %end;

    %put !!!&y: &&STATES&y;
  %end;
%mend BuildNonRevStList;
%BuildNonRevStList
