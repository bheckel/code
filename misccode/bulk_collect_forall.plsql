
-- DevGym 01Apr19
-- Modified: Tue 23 Apr 2019 14:01:47 (Bob Heckel)
-- See also suppress_rowlevel_dml_errors.plsql
--
-- The PL/SQL features that comprise bulk SQL are the FORALL statement and the
-- BULK COLLECT clause.
-- The FORALL statement sends DML statements from PL/SQL to SQL in batches rather 
-- than one at a time i.e. it binds all the data in a collection into a DML statement.
-- The BULK COLLECT clause returns results from SQL to PL/SQL in batches rather than 
-- one at a time i.e. it pulls multiple rows back into a collection.
--
-- If a query or DML statement affects four or more database rows, then bulk SQL can
-- significantly improve performance but reducing context switches.
--
-- If the query does not return any rows, then NO_DATA_FOUND is not raised.
-- Instead, the collection is emptied.

---

DECLARE
   l_cursor         SYS_REFCURSOR;
   l_list           DBMS_SQL.varchar2s;
   c_limit CONSTANT PLS_INTEGER := 2;
BEGIN
   OPEN l_cursor FOR SELECT partname FROM plch_parts;

   FETCH l_cursor BULK COLLECT INTO l_list LIMIT c_limit;
   
   DBMS_OUTPUT.PUT_LINE(l_list.COUNT);  -- 2

   CLOSE l_cursor;
END;
/

---

PROCEDURE bulkdel IS
  l_cnt PLS_INTEGER := 0;

  CURSOR c1 IS
    SELECT u.user_oncall_results_id, u.execute_time
    FROM zuser_oncall_results u
    WHERE u.execute_time < (sysdate - 1470);
    
  TYPE t1 IS TABLE OF c1%ROWTYPE;
  l_recs t1;
          
  BEGIN
    OPEN c1;
    LOOP
      FETCH c1 BULK COLLECT INTO l_recs LIMIT 100;  

      l_cnt := l_cnt + l_recs.COUNT;
      
      EXIT WHEN l_recs.COUNT = 0;
      
      FORALL i IN 1 .. l_recs.COUNT
        DELETE 
          FROM zuser_oncall_results u
         WHERE u.user_oncall_results_id = l_recs(i).user_oncall_results_id;
        
        --COMMIT;
        ROLLBACK;
    END LOOP;
    CLOSE c1;
    dbms_output.put_line(l_cnt);
END;

---

-- Query a nested table then remove any zeros from it:

CREATE OR REPLACE TYPE plch_numbers_t IS TABLE OF NUMBER
/

CREATE OR REPLACE PROCEDURE plch_squish(numbers_io IN OUT plch_numbers_t) IS
   l_numbers   plch_numbers_t;
BEGIN
   SELECT COLUMN_VALUE
     BULK COLLECT INTO l_numbers
     FROM TABLE(numbers_io)
    WHERE COLUMN_VALUE <> 0;

   numbers_io := l_numbers;
END;
/

-- compare with MINUS-ish way
CREATE OR REPLACE PROCEDURE plch_squish(numbers_io IN OUT plch_numbers_t) IS
   l_zeroes   plch_numbers_t := plch_numbers_t(0);
BEGIN
   numbers_io := numbers_io MULTISET EXCEPT DISTINCT l_zeroes;
END;
/

---

PROCEDURE simple_bulkcollect_forall IS
	cnt PLS_INTEGER := 0;

	CURSOR c1 IS
		SELECT u.user_oncall_results_id, u.execute_time
		FROM zuser_oncall_results u
		WHERE u.execute_time < (sysdate - 1470);
		
	TYPE t1 IS TABLE OF c1%ROWTYPE;
	l_recs t1;
					
	BEGIN
		OPEN c1;
		LOOP
			FETCH c1 BULK COLLECT INTO l_recs LIMIT 20;  
			
			EXIT WHEN l_recs.COUNT = 0;
			
			FORALL i IN 1 .. l_recs.COUNT
				DELETE 
					FROM zuser_oncall_results u
				 WHERE u.user_oncall_results_id = l_recs(i).user_oncall_results_id;
			
				cnt := cnt + SQL%ROWCOUNT;
				
				--COMMIT;
				ROLLBACK;
		END LOOP;
		CLOSE c1;
		dbms_output.put_line(cnt);
