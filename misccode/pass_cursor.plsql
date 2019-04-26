/* Modified: Mon 15 Apr 2019 13:28:26 (Bob Heckel) */ 

DECLARE
   cv   sys_refcursor;  -- weak REF CURSOR type can be used in an OPEN FOR statement with either a static or dynamic SQL statement
BEGIN
   -- Dynamic works for weak or strong
   OPEN cv FOR 'select * from SYS.dual';
   CLOSE cv;

   -- Static works for weak only
   OPEN cv FOR SELECT * FROM SYS.dual;
   CLOSE cv;
END;

---

FUNCTION pass_cursor RETURN sys_refcursor
  IS
    l_contactCursor SYS_REFCURSOR;
  BEGIN
    OPEN l_contactCursor FOR q'[SELECT contact_id, gonereason FROM base c WHERE ROWNUM <10]';
    RETURN l_contactCursor;
END;


PROCEDURE print_cursor IS
  gonereason    BOOLEAN;
  l_contact_id  NUMBER;
  l_gonereason  NUMBER;
  l_c           SYS_REFCURSOR;  -- weakly typed
   
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
  OPEN weak_cursor FOR stmt USING job_segment;
  RETURN weak_cursor;
END;

-- View cursor results
declare
  en varchar2(80);
  jo varchar2(80);
  cv sys_refcursor;
begin
  cv := weakly_typed_cursor('KING');
  
  loop
    fetch cv into en, jo;
    exit when cv%notfound;
    dbms_output.put_line(en || ' is ' || jo);  -- must come after notfound check
  end loop;
end;

-- Or better:
-- Create a structure declaration package, like an interface or abstract class
CREATE OR REPLACE PACKAGE pipeliner IS
  -- Declares a row structure that doesn't map to a catalog object
  TYPE title_structure IS RECORD (item_title    VARCHAR2(60),
																	item_subtitle VARCHAR2(60));

  TYPE title_collection IS TABLE OF title_structure;
END pipeliner;

-- Receives a cursor as an input and returns an aggregate TABLE
CREATE OR REPLACE FUNCTION use_of_bulk_cursor(incoming_cursor SYS_REFCURSOR)
  RETURN pipeliner.title_collection PIPELINED
IS
  active_collection pipeliner.TITLE_COLLECTION := pipeliner.title_collection();
  
BEGIN
  -- Fetch the already open cursor
  FETCH incoming_cursor BULK COLLECT INTO active_collection;
  
  FOR i IN 1..active_collection.COUNT LOOP -- not FORALL!
	-- Add a row to the aggregate return table
    PIPE ROW(active_collection(i));
  END LOOP;
  
  CLOSE incoming_cursor;
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
  ,jokes_out OUT sys_refcursor
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

   FETCH l_jokes
   BULK COLLECT INTO l_joke_array;

   CLOSE l_jokes;

   FORALL indx IN l_joke_array.FIRST .. l_joke_array.LAST
      INSERT INTO joke_archive
           VALUES (SYSDATE, l_joke_array (indx));
END;

