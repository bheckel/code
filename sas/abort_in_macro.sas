options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: abort_in_macro.sas
  *
  *  Summary: Stop running if macro finds a problem.  Or exit if macrovar
  *           is missing.
  *
  *  Created: Tue 10 Feb 2004 14:18:18 (Bob Heckel)
  * Modified: Fri 19 Jun 2009 13:38:54 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

/***%let FOO=bar;***/
data _NULL_; 
  test = symget('FOO');
  put test=;
  if test eq '' then do;
    put "ERROR: macrovariable FOO is empty - aborting";
    abort abend 002;
  end;
run;


endsas;
%macro NotInAlpha(state);
  %if not %sysfunc(indexw(AK AR VI WV, &state)) %then
    %do;
      %put !!! alpha &state is NOT IN the list of states;
      data _NULL_; abort abend 002; run;
    %end;
  %else
    %put !!! alpha &state is one of the states in the list;
%mend;
%NotInAlpha(AX);

data;
  input x;
  cards;
1
2
3
  ;
run;
proc print; run;
