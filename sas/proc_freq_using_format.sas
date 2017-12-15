
proc print data=sashelp.shoes(obs=10) width=minimum heading=H;run;title;

proc format;
  value sls 0-1000 = '1'
            1001-50000 = '2'
            50001-high = '3'
            ;
run;

proc freq data=sashelp.shoes;
  table sales;
  format sales sls.;
run;
