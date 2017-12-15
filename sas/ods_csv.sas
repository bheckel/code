options ls=180 ps=max; libname l '.';

ODS listing close;

ODS csvall FILE='t.csv'  STYLE=Styles.NoBorder; 
proc print data=sashelp.class NOobs label; run;
ODS csvall CLOSE;

ods csv file='t2.csv' options(delimiter='|');
proc print data=sashelp.class NOobs label; run;
ods csv close;
