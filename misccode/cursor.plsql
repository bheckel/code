-- Modified: Modified: 31-Jan-2020 (Bob Heckel)
-- See also pass_cursor.plsql

-- A cursor is a pointer to a memory location (context area). PL/SQL controls the context area
-- through a cursor. A cursor holds the rows (one or more) returned by a SQL
-- statement. The set of rows the cursor holds is referred to as the active set.

-- Declaring the cursor defines the cursor with a name and the associated SELECT statement:
-- 
-- CURSOR c_customers IS 
--    SELECT id, name, address FROM customers; 
-- 
-- Opening the cursor allocates the memory for the cursor and makes it ready for
-- fetching the rows (returned by the SQL statement) into it:
-- 
-- OPEN c_customers;  -- %ISOPEN is TRUE
-- 
-- Fetching the cursor involves accessing one row at a time:
-- 
-- FETCH c_customers INTO c_id, c_name, c_addr; 
-- 
-- Closing the cursor means releasing the allocated memory:
-- 
-- CLOSE c_customers;

--  As long as you do not have DML inside the loop, use the cursor FOR loop
-- https://oracle-base.com/articles/misc/implicit-vs-explicit-cursors-in-oracle-plsql

-- Strong ref cursor - has the small advantage that you will get a compile-time error rather than a 
-- run-time error in the case that you attempt to fetch into a record or a set of scalars that don’t 
-- match the shape of the select list:
--
-- TYPE result_t IS RECORD(pk t.pk%TYPE, v1 t.v1%TYPE);
-- TYPE strong_cur_t IS REF CURSOR RETURN result_t;

---

-- Implicit cursor

CREATE TABLE test_table ( col1 INTEGER, col2 INTEGER );

insert into test_table values (3, 4)

CREATE OR REPLACE PROCEDURE test_proc AS
	BEGIN
		FOR x IN ( SELECT col1, col2 FROM test_table )
		LOOP
			dbms_output.put_line(x.col1);
		END LOOP;
END;

---

-- For queries that return more than one row, you must declare an explicit
-- cursor and use OPEN, FETCH, CLOSE in a loop

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

-- For small number of UPDATEs only, otherwise BULK COLLECT
CREATE OR REPLACE PROCEDURE upd IS
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

CREATE OR REPLACE PROCEDURE test(in_aid contact_base.account_name_id%TYPE) IS
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

---

DECLARE 
  CURSOR c_customers is SELECT name FROM tmpcustomers; 

  type c_list is varray(6) of customers.name%type; 

  name_list c_list := c_list(); 

  counter integer :=0; 
BEGIN 
  FOR n IN c_customers LOOP 
     counter := counter + 1; 
     name_list.extend; 
     name_list(counter) := n.name; 
     dbms_output.put_line('Customer('||counter ||'):'||name_list(counter)); 
  END LOOP; 
END;

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

-- Use a collection based on a cursor
CREATE OR REPLACE PROCEDURE do4 IS
  cnt PLS_INTEGER := 0;

  CURSOR c1 IS
    SELECT u.user_oncall_results_id, u.execute_time
    FROM zuser_oncall_results u
    WHERE u.execute_time < (sysdate - 1470);
    
  TYPE t1 IS TABLE OF c1%ROWTYPE;
  l_recs t1;
          
  BEGIN
    OPEN c1;
    LOOP
      FETCH c1 BULK COLLECT INTO l_recs LIMIT 20;  
      
      EXIT WHEN l_recs.COUNT = 0;
      
      FORALL i IN 1 .. l_recs.COUNT
        DELETE 
          FROM zuser_oncall_results u
         WHERE u.user_oncall_results_id = l_recs(i).user_oncall_results_id;
      
        cnt := cnt + SQL%ROWCOUNT;
        
        --COMMIT;
        ROLLBACK;
    END LOOP;
    CLOSE c1;
    dbms_output.put_line(cnt);
END;

---

-- Dynamic cursor 'OPEN FOR'.  See also pass_cursor.plsql

-- 1. single column
DECLARE
  rn    NUMBER := 2;
  myres varchar(99);
  -- SYS_REFCURSOR is defined in the STANDARD package as a REF CURSOR (type sys_refcursor is ref cursor;). It is a 
  -- predefined weak REF CURSOR type, unlike this strong type: TYPE book_data_t IS REF CURSOR RETURN book%ROWTYPE;
  cv    SYS_REFCURSOR;
BEGIN
  OPEN cv FOR 'select ename from emp where rownum <= :1'
    USING rn;

  LOOP
    FETCH cv INTO myres;

    EXIT WHEN cv%NOTFOUND;
    
    dbms_output.put_line(myres);
  END LOOP;

  CLOSE cv;
