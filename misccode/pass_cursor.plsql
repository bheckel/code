-- Modified: 31-Jan-2020 (Bob Heckel)
-- See also cursor.plsql

-- There are two types of REF CURSORS: strong and weak. A strong REF CURSOR
-- type is used to declare a cursor variable associated with a specific record
-- structure (or, to put it another way, a specific SELECT list in a query); a
-- cursor variable declared based on a weak REF CURSOR type can be associated with
-- any set of columns or expressions returned by a query. It is almost always used
-- with dynamic queries.  A cursor variable based on a weak REF CURSOR type CANNOT be 
-- declared at the package level (outside of any procedure or function in the package)
--
-- There is no way to ask "Are these two cursor variables equal?" That would be
-- like asking PL/SQL to tell us "Are the contents of this query equal to that
-- of a second one?"
--
-- REF CURSOR types (such as SYS_REFCURSOR) cannot be used as the datatype of a collection.

---

DECLARE
  /* Declare a strong REF CURSOR type then we can use  OPEN curv FOR SELECT * FROM emp; */
  /* TYPE CREF_T IS REF CURSOR RETURN emp%ROWTYPE; */
  /* curv CREF_T; */

  /* Declare a weak REF cursor type */
  TYPE CREF_T IS REF CURSOR;
  /* Declare a cursor variable of REF CURSOR type */
  curv CREF_T;

  l_ename emp.ename%TYPE;
  l_sal   emp.sal%TYPE;

  l_deptno dept.deptno%TYPE;
  l_dname  dept.dname%TYPE;
BEGIN
  /* Open the cursor variable for first SELECT statement */
  OPEN curv FOR
    SELECT ename, sal
      FROM emp
     WHERE ename='JAMES';

   FETCH curv INTO l_ename, l_sal;
   CLOSE curv;
   DBMS_OUTPUT.PUT_LINE('Salary of '||L_ENAME||' is '||L_SAL);

  /* Reopen the cursor variable for second SELECT statement */
  OPEN curv FOR
    SELECT deptno, dname
      FROM dept
     WHERE loc='DALLAS';

  FETCH curv INTO l_deptno, l_dname;
  CLOSE curv;

  DBMS_OUTPUT.PUT_LINE('Department name '||l_dname ||' for '||l_deptno);
END;
/

---

DECLARE
  cv   SYS_REFCURSOR;
BEGIN
  OPEN cv FOR 'select * from SYS.dual';
  CLOSE cv;

  -- same
  OPEN cv FOR SELECT * FROM SYS.dual;
  CLOSE cv;
END;

---

CREATE OR REPLACE FUNCTION pass_cursor RETURN SYS_REFCURSOR IS
  l_contactCursor SYS_REFCURSOR;

  BEGIN
    OPEN l_contactCursor FOR q'[SELECT contact_id, gonereason FROM base c WHERE ROWNUM <10]';
    RETURN l_contactCursor;
END;

CREATE OR REPLACE PROCEDURE print_cursor IS
  gonereason    BOOLEAN;
  l_contact_id  NUMBER;
  l_gonereason  NUMBER;
  l_c           SYS_REFCURSOR;
   
  BEGIN
    l_c := pass_cursor();

    LOOP
      FETCH l_c INTO l_contact_id, l_gonereason;

      gonereason := (l_gonereason = 0);

      IF gonereason THEN
        DBMS_OUTPUT.PUT_LINE ('not gone: ' || l_contact_id);
      ELSE
        DBMS_OUTPUT.PUT_LINE ('gone: ' || l_contact_id); 
      END IF;

      EXIT WHEN l_c%NOTFOUND;
    END LOOP;
END;

---

-- Adapted http://blog.mclaughlinsoftware.com/2008/10/11/reference-cursors-why-when-and-how
-- Creates a function to dynamically open a cursor and return it as a return type
CREATE OR REPLACE FUNCTION weakly_typed_cursor(job_segment VARCHAR2) RETURN SYS_REFCURSOR IS
  weak_cursor SYS_REFCURSOR;
  stmt VARCHAR2(4000);
  
BEGIN
  -- Dynamic SQL
  stmt := 'SELECT ename, job '
       || 'FROM   scott.emp '
       || 'WHERE  REGEXP_LIKE(ename, :input) or deptno=10';
       
  -- Explicit cursor structures are required for system reference cursors
  OPEN weak_cursor FOR stmt
    USING job_segment;

  RETURN weak_cursor;
END;

-- View cursor results
DECLARE
  en varchar2(80);
  jo varchar2(80);

  /* TYPE cv_type IS REF CURSOR; */
  /* cv cv_type; */
  -- same
  cv sys_refcursor;

BEGIN
  cv := weakly_typed_cursor('KING');
  
  LOOP
    FETCH cv INTO en, jo;

    EXIT WHEN cv%NOTFOUND;

    dbms_output.put_line(en || ' is ' || jo);  -- must come after NOTFOUND check
  END LOOP;
END;

-- Or better:
-- Create a structure declaration package, like an interface or abstract class
CREATE OR REPLACE PACKAGE pipeliner IS
  -- Declares a row structure that doesn't map to a catalog object
  TYPE title_structure IS RECORD (item_title    VARCHAR2(60),
																	item_subtitle VARCHAR2(60));

  TYPE title_collection IS TABLE OF title_structure;
END pipeliner;

