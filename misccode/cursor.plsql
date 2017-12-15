-- For queries that return more than one row, you must declare an explicit
-- cursor and use OPEN, FETCH, CLOSE

SET serveroutput on;
SHOW ERRORS;  -- if submitted via @cursor.plsql in SQL*Plus

-- Anonymous block
DECLARE
  emp_name VARCHAR2(10);
  CURSOR c1 is  select fooC1 from tmpbobh where fooN1 = 67;
BEGIN 
  OPEN c1;
  /* The number of iterations will equal the number of rows returned by c1 */
  LOOP
    FETCH c1 INTO emp_name;
    EXIT WHEN c1%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('emp is '||emp_name);
  END LOOP;
END;
/


 /* new example */

SET serveroutput on;
SHOW ERRORS;

-- Anonymous block
DECLARE
  CURSOR c1 is  select * from tmpbobh where fooN1 = 67;
  therec c1%ROWTYPE;  -- hold the entire cursor record from the above SELECT *
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 INTO therec;
    EXIT WHEN c1%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(therec.fooD1||' '||therec.fooN1);
  END LOOP;
END;
/
