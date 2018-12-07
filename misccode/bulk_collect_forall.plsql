-- To do bulk binds with SELECT statements, you include the BULK COLLECT clause in the SELECT statement instead of using INTO clause (or FETCH INTO, RETURNING INTO)
DECLARE
  TYPE NumTab IS TABLE OF hr.employees.employee_id%TYPE;
  TYPE NameTab IS TABLE OF hr.employees.last_name%TYPE;
 
  -- Collections to bulk collect into:
  nums  NumTab;
  names NameTab;
 
  PROCEDURE print_first_n(n POSITIVE) IS
		BEGIN
			IF nums.COUNT = 0 THEN
				DBMS_OUTPUT.PUT_LINE ('Collections are empty.');
			ELSE
				DBMS_OUTPUT.PUT_LINE ('First ' || n || ' employees:');
	 
				FOR i IN 1 .. n LOOP
					DBMS_OUTPUT.PUT_LINE ('  Employee #' || nums(i) || ': ' || names(i));
				END LOOP;
			END IF;
		END;
 
BEGIN
  SELECT employee_id, last_name
  BULK COLLECT INTO nums, names
  FROM hr.employees
  ORDER BY employee_id;
 
  print_first_n(3);
  print_first_n(6);
END;
/


-- To do bulk binds with INSERT, UPDATE, and DELETE statements, you enclose the SQL statement within a PL/SQL FORALL statement
DECLARE
  TYPE NumList IS VARRAY(20) OF NUMBER;
  depts NumList := NumList(10, 30, 70);
BEGIN
  FORALL i IN depts.FIRST..depts.LAST
    DELETE FROM emp WHERE deptno = depts(i);
END;

DECLARE
  TYPE NumList IS VARRAY(10) OF NUMBER;
  depts NumList := NumList(20, 30, 50, 55, 57, 60, 70, 75, 90, 92);
BEGIN
  FORALL j IN 4..7  -- bulk-bind only part of varray
    UPDATE emp SET sal = sal * 1.10 WHERE deptno = depts(j);
END;

---

CREATE OR REPLACE PACKAGE DemoBCFA_Pkg IS

 PROCEDURE DemoBCFA;

END DemoBCFA_Pkg;
/
CREATE OR REPLACE PACKAGE BODY DemoBCFA_Pkg IS

  PROCEDURE DemoBCFA IS
    l_tbl_rows     PLS_INTEGER := 0;
    l_tbl_rows_tot PLS_INTEGER := 0;
    l_limit_group  PLS_INTEGER := 0;

    failure_in_forall EXCEPTION;  
    PRAGMA EXCEPTION_INIT (failure_in_forall, -24381);  -- ORA-24381: error(s) in array DML  

    CURSOR c IS 
      select id from employees where id=162;
    
    TYPE t_emp_tbl_type IS TABLE OF c%ROWTYPE;

    t_emp_tbl t_emp_tbl_type;

    BEGIN
      OPEN c;
      LOOP
        FETCH c BULK COLLECT INTO t_emp_tbl LIMIT 300;

        l_limit_group := l_limit_group + 1;
        l_tbl_rows := t_emp_tbl.COUNT;
        l_tbl_rows_tot := l_tbl_rows_tot + l_tbl_rows;
        
        -- Message assumes each FORALL loop *will* process these counts, not that we *have* processed them
        dbms_output.put_line(to_char(sysdate, 'DD-Mon-YYYY HH24:MI:SS') || ': iteration ' || l_limit_group || ' processing ' || l_tbl_rows || ' records' || ' total ' || l_tbl_rows_tot);

        EXIT WHEN l_tbl_rows = 0;

        BEGIN
          -- A FORALL statement is usually much faster than an equivalent FOR
          -- LOOP statement. However, a FOR LOOP statement can contain multiple DML
          -- statements, while a FORALL statement can contain only one. The batch of
          -- DML statements that a FORALL statement sends to SQL differ only in
          -- their VALUES and WHERE clauses. The values in those clauses must come
          -- from existing, populated collections.
          FORALL i IN 1 .. l_tbl_rows SAVE EXCEPTIONS  -- to have a bulk bind complete despite errors, add keywords SAVE EXCEPTIONS
            DELETE FROM employees WHERE id=t_emp_tbl(i).id;
            --raise failure_in_forall;

        EXCEPTION
            WHEN failure_in_forall THEN   
              DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_stack);   
              DBMS_OUTPUT.put_line('Updated ' || SQL%ROWCOUNT || ' rows prior to EXCEPTION');
   
              FOR ix IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP   
                DBMS_OUTPUT.put_line ('Error ' || ix || ' occurred on iteration ' || SQL%BULK_EXCEPTIONS(ix).ERROR_INDEX || '  with error code ' || SQL%BULK_EXCEPTIONS(ix).ERROR_CODE ||
                                       ' ' || SQLERRM(-(SQL%BULK_EXCEPTIONS(ix).ERROR_CODE)));
              END LOOP; 
              -- Now keep doing the next l_limit_group...
        END;
        COMMIT;  -- 300 rows to minimize locks
      END LOOP;
      COMMIT;
    CLOSE c;
    
  END DemoBCFA;

