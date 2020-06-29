
CREATE OR REPLACE PACKAGE tmr IS
   PROCEDURE start_timer;

   PROCEDURE show_elapsed_time(message_in IN VARCHAR2);
END;
/

CREATE OR REPLACE PACKAGE BODY tmr IS
   l_wall_start  INTEGER;
   l_cpu_start   INTEGER;

   PROCEDURE start_timer IS
     BEGIN
        l_wall_start := DBMS_UTILITY.get_time;
        l_cpu_start := DBMS_UTILITY.get_cpu_time;
   END;

   PROCEDURE show_elapsed_time(message_in IN VARCHAR2) IS
     BEGIN
       DBMS_OUTPUT.put_line (
         CASE
            WHEN message_in IS NULL THEN 'Completed in:'
            ELSE '"' || message_in || '" completed in: '
         END
         || (DBMS_UTILITY.get_time - l_wall_start)
         || ' '
         || (DBMS_UTILITY.get_cpu_time - l_cpu_start)
         || ' cs');

        /* Reset timer */
        start_timer;
   END show_elapsed_time;
END;
/
