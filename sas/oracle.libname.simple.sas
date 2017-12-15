options NOreplace;

%let usr=pks;
%let pw=dev123dba;
%let db=usdev581;
%let sch=gdm_dist;
%let tbl=user_role2;

libname ORA oracle user=&usr password=&pw path=&db schema=&sch;

proc print data=ORA.&tbl(obs=10) width=minimum; run;
