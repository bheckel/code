DECLARE
  TYPE RecordTyp IS RECORD (
    last employees.last_name%TYPE,
    id   employees.employee_id%TYPE
  );
  rec1 RecordTyp;
BEGIN
  SELECT last_name, employee_id INTO rec1
  FROM employees
  WHERE job_id = 'AD_PRES';

  DBMS_OUTPUT.PUT_LINE ('Employee #' || rec1.id || ' = ' || rec1.last);
END;
/

---

-- If you need to retrieve a single row and you know that at most one row
-- should be retrieved, you should use a SELECT INTO statement, as in the following:
--
-- The implicit SELECT INTO offers the most-efficient means of returning that
-- single row of information to your PL/SQL program. In addition, the use of SELECT INTO states 
-- very clearly that you expect at most one row, and the statement will raise exceptions 
-- (NO_DATA_FOUND or TOO_MANY_ROWS) if your expectations are not met.
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
