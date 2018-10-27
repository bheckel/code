/* Fill a collection */

CREATE TABLE plch_employees
(
   employee_id   INTEGER
 ,  last_name    VARCHAR2 (100)
 ,  salary       NUMBER
)
/

BEGIN
   INSERT INTO plch_employees
        VALUES (100, 'Ellison', 1000000);

   INSERT INTO plch_employees
        VALUES (200, 'Gates', 1000000);

   INSERT INTO plch_employees
        VALUES (300, 'Zuckerberg', 1000000);

   COMMIT;
END;
/

/* With an explicit cursor: */

DECLARE
   CURSOR plch_employees_cur
   IS
      SELECT * FROM plch_employees;

   /* Must index by number if using assoc array collection */
   TYPE plch_employees_aat
      IS TABLE OF plch_employees%ROWTYPE
            INDEX BY BINARY_INTEGER;

   l_plch_employees   plch_employees_aat;
BEGIN
   OPEN plch_employees_cur;

   FETCH plch_employees_cur BULK COLLECT INTO l_plch_employees;

   CLOSE plch_employees_cur;
END;
/

/* With an implicit cursor: */

DECLARE
   TYPE plch_employees_aat
      IS TABLE OF plch_employees%ROWTYPE
            INDEX BY BINARY_INTEGER;

   l_plch_employees   plch_employees_aat;
BEGIN
   SELECT *
     BULK COLLECT INTO l_plch_employees
     FROM plch_employees;
END;
/

/* With a dynamic SQL statement (Oracle 9i Release 2 and above): */

DECLARE
   TYPE plch_employees_aat
      IS TABLE OF plch_employees%ROWTYPE
            INDEX BY BINARY_INTEGER;

   l_plch_employees   plch_employees_aat;
BEGIN
   EXECUTE IMMEDIATE 'SELECT * FROM plch_employees'
      BULK COLLECT INTO l_plch_employees;
END;
/

/* And here's an example of using BULK COLLECT with a cursor variable: */

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

CREATE TABLE plch_stuff
(
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
   x number;
BEGIN
   SELECT *
     BULK COLLECT INTO l_stuff
     FROM plch_stuff;

   /* First is always 1, and COUNT = count of rows fetched. */
   DBMS_OUTPUT.put_line(l_stuff.FIRST);
   DBMS_OUTPUT.put_line(l_stuff.COUNT);

   FOR i IN 1 ..l_stuff.COUNT
   LOOP
    --x := l_stuff(i).rating;
    --dbms_output.put_line(x);
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
-- collection. The resulting performance improvement can be an order of magnitude
-- or greater.

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



DECLARE
  TYPE empcurtyp IS REF CURSOR;
  TYPE namelist_ntt IS TABLE OF employees.last_name%TYPE;
  TYPE sallist_ntt  IS TABLE OF employees.salary%TYPE;
  emp_cv  empcurtyp;
  names   namelist_ntt;
  sals    sallist_ntt;
BEGIN
  OPEN emp_cv FOR
    SELECT last_name, salary FROM employees
    WHERE job_id = 'SA_REP'
    ORDER BY salary DESC;

  FETCH emp_cv BULK COLLECT INTO names, sals;
  CLOSE emp_cv;
  -- loop through the names and sals collections
  FOR i IN names.FIRST .. names.LAST
  LOOP
    DBMS_OUTPUT.PUT_LINE('Name = ' || names(i) || ', salary = ' || sals(i));
  END LOOP;
END;
/

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
         SET emp.salary =
                emp.salary + emp.salary * increase_pct_in
       WHERE emp.employee_id = l_eligible_ids (indx);
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
         where  risk_product_id = t_tab(i).risk_product_id;
         
     COMMIT;
          
  END LOOP;
  CLOSE c;
END;


---

CREATE OR REPLACE PACKAGE ORION32598 IS

 PROCEDURE ptgcleanup;

END ORION32598;
/
CREATE OR REPLACE PACKAGE BODY ORION32598 IS

  PROCEDURE ptgcleanup IS
    l_defect_num   VARCHAR2(50)   := 'ORION-32598';
    l_release_num  VARCHAR2(50)   := 'N/A';
    l_description  VARCHAR2(4000) := 'Delete (move to hist table) Inactive and > 6 month-old PLAN_TO_GOAL records';
    l_tab_size     PLS_INTEGER    := 0;
    l_tab_size_tot PLS_INTEGER    := 0;
    l_limit_group  PLS_INTEGER    := 0;

    CURSOR c IS 
      select x.plan_to_goal_id
      ...
    ;
    
    TYPE t_ptg_tab_type IS TABLE OF c%ROWTYPE;

    t_ptg t_ptg_tab_type;

    BEGIN
      OPEN c;
      LOOP
        FETCH c BULK COLLECT INTO t_ptg LIMIT 300;

        l_limit_group := l_limit_group + 1;
        l_tab_size := t_ptg.COUNT;
        l_tab_size_tot := l_tab_size_tot + l_tab_size;
        
        dbms_output.put_line(to_char(sysdate, 'DD-Mon-YYYY HH24:MI:SS') || ': iteration ' || l_limit_group || ' processed ' || l_tab_size || ' records' || ' total ' || l_tab_size_tot);

        EXIT WHEN l_tab_size = 0;

        /* Implicit update of plan_to_goal_hist */
        FORALL i IN 1 .. l_tab_size
          DELETE from plan_to_goal where plan_to_goal_id=t_ptg(i).plan_to_goal_id;

        --ROLLBACK;
        COMMIT;
      END LOOP;
    CLOSE c;
    
    MAINT.logdatachange(step => 0, status => l_description, release => l_release_num, defect => l_defect_num, startTime => SYSDATE); 

  END ptgcleanup;

END ORION32598;
/
