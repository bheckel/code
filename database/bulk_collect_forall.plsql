--  Adapted: Tue 01 Apr 2019 10:49:35 (Bob Heckel--DevGym)
-- Modified: 23-Feb-2022 (Bob Heckel)

-- See also row.plsql suppress_rowlevel_dml_errors.plsql, restore_records_from_hist.sql, execute_immediate.plsql

-- The PL/SQL features that comprise bulk SQL are the FORALL statement and the
-- BULK COLLECT clause.
--
-- SELECT column(s)               BULK COLLECT INTO collection(s)
-- FETCH cursor                   BULK COLLECT INTO collection(s)
-- EXECUTE IMMEDIATE query_string BULK COLLECT INTO collection(s)
--
-- The FORALL statement *sends* DML statements from PL/SQL to SQL in batches rather 
-- than one at a time i.e. it binds all the data in a collection into a DML statement.
-- The BULK COLLECT clause *returns* results from SQL to PL/SQL in batches rather than 
-- one at a time i.e. it pulls multiple rows back into a collection.
--
-- If a query or DML statement affects four or more database rows, then bulk SQL can
-- significantly improve performance but reducing context switches.
--
-- If the query does not return any rows, then NO_DATA_FOUND is NOT raised.
-- Instead, the collection is emptied.  Like FETCH inside a LOOP PL/SQL does
-- not raise an exception when a statement with a BULK COLLECT clause returns no
-- rows. You must check the target collection for emptiness.
--
-- Statement level triggers only fire once at the start and end of the bulk insert operation,
-- but fire on a row-by-row basis for the bulk update and delete operations:
-- *** FORALL - INSERT ***
-- BEFORE STATEMENT - INSERT
-- BEFORE EACH ROW - INSERT (new.id=1)
-- AFTER EACH ROW - INSERT (new.id=1)
-- BEFORE EACH ROW - INSERT (new.id=2)
-- AFTER EACH ROW - INSERT (new.id=2)
-- BEFORE EACH ROW - INSERT (new.id=3)
-- AFTER EACH ROW - INSERT (new.id=3)
-- AFTER STATEMENT - INSERT
-- *** FORALL - UPDATE/DELETE ***
-- BEFORE STATEMENT - UPDATE
-- BEFORE EACH ROW - UPDATE (new.id=1 old.id=1)
-- AFTER EACH ROW - UPDATE (new.id=1 old.id=1)
-- AFTER STATEMENT - UPDATE
-- BEFORE STATEMENT - UPDATE
-- BEFORE EACH ROW - UPDATE (new.id=2 old.id=2)
-- AFTER EACH ROW - UPDATE (new.id=2 old.id=2)
-- AFTER STATEMENT - UPDATE
-- BEFORE STATEMENT - UPDATE
-- BEFORE EACH ROW - UPDATE (new.id=3 old.id=3)
-- AFTER EACH ROW - UPDATE (new.id=3 old.id=3)
-- AFTER STATEMENT - UPDATE

---

-- Compare without limit & with:
--  DECLARE                                                                      |  DECLARE
--     TYPE employees_aat IS TABLE OF employees%ROWTYPE INDEX BY BINARY_INTEGER; |     TYPE employees_aat IS TABLE OF employees%ROWTYPE INDEX BY BINARY_INTEGER;
--     l_employees   employees_aat;                                              |     l_employees         employees_aat;
--                                                                               |     CURSOR emp_cur IS
--  BEGIN                                                                        |  ----------------------------------------------------------------------------------------------------------------------------------
--       SELECT *                                                                |       SELECT *
--         BULK COLLECT INTO l_employees                                         |  ----------------------------------------------------------------------------------------------------------------------------------
--         FROM employees;                                                       |       FROM employees;
--                                                                               | 
--  -----------------------------------------------------------------------------|  BEGIN
--  -----------------------------------------------------------------------------|     OPEN emp_cur;
--  -----------------------------------------------------------------------------| 
--  -----------------------------------------------------------------------------|     LOOP
--  -----------------------------------------------------------------------------|        FETCH emp_cur BULK COLLECT INTO l_employee LIMIT 100;
--  -----------------------------------------------------------------------------|        EXIT WHEN l_employees.COUNT = 0;
--                                                                               | 
--     FOR indx IN 1 .. l_employees.COUNT                                        |        FOR indx IN 1 .. l_employees.COUNT
--     LOOP                                                                      |        LOOP
--        DBMS_OUTPUT.put_line (l_employees (indx).last_name);                   |          DBMS_OUTPUT.put_line (l_employees (indx).last_name);
--     END LOOP;                                                                 |        END LOOP;
--                                                                               |     END LOOP;
--                                                                               |  ----------------------------------------------------------------------------------------------------------------------------------
--                                                                               | 
--     CLOSE emp_cur;                                                            |     CLOSE emp_cur;
--  END;                                                                         |  END;

