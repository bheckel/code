DECLARE
	CURSOR course_cur IS
		SELECT * FROM course WHERE rownum < 2;

	TYPE course_type IS RECORD (
    course_no NUMBER(38)
   ,description VARCHAR2(50)
   ,cost NUMBER(9,2)
   ,prerequisite NUMBER(8)
   ,created_by VARCHAR2(30)
   ,created_date DATE
   ,modified_by VARCHAR2(30)
   ,modified_date DATE
  );

  course_rec1 course%ROWTYPE;     -- table-based record
  course_rec2 course_cur%ROWTYPE; -- cursor-based record
  course_rec3 course_type;        -- user-defined record

BEGIN
  -- Populate table-based record
  SELECT *
  INTO course_rec1
  FROM course
  WHERE course_no = 10;

  -- Populate cursor-based record
  OPEN course_cur;
  LOOP
    FETCH course_cur INTO course_rec2;
    EXIT WHEN course_cur%NOTFOUND;
  END LOOP;

  -- Assign COURSE_REC2 to COURSE_REC1 and COURSE_REC3
  course_rec1 := course_rec2;
  course_rec3 := course_rec2;

  DBMS_OUTPUT.PUT_LINE(course_rec1.course_no||' - '||course_rec1.description);
  DBMS_OUTPUT.PUT_LINE(course_rec2.course_no||' - '||course_rec2.description);
  DBMS_OUTPUT.PUT_LINE(course_rec3.course_no||' - '||course_rec3.description);
END;

---

-- Records cannot be tested for nullity, equality, or inequality

---

CREATE OR REPLACE PACKAGE department_pkg AUTHID DEFINER IS
 
  TYPE dept_info_record IS RECORD (
    dept_name  departments.department_name%TYPE,
    mgr_name   employees.last_name%TYPE,
    dept_size  PLS_INTEGER
    dept_cnt   PLS_INTEGER := 10;
  );
 
  -- Function declaration
  -- The best candidates for result-caching are functions that are invoked frequently but 
  -- depend on information that changes infrequently or never
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
    -- Populate the record 'rec':

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
  -- John Doe
  DBMS_OUTPUT.PUT_LINE('name1: ' || name1.first || ' ' || name1.last);

  -- Jane Smith
  name1.first := 'Jane'; name1.last := 'Smith'; 
  DBMS_OUTPUT.PUT_LINE('name1: ' || name1.first || ' ' || name1.last);

  -- Assign one record to another
  -- Jane Smith
  name2 := name1;
  DBMS_OUTPUT.PUT_LINE('name2: ' || name2.first || ' ' || name2.last); 
END;
/
