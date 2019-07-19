CREATE OR REPLACE PACKAGE ztestbob AS
  
  PROCEDURE test(in_x number);

END ztestbob;
/


CREATE OR REPLACE PACKAGE BODY ztestbob AS

  PROCEDURE test(in_x number)
  IS
    l_now DATE := sysdate;

  BEGIN
    dbms_output.put_line('ok1 ' || l_now);
    dbms_output.put_line('ok2 ' || in_x);
  END;

END ztestbob;
/
