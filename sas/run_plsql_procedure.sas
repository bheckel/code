 /* See ~/code/misccode/procedure.plsql which was run in Oracle to create
  * fire_emp() 
  */
PROC SQL;
  CONNECT TO ORACLE(USER=pks ORAPW=dev123dba BUFFSIZE=25000 READBUFF=25000 PATH="usdev388" DBINDEX=YES);
    EXECUTE 
    (

execute fire_emp(67)

    ) BY ORACLE;
  DISCONNECT FROM ORACLE;
QUIT;
