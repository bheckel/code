-- Adapted: Thu, Jul 11, 2019  9:24:12 AM (Bob Heckel--http://stevenfeuersteinonplsql.blogspot.com/2019/07/best-type-of-collection-for-forall.html)
CREATE OR REPLACE PACKAGE tmr
IS
   PROCEDURE start_timer;

   PROCEDURE show_elapsed_time (message_in IN VARCHAR2);
END;
/

CREATE OR REPLACE PACKAGE BODY tmr
IS
   l_start   INTEGER;

   PROCEDURE start_timer
   IS
   BEGIN
      l_start := DBMS_UTILITY.get_cpu_time;
   END start_timer;

   PROCEDURE show_elapsed_time (message_in IN VARCHAR2)
   IS
   BEGIN
      DBMS_OUTPUT.put_line (
            CASE
               WHEN message_in IS NULL THEN 'Completed in:'
               ELSE '"' || message_in || '" completed in: '
            END
         || (DBMS_UTILITY.get_cpu_time - l_start)
         || ' cs');

      /* Reset timer */
      start_timer;
   END show_elapsed_time;
END;
/
