%let enddt=1601377424;
%let enddt=05-OCT-10 11:06:13;
proc sql;
  create table t as
  select put(&enddt, DATETIME18.) as maxts
  from sashelp.shoes
  ;
quit;
proc print data=_LAST_(obs=max) width=minimum; run;
