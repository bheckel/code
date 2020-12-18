
CREATE OR REPLACE PROCEDURE print_cursor (
  p_dept IN emp.deptno%TYPE)
IS
  l_cursor  SYS_REFCURSOR;
BEGIN
  OPEN l_cursor FOR
    SELECT ename
      FROM emp
     WHERE deptno = p_dept;

  DBMS_SQL.return_result (l_cursor);
END;

exec print_cursor(10);
