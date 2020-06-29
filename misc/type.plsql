-- Adapted: 04-Jun-2020 (Bob Heckel--DevGym)
-- See also collections.plsql

DECLARE
   TYPE t_employee IS TABLE OF emp%ROWTYPE;
   /* TYPE t_employee IS TABLE OF emp%ROWTYPE INDEX BY PLS_INTEGER; */

   l_employees  t_employee;
BEGIN
   SELECT *
     BULK COLLECT INTO l_employees
     FROM emp
    WHERE deptno = 20;

   DBMS_OUTPUT.PUT_LINE(l_employees.COUNT);
END;

-- If you do not want to retrieve all the columns in a table, create your own user-defined record type and use that to define your
-- collection. All you have to do is make sure the list of expressions in the SELECT match the record type's fields.
DECLARE
   TYPE rt_two_col_employee IS RECORD (
     employee_id   emp.empno%TYPE,
     salary        emp.sal%TYPE
   );

   TYPE t_employee IS TABLE OF rt_two_col_employee;
   /* TYPE t_employee IS TABLE OF rt_two_col_employee INDEX BY PLS_INTEGER; */

   l_employees   t_employee;
BEGIN
   SELECT empno, sal
     BULK COLLECT INTO l_employees
     FROM emp
    WHERE deptno = 20;

   DBMS_OUTPUT.PUT_LINE(l_employees.COUNT);
END;
