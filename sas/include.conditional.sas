options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: include.conditional.sas
  *
  *  Summary: Conditionally include code based on day of week.
  *
  *  Created: Tue 10 Mar 2009 08:59:59 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

%let f=t2.sas;

data _null_;
  if weekday(today()) eq 4 then do;
    /* It DOES resolve mvar */
    call execute('%include "&f";');
    ;
  end;
run;



endsas;
This won't work:
data _null_;
  if weekday(today()) eq 4 then do;
    %include "t2.sas";
    ;
  end;
run;