---

DECLARE
  l_cnt PLS_INTEGER := 0;

  CURSOR c1 IS
    SELECT account_team_assignment_id 
      FROM account_team_assign_all 
     WHERE created>(sysdate - interval '48' hour) and audit_source='l10g279' and assignment_active=0;
    
  TYPE t1 IS TABLE OF c1%ROWTYPE;
  l_recs t1;
          
  BEGIN
    OPEN c1;
    LOOP
      FETCH c1 BULK COLLECT INTO l_recs LIMIT 200;  

      l_cnt := l_cnt + l_recs.COUNT;
      
      EXIT WHEN l_recs.COUNT = 0;
      
      FORALL i IN 1 .. l_recs.COUNT
        DELETE 
          FROM account_team_assign_all
         WHERE account_team_assignment_id = l_recs(i).account_team_assignment_id;
        
        --COMMIT;
        ROLLBACK;
    END LOOP;
    CLOSE c1;
    dbms_output.put_line(l_cnt);
END;

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

-- Not using FORALL here so that we can debug print
DECLARE 
  TYPE mynt_t IS TABLE OF my_family%ROWTYPE; 
  mynt mynt_t; 
  CURSOR c is select * from my_family;

BEGIN 
  open c;
  loop
    FETCH c BULK COLLECT into mynt limit 2;
    EXIT WHEN mynt.count = 0;
    FOR i in 1..mynt.COUNT LOOP 
      dbms_output.put_line('Name('||i||'):' || mynt(i).name); 
    END LOOP; 
  END LOOP;
  CLOSE c;
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
        -- If you have very few rows, you might want to increase the array size. If you have very wide rows, 100 may be too large.
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
              DBMS_OUTPUT.put_line ('Error ' || ix || ' occurred on iteration ' || SQL%BULK_EXCEPTIONS(ix).ERROR_INDEX ||
                                    '  with error code ' || SQL%BULK_EXCEPTIONS(ix).ERROR_CODE ||
                                    ' ' || SQLERRM(-(SQL%BULK_EXCEPTIONS(ix).ERROR_CODE)));
            END LOOP;
            -- Now keep going with the next l_limit_group...
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

/* Populate a collection with an explicit cursor: */
DECLARE
   CURSOR plch_employees_cur IS
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

/* Populate a collection with an implicit cursor: */
DECLARE
   TYPE plch_employees_aat IS TABLE OF plch_employees%ROWTYPE INDEX BY BINARY_INTEGER;
   l_plch_employees plch_employees_aat;

BEGIN
   SELECT *
     BULK COLLECT INTO l_plch_employees
     FROM plch_employees;
END;
/

/* Populate a collection with a dynamic SQL statement (Oracle 9i Release 2 and above): */
DECLARE
   TYPE plch_employees_aat IS TABLE OF plch_employees%ROWTYPE INDEX BY BINARY_INTEGER;
   l_plch_employees plch_employees_aat;

BEGIN
   EXECUTE IMMEDIATE 'SELECT * FROM plch_employees'
     BULK COLLECT INTO l_plch_employees;
END;
/

/* Populate a collection with a cursor variable: */
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
   l_stuff stuff_t;
   x NUMBER;
