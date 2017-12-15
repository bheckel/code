
data t;
  ch='123';
  num=123;
  ch2 = put(ch, Z4.);
  num2 = put(num, Z4.);
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H; run;title;



endsas;
proc sql;
  select distinct clientid, trim(leading '0' from storeid) as storeid
  from ...
quit;



 /* Skip a leading zero */
data TMPmerps;
  set MERPS.&InputFile5;
  if substr(mat_cod, 1, 1) eq '0' then do;
    mat_cod=substr(mat_cod, 2);
  end;
run;
