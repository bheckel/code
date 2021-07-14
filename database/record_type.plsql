------------------------------------------------------------------------------------------
-- Modified: Fri 26 Apr 2019 13:01:44 (Bob Heckel) 

-- RECORDs cannot be tested for nullity (e.g. IS NULL), equality, or inequality but can be
-- assigned a value of NULL
------------------------------------------------------------------------------------------

DECLARE
  -- Record based on a table's columns
  TYPE name_rec IS RECORD (
    first  employees.first_name%TYPE DEFAULT 'John',
    last   employees.last_name%TYPE DEFAULT 'Doe'
  );
 
  name1 name_rec;
  name2 name_rec;
 
BEGIN
  DBMS_OUTPUT.PUT_LINE('name1: ' || name1.first || ' ' || name1.last);
/*
John Doe
*/
  name1.first := 'Jane';
  name1.last := 'Smith'; 
  DBMS_OUTPUT.PUT_LINE('name1: ' || name1.first || ' ' || name1.last);
/*
Jane Smith
*/
  -- Assign one record to another
  name2 := name1;
  DBMS_OUTPUT.PUT_LINE('name2: ' || name2.first || ' ' || name2.last); 
/*
Jane Smith
*/
END;
/

---

DECLARE
	CURSOR course_cur IS
		SELECT * FROM course WHERE rownum < 2;

  -- Declare TYPE
	TYPE course_rectype IS RECORD (
    course_no NUMBER(38)
   ,description VARCHAR2(50)
   ,cost NUMBER(9,2)
   ,prerequisite NUMBER(8)
   ,created_by VARCHAR2(30)
   ,created_date DATE
   ,modified_by VARCHAR2(30)
   ,modified_date DATE
   ,dataset SYS_REFCURSOR
  );

  -- Declare RECORDs
  course_rec1 course%ROWTYPE;     -- table-based record anchor
  course_rec2 course_cur%ROWTYPE; -- cursor-based record anchor
  course_rec3 course_rectype;     -- programmer-defined record, note no ROWTYPE needed
  --course_rec4 course_rectype;   -- implicit record so doesn't need to be declared

BEGIN
  -- Populate a table-based record type
  SELECT *
  INTO course_rec1
  FROM course
  WHERE course_no = 10;

  -- Populate a cursor-based record type
  OPEN course_cur;
  LOOP
    FETCH course_cur INTO course_rec2;
    EXIT WHEN course_cur%NOTFOUND;
  END LOOP;

  course_rec1 := course_rec2;
  course_rec3 := course_rec2;

  DBMS_OUTPUT.PUT_LINE(course_rec1.course_no||' - '||course_rec1.description);
  DBMS_OUTPUT.PUT_LINE(course_rec2.course_no||' - '||course_rec2.description);
  DBMS_OUTPUT.PUT_LINE(course_rec3.course_no||' - '||course_rec3.description);

  -- Or implicitly, with a cursor FOR loop
   FOR course_rec4 IN ( SELECT * FROM course WHERE course_no = 10 ) LOOP
     DBMS_OUTPUT.PUT_LINE(course_rec4.course_no||' - '||course_rec4.description);
   END LOOP;
END;

---

CREATE OR REPLACE PACKAGE department_pkg AUTHID DEFINER
IS
  TYPE dept_info_record IS RECORD (
    dept_name  DEPARTMENTS.department_name%TYPE,  -- we don't want the whole %ROWTYPE from DEPARTMENTS
    mgr_name   EMPLOYEES.last_name%TYPE,
    dept_size  PLS_INTEGER
    dept_cnt   PLS_INTEGER := 10;
  );
 
  -- Function declaration
  FUNCTION get_dept_info(dept_id NUMBER)
    RETURN dept_info_record RESULT_CACHE;
 
END department_pkg;
/
CREATE OR REPLACE PACKAGE BODY department_pkg
IS
  -- Function definition
  FUNCTION get_dept_info(dept_id NUMBER)
    RETURN dept_info_record RESULT_CACHE
  IS
    rec  dept_info_record;
  BEGIN
    -- Populate the RECORD 'rec':

    SELECT department_name
      INTO rec.dept_name
      FROM departments
     WHERE department_id = dept_id;
 
    SELECT e.last_name 
      INTO rec.mgr_name
      FROM departments d, employees e
     WHERE d.department_id = dept_id
       AND d.manager_id = e.employee_id;
 
    SELECT COUNT(*) 
      INTO rec.dept_size
      FROM employees
     WHERE department_id = dept_id;
 
    RETURN rec;
  END get_dept_info;
END department_pkg;

---

-- Record constant https://docs.oracle.com/database/121/LNPLS/composites.htm#LNPLS99856
CREATE OR REPLACE PACKAGE mypkg AUTHID CURRENT_USER IS
  TYPE t_rec IS RECORD (a NUMBER,
                        b NUMBER);

  FUNCTION Init_My_Rec RETURN t_rec;
END mypkg;
/
CREATE OR REPLACE PACKAGE BODY mypkg IS
  FUNCTION Init_My_Rec RETURN t_rec
  IS
    myrec t_rec;
  BEGIN
    myrec.a := 0;
    myrec.b := 1;

    RETURN myrec;
  END Init_My_Rec;
END mypkg;
/
DECLARE
  r CONSTANT mypkg.t_rec := mypkg.Init_My_Rec();
BEGIN
  DBMS_OUTPUT.PUT_LINE('r.a = ' || r.a);
  DBMS_OUTPUT.PUT_LINE('r.b = ' || r.b);
END;
/

DROP PACKAGE mypkg;

---

-- Nested record
DECLARE
  TYPE name_rec IS RECORD (
    first EMPLOYEES.first_name%TYPE,
    last  EMPLOYEES.last_name%TYPE
  );
 
  TYPE contact_rec IS RECORD (
    nnm    name_rec,  -- nested record
    phone  EMPLOYEES.phone_number%TYPE
  );
 
  friend contact_rec;
/
BEGIN
  friend.nnm.first := 'John';
  friend.nnm.last := 'Smith';
  friend.phone := '1-650-555-1234';
  
  DBMS_OUTPUT.PUT_LINE (
    friend.nnm.first  || ' ' ||
    friend.nnm.last   || ', ' ||
    friend.phone
  );
END;

---

DECLARE
   rain_forest_rec rain_forest_history%ROWTYPE;
BEGIN
   /* Set values for the record */
   rain_forest_rec.country_code  := 1005;
   rain_forest_rec.analysis_date := ADD_MONTHS(TRUNC(SYSDATE), −3);
   rain_forest_rec.size_in_acres := 32;
   rain_forest_rec.species_lost  := 425;

   /* Insert a row in the table using the record values */

   /*
   INSERT INTO rain_forest_history
          (country_code, analysis_date, size_in_acres, species_lost)
   VALUES
      (rain_forest_rec.country_code,
       rain_forest_rec.analysis_date,
       rain_forest_rec.size_in_acres,
       rain_forest_rec.species_lost);
   */       
   -- or v9+ simply
   INSERT INTO rain_forest_history
       VALUES rain_forest_rec;

   ...
END;
