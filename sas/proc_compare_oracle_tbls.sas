
proc sql;
  CONNECT TO ORACLE(USER=retain_user ORAPW=xxx BUFFSIZE=25000 READBUFF=25000 PATH=usprdxxx);
    CREATE TABLE t AS SELECT * FROM CONNECTION TO ORACLE
    (
      select distinct prod_desc, prod_class 
      from retain.material
      where prod_class is not null
      order by prod_class
    );
  DISCONNECT FROM ORACLE;
quit;
proc sql;
  CONNECT TO ORACLE(USER=retain_user ORAPW=xxx BUFFSIZE=25000 READBUFF=25000 PATH=usprdxxx);
    CREATE TABLE t2 AS SELECT * FROM CONNECTION TO ORACLE
    (
      select distinct prod_desc, prod_class 
      from retain.material
      where prod_class is not null and prod_desc not like 'LAMICTAL DE%'
      order by prod_class
    );
  DISCONNECT FROM ORACLE;
quit;

/***proc compare base=t compare=t2 BRIEFSUMMARY out=t3; run; proc print data=_LAST_(obs=max) width=minimum; run;***/
proc compare base=t compare=t2 PRINTALL; run;
