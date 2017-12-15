options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: length.macro.sas
  *
  *  Summary: Determine the length of a macrovariable.
  *
  *  Created: Tue 02 Dec 2003 16:02:48 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

%macro x;
  %let foo=abcd;
  %if %length(&foo) > 3 %then
    %put !!!ok;
%mend;
%x
