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
