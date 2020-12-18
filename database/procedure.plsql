-- Modified: 14-Dec-2020 (Bob Heckel)
-- See also nocopy.plsql

CREATE OR REPLACE PROCEDURE unique_seq(seq_name IN VARCHAR2, num_seqs_wanted IN PLS_INTEGER, seq_ids IN OUT NUMBER)
IS
	l_current_num  NUMBER := 0;
	l_max_num      NUMBER := 0;
	l_seq_name     VARCHAR2(100);
	
BEGIN   
  -- Get max from each database
  l_seq_name := seq_name || '@sed';

  EXECUTE IMMEDIATE 'SELECT ' || seq_name || '.NEXTVAL FROM dual'
    INTO l_current_num;
  
  IF l_current_num > l_max_num THEN
    l_max_num := l_current_num;
  END IF;
  
  dbms_output.put_line(l_max_num);
  seq_ids := 1;
END;

---

DECLARE
  emp_num NUMBER(6) := 120;
  bonus   NUMBER(6) := 50;

  PROCEDURE raise_salary (
    emp_id NUMBER,
    amount NUMBER)
  IS
  BEGIN
    UPDATE employees
    SET salary = salary + amount
    WHERE employee_id = emp_id;
  END raise_salary;

BEGIN
  -- Equivalent invocations:
  raise_salary(emp_num, bonus);                      -- positional notation
  raise_salary(amount => bonus, emp_id => emp_num);  -- named notation
  raise_salary(emp_id => emp_num, amount => bonus);  -- named notation
  raise_salary(emp_num, amount => bonus);            -- mixed notation
END;
/

---

-- SQL> @c:/temp/t.sql
CREATE OR REPLACE PROCEDURE Fire_Emp(Emp_Id NUMBER) AS
BEGIN
  delete from tmpbobh where foon1 = Emp_id;
  commit;
END;
/
-- SQL> EXECUTE FIRE_EMP(67)

---

-- Formal parameters:
--
-- IN (read-only) parameter passes a constant value from the calling environment to the procedure
--
-- OUT (write-only, sort of) parameter passes a value from the procedure to the calling environment
--
-- IN OUT (read/write) parameter passes a value from the calling environment to the
-- procedure and a possibly different value from the procedure back to the calling environment 
-- using the same parameter
--
-- Actual parameters could be variables (they MUST be variables if the parameter mode is OUT or IN OUT), constants, literals
-- or expressions e.g. display_title(INITCAP(happy_title));

-- Functions and procedures are structured alike. A function MUST return a value to the calling environment, 
-- whereas a procedure returns zero or more values to its calling environment through OUT parameters.

create or replace procedure raise_salary
  (p_id       IN employees.employee_id%TYPE,
   p_percent  IN NUMBER default 0)
is
begin
  update employees
  set salary=salary*(1+p_percent/100)
  where employee_id=p_id
  ;
end raise_salary;
/

execute raise_salary(176,10)

---

-- Use Native Dynamic SQL to pass a record to a procedure that will fill that record based on your parms
CREATE OR REPLACE PACKAGE mypkg AUTHID DEFINER 
AS
  TYPE myrec IS RECORD (
    n1 NUMBER,
    n2 NUMBER
  );
 
  PROCEDURE myp(x OUT myrec, y NUMBER default 0, z NUMBER := 0);
END mypkg;
/
CREATE OR REPLACE PACKAGE BODY mypkg
AS
  PROCEDURE myp(x OUT myrec, y NUMBER default 0, z NUMBER := 0)
  IS
  BEGIN
    x.n1 := y;
    x.n2 := z;
  END myp;
END mypkg;
/
-- Then use it
DECLARE
  r        mypkg.myrec;
  dyn_str  VARCHAR2(3000);
BEGIN
  dyn_str := 'BEGIN mypkg.myp(:x, 6, 8); END;';
 
  EXECUTE IMMEDIATE dyn_str 
    USING OUT r;
 
  DBMS_OUTPUT.PUT_LINE('r.n1 = ' || r.n1);
  DBMS_OUTPUT.PUT_LINE('r.n2 = ' || r.n2);
END;

---

