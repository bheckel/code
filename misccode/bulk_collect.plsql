CREATE TABLE plch_stuff
(
   id       NUMBER PRIMARY KEY
 ,  rating   INTEGER
)
/

BEGIN
   INSERT INTO plch_stuff
        VALUES (100, 50);

   INSERT INTO plch_stuff
        VALUES (200, 25);

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
   DBMS_OUTPUT.put_line (l_stuff.FIRST);
   DBMS_OUTPUT.put_line (l_stuff.COUNT);

   for i in 1 ..l_stuff.count
   loop
    --x := l_stuff(i).rating;
    --dbms_output.put_line(x);
    dbms_output.put_line(l_stuff(i).rating);
   end loop;

   /* Now do it again - will see same count */
   SELECT *
     BULK COLLECT INTO l_stuff
     FROM plch_stuff;

   DBMS_OUTPUT.put_line (l_stuff.COUNT);
END;
/

/* Clean up */

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

   TYPE employee_tt IS TABLE OF employees_cur%ROWTYPE INDEX BY PLS_INTEGER;
   l_employees   employee_tt;

BEGIN
   OPEN employees_cur;
   LOOP
      FETCH employees_cur
      BULK COLLECT INTO l_employees LIMIT limit_in;
      FOR indx IN 1 .. l_employees.COUNT
      LOOP
         process_each_employees (l_employees (indx));
      END LOOP;
      EXIT WHEN employees_cur%NOTFOUND;
   END LOOP;
   CLOSE employees_cur;
END bulk_with_limit;