BEGIN
   SELECT *
     BULK COLLECT INTO l_stuff
     FROM plch_stuff;

   /* First is always 1, and COUNT = count of rows fetched */
   DBMS_OUTPUT.put_line(l_stuff.FIRST);
   DBMS_OUTPUT.put_line(l_stuff.COUNT);

   /* Loop skipped if count = 0 */
   FOR i IN 1 .. l_stuff.COUNT LOOP
     x := l_stuff(i).rating;
     dbms_output.put_line(x);
     dbms_output.put_line(l_stuff(i).rating);
   END LOOP;

   /* Now do it again - will see same count */
   SELECT *
     BULK COLLECT INTO l_stuff
     FROM plch_stuff;

   DBMS_OUTPUT.put_line(l_stuff.COUNT);
END;
/

DROP TABLE plch_stuff
/

---

-- BULK COLLECT with LIMIT when you don’t know the upper limit. BULK COLLECT
-- helps retrieve multiple rows of data quickly. Rather than retrieve one row of
-- data at a time into a record or a set of individual variables, BULK COLLECT
-- lets us retrieve hundreds, thousands, even tens of thousands of rows with a
-- single context switch to the SQL engine and deposit all that data into a collection.

PROCEDURE bulk_with_limit (
   dept_id_in   IN   employees.department_id%TYPE
 , limit_in     IN   PLS_INTEGER DEFAULT 100
)
IS
   CURSOR employees_cur IS
     SELECT *
     FROM employees
     WHERE department_id = dept_id_in;

   TYPE employee_ntt IS TABLE OF employees_cur%ROWTYPE INDEX BY PLS_INTEGER;
   l_employees employee_ntt;

BEGIN
   OPEN employees_cur;
   LOOP
      FETCH employees_cur
      BULK COLLECT INTO l_employees LIMIT limit_in;
      FOR indx IN 1 .. l_employees.COUNT LOOP
         process_each_employees(l_employees(indx));
      END LOOP;
      EXIT WHEN employees_cur%NOTFOUND;  -- exit goes here - AFTER you've gone through the collection
   END LOOP;
   CLOSE employees_cur;
END bulk_with_limit;

---

/* See also insert_invitations.pck */

