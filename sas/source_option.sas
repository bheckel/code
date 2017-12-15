options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: source_option.sas
  *
  *  Summary: Demo of two ways to include source code on an included file.
  *
  *  Created: Tue 01 Jun 2010 10:50:33 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;
/***options source source2 NOcenter;***/  /* Option A */

data t;
  set sashelp.shoes;
run;

%macro m;
  %put in macro m;
/***  %include './source_option_callme.sas';***/
  %include './source_option_callme.sas' / source2;  /* Option B */
%mend;
%m;