-- Receives a cursor as an input and returns an aggregate TABLE
CREATE OR REPLACE FUNCTION use_of_bulk_cursor(cursor_in SYS_REFCURSOR)
  RETURN pipeliner.title_collection PIPELINED
IS
  active_collection pipeliner.title_collection := pipeliner.title_collection();  -- constructor
  
BEGIN
  -- Load the already open cursor into the nested table
  FETCH cursor_in BULK COLLECT INTO active_collection;
  
  FOR i IN 1..active_collection.COUNT LOOP -- not FORALL!
	-- Add a row to the aggregate return table
    PIPE ROW(active_collection(i));
  END LOOP;
  
  CLOSE cursor_in;

  RETURN;
END;

SELECT * FROM TABLE(use_of_bulk_cursor(weakly_typed_cursor('KING')))

---

-- Adapted: Fri, Apr 26, 2019 10:48:03 AM (Bob Heckel -- sfdemo Stephen Feurstein)
-- Use a procedure to pass cursor

CREATE TABLE jokes (
   joke_id INTEGER,
   title VARCHAR2(100),
   text VARCHAR2(4000)
)
/
CREATE TABLE joke_archive (
   archived_on DATE, old_stuff VARCHAR2(4000)
)
/

BEGIN
   INSERT INTO jokes
        VALUES (100, 'Why does an elephant take a shower?'
               ,'Why does an elephant take a shower? Because he can''t fit in the bathtub!');

   INSERT INTO jokes
        VALUES (100
               ,'How can you prevent deseases caused by biting insects?'
               ,'How can you prevent deseases caused by biting insects? Don''t bite any!');

   COMMIT;
END;
/

CREATE OR REPLACE PROCEDURE get_title_or_text(
   title_like_in IN VARCHAR2
  ,return_title_in IN BOOLEAN
  ,joke_count_out OUT PLS_INTEGER
  ,jokes_out OUT SYS_REFCURSOR
)
IS
   c_from_where   VARCHAR2 (100) := ' FROM jokes WHERE title LIKE :your_title';
   l_colname      all_tab_columns.column_name%TYPE := 'TEXT';
   l_query        VARCHAR2 (32767);
BEGIN
   IF return_title_in
   THEN
      l_colname := 'TITLE';
   END IF;

   l_query := 'SELECT ' || l_colname || c_from_where;

   OPEN jokes_out FOR l_query USING title_like_in;

   EXECUTE IMMEDIATE 'SELECT COUNT(*)' || c_from_where
                INTO joke_count_out
               USING title_like_in;
END get_title_or_text;
/

DECLARE
   l_count        PLS_INTEGER;
   l_jokes        sys_refcursor;

   TYPE jokes_tt IS TABLE OF jokes.text%TYPE;

   l_joke_array   jokes_tt := jokes_tt();
BEGIN
   get_title_or_text (title_like_in        => '%insect%'
                     ,return_title_in      => FALSE
                     ,joke_count_out       => l_count
                     ,jokes_out            => l_jokes
                     );
   DBMS_OUTPUT.put_line ('Number of jokes found = ' || l_count);

   -- Load cursor into a nested table
   FETCH l_jokes
   BULK COLLECT INTO l_joke_array;

   CLOSE l_jokes;

   FORALL indx IN l_joke_array.FIRST .. l_joke_array.LAST
      INSERT INTO joke_archive
           VALUES (SYSDATE, l_joke_array(indx));
END;

---

/* Adapted from https://docs.oracle.com/database/121/LNPLS/static.htm#LNPLS494 */
/* Query a collection */

-- The data type of the collection must either be created at schema level or
-- declared in a package specification:
CREATE OR REPLACE PACKAGE pkg AUTHID DEFINER AS
  TYPE rec IS RECORD(f1 NUMBER, f2 VARCHAR2(30));
  TYPE aa IS TABLE OF rec INDEX BY pls_integer;
END;
/
DECLARE
  collection_of_recs  pkg.aa;
  recs                pkg.rec;

  -- Cursor variable is an SQL query on an associative array of records
  c1 SYS_REFCURSOR;

BEGIN
  -- Load associative array
  collection_of_recs(1).f1 := 1;
  collection_of_recs(1).f2 := 'two';

  OPEN c1 FOR SELECT * FROM TABLE(collection_of_recs);
  FETCH c1 INTO recs;
  CLOSE c1;

  DBMS_OUTPUT.PUT_LINE('Values in record are ' || recs.f1 || ' and ' || recs.f2);
END;

---

-- Single record
DECLARE
   l_cv  SYS_REFCURSOR;

   l_record  employees%ROWTYPE;
BEGIN
   EXECUTE IMMEDIATE 'BEGIN OPEN :cv FOR select * from employees where rownum=1; END;'
     USING IN OUT l_cv;

   FETCH l_cv INTO l_record;

   DBMS_OUTPUT.put_line(l_record.last_name);

   CLOSE l_cv;
END;

-- Multiple records
DECLARE
   l_cv  SYS_REFCURSOR;

   TYPE aa_t IS TABLE of scott.emp%ROWTYPE INDEX BY BINARY_INTEGER;
   emp_aa  aa_t;
   
BEGIN
   -- Load cursor into associative array
   EXECUTE IMMEDIATE 'BEGIN OPEN :cv FOR select * from scott.emp; END;'
     USING IN OUT l_cv;

   FETCH l_cv BULK COLLECT INTO emp_aa;

   DBMS_OUTPUT.put_line(emp_aa(3).ename);

   CLOSE l_cv;
END;

