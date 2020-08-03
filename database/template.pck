CREATE OR REPLACE PACKAGE ztest2 AS
  
  PROCEDURE t(in_x number);

END ztest2;

CREATE OR REPLACE PACKAGE BODY ztest2 AS

  PROCEDURE t(in_x number) IS
  	x number := 1;
  	y NUMBER;
  BEGIN
    dbms_output.put_line('ok ' || SYSTIMESTAMP);
    y := in_x + 1;
  END;

END ztest2;
