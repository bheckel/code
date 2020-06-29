
-- Modified: Thu 25 Apr 2019 11:28:41 (Bob Heckel) 
-- If your program does not require that an OUT or IN OUT parameter retain its
-- pre-invocation value if the subprogram ends with an unhandled exception, then
-- include the NOCOPY hint in the parameter declaration. The NOCOPY hint requests
-- (but does not ensure) that the compiler pass the corresponding actual parameter
-- by reference instead of value.
DECLARE
  TYPE EmpTabTyp IS TABLE OF hr.employees%ROWTYPE;
  emp_tab EmpTabTyp := EmpTabTyp(NULL);
  t1 timestamp;
  t2 timestamp;
  t3 timestamp;

  PROCEDURE do_nothing1(tab IN OUT EmpTabTyp) IS
  BEGIN
    NULL;
  END;

  PROCEDURE do_nothing2(tab IN OUT NOCOPY EmpTabTyp) IS
  BEGIN
    NULL;
  END;

BEGIN
  SELECT * INTO emp_tab(1)
  FROM hr.employees
  WHERE employee_id = 100;

  emp_tab.EXTEND(499999, 1);  -- copy element 1 into 2 .. 500000
  
  -- Benchmark performance
  SELECT SYSTIMESTAMP INTO t1 FROM DUAL;

  do_nothing1(emp_tab);  -- pass IN OUT parameter
  SELECT SYSTIMESTAMP INTO t2 FROM DUAL;

  do_nothing2(emp_tab);  -- pass IN OUT NOCOPY parameter
  SELECT SYSTIMESTAMP INTO t3 FROM DUAL;
  
  DBMS_OUTPUT.PUT_LINE ('Just IN OUT: ' || (t2 - t1));
  DBMS_OUTPUT.PUT_LINE ('With NOCOPY: ' || (t3 - t2));
END;
/
