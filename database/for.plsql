-- Modified: 22-May-2020 (Bob Heckel)
-- See also bulk_collect_forall.plsql

---

BEGIN
   FOR rec IN (SELECT contact_id FROM contact WHERE contact_id=9990034351)
   LOOP
      -- There is no NO_DATA_FOUND exception
      DBMS_OUTPUT.put_line (rec.contact_id);
   END LOOP;
END;

---

-- As long as your PL/SQL optimization level is set to 2 (the default) or higher, the compiler will automatically optimize
-- cursor FOR loops to retrieve 100 rows with each fetch. You cannot modify this number.
...
CURSOR c_dun_nbrs IS
  SELECT aa.duns_nbr FROM account_base ab;
...
BEGIN
	FOR rec IN c_dun_nbrs LOOP
		dbms_output.put_line(rec.duns_nbr);
	END LOOP;
...

---

DECLARE
  v_employees employees%ROWTYPE;
  CURSOR c1 is SELECT * FROM employees;
BEGIN
  OPEN c1;
  -- Fetch entire row into v_employees record:
  FOR i IN 1..10 LOOP
    FETCH c1 INTO v_employees;
    EXIT WHEN c1%NOTFOUND;
    -- Process data here
  END LOOP;
  CLOSE c1;
END;
/

---

DROP TABLE temp;
CREATE TABLE temp (
  emp_no      NUMBER,
  email_addr  VARCHAR2(50)
);
 
DECLARE
  emp_count  NUMBER;
BEGIN
  SELECT COUNT(employee_id) INTO emp_count
  FROM employees;
  
  FOR i IN 1..emp_count LOOP
    INSERT INTO temp (emp_no, email_addr)
    VALUES(i, 'to be added later');
  END LOOP;
END;
/

---

-- Any kind of FOR loop is saying, implicitly, “I am going to execute the loop
-- body for all iterations defined by the loop header” (N through M or SELECT).
-- Conditional exits mean the loop could terminate in multiple ways, resulting in
-- code that is hard to read and maintain.  Use a WHILE loop instead.
DECLARE
   CURSOR plch_parts_cur
   IS
      SELECT * FROM plch_parts;
BEGIN
   FOR rec IN plch_parts_cur
   LOOP
      DBMS_OUTPUT.put_line (rec.partname);
   END LOOP;
END;
/
-- This is better if you only use the "cursor" once
BEGIN
   FOR rec IN (SELECT * FROM plch_parts)
   LOOP
      DBMS_OUTPUT.put_line (rec.partname);
   END LOOP;
END;
/

---

DECLARE
  v_lower  NUMBER := 1;
  v_upper  NUMBER := 1;
BEGIN
  FOR i IN v_lower .. v_upper LOOP
    INSERT INTO foo (ordid, itemid) VALUES (v_ordid, i);
  END LOOP;
END;

---

-- FOR vs. FORALL

DECLARE
  TYPE NumList IS VARRAY(20) OF NUMBER;
  depts NumList := NumList(10, 30, 70);
BEGIN
  FOR i IN depts.FIRST..depts.LAST LOOP
    DELETE FROM employees_temp
    WHERE department_id = depts(i);
  END LOOP;
END;

-- Any failure rolls everything back
DECLARE
  TYPE NumList IS VARRAY(20) OF NUMBER;
  depts NumList := NumList(10, 30, 70);
BEGIN
  FORALL i IN depts.FIRST..depts.LAST  -- no LOOP but only 1 statement allowed!
    DELETE FROM employees_temp
    WHERE department_id = depts(i);
END;

-- Any failure does NOT roll anything back
DECLARE
  TYPE NumList IS VARRAY(20) OF NUMBER;
  depts NumList := NumList(10, 30, 70);
BEGIN
  FORALL i IN depts.FIRST..depts.LAST  -- no LOOP but only 1 statement allowed!
    DELETE FROM employees_temp
    WHERE department_id = depts(i);

  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
      COMMIT;  -- Commit results of the successful updates prior to this one
      RAISE;
END;

---

DECLARE
  TYPE NumList IS TABLE OF NUMBER;
  depts NumList := NumList(30, 50, 60);
BEGIN
  FORALL j IN depts.FIRST..depts.LAST
    DELETE FROM emp_temp WHERE department_id = depts(j);

  FOR i IN depts.FIRST .. depts.LAST LOOP
    DBMS_OUTPUT.PUT_LINE (
      'Statement #' || i || ' deleted ' ||
      SQL%BULK_ROWCOUNT(i) || ' rows.'
    );
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Total rows deleted: ' || SQL%ROWCOUNT);
END;
/*
Statement #1 deleted 6 rows.
Statement #2 deleted 45 rows.
Statement #3 deleted 5 rows.
Total rows deleted: 56
*/