/* https://blogs.oracle.com/oraclemagazine/bulk-processing-with-bulk-collect-and-forall */

 /* If the SQL engine (NOT the PL/SQL runtime engine!) raises an error, the
  * PL/SQL engine will save that information in a pseudocollection named
  * SQL%BULK_EXCEPTIONS, and continue executing statements. When all statements
  * have been attempted, PL/SQL then raises "ORA-24381: error(s) in array DML"
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
                  SQL%BULK_EXCEPTIONS(indx).ERROR_INDEX
               || ': '
               || SQL%BULK_EXCEPTIONS(indx).ERROR_CODE);
         END LOOP;
      ELSE
         RAISE;
      END IF;
END;

---

--  BULK COLLECT fetching into nested table of records based on a cursor
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
         SET    updated = updated, updatedby = updatedby,
                at_risk_amount = t_tab(i).at_risk_amount
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

---

PROCEDURE removeDuplicatedDump IS
  TYPE numberTable IS TABLE OF NUMBER;
  acctAttrTable numberTable;
  
  rowsAffected  NUMBER := 0;

BEGIN
  EXECUTE IMMEDIATE 'SELECT DISTINCT FIRST_VALUE(ATTRIBUTE_ID) 
                            OVER(PARTITION BY dump_NBR ORDER BY dump_nbr, primary_aa_flag desc) AS AAN_ID
                      FROM (SELECT DISTINCT AAN.ATTRIBUTE_ID,
                                      AAN.dump_NBR,
                                      DECODE(AAN.ATTRIBUTE_ID,
                                             ABN.PRIMARY_ATTRIBUTE_ID,
                                             1,
                                             0) AS PRIMARY_AA_FLAG
                            FROM ATTRIBUTE_NEW      AAN,
                                 NAME_ATTRIBUTE_NEW ANAN,
                                 NAME_NEW           ANN,
                                 BASE_NEW           ABN
                           WHERE AAN.ATTRIBUTE_ID = ANAN.ATTRIBUTE_ID
                             AND ANAN.NAME_ID = ANN.NAME_ID
                             AND ANN.ID = ABN.ID
                             AND AAN.dump_NBR IN (SELECT dump_NBR
                                                    FROM ATTRIBUTE_NEW AAN
                                                   GROUP BY dump_NBR
                                                  HAVING COUNT(dump_NBR) > 1))'
     BULK COLLECT INTO acctAttrTable;

  FOR i IN 1 .. acctAttrTable.COUNT LOOP
    EXECUTE IMMEDIATE 'DELETE FROM ATTRIBUTE_NEW AAN WHERE AAN.ATTRIBUTE_ID = :1'
      USING acctAttrTable(i);
  
    rowsAffected := rowsAffected + SQL%ROWCOUNT;
  
    IF (mod(rowsAffected, 10000) = 0) THEN
      COMMIT;
    END IF;
  END LOOP;

  COMMIT;
END;

---

-- Change a column's data type.
-- But we must first update a temp column with the existing data but since the temporary column doesn't yet exist, we must go dynamic
DECLARE
  l_dtype         VARCHAR2(32);
  l_cnt           NUMBER := 0;
  l_rows_updated  NUMBER := 0;

  CURSOR c1 IS
    SELECT ASP_ID
      FROM ASP;

  TYPE t1 IS TABLE OF NUMBER;
  l_recs t1;

  BEGIN
    SELECT data_type
    INTO l_dtype 
    FROM user_tab_columns 
   WHERE table_name='ASP' AND column_name = 'FUTURE_SUP_ACCOUNT_ID';

    -- 1) Change data type
    IF l_dtype = 'BINARY_DOUBLE' THEN  
      OPEN c1;

      -- Populate temp column with current IDs
      LOOP
        FETCH c1 BULK COLLECT INTO l_recs LIMIT 500;  

        l_cnt := l_cnt + l_recs.COUNT;

        EXIT WHEN l_recs.COUNT = 0;

        FOR i IN 1 .. l_recs.COUNT LOOP
          EXECUTE IMMEDIATE 'update ASP set FSAID_TMP = FUTURE_SUP_ACCOUNT_ID where ASP_ID = :1'
            USING l_recs(i);
          l_rows_updated := SQL%ROWCOUNT;
        END LOOP;

        COMMIT;
          
      END LOOP;
      CLOSE c1;
  ...

---

  PROCEDURE update_from_asp2 IS
		mytbl ASP_PKG_TYPES.assignTable := ASP_PKG_TYPES.assignTable();
    v_assign_limit  CONSTANT NUMBER := 10000; -- MANY tests run on this - for whatever reason this seemed to be the optimal number 

		CURSOR update_account_assignment_c IS
			SELECT account_id, account_team_assignment_id, lead_owner_id, assignment_active
				FROM account_team_assign_all 
		   WHERE account_id in (SELECT distinct account_id FROM ACCOUNT_TEAM_ASSIGN_ALL WHERE assignment_active = 0)
       ORDER BY 1,4,3;

    type mytmp_t  is table of update_account_assignment_c%rowtype;
    mytmp mytmp_t;

  BEGIN
    DBMS_OUTPUT.enable(NULL);
    OPEN update_account_assignment_c;
    LOOP
      FETCH update_account_assignment_c BULK COLLECT INTO mytmp limit v_assign_limit;
      EXIT WHEN mytmp.COUNT = 0;

      FOR i IN 1 .. mytmp.COUNT LOOP
        /* i := i + 1; */
        mytbl.EXTEND;
        mytbl(i).account_id := mytmp(i).account_id;
        IF mytmp(i).assignment_active = 0 THEN
          mytbl(i).new_account_team_assignment_id := mytmp(i).account_team_assignment_id;
        ELSE
          mytbl(i).old_account_team_assignment_id := mytmp(i).account_team_assignment_id;
        END IF;
        mytbl(i).old_lead_owner_id := mytmp(i).lead_owner_id;
        mytbl(i).assignment_active := mytmp(i).assignment_active;
        mytbl(i).assign_error := 0;
        mytbl(i).assign_error_msg := NULL;

        DBMS_OUTPUT.PUT_LINE ('|||> processing account_id: ' || mytbl(i).account_id || ' old_account_team_assignment_id: ' || mytbl(i).old_account_team_assignment_id || ' new_account_team_assignment_id: ' || mytbl(i).new_account_team_assignment_id || ' activ: ' ||  mytbl(i).assignment_active);
      END LOOP;  
    END LOOP;

    update_account_assignment(mytbl);
