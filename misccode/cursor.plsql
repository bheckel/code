--  As long as you do not have DML inside the loop, use the cursor FOR loop

PROCEDURE test(in_aid contact_base.account_name_id%TYPE) IS
	v_in_aid contact_base.account_name_id%TYPE;
	v_gonereason BOOLEAN;
 
	CURSOR contactCursor IS
		SELECT contact_id, gonereason
		FROM contact_base
		WHERE account_name_id in in_aid;
	 
	BEGIN
		<< loopy >>
		FOR c IN contactCursor LOOP
			v_in_aid := c.contact_id;
			v_gonereason := (c.gonereason = 0);
			IF v_gonereason THEN
				DBMS_OUTPUT.PUT_LINE ('not gone: ' || v_in_aid );
			END IF;
		END LOOP loopy;
END test;

-- A cursor is a pointer to this context area. PL/SQL controls the context area
-- through a cursor. A cursor holds the rows (one or more) returned by a SQL
-- statement. The set of rows the cursor holds is referred to as the active set.
--
-- Declaring the cursor defines the cursor with a name and the associated SELECT
-- statement.
-- 
-- CURSOR c_customers IS 
--    SELECT id, name, address FROM customers; 
-- 
-- Opening the cursor allocates the memory for the cursor and makes it ready for
-- fetching the rows returned by the SQL statement into it. For example, we will
-- open the above defined cursor as follows
-- 
-- OPEN c_customers; 
-- 
-- Fetching the cursor involves accessing one row at a time. For example, we will
-- fetch rows from the above-opened cursor as follows
-- 
-- FETCH c_customers INTO c_id, c_name, c_addr; 
-- 
-- Closing the cursor means releasing the allocated memory.
-- 
-- CLOSE c_customers;



DECLARE 
   CURSOR c_customers is SELECT  name FROM tmpcustomers; 

   type c_list is varray (6) of customers.name%type; 

   name_list c_list := c_list(); 

   counter integer :=0; 
BEGIN 
   FOR n IN c_customers LOOP 
      counter := counter + 1; 
      name_list.extend; 
      name_list(counter)  := n.name; 
      dbms_output.put_line('Customer('||counter ||'):'||name_list(counter)); 
   END LOOP; 
END;



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

---

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
