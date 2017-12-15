data t1;
  length make $50;
  set sashelp.cars(rename=(make=xmake) );

  if xmake eq: 'Audi' then do;
    make = 'foo';
  end;
  else do;
    make = xmake;
  end;

  drop xmake;
run;
/***title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;***/
data t2;
  set sashelp.cars;
run;
/***title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;***/

 /* Find records that differ between tables.  Use MINUS instead of EXCEPT for
  * Oracle.  Can't differentiate source (t1 vs t2) though.
  */
proc sql;
  (select * from t1
  EXCEPT
  select * from t2)

  UNION ALL

  (select * from t2
  EXCEPT
  select * from t1)
  ;
quit;