rollback;
/* commit; */
  END update_from_asp2;

---

CREATE OR REPLACE TYPE t_numlist IS TABLE OF NUMBER
/
CREATE OR REPLACE TYPE t_namelist IS TABLE OF VARCHAR2(15)
/
CREATE OR REPLACE PROCEDURE update_emps (col_in IN VARCHAR2, empnos_in IN t_numlist)
IS
   enames   t_namelist;
BEGIN
   FORALL indx IN empnos_in.FIRST .. empnos_in.LAST
      EXECUTE IMMEDIATE
            'UPDATE employees SET '
         || col_in
         || ' = '
         || col_in
         || ' * 1.1 WHERE employee_id = :1
         RETURNING last_name INTO :2'
         USING empnos_in(indx)
         RETURNING BULK COLLECT INTO enames;

   FOR indx IN 1 .. enames.COUNT LOOP
      DBMS_OUTPUT.put_line ('10% raise to ' || enames(indx));
   END LOOP;
END;
/

DECLARE
   l_ids   t_numlist := t_numlist(138, 147);
BEGIN
   update_emps('salary', l_ids);
END;
/

---

PROCEDURE auto_exclude_rows IS
  TYPE t_numberTable IS TABLE OF NUMBER;
  TYPE t_varchar2Table IS TABLE OF VARCHAR2(32767);
  TYPE t_dateTable IS TABLE OF DATE;
  
  v_sdm_business_keytbl               t_varchar2Table;
  v_new_tor_indtbl                    t_numberTable;
  v_new_mkc_exclusion_reason_idtbl    t_numberTable;
  v_new_mkc_exclusion_reasontbl       t_varchar2Table;
  v_new_mkc_exclusion_reason_datetbl  t_varchar2Table;
  v_conditiontbl                      t_varchar2Table;
  v_sql                               VARCHAR(32767);
  v_tab_size                          NUMBER;
  v_did_update                        NUMBER;
  updateCursor                        SYS_REFCURSOR;
            
