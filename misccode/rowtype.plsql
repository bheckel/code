
DECLARE
  -- Based on TABLE (see cursor.plsql for example of on CURSOR)
  emp_rec emp%ROWTYPE;
BEGIN
  SELECT * INTO emp_rec FROM emp WHERE ...
  IF emp_rec.deptno = 20 THEN
    emp_rec.ename := 'JOHNSON';
  END IF;
END;
