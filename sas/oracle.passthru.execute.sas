
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
