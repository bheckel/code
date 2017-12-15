
proc import datafile='c:\temp\RePopulate_DATALOAD.xls' out=work.tmp dbms=EXCEL2000;
  range='Advair HFA$';
  getnames=yes;
run;

data tmp;
  set tmp(keep=prod_batch_nbr prod_matl_nbr);
run;

%let DbId=pks;
%let DbPsw=pks;
%let DbServerName=usdev100;
proc sql;
  CONNECT TO ORACLE(USER=&DbId ORAPW=&DbPsw BUFFSIZE=25000 READBUFF=25000 PATH="&DbServerName" DBINDEX=YES);
  CREATE TABLE lm AS SELECT * FROM CONNECTION TO ORACLE
  (SELECT DISTINCT matl_nbr, batch_nbr, matl_mfg_dt, matl_typ
   FROM links_material
  );
  DISCONNECT FROM ORACLE;
quit;

proc sql;
  create table before as
  select b.batch_nbr, b.matl_nbr, b.matl_mfg_dt, b.matl_typ
  from tmp t left join lm b  ON b.batch_nbr=t.prod_batch_nbr and
                                      b.matl_nbr=t.prod_matl_nbr
  ;
quit;

title 'Links_Material before update';
proc print data=before(obs=max); run;