END;

-- 2. multiple columns
DECLARE
  rn  NUMBER := 2;
  r   emp%ROWTYPE;
  cv  SYS_REFCURSOR;
  i   NUMBER;
BEGIN
  OPEN cv FOR 'select * from emp where rownum <= :1'
    USING rn;

  LOOP
    FETCH cv INTO r;

    EXIT WHEN cv%NOTFOUND;

    i := i + 1;
    
    dbms_output.put_line(r.ename);
  END LOOP;

  CLOSE cv;
END;

-- 3. multiple columns using collection
DECLARE
  rn       NUMBER := 2;
 	type     char_t is table of emp%rowtype;
	chartbl  char_t;
  cv       SYS_REFCURSOR;
BEGIN
  OPEN cv FOR 'select * from emp where rownum <= :1'
    USING rn;

  LOOP
    FETCH cv bulk collect INTO chartbl;  -- no initialization required for bulk collect! 

    EXIT WHEN chartbl.count = 0;

    for i in 1..chartbl.count loop
			dbms_output.put_line(chartbl(i).ename);
    end loop;

  END LOOP;

  CLOSE cv;
END;

---

DECLARE
  cv SYS_REFCURSOR;

	type numtbl_t is table of number;
	numtbl numtbl_t;

BEGIN
   OPEN cv FOR SELECT empno FROM emp;
   LOOP
		 FETCH cv bulk collect INTO numtbl limit 10;
		 --EXIT WHEN cv%NOTFOUND;  -- only gives 10 then quits
		 exit when numtbl.COUNT = 0;

     for i in 1..numtbl.COUNT loop
		   dbms_output.put_line(i || ' ' || numtbl(i));
     end loop;
   END LOOP;

   CLOSE cv;
END;

---

-- See also dynamic_procedure.plsql

create or REPLACE PROCEDURE zrestore_grants (table_name IN VARCHAR, back_date IN NUMBER DEFAULT 1) IS
  char_back_date VARCHAR2(20);
  grantStatement varchar2(4000);

  TYPE restore_grants_t IS REF CURSOR;
  restore_grants_c restore_grants_t;

  BEGIN
    char_back_date := to_char(SYSDATE - back_date, 'yyyymmdd');

     -- Choose which cursor to use...
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
    -- ...then loop it
    LOOP
       FETCH restore_grants_t INTO grantStatement;
       EXIT WHEN restore_grants_t%NOTFOUND;
         dbms_output.put_line('EXECUTE IMMEDIATE ''' || grantStatement || ''';');
         -- EXECUTE IMMEDIATE (grantStatement);
    END LOOP;
  CLOSE restore_grants;
END;

---

-- Parameterized cursor (with defaults)
DECLARE
  CURSOR cur_revenue(p_year NUMBER :=2017 , p_customer_id NUMBER := 1) IS
    SELECT SUM(quantity * unit_price) revenue
    FROM order_items JOIN orders USING (order_id)
    WHERE status = 'Shipped' AND EXTRACT(YEAR FROM order_date) = p_year
    GROUP BY customer_id
    HAVING customer_id = p_customer_id
  ;

  rec_revenue cur_revenue%ROWTYPE;

BEGIN
  OPEN cur_revenue;
  LOOP
    FETCH cur_revenue INTO rec_revenue;
    EXIT WHEN cur_revenue%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(rec_revenue.revenue);
  END LOOP;
  CLOSE cur_revenue;
END;

---

-- Dynamic cursor passed in from procedure parameter
CREATE OR REPLACE PACKAGE optm_view_mrl2 IS
   PROCEDURE cast_max_len2(tablename IN VARCHAR2);
END;
CREATE OR REPLACE PACKAGE BODY optm_view_mrl2 IS
  PROCEDURE cast_max_len2(tablename IN VARCHAR2) IS
    colnm VARCHAR(99);
    colsz NUMBER;
    cv    SYS_REFCURSOR;
  BEGIN
    OPEN cv FOR 'SELECT column_name, data_length
                  FROM user_tab_columns
                 WHERE table_name = :1'
      USING tablename;
  
    LOOP
      FETCH cv INTO colnm, colsz;
  
      EXIT WHEN cv%notfound;
      
      dbms_output.put_line('create or replace view ' || tablename || '_mrl as select ' || colnm || ' HOWEVER_YOU_DO_A_CAST(' || colsz || ') from ' || tablename);
    END LOOP;
  
    CLOSE cv;
  END;
END;
exec  Optm_view_mrl2.cast_max_len2('ACCOUNT');