DECLARE
  -- A nested local procedure. Local modules must be located after all of the other declaration 
  -- statements in the declaration section. You must declare your variables, cursors, 
  -- exceptions, types, records, tables, and so on before you type in the first PROCEDURE
  -- or FUNCTION keyword.
  --
  -- You should use local modules only to encapsulate code that does not need to be called
  -- outside of the current program. Otherwise create a package.
  PROCEDURE show_date(date_in IN DATE)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(date_in, 'Month DD, YYYY');
  END show_date;

  -- Overloading is legal
  PROCEDURE show_date(date_in IN VARCHAR2)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(date_in);
  END show_date;
BEGIN
  ...
END;

PROCEDURE assign_workload(department_in IN emp.deptno%TYPE)
IS
  -- Cursor takes same IN parameter
  CURSOR emps_in_dept_cur(department_in IN emp.deptno%TYPE) IS
    SELECT * FROM emp WHERE deptno = department_in;

  PROCEDURE assign_next_open_case(emp_id_in IN NUMBER, case_out OUT NUMBER)
  IS
  BEGIN
    ...full implementation...
  END;

  FUNCTION next_appointment(case_id_in IN NUMBER)
    RETURN DATE
  IS
  BEGIN
    ...full implementation...
  END;

  PROCEDURE schedule_case(case_in IN NUMBER, date_in IN DATE)
  IS
  BEGIN
    ...full implementation...
  END;

BEGIN /* main */
  FOR emp_rec IN emps_in_dept_cur (department_in) LOOP
    IF analysis.caseload (emp_rec.emp_id) < analysis.avg_cases (department_in);
      THEN
        assign_next_open_case (emp_rec.emp_id, case#);
        schedule_case (case#, next_appointment (case#));
    END IF;
   END LOOP
END assign_workload;

---

--https://learning.oreilly.com/library/view/oracle-plsql-programming/9781449324445/ch17.html#defining_pl_solidus_sql_subprograms_in

PROCEDURE calc_percentages(total_sales_in IN NUMBER)
IS
  l_profile sales_descriptors%ROWTYPE;
BEGIN
  l_profile.food_sales_stg :=
     TO_CHAR((sales_pkg.food_sales / total_sales_in ) * 100,
              '$999,999');
  l_profile.service_sales_stg :=
     TO_CHAR((sales_pkg.service_sales / total_sales_in ) * 100,
              '$999,999');
  l_profile.toy_sales_stg :=
     TO_CHAR((sales_pkg.toy_sales / total_sales_in ) * 100,
              '$999,999');
  ...              
END;

-- Better
PROCEDURE calc_percentages(total_sales_in IN NUMBER)
IS
  l_profile sales_descriptors%ROWTYPE;
  /* Define a function inside the procedure! */
  FUNCTION pct_stg(val_in IN NUMBER) RETURN VARCHAR2
  IS
  BEGIN
    RETURN TO_CHAR((val_in/total_sales_in ) * 100, '$999,999');
  END;
BEGIN
  l_profile.food_sales_stg := pct_stg(sales_pkg.food_sales);
  l_profile.service_sales_stg := pct_stg(sales_pkg.service_sales);
  l_profile.toy_sales_stg := pct_stg(sales_pkg.toy_sales);
  ...  
END;


-- Forward declaration
--
-- Define two mutually recursive functions within a procedure. Consequently, we 
-- MUST declare just the header of my second function, total_cost, before the 
-- full declaration of net_profit:
PROCEDURE perform_calcs(year_in IN INTEGER)
IS
  /* Header only for total_cost function. */
  FUNCTION total_cost(...) RETURN NUMBER;

  /* The net_profit function uses the total_cost function */
  FUNCTION net_profit(...) RETURN NUMBER
  IS
  BEGIN
    RETURN total_sales(...) - total_cost(...);
  END;

  /* The total_cost function uses the net_profit function */
   FUNCTION total_cost(...) RETURN NUMBER
   IS
   BEGIN
     IF <condition based on parameters>
     THEN
       RETURN net_profit(...) * .10;
     ELSE
       RETURN <parameter value>;
      END IF;
   END;
BEGIN
   ...
END;
