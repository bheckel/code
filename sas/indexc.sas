
title 'find one of these chars:  "x y -"  and give pos of first found only';
data _null_;
  s='x has a dash -';
  idx=indexc(s, 'xy-');
  put _all_;
run;


data _null_;
  s='x has a dash -';
  if indexc(s, ':') then
    put 'found a colon';
run;


endsas;
 /* Look for spaces in a var */
data foo;
  x='bob heck';
  output;
  x='bob';
  output;
run;
proc print data=_LAST_(obs=max); run;

data _null_;
  set foo;
  /* v9-specific */
  if indexc(strip(x), ' ') > 0 then
    put 'found a space' x=;
run;


