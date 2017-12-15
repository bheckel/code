
proc sql;
  CONNECT TO ORACLE(USER=pks ORAPW=dev123dba BUFFSIZE=25000 READBUFF=25000 PATH="usdev388" DBINDEX=YES);
  CREATE TABLE all_procedures_functions AS SELECT * FROM CONNECTION TO ORACLE 
  (
    select object_name, object_type 
    from user_objects 
    where object_type in ('PROCEDURE','FUNCTION')
  );
  DISCONNECT FROM ORACLE;
quit;
proc print data=_LAST_(obs=max); run;
