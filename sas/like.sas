
data t;
  length x $5;
  x='foo'; output;
  x='foo''bar'; output;
  x='baz'; output;
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H; run;title;

proc sql;
  select * 
  from t
  where x like "%'%"
  ;
quit;



endsas;
proc sql;
  select * 
  from sashelp.shoes(drop=sales)
  where region like 'A%a'
  ;
quit;



data foo;
  set l.lelimsindres01aADVCOM;
  if index(specname, 'AIR');
run;



 /* select * from foo where Matl_Nbr like 'ADVAIR%' or ... */
data _null_;
  Matl_Nbr='012';
  select (substr(Matl_Nbr,1,6));
    when ('ADVAIR','AGENER','AMERGE')  Matl_Nbr = '';
    otherwise;
  end;
run;