END;

---

-- Not using FORALL here so we can debug print
DECLARE 
  TYPE mynt_t IS TABLE of my_family%ROWTYPE; 
  mynt mynt_t; 
  cursor c is select * from my_family;
BEGIN 
  open c;
  loop
    fetch c bulk collect into mynt limit 2;
    exit when mynt.count = 0;
    FOR i in 1..mynt.COUNT LOOP 
      dbms_output.put_line('Name('||i||'):' || mynt(i).name); 
    END LOOP; 
  end loop;
  close c;
END;

---

dbms_output.enable(NULL);

CREATE OR REPLACE PACKAGE ORION34136 IS
 failure_in_forall EXCEPTION;  
 PRAGMA EXCEPTION_INIT (failure_in_forall, -24381);  -- ORA-24381: error(s) in array DML  
 
 PROCEDURE upd;

END ORION34136;
/
CREATE OR REPLACE PACKAGE BODY ORION34136 IS

  PROCEDURE upd IS
    l_limit_group  PLS_INTEGER := 0;
    l_tab_size     PLS_INTEGER := 0;
    l_tab_size_tot PLS_INTEGER := 0;

    CURSOR c1 IS
      SELECT o.opportunity_id
        FROM opportunity_base o
       WHERE o.status_achieved_date < ADD_MONTHS(sysdate, -3) 
         AND o.opportunity_id IN ( SELECT oo.opportunity_id FROM zOPPORTUNITY_OPT_OUT oo WHERE NVL(oo.POOR_CLOSEOUT_OPT_OUT, 0) != 1 )
AND ROWNUM<600
      ;

    TYPE t1 IS TABLE OF c1%ROWTYPE;
    l_recs t1;
            
    BEGIN
    
      OPEN c1;
      LOOP
        FETCH c1 BULK COLLECT INTO l_recs LIMIT 500;  
        
        l_limit_group := l_limit_group + 1;
        l_tab_size := l_recs.COUNT;
        l_tab_size_tot := l_tab_size_tot + l_tab_size;

        -- Only print every 100K records
        IF (MOD(l_limit_group, 1000) = 0) THEN
          dbms_output.put_line(to_char(sysdate, 'DD-Mon-YYYY HH24:MI:SS') || ': iteration ' || l_limit_group || ' processing ' || l_tab_size || ' records' || ' total ' || l_tab_size_tot);
        END IF;
        
        EXIT WHEN l_tab_size = 0;
        
        BEGIN
          -- A FORALL statement is usually much faster than an equivalent FOR
          -- LOOP statement. However, a FOR LOOP statement can contain multiple DML
          -- statements while a FORALL statement can contain only one. The batch of
          -- DML statements that a FORALL statement sends to SQL differ only in
          -- their VALUES and WHERE clauses. The values in those clauses must come
          -- from existing, populated collections.
          --
          -- The FORALL statement is not a loop; it is a declarative statement
          -- to the PL/SQL engine: “Generate all the DML statements that would
          -- have been executed one row at a time, and send them all across to the
          -- SQL engine with one context switch”
          FORALL i IN 1 .. l_tab_size SAVE EXCEPTIONS
            UPDATE zOPPORTUNITY_OPT_OUT
               SET POOR_CLOSEOUT_OPT_OUT = 1
             WHERE OPPORTUNITY_ID = l_recs(i).opportunity_id
            ;
            --raise failure_in_forall;
          
        EXCEPTION
          WHEN failure_in_forall THEN   
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_stack);   
            DBMS_OUTPUT.put_line('Updated ' || SQL%ROWCOUNT || ' rows prior to EXCEPTION');
   
            FOR ix IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP   
              DBMS_OUTPUT.put_line('Updated ' || SQL%ROWCOUNT || ' rows (in this LIMIT group) prior to EXCEPTION');
              DBMS_OUTPUT.put_line ('Error ' || ix || ' occurred on iteration ' || SQL%BULK_EXCEPTIONS(ix).ERROR_INDEX ||
                                    '  with error code ' || SQL%BULK_EXCEPTIONS(ix).ERROR_CODE ||
                                    ' ' || SQLERRM(-(SQL%BULK_EXCEPTIONS(ix).ERROR_CODE)));
            END LOOP;
            -- Now keep doing the next l_limit_group...
        END;
        
        COMMIT;  -- 500 rows to minimize locks
      END LOOP;

      CLOSE c1;
      
  END upd;

