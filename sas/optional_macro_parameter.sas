options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: optional_macro_parameter.sas
  *
  *  Summary: Demo of passing one or two parameters to a macro.
  *
  *  Created: Mon 03 Nov 2003 14:11:43 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* p2 is optional and will use 'the default' if missing in the function call.
  * Both must use the equal sign parm style.
  */
%macro VariableNumParms(p1=, p2=the default);
  %put &p1 and &p2;
%mend;
%VariableNumParms(p1=bob);
%VariableNumParms(p1=bob, p2=heck);
