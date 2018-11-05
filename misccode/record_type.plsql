CREATE OR REPLACE PACKAGE department_pkg AUTHID DEFINER IS
 
  TYPE dept_info_record IS RECORD (
    dept_name  departments.department_name%TYPE,
    mgr_name   employees.last_name%TYPE,
    dept_size  PLS_INTEGER
  );
 
  -- Function declaration
  -- The best candidates for result-caching are functions that are invoked frequently but depend on information that changes infrequently 
  -- or never
  FUNCTION get_dept_info(dept_id NUMBER)
    RETURN dept_info_record
    RESULT_CACHE;
 
END department_pkg;
/
CREATE OR REPLACE PACKAGE BODY department_pkg IS
  -- Function definition
  FUNCTION get_dept_info(dept_id NUMBER)
    RETURN dept_info_record
    RESULT_CACHE
  IS
    rec  dept_info_record;
  BEGIN
    SELECT department_name INTO rec.dept_name
    FROM departments
    WHERE department_id = dept_id;
 
    SELECT e.last_name INTO rec.mgr_name
    FROM departments d, employees e
    WHERE d.department_id = dept_id
    AND d.manager_id = e.employee_id;
 
    SELECT COUNT(*) INTO rec.dept_size
    FROM EMPLOYEES
    WHERE department_id = dept_id;
 
    RETURN rec;
  END get_dept_info;
END department_pkg;
/

---

DECLARE
  TYPE name_rec IS RECORD (
    first  employees.first_name%TYPE DEFAULT 'John',
    last   employees.last_name%TYPE DEFAULT 'Doe'
  );
 
  name1 name_rec;
  name2 name_rec;
 
BEGIN
  name1.first := 'Jane'; name1.last := 'Smith'; 
  DBMS_OUTPUT.PUT_LINE('name1: ' || name1.first || ' ' || name1.last);
  name2 := name1;
  DBMS_OUTPUT.PUT_LINE('name2: ' || name2.first || ' ' || name2.last); 
END;
/