BEGIN
  -- Prepare temp comparison table
  EXECUTE IMMEDIATE 'truncate table MKC_REVENUE_SOURCE_ROWS';

  v_sql := 
    'INSERT INTO MC_REVENUE_SOURCE_ROWS (sdm_business_key, tor_ind, source_db )
       SELECT DISTINCT sdm_business_key, tor_ind, ''SDM_REVENUE'' as source_db
         FROM appedw.sdm_revenue@edw
        WHERE extract(year from report_date) >= ' || get_current_reporting_year() ;
   
  EXECUTE IMMEDIATE v_sql;
  COMMIT;
 
  v_sql := '
    INSERT INTO MKC_REVENUE_SOURCE_ROWS (sdm_business_key, tor_ind, source_db )
      SELECT DISTINCT TRIM(dr."SOURCE_INVOICE_ID"||fr."SOURCE_INVOICE_LINE_ID"||f."SOURCE_FINANCIAL_SYSTEM_CD") as sdm_business_key,
             f.tor_ind, ''INVOICE_FACT'' as source_db
        FROM appedw.invoice_fact@edw f 
        LEFT JOIN APPEDW.INVOICE_DIM_REF@EDW dr
          ON f.invoice_id = dr.invoice_id
        LEFT JOIN APPEDW.INVOICE_FACT_REF@EDW fr
          ON f.invoice_line_id = fr.invoice_line_id
       WHERE extract(year from f.report_date) >= ' || get_current_reporting_year() || '
         AND NOT EXISTS (SELECT 1
                           FROM MKC_REVENUE_SOURCE_ROWS x
                          WHERE x.sdm_business_key = TRIM(dr.SOURCE_INVOICE_ID||fr.SOURCE_INVOICE_LINE_ID||f.SOURCE_FINANCIAL_SYSTEM_CD))';
  EXECUTE IMMEDIATE v_sql;
  COMMIT;

  -- Build UPDATE cursor for the 3 exclusion situations
  v_sql := '
    WITH v as (
     -- 1. SDMBK is gone from upstream (we must exclude it)
     SELECT  sdm_business_key,
             0 new_tor_ind,
             91 new_mkc_exclusion_reason_id, 
             ''SDM_BK no longer in source data'' new_mkc_exclusion_reason, 
             SYSDATE new_mkc_exclusion_reason_date, 
             ''condition 1'' conditionsrc
       FROM (
             SELECT krf.sdm_business_key,
                    krf.source_db,
                    krf.mkc_exclusion_reason_id,
                    krf.report_date_adj, krf.report_date_sr, krf.report_date_f
              FROM mkc_revenue_full krf
                WHERE NOT EXISTS ( select 1 
                                  from appedw.sdm_revenue@edw src
                                 where krf.sdm_business_key = src.sdm_business_key
                                   and extract(year from src.report_date) >= ' || get_current_reporting_year() || ')
             )
       WHERE extract(year from COALESCE(report_date_adj, report_date_sr, report_date_f)) >= ' || get_current_reporting_year() || '
         AND source_db = ''SDM_REVENUE''
         AND mkc_exclusion_reason_id = -99  -- not already excluded
      union
      SELECT krf.sdm_business_key, 
             CASE
              -- 2. Indicator has changed to 0 upstream but we show it as not excluded (we must clear the previous exclusion)       
               WHEN krf.mkc_exclusion_reason_id = -99 AND src.tor_ind = 0 THEN
                 0
               -- 3. Indicator has changed back to 1 but we show it as excluded (we must reverse the previous exclusion)           
               WHEN krf.mkc_exclusion_reason_id != -99 AND src.tor_ind = 1 THEN 
                 1
             END AS new_tor_ind,        
             CASE
               WHEN krf.mkc_exclusion_reason_id = -99 AND src.tor_ind = 0 THEN
                 92
               WHEN krf.mkc_exclusion_reason_id != -99 AND src.tor_ind = 1 THEN 
                -99
             END AS new_mkc_exclusion_reason_id,
             CASE
               WHEN krf.mkc_exclusion_reason_id = -99 AND src.tor_ind = 0 THEN
                 ''TOR IND has changed from 1 to 0 in source data''
               WHEN krf.mkc_exclusion_reason_id != -99 AND src.tor_ind = 1 THEN
                 -- No longer excluded
                 NULL
             END AS new_mkc_exclusion_reason,
             CASE
               WHEN krf.mkc_exclusion_reason_id = -99 AND src.tor_ind = 0 THEN
                 TO_DATE(TO_CHAR(TRUNC(sysdate), ''DDMONYY hh:mi:ss pm''),''DDMONYY hh:mi:ss pm'')
               WHEN krf.mkc_exclusion_reason_id != -99 AND src.tor_ind = 1 THEN 
                 NULL
             END AS new_mkc_exclusion_reason_date,      
             ''condition 2 or 3'' conditionsrc
        FROM mkc_revenue_full krf
        LEFT JOIN mkc_revenue_source_rows src
          ON krf.sdm_business_key = src.sdm_business_key
         AND krf.source_db = src.source_db
        WHERE extract(year from COALESCE(report_date_adj, report_date_sr, report_date_f)) >= ' || get_current_reporting_year() || '
    )
  SELECT *
    FROM v
    WHERE new_mkc_exclusion_reason_id IS NOT NULL  -- keep newly identified exclusions only
  ';
  
  OPEN updateCursor FOR v_sql;
    v_did_update := 0;
    LOOP
      FETCH updateCursor BULK COLLECT INTO v_sdm_business_keytbl,
                                           v_new_tor_indtbl,
                                           v_new_mkc_exclusion_reason_idtbl,
                                           v_new_mkc_exclusion_reasontbl,
                                           v_new_mkc_exclusion_reason_datetbl,
                                           v_conditiontbl
                                           LIMIT 500;  
      v_tab_size := v_sdm_business_keytbl.COUNT;
    
      EXIT WHEN v_tab_size = 0;
    
      BEGIN
          FOR i IN 1 .. v_sdm_business_keytbl.COUNT LOOP
            log(v_main_table, 'auto_exclude_rows: ' || v_sdm_business_keytbl(i) || ' new tor_ind: ' ||
                v_new_tor_indtbl(i) || ' new excl id: ' || v_new_mkc_exclusion_reason_idtbl(i) || ' new excl: ' || v_new_mkc_exclusion_reasontbl(i)
                || ' new excl date: ' || v_new_mkc_exclusion_reason_datetbl(i) || ' conditionsrc: ' || v_conditiontbl(i));
          END LOOP;
      
        FORALL i IN 1 .. v_tab_size SAVE EXCEPTIONS
          EXECUTE IMMEDIATE 'UPDATE /*+ NO_PARALLEL*/ ' || v_main_table || '
                                SET tor_ind_sr = :1,
                                    mkc_exclusion_reason_id = :2,
                                    mkc_exclusion_reason = :3,
                                    mkc_exclusion_reason_date = :4,
                                    audit_source = ''MKC.auto_exclude_rows''
                              WHERE sdm_business_key = :5'
                              USING v_new_tor_indtbl(i),
                                    v_new_mkc_exclusion_reason_idtbl(i),
                                    v_new_mkc_exclusion_reasontbl(i),
                                    v_new_mkc_exclusion_reason_datetbl(i),
                                    v_sdm_business_keytbl(i);
    
      EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_stack);   
          DBMS_OUTPUT.put_line('Updated ' || SQL%ROWCOUNT || ' rows prior to EXCEPTION');
  
          FOR ix IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP   
            log(v_main_table, 'ERROR in auto_exclude_rows ' || ix || ' occurred on iteration ' || SQL%BULK_EXCEPTIONS(ix).ERROR_INDEX || '  with error code ' || SQL%BULK_EXCEPTIONS(ix).ERROR_CODE || ' ' || SQLERRM(-(SQL%BULK_EXCEPTIONS(ix).ERROR_CODE)));
          END LOOP;
      END;

      v_did_update := v_did_update + sql%ROWCOUNT;
       
      COMMIT;

    END LOOP; -- updateCursor
  CLOSE updateCursor;

  IF v_did_update > 0 THEN
    e_mail_message('replies-disabled@s.com',
                   'bob.heckel@s.com',
                   '[MKC] New Build auto_exclude_rows executed',
                   '');
  END IF;
