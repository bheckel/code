
-- Compare performance of cursor FOR loops
-- Adapted: 04-Jun-2020 (Bob Heckel -- Oracle DevGym)

CREATE OR REPLACE PROCEDURE test_cursor_performance(approach IN VARCHAR2) IS
  CURSOR cur IS
    SELECT * FROM all_source WHERE ROWNUM < 150001;

  one_row cur%ROWTYPE;

  TYPE t IS TABLE OF cur%ROWTYPE INDEX BY PLS_INTEGER;

  many_rows     t;
  last_timing   NUMBER;
  cntr number := 0;

  PROCEDURE start_timer IS
    BEGIN
      last_timing := DBMS_UTILITY.get_cpu_time;
    END;

  PROCEDURE show_elapsed_time(message_in IN VARCHAR2 := NULL) IS
    BEGIN
       DBMS_OUTPUT.put_line(
             '"'
          || message_in
          || '" completed in: '
          || TO_CHAR(ROUND((DBMS_UTILITY.get_cpu_time - last_timing) / 100, 2))
       );
    END;

  BEGIN
     start_timer;

     CASE approach
        /* 1. */
        WHEN 'implicit cursor for loop' THEN
           FOR j IN cur LOOP
              cntr := cntr + 1;
           END LOOP;

           DBMS_OUTPUT.put_line(cntr);

        /* 2. */
        WHEN 'explicit open, fetch, close' THEN
           OPEN cur;

           LOOP
              FETCH cur INTO one_row;
              EXIT WHEN cur%NOTFOUND;  -- <~~~~~~~~~~~~~

              cntr := cntr + 1;
           END LOOP;

           DBMS_OUTPUT.put_line(cntr);

           CLOSE cur;

        /* 3. */
        WHEN 'bulk fetch' THEN
           OPEN cur;

           LOOP
              FETCH cur BULK COLLECT INTO many_rows LIMIT 100;
              EXIT WHEN many_rows.COUNT() = 0;  -- <~~~~~~~~~~~~~

              FOR indx IN 1 .. many_rows.COUNT LOOP
                 cntr := cntr + 1;
              END LOOP;
           END LOOP;

           DBMS_OUTPUT.put_line(cntr);

           CLOSE cur;
     END CASE;

     show_elapsed_time(approach);
  END test_cursor_performance;

 -- Default level is 2, #1 & #3 perform the same at that level
ALTER PROCEDURE test_cursor_performance COMPILE plsql_optimize_level=2;

BEGIN
  -- Won't work here:
  --execute immediate 'ALTER PROCEDURE test_cursor_performance COMPILE plsql_optimize_level=0';
   
  /* 1. */
  test_cursor_performance('implicit cursor for loop');
  /* 2. */
  test_cursor_performance('explicit open, fetch, close');
  /* 3. */
  test_cursor_performance('bulk fetch');
END;
