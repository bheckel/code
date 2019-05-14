-- Modified: Tue, Apr 23, 2019 12:47:11 PM (Bob Heckel) 

-- When you need to get info back after a DML operation

/* https://docs.oracle.com/database/121/LNPLS/composites.htm#LNPLS1414 */

-- One record:
DECLARE
  old_salary  employees.salary%TYPE;

  TYPE EmpRec IS RECORD (
    last_name  employees.last_name%TYPE,
    salary     employees.salary%TYPE
  );

  emp EmpRec;

BEGIN
  SELECT salary INTO old_salary
   FROM employees
   WHERE employee_id = 100;
 
  -- Use the RETURNING clause to retrieve details from the employee's modified row (i.e. row(s) affected by 
  -- DML statements), within the same context switch used to execute the UPDATE statement (i.e. no following SELECT
  -- is required)
  UPDATE employees
    SET salary = salary * 1.1
    WHERE employee_id = 100
    RETURNING last_name, salary INTO emp;
 
  DBMS_OUTPUT.PUT_LINE (
    'Salary of ' || emp.last_name || ' raised from ' ||
    old_salary || ' to ' || emp.salary
  );
END;
/

---

-- Multiple records
CREATE TABLE plch_parts
(
   partnum    INTEGER
 , partname   VARCHAR2 (100)
);

BEGIN
   INSERT INTO plch_parts VALUES (1, 'Mouse');
   INSERT INTO plch_parts VALUES (100, 'Keyboard');
   INSERT INTO plch_parts VALUES (500, 'Monitor');
   COMMIT;
END;

--delete from plch_parts

--select partname from plch_parts WHERE partname LIKE 'M%'

DECLARE
   type nt_t is table of plch_parts.partnum%type;
   nt nt_t;
BEGIN
      UPDATE plch_parts
         SET partname = UPPER (partname)
       WHERE partname LIKE 'M%'
   RETURNING partnum BULK COLLECT INTO nt;  -- must bulk collect

  for i in nt.first .. nt.last loop
     DBMS_OUTPUT.put_line ('x ' || nt(i)) ;
  end loop;

  rollback;
END;

---

-- Aggregates
DECLARE
   l_num   PLS_INTEGER;
BEGIN
      UPDATE plch_parts
         SET partname = UPPER (partname)
       WHERE partname LIKE 'M%'
   RETURNING count(1) INTO l_num;

   DBMS_OUTPUT.put_line ('x ' || l_num) ;

	rollback;
END;
