-- Modified: 10-Feb-2022 (Bob Heckel)
-- The loop statements are the basic LOOP, FOR LOOP, and WHILE LOOP.
--
-- The EXIT statement transfers control to the end of a loop. The CONTINUE
-- statement exits the current iteration of a loop and transfers control to the
-- next iteration. Both EXIT and CONTINUE have an optional WHEN clause, where you
-- can specify a condition.

-- See also for.plsql

---

-- Basic loop ------------
LOOP
   ...statements
-- Note: one of your statements in a simple loop should be EXIT or EXIT WHEN to ensure that you don't end up with an infinite loop.
END LOOP;

-- While loop ------------
WHILE condition
LOOP
   ...statements
END LOOP;

-- For loop -------------
FOR iterator IN low_value .. high_value
LOOP
   statements
END LOOP;

FOR record IN [cursor | (SELECT statement) ]
LOOP
   statements
END LOOP;

---

DECLARE
  s  PLS_INTEGER := 0;
  i  PLS_INTEGER := 0;
  j  PLS_INTEGER;
BEGIN
  <<outer_loop>>
  LOOP
    i := i + 1;
    j := 0;
    <<inner_loop>>
    LOOP
      j := j + 1;
      s := s + i * j; -- Sum several products
      EXIT inner_loop WHEN (j > 5);
      EXIT outer_loop WHEN ((i * j) > 15);
    END LOOP inner_loop;
  END LOOP outer_loop;
  DBMS_OUTPUT.PUT_LINE
    ('The sum of products equals: ' || TO_CHAR(s));
END;
/


DECLARE
  done  BOOLEAN := FALSE;
BEGIN
  WHILE done LOOP
    DBMS_OUTPUT.PUT_LINE ('This line does not print.');
    done := TRUE;  -- This assignment is not made.
  END LOOP;

  WHILE NOT done LOOP
    DBMS_OUTPUT.PUT_LINE ('Hello, world!');
    done := TRUE;
  END LOOP;
END;
/

---

FOR r IN cursor1 LOOP
	SET_CONTACT_MATCH_CODE(r.CONTACT_ID, 1);
	rowcnt := rowcnt + 1;
	IF MOD(rowcnt, 100) = 0 THEN
		COMMIT;
	END IF;
END LOOP;

---

CREATE OR REPLACE PROCEDURE test_proc AS
	BEGIN
		FOR x IN ( SELECT col1, col2 FROM test_table )
		LOOP
			dbms_output.put_line(x.col1);
		END LOOP;
END;

---

DECLARE
  CURSOR c1 IS
    SELECT * FROM USER_TABLES WHERE TABLE_NAME LIKE 'MKC%';

  CURSOR indexCursor(in_table_name VARCHAR2) IS
    select index_name, degree
      from dba_indexes
     where table_name = in_table_name;
BEGIN
  FOR rec IN c1 LOOP
    FOR index_rec IN indexCursor(rec.table_name) LOOP
      DBMS_OUTPUT.put_line(index_rec.index_name || ' ' || index_rec.degree);
    
      IF (index_rec.degree != 1) THEN
        BEGIN
          EXECUTE IMMEDIATE 'alter index ' || index_rec.index_name || ' NOPARALLEL';
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      END IF;
    END LOOP;
  END LOOP;
END;

---

DECLARE
  TYPE dow_tab_t IS TABLE OF VARCHAR2(10);
  dow_tab dow_tab_t := dow_tab_t('Sunday' ,'Monday','Tuesday','Wednesday','Thursday' ,'Friday','Saturday');
BEGIN
  FOR counter IN 2 .. 6 LOOP
    --Skip Wednesdays
    CONTINUE day_loop 
      WHEN dow_tab(counter)='Wednesday';
    DBMS_OUTPUT.PUT_LINE(dow_tab(counter));
  END LOOP;
END;

---

-- An actual use of loop tags
BEGIN
  <<outer_loop>>
  FOR outer_counter IN 1 .. 3 LOOP
    DBMS_OUTPUT.PUT_LINE(outer_counter);
    <<inner_loop>>
    FOR inner_counter IN 10 .. 15 LOOP
      CONTINUE outer_loop 
         WHEN outer_counter > 1 
              AND inner_counter = 12;
      DBMS_OUTPUT.PUT_LINE('...'||inner_counter);
    END LOOP;
  END LOOP;
END;
