-- The loop statements are the basic LOOP, FOR LOOP, and WHILE LOOP.
--
-- The EXIT statement transfers control to the end of a loop. The CONTINUE
-- statement exits the current iteration of a loop and transfers control to the
-- next iteration. Both EXIT and CONTINUE have an optional WHEN clause, where you
-- can specify a condition.

-- See also for.plsql

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

-- Compare virtual columns on two tables
DECLARE
  TYPE varcharTable IS TABLE OF VARCHAR2(32767);

  column_table varcharTable;
  full_table   varcharTable;
  uat_table    varcharTable;
  
  v_sql VARCHAR2(32767) := 'select utc1.column_name, utc1.data_default, utc2.data_default
                              from user_tab_cols utc1, user_tab_cols utc2
                             where utc1.TABLE_NAME = ''MKC_REVENUE_FULL''
                               and utc1.VIRTUAL_COLUMN = ''YES''
                               and utc2.TABLE_NAME = ''MKC_REVENUE_FULL_UAT''
                               and utc2.VIRTUAL_COLUMN = ''YES''
                               and utc1.COLUMN_NAME = utc2.COLUMN_NAME';
BEGIN
  EXECUTE IMMEDIATE v_sql BULK COLLECT
    INTO column_table, full_table, uat_table;

  FOR i IN 1 .. full_table.COUNT LOOP
    IF (UPPER(REPLACE(full_table(i), ' ', '')) != UPPER(REPLACE(uat_table(i), ' ', ''))) THEN
      DBMS_OUTPUT.put_line(column_table(i) || ' are NOT equal!');
      DBMS_OUTPUT.put_line(' ');
      
      DBMS_OUTPUT.put_line('  ' || full_table(i));
      DBMS_OUTPUT.put_line('   DOES NOT EQUAL');
      DBMS_OUTPUT.put_line('  ' || uat_table(i));
      DBMS_OUTPUT.put_line(' ');
    END IF;
  END LOOP;
END;
