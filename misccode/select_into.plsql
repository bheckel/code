
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