END auto_exclude_rows;

---

declare
  cursor c1 is 
    SELECT UID_MKC_REVENUE_ID.NEXTVAL MKC_revenue_id, ACCOUNT_ID_ADJ,ACCOUNT_ID_AS,ACCOUNT_ID_CW,ACCOUNT_ID_HB,created,createdby
      FROM MKC_REVENUE_FULL
     WHERE rownum<10000;

  type idtbl_t is table of c1%ROWTYPE;
  id_table idtbl_t;

begin
  open c1; 
  loop
    fetch c1 BULK COLLECT into id_table limit 1000;
    exit when id_table.COUNT = 0;

    forall i IN 1 .. id_table.COUNT
      INSERT  INTO MKC_REVENUE_FULL_BOB ( mkc_revenue_id,account_id_adj,account_id_as,account_id_cw,account_id_hb,created,createdby )
      VALUES ( id_table(i).mkc_revenue_id,id_table(i).account_id_adj,id_table(i).account_id_as,id_table(i).account_id_cw,id_table(i).account_id_hb,id_table(i).created,id_table(i).createdby );
    --COMMIT;
    rollback;
  end loop;      
  rollback;
  --COMMIT;

exception
  when OTHERS then
    rollback;
    DBMS_OUTPUT.put_line(SQLCODE || ':' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
end;
