options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: macro.scope.sas
  *
  *  Summary: Scoping scope of macros macrovariables.
  *
  *  Created: Fri 21 Jan 2005 15:14:24 (Bob Heckel)
  * Modified: Thu 26 May 2005 09:07:53 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

%global GLO;
%let GLO=everywhere;
 /* Don't need %global unless mvar is created inside macro, I think. */
%let NOTGLO=everywhereanyway;

%macro x;
  %local foo;
  %let foo=bar;

  %put !!!&GLO;
  %put !!!&NOTGLO;

  %do i=1 %to 3;
    %global COUNT&i;
    %let COUNT&i=&NOTGLO;
  %end;
%mend;
%x

%put !!! &COUNT1;
%put !!! &COUNT2;
%put !!! &foo;  /* error */
%put !!! &i;  /* error */
