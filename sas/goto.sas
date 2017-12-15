options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: goto.sas
  *
  *  Summary: Deadly goto
  *
  *           See also link.sas for more bouncing around options
  *
  * Adapted: Mon Nov 29 15:05:47 2004 (Bob Heckel --
  * http://support.sas.com/91doc/getDoc/mcrolref.hlp/a000209058.htm)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

%macro m;
  %if %sysfunc(weekday("&SYSDATE"d)) ne 5 %then %goto NOTSATURDAY;
  ...
%NOTSATURDAY:
%mend;



%macro check(parm);
  %local status;

  %if &parm= %then %do;
    %put ERROR:  You must supply a parameter to macro CHECK.;
    %goto EXIT;
   %end;

  %let status=0;

  %if &status > 0 %then %do;
     %put ERROR:  File is empty.;
     %goto EXIT;
  %end;

   %put Check completed successfully.;

%EXIT: 
%mend check;

%check(me)
