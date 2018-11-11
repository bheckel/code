
DECLARE
  TYPE R_TARGET IS RECORD(
    COMP_EMP_TARGET_ID            COMP_EMP_TARGET_BASE.COMP_EMP_TARGET_ID%TYPE,
    EMPLOYEE_ID                   COMP_EMP_TARGET_BASE.EMPLOYEE_ID%TYPE,
    PERCENT_ATTAINMENT_DATE       CHAR(6));

  TYPE T_TARGET_TABLE IS TABLE OF R_TARGET INDEX BY PLS_INTEGER;
BEGIN
  target R_TARGET; 

  select COMP_EMP_TARGET_ID, EMPLOYEE_ID, PERCENT_ATTAINMENT_DATE
  into target
  from foo;

  targettbl T_TARGET_TABLE;

  select 1234 COMP_EMP_TARGET_ID, EMPLOYEE_ID, PERCENT_ATTAINMENT_DATE
  into targettbl(1)
  from foo;

  select 5678 COMP_EMP_TARGET_ID, EMPLOYEE_ID, PERCENT_ATTAINMENT_DATE
  into targettbl(2)
  from foo;

END:

---

-- Treat nested tables like either fixed-size arrays (and use only DELETE) or
-- stacks (and use only TRIM and EXTEND)

---

-- https://www.tutorialspoint.com/plsql/plsql_collections.htm

DECLARE 
   TYPE salary IS TABLE OF NUMBER INDEX BY VARCHAR2(20); 
   salary_list salary; 
   name   VARCHAR2(20); 
BEGIN 
   -- adding elements to the table 
   salary_list('Rajnish') := 62000; 
   salary_list('Minakshi') := 75000; 
   salary_list('Martin') := 100000; 
   salary_list('James') := 78000;  
   
   -- printing the table 
   name := salary_list.FIRST; 
   WHILE name IS NOT null LOOP 
      dbms_output.put_line 
      ('Salary of ' || name || ' is ' || TO_CHAR(salary_list(name))); 
      name := salary_list.NEXT(name); 
   END LOOP; 
END;

---

DECLARE 
   CURSOR c IS 
      select name from customers; 

   TYPE c_list IS TABLE of customers.Name%type INDEX BY binary_integer; 
   name_list c_list; 
   counter integer :=0; 
BEGIN 
   FOR n IN c LOOP 
      counter := counter +1; 
      name_list(counter) := n.name; 
      dbms_output.put_line('Customer('||counter||'):'||name_lis t(counter)); 
   END LOOP; 
END; 
/ 
