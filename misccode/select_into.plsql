-- If you need to retrieve a single row and you know that at most one row
-- should be retrieved, you should use a SELECT INTO statement, as in the following:

PROCEDURE process_employee (
   id_in IN employees.employee_id%TYPE)
IS
   l_last_name employees.last_name%TYPE;
BEGIN
   SELECT e.last_name
      INTO l_last_name
     FROM employees e
   WHERE e.employee_id = process_employee.id_in;
   ...
END process_employee;
-- The implicit SELECT INTO offers the most-efficient means of returning that
-- single row of information to your PL/SQL program. In addition, the use of SELECT INTO states 
-- very clearly that you expect at most one row, and the statement will raise exceptions 
-- (NO_DATA_FOUND or TOO_MANY_ROWS) if your expectations are not met.

---

DECLARE
   emp_id   emp.empno%TYPE;
   emp_name emp.ename%TYPE;
   wages    NUMBER(7,2);
BEGIN
   -- assign a value to emp_id here
   SELECT ename, sal + comm
      INTO emp_name, wages FROM emp
      WHERE empno = emp_id;
   ...
END;
