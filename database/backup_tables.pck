CREATE OR REPLACE PACKAGE RION39939 IS
 
 PROCEDURE bkuptbl(tblnm VARCHAR2);

END;
/


CREATE OR REPLACE PACKAGE BODY RION39939 IS

  PROCEDURE bkuptbl(tblnm VARCHAR2) IS
    sqlstr VARCHAR2(4000);

    BEGIN
      dbms_output.put_line(tblnm);
      
      sqlstr := 'create table ' || trim(tblnm) || '_2 as select * from ' || tblnm;
      
      execute immediate sqlstr;
      
      
  END;
  
END;
/
