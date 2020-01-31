DECLARE
  starting_time  TIMESTAMP WITH TIME ZONE;
  ending_time    TIMESTAMP WITH TIME ZONE;
BEGIN
  -- Invokes SQRT for every row of employees table:
 
  SELECT SYSTIMESTAMP INTO starting_time FROM DUAL;
 
  FOR item IN (
    SELECT DISTINCT(SQRT(department_id)) col_alias
    FROM employees
    ORDER BY col_alias
  )
  LOOP
    DBMS_OUTPUT.PUT_LINE('Square root of dept. ID = ' || item.col_alias);
  END LOOP;
 
  SELECT SYSTIMESTAMP INTO ending_time FROM DUAL;
 
  DBMS_OUTPUT.PUT_LINE('Time = ' || TO_CHAR(ending_time - starting_time));
 
  -- Invokes SQRT for every distinct department_id of employees table:
 
  SELECT SYSTIMESTAMP INTO starting_time FROM DUAL;
 
  -- Nested query improves performance:
  FOR item IN (
    SELECT SQRT(department_id) col_alias
    FROM (SELECT DISTINCT department_id FROM employees)
    ORDER BY col_alias
  )
  LOOP
    IF item.col_alias IS NOT NULL THEN
      DBMS_OUTPUT.PUT_LINE('Square root of dept. ID = ' || item.col_alias);
    END IF;
  END LOOP;
 
  SELECT SYSTIMESTAMP INTO ending_time FROM DUAL;
 
  DBMS_OUTPUT.PUT_LINE('Time = ' || TO_CHAR(ending_time - starting_time));
END;
/

---

/*Create a table for performance test study*/
CREATE TABLE t_fun_plsql
(id number,
 str varchar2(30))
/
/*Generate and load random data in the table*/
INSERT /*+APPEND*/ INTO t_fun_plsql
SELECT ROWNUM, DBMS_RANDOM.STRING('X', 20)
FROM dual
CONNECT BY LEVEL <= 1000000
/
COMMIT
/
