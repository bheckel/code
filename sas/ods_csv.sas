options ls=180 ps=max; libname l '.';

ODS listing close;

ODS csvall FILE='t.csv'  STYLE=Styles.NoBorder; 
proc print data=sashelp.class NOobs label; run;
ODS csvall CLOSE;

ods csv file='t2.csv' options(delimiter='|');
proc print data=sashelp.class NOobs label; run;
ods csv close;



 /* Without header */
data t;
  do x = 1 to 5;
    do y = 8 to 9;
      z = 'foo';
      output;
    end;
  end;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;

data _null_;
  set t;
  file 't.csv' dlm=',' lrecl=32676;
  put (_all_)(+0);
run;
