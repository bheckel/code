-- Modified: Mon 17 Jun 2019 11:41:50 (Bob Heckel)
-- See also table_function.plsql

CREATE TYPE department_typ AS OBJECT(d_name    VARCHAR2(100),
                                     d_address VARCHAR2(200));

CREATE TABLE departments_obj_t OF department_typ;

INSERT INTO departments_obj_t VALUES ('hr', '10 Main St, Sometown, CA');

select * from departments_obj_t 

desc departments_obj_t 

---

-- Adapted 08-Mar-19 https://devgym.oracle.com
CREATE OR REPLACE TYPE timer_t AS OBJECT 
(
       start_time INTEGER
     , title VARCHAR2 (2000)
     , MEMBER PROCEDURE start_timer
     , MEMBER PROCEDURE show_elapsed_time
     , CONSTRUCTOR FUNCTION timer_t (
          self       IN OUT timer_t
        , title_in   IN     VARCHAR2)
          RETURN SELF AS RESULT
)
/

CREATE OR REPLACE TYPE BODY timer_t
AS
   CONSTRUCTOR FUNCTION timer_t (self IN OUT timer_t, title_in IN VARCHAR2)
      RETURN SELF AS RESULT
   IS
   BEGIN
      self.title := title_in;
      RETURN;
   END;

   MEMBER PROCEDURE start_timer
   IS
   BEGIN
      start_time := DBMS_UTILITY.get_time;
   END;

   MEMBER PROCEDURE show_elapsed_time
   IS
   BEGIN
      DBMS_OUTPUT.
       put_line (
         'Elapsed ' || 'for ' || self.title || ' = '
         || TO_CHAR (
                MOD (DBMS_UTILITY.get_time - start_time + POWER (2, 32)
                   , POWER (2, 32)))
                 );
   END;
END;
/

DECLARE
   l_timer     timer_t := timer_t('Assign!');
   l_integer   PLS_INTEGER;
BEGIN
   l_timer.start_timer();

   FOR indx IN 1 .. 10000000
   LOOP
      l_integer := l_integer + 1;
   END LOOP;

   l_timer.show_elapsed_time();
END;
/