END ORION34136;
/

---

-- SELECT INTO
DECLARE
  TYPE NumTab IS TABLE OF hr.employees.employee_id%TYPE;
  TYPE NameTab IS TABLE OF hr.employees.last_name%TYPE;
 
  -- Collections to bulk collect into:
  nums  NumTab;
  names NameTab;
 
  PROCEDURE print_first_n(n POSITIVE) IS
		BEGIN
			IF nums.COUNT = 0 THEN
				DBMS_OUTPUT.PUT_LINE('Collections are empty.');  -- not reached in this example
			ELSE
				DBMS_OUTPUT.PUT_LINE('First ' || n || ' employees:');
	 
				FOR i IN 1 .. n LOOP
					DBMS_OUTPUT.PUT_LINE('  Employee #' || nums(i) || ': ' || names(i));
				END LOOP;
			END IF;
		END;
 
BEGIN
  -- A SELECT BULK COLLECT INTO statement will move all specified rows into one
  -- or more collections. This "unlimited" type of bulk query can lead to
  -- excessive allocation of PGA (process global area) memory.
  --
  -- If you need to process a very large number of rows but cannot afford the
  -- PGA to do them all in one fetch, then use FETCH BULK COLLECT with a LIMIT clause, not this:
  SELECT employee_id, last_name
  BULK COLLECT INTO nums, names -- LIMIT 100 fails!
  FROM hr.employees
  ORDER BY employee_id;
 
  print_first_n(3);
  print_first_n(6);
END;
/
/*
First 3 employees:
Employee #100: King
Employee #101: Kochhar
Employee #102: De Haan
First 6 employees:
Employee #100: King
Employee #101: Kochhar
Employee #102: De Haan
Employee #103: Hunold
Employee #104: Ernst
Employee #105: Austin
*/

---

-- To do bulk binds with INSERT, UPDATE, and DELETE statements, you enclose the
-- SQL statement within a PL/SQL FORALL statement
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

/* Fill a collection with a cursor variable: */
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

-- Cursor-less (can't use LIMIT)

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
     -- Must bulk collect if not fetching via a cursor
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

---

-- https://devgym.oracle.com/pls/apex/f?p=10001:1111:1445998260540:QUESTION:NO:RP,1111:P1111_COMP_EVENT_ID,P1111_CLASS_ID,P1111_WORKOUT_ID,P1111_SKIPPED_ANSWER,P1111_PAGE_STATE:3772376,,,,QUESTION&success_msg=Q29uZ3JhdHVsYXRpb25zIG9uIGNvbXBsZXRpbmcgYW5vdGhlciBxdWl6IQ~~%2FO_SQoZ4NWQadZtQ7_89LrHQsHmKjT8Kw9FARmlGGobBBPKKLfcB-ekxSn7WfpkN0F9xW_8fkqwUXFcdTm4DRcg
-- After you execute a FORALL statement, you can access a special implicit
-- cursor attribute, SQL%BULK_ROWCOUNT, to determine the number of rows that were
-- modified by each DML statement generated by FORALL and passed to the SQL engine.
-- If you want to iterate through the elements of SQL%BULK_ROWCOUNT, then you must
-- reconstruct the looping algorithm employed by FORALL to identify and execute the DML 
-- statements. With "FORALL indx IN low_value .. high_value", you can execute code like this:
FOR indx IN low_value .. high_value LOOP
  DBMS_OUTPUT.PUT_LINE(SQL%BULK_ROWCOUNT(indx));
END LOOP;
