Put this in c:/temp/t.sql:

set serveroutput on

CREATE OR REPLACE PROCEDURE Fire_Emp(Emp_Id NUMBER) AS
BEGIN
  delete from tmpbobh where foon1 = Emp_id;
  commit;
END;
/

SQL> @c:/temp/t.sql

SQL> EXECUTE FIRE_EMP(67)