END DemoBCFA_Pkg;
/

---

DECLARE
  TYPE NumList IS TABLE OF NUMBER;
  depts  NumList := NumList(10,20,30);

  TYPE enum_t IS TABLE OF employees.employee_id%TYPE;
  e_ids  enum_t;

  TYPE dept_t IS TABLE OF employees.department_id%TYPE;
  d_ids  dept_t;

BEGIN
  FORALL d IN depts.FIRST..depts.LAST
    DELETE FROM emp_temp
    WHERE department_id = depts(d)
    RETURNING employee_id, department_id
    BULK COLLECT INTO e_ids, d_ids;

  DBMS_OUTPUT.PUT_LINE ('Deleted ' || SQL%ROWCOUNT || ' rows:');

  FOR e IN e_ids.FIRST .. e_ids.LAST LOOP
    DBMS_OUTPUT.PUT_LINE ('Employee #' || e_ids(e) || ' from dept #' || d_ids(e));
  END LOOP;
END;
/

---

CREATE TABLE plch_employees (
  employee_id   INTEGER
  , last_name   VARCHAR2(100)
  , salary      NUMBER
)
/

BEGIN
   INSERT INTO plch_employees VALUES (100, 'Ellison', 1000000);
   INSERT INTO plch_employees VALUES (200, 'Gates', 1000000);
   INSERT INTO plch_employees VALUES (300, 'Zuckerberg', 1000000);
   COMMIT;
END;
/

/* Fill a collection with an explicit cursor: */
DECLARE
   CURSOR plch_employees_cur
   IS
      SELECT * FROM plch_employees;

   /* Must index by number if using assoc array collection */
   TYPE plch_employees_aat IS TABLE OF plch_employees%ROWTYPE INDEX BY BINARY_INTEGER;

   l_plch_employees plch_employees_aat;
BEGIN
   OPEN plch_employees_cur;

   FETCH plch_employees_cur BULK COLLECT INTO l_plch_employees;

   CLOSE plch_employees_cur;
END;
/

/* Fill a collection with an implicit cursor: */
DECLARE
   TYPE plch_employees_aat IS TABLE OF plch_employees%ROWTYPE INDEX BY BINARY_INTEGER;

   l_plch_employees plch_employees_aat;
BEGIN
   SELECT *
     BULK COLLECT INTO l_plch_employees
     FROM plch_employees;
END;
/

/* Fill a collection with a dynamic SQL statement (Oracle 9i Release 2 and above): */
DECLARE
   TYPE plch_employees_aat IS TABLE OF plch_employees%ROWTYPE INDEX BY BINARY_INTEGER;

   l_plch_employees plch_employees_aat;
BEGIN
   EXECUTE IMMEDIATE 'SELECT * FROM plch_employees'
      BULK COLLECT INTO l_plch_employees;
END;
/

/* Fill a collection with a strong cursor variable: */
DECLARE
   l_cursor   SYS_REFCURSOR;
   l_list     DBMS_SQL.varchar2s;
BEGIN
   OPEN l_cursor FOR SELECT last_name FROM plch_employees;

   LOOP
      FETCH l_cursor BULK COLLECT INTO l_list LIMIT 100;

      EXIT WHEN l_list.COUNT = 0;
   END LOOP;

   CLOSE l_cursor;
END;
/

DROP TABLE plch_employees
/

---

CREATE TABLE plch_stuff (
   id       NUMBER PRIMARY KEY
 , rating   INTEGER
)
/

BEGIN
   INSERT INTO plch_stuff VALUES (100, 50);
   INSERT INTO plch_stuff VALUES (200, 25);
   COMMIT;
END;
/

DECLARE
   TYPE stuff_t IS TABLE OF plch_stuff%ROWTYPE;

   l_stuff   stuff_t;
   x NUMBER;
