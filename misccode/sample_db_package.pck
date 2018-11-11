CREATE OR REPLACE PACKAGE ztestbob AS
  
  PROCEDURE t;

END ztestbob;
/
CREATE OR REPLACE PACKAGE BODY ztestbob AS

  PROCEDURE t
  IS

  BEGIN
    dbms_output.put_line('ok ' || systimestamp);
  END;

END ztestbob;
/
