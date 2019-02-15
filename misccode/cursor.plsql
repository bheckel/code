
create or REPLACE PROCEDURE zrestore_grants (table_name IN VARCHAR, back_date IN NUMBER DEFAULT 1) IS
  char_back_date VARCHAR2(20);
  grantStatement varchar2(4000);

  TYPE restore_grants_t IS REF CURSOR;
  restore_grants_c restore_grants_t;

  BEGIN
    char_back_date := to_char(SYSDATE - back_date, 'yyyymmdd');
     IF (TABLE_NAME IS NOT NULL) THEN
        BEGIN
        dbms_output.put_line ('in table_name is ' || table_name);
        OPEN restore_grants_t FOR
           'SELECT DISTINCT grant_statement
             FROM rar_select_restore sr
            WHERE sr.table_name = ''' || trim(table_name) || ''' AND sr.restoreDate= ''' || trim(char_back_date) || ''' ';
        END;
     ELSE
       BEGIN
         dbms_output.put_line ('in table_name is null');
       OPEN restore_grants_t FOR
          SELECT DISTINCT grant_statement
             FROM rar_select_restore sr
            WHERE sr.restoreDate=to_char (SYSDATE - back_date, 'yyyymmdd');
       END;
     END IF;
    LOOP
       FETCH restore_grants_t INTO grantStatement;
       EXIT WHEN restore_grants_t%NOTFOUND;
				 dbms_output.put_line('EXECUTE IMMEDIATE ''' || grantStatement || ''';');
         -- EXECUTE IMMEDIATE (grantStatement);
    END LOOP;
  CLOSE restore_grants;
END;

---

-- For small number of UPDATEs only
PROCEDURE upd IS
  rc pls_integer := 0;

	CURSOR c IS
		 SELECT * 
			 FROM reference_employee_base 
			WHERE employee_id = 1234 
				AND territory_lov_id IN( SELECT r.territory_lov_id 
																	 FROM rs_ptg_territory_hierarchy r 
																	WHERE upper(r.TERRITORY_CODE) LIKE '%QQFC%'  
																		 OR upper(r.TERRITORY_CODE) LIKE '%QQFS%'
																		 OR upper(r.TERRITORY_CODE) LIKE '%QQFT%'
															 );  
	
	BEGIN
	
		FOR r IN c LOOP
			UPDATE reference_employee_base
				 SET employee_id=9999
			 WHERE reference_id = r.reference_id;
		
			dbms_output.put_line(r.reference_id);
		END LOOP;

    rc := SQL%ROWCOUNT; dbms_output.put_line('rows affected: ' || rc);
	  COMMIT;
END upd;

---

-- https://oracle-base.com/articles/misc/implicit-vs-explicit-cursors-in-oracle-plsql

---

--  As long as you do not have DML inside the loop, use the cursor FOR loop

---

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

---

-- Cursor-less

FOR r IN ( SELECT t.msg, t.execute_time
					 FROM SUER_ONCALL_RESULTS t 
					 WHERE r.execute_time > (sysdate - 1) AND r.execute_time < to_date('2019-01-16:11:00','YYYY-MM-DD:HH:MI') --debug 
					 --r.execute_time > (SYSTIMESTAMP - INTERVAL '4' minute)
					ORDER BY r.execute_time DESC
) LOOP
	dbms_output.put_line(r.msg);
END LOOP;
