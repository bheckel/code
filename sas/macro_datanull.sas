options nosource;
 /*---------------------------------------------------------------------
  *     Name: macro_datanull.sas 
  *
  *  Summary: Demo of showing when macrovariable resolution occurs.
  *
  *  Created: Thu 06 Feb 2003 09:51:50 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options source;

%global VARX;

%let VARX = Race;

data _NULL_;
  put '!!! due to resolution rules, this comes last!';
  %put !!! testbobh ONE;
  %macro Foo;
  %if &VARX eq Race %then
    %do;
      %put !!! bobh TWO ok;
      %put !!! &VARX;
    %end;
  %mend;
  %Foo
run;
