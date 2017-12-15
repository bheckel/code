
PROC SQL;
  CONNECT TO ORACLE(USER=pks ORAPW=dev123dba BUFFSIZE=25000 READBUFF=25000 PATH="usdev388" DBINDEX=YES);
    CREATE TABLE P_SAMP0 AS SELECT * FROM CONNECTION TO ORACLE
    (SELECT DISTINCT samp_id, samp_status, approved_dt
     FROM samp
     WHERE samp_id=183055
    );
  DISCONNECT FROM ORACLE;
QUIT;



PROC SQL feedback;
  CONNECT TO ORACLE(USER=pks ORAPW=pks PATH="usdev100");
          EXECUTE (
          UPDATE SAMP
          SET Prod_Grp ='solid', 
              Prod_Nm  ='testing'
          WHERE Samp_Id  = 144539 AND MATL_NBR = '4146344' AND BATCH_NBR = '4ZM6609'
          ) BY ORACLE;
  DISCONNECT FROM ORACLE;
QUIT;