BEGIN
   SELECT *
     BULK COLLECT INTO l_stuff
     FROM plch_stuff;

   /* First is always 1, and COUNT = count of rows fetched. */
   DBMS_OUTPUT.put_line(l_stuff.FIRST);
   DBMS_OUTPUT.put_line(l_stuff.COUNT);

   FOR i IN 1 ..l_stuff.COUNT
   LOOP
    x := l_stuff(i).rating;
    dbms_output.put_line(x);
    dbms_output.put_line(l_stuff(i).rating);
   END LOOP;

   /* Now do it again - will see same count */
   SELECT *
     BULK COLLECT INTO l_stuff
     FROM plch_stuff;

   DBMS_OUTPUT.put_line (l_stuff.COUNT);
END;
/

DROP TABLE plch_stuff
/

---

-- BULK COLLECT with LIMIT when you don’t know the upper limit. BULK COLLECT
-- helps retrieve multiple rows of data quickly. Rather than retrieve one row of
-- data at a time into a record or a set of individual variables, BULK COLLECT
-- lets us retrieve hundreds, thousands, even tens of thousands of rows with a
-- single context switch to the SQL engine and deposit all that data into a
-- collection.

PROCEDURE bulk_with_limit (
   dept_id_in   IN   employees.department_id%TYPE
 , limit_in     IN   PLS_INTEGER DEFAULT 100
)
IS
   CURSOR employees_cur
   IS
      SELECT *
      FROM employees
      WHERE department_id = dept_id_in;

   TYPE employee_ntt IS TABLE OF employees_cur%ROWTYPE INDEX BY PLS_INTEGER;
   l_employees   employee_ntt;

BEGIN
   OPEN employees_cur;
   LOOP
      FETCH employees_cur
      BULK COLLECT INTO l_employees LIMIT limit_in;
      FOR indx IN 1 .. l_employees.COUNT
      LOOP
         process_each_employees(l_employees (indx));
      END LOOP;
      EXIT WHEN employees_cur%NOTFOUND;
   END LOOP;
   CLOSE employees_cur;
END bulk_with_limit;

---

/* See also insert_invitations.pck */

/* https://blogs.oracle.com/oraclemagazine/bulk-processing-with-bulk-collect-and-forall */

 /* If the SQL engine raises an error, the PL/SQL engine will save that
  * information in a pseudocollection named SQL%BULK_EXCEPTIONS, and continue
  * executing statements. When all statements have been attempted, PL/SQL then
  * raises the ORA-24381 error
*/
BEGIN
   FORALL indx IN 1 .. l_eligible_ids.COUNT SAVE EXCEPTIONS
      UPDATE employees emp
         SET emp.salary = emp.salary + emp.salary * increase_pct_in
       WHERE emp.employee_id = l_eligible_ids(indx);
EXCEPTION
   WHEN OTHERS
   THEN
      IF SQLCODE = -24381
      THEN
         FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT
         LOOP
            DBMS_OUTPUT.put_line (
                  SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX
               || ': '
               || SQL%BULK_EXCEPTIONS (indx).ERROR_CODE);
         END LOOP;
      ELSE
         RAISE;
      END IF;
END;

---

CURSOR c IS
   select ri.risk_id as import_risk_id, ri.new_risk_id, rp.risk_id, 
          asp.account_site_id, asp.product, ri.product_code
          ,rp.risk_product_id,ri.at_risk_amount, ri.risk_amount,
          sum(nvl(ri.at_risk_amount,0)) over (partition by rp.risk_id) as tot_at_risk_amt
   from   risk_import_uk ri,
          risk_product rp,
          account_site_product asp
   where  rp.risk_id = ri.new_risk_id
   and    asp.ACCOUNT_SITE_PRODUCT_ID = rp.ACCOUNT_SITE_PRODUCT_ID
   and    asp.PRODUCT = ri.PRODUCT_CODE
   order  by rp.risk_id;
   
TYPE t_tab_type IS TABLE OF c%ROWTYPE;
t_tab t_tab_type;

l_tab_size NUMBER := 0;

BEGIN
  OPEN c;
  LOOP
     FETCH c BULK COLLECT INTO t_tab LIMIT 500;
     l_tab_size := t_tab.COUNT;
     EXIT WHEN l_tab_size = 0;
     
     FORALL i IN 1..l_tab_size
         UPDATE RISK_PRODUCT
         SET    UPDATED = UPDATED, UPDATEDBY = UPDATEDBY,
                AT_RISK_AMOUNT = t_tab(i).AT_RISK_AMOUNT
         WHERE  risk_product_id = t_tab(i).risk_product_id;
         
     COMMIT;
          
  END LOOP;
  CLOSE c;
END;
