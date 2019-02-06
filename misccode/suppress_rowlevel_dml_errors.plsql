-- Adapted: 01-Feb-19 Oracle Nine Good-to-Knows for PL/SQL Error Management Dev Gym *?
--
-- When you execute a non-SELECT DML statement against a table and an error
-- occurs, the statement is terminated and rolled back in its entirety. This can
-- be wasteful of time and system resources. You can avoid this situation by using
-- the DML error logging feature.


---


BEGIN  
  DBMS_ERRLOG.create_error_log(dml_table_name => 'EMPLOYEES');  
END; 

SELECT * --column_name, data_type 
  FROM user_tab_columns 
 WHERE table_name = 'ERR$_EMPLOYEES'

DECLARE  
  l_count   PLS_INTEGER;  
BEGIN  
  SELECT COUNT (1)  
    INTO l_count  
    FROM employees  
   WHERE salary > 24000;  
  
  DBMS_OUTPUT.put_line ('Before ' || l_count);  
  
	UPDATE employees  
     SET salary = salary * 200  -- this will overflow column salary's datatype max in cases of high earners
  -- We don't care how many errors occur - just keeping going, no longer terminate and roll back the statement
	LOG ERRORS INTO ERR$_EMPLOYEES (substr (last_name, 1, 20)) REJECT LIMIT UNLIMITED;   
  -- If we have 5+ errors put 6 of them in err$_employees then give up (do not commit, something is wrong)
	/* LOG ERRORS INTO ERR$_EMPLOYEES (substr (last_name, 1, 20)) REJECT LIMIT 5; */   
  
  DBMS_OUTPUT.put_line ('After - SQL%ROWCOUNT ' || SQL%ROWCOUNT);   
   
  SELECT COUNT ( * )   
    INTO l_count   
    FROM employees   
   WHERE salary > 24000;   
   
  DBMS_OUTPUT.put_line ('After - Count in Table ' || l_count);  

  FOR rec IN (SELECT * FROM err$_employees) LOOP
    DBMS_OUTPUT.put_line(rec.ora_err_mesg$ || ' ' || rec.employee_id);
  END LOOP;
END; 

-- Then you must check
-- SELECT COUNT(1) "Number of Failures" FROM err$_employees 
-- SELECT ora_err_mesg$, ora_err_rowid$, ora_err_tag$, last_name  FROM err$_employees 

-- And if you'll try again:
DELETE FROM err$_employees;  
COMMIT;  


---


CREATE TABLE plch_employees ( 
  employee_id   INTEGER PRIMARY KEY, 
  last_name     VARCHAR2 (100), 
  salary        NUMBER (3) 
);

BEGIN 
  INSERT INTO plch_employees VALUES (100, 'Sumac', 100); 
  INSERT INTO plch_employees VALUES (200, 'Birch', 50); 
  INSERT INTO plch_employees VALUES (300, 'Alder', 200); 
  COMMIT; 
END;

BEGIN 
  DBMS_ERRLOG.create_error_log (dml_table_name => 'PLCH_EMPLOYEES'); 
  -- DBMS_ERRLOG.create_error_log will create a table named
  -- ERR$_your_table_name, where your_table_name is up to the first 25 characters
  -- of your DML table name, unless you specify an overriding table name of your
  -- own. If your table contains unsupported types, you will also need to specify
  -- "skip" for those columns. E.g. if table has a CLOB:
  --  DBMS_ERRLOG.create_error_log (
  --     dml_table_name     => 'plch_hitting_some_oracle_limit',
  --     err_log_table_name => 'plch_hitting_errors',  -- Oracle would have chosen "err$_plch_hitting_some_oracle_" for you
  --     skip_unsupported   => TRUE);
END;

DECLARE
  TYPE empid_range_rt IS RECORD (
    lowval   NUMBER,
    hival    NUMBER
  );

  TYPE ids_t IS TABLE OF empid_range_rt;

  l_ids     ids_t := ids_t(NULL, NULL);

  l_total   NUMBER;

  PROCEDURE show_sum IS
  BEGIN
    SELECT SUM (salary) INTO l_total FROM plch_employees;
    DBMS_OUTPUT.put_line (l_total);
  END;

BEGIN
  l_ids(1).lowval := 290;
  l_ids(1).hival  := 500;

  l_ids(2).lowval := 75;
  l_ids(2).hival  := 275;

  --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Employees 100 and 300 cannot have their salary increased by a factor of
  -- 10, since the constraint on the salary column is 3 digits - NUMBER(3). So only
  -- employee 200 can receive the increase.
  FORALL indx IN 1 .. l_ids.COUNT
 	  UPDATE plch_employees SET salary = salary * 10
 	  WHERE employee_id
 	 		BETWEEN l_ids(indx).lowval AND l_ids(indx).hival
 	  LOG ERRORS REJECT LIMIT UNLIMITED;
  --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  -- Apparently no COMMIT needed if errors were under your threshold

  show_sum;

EXCEPTION 
  WHEN OTHERS 
  THEN 
    -- This can't be reached unless we change UNLIMITED to a number
    dbms_output.put_line('we exceeded our LIMIT and rolled back');
    show_sum;
END; 
-- The error logging is always performed as an autonomous transaction, so that
-- the logged errors are not rolled back when a DML statement fails and/or is
-- rolled back, thus allowing them to be used for checking and error correction.
--
-- If not UNLIMITED logging table will hold rows = error limit + 1
-- select * from err$_plch_employees

-- This would be a bad alternative to the FORALL loop:
  --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   FOR indx IN 1 .. l_ids.COUNT
   LOOP
      FOR rec
         IN (SELECT employee_id
               FROM plch_employees
              WHERE employee_id BETWEEN l_ids (indx).lowval
                                    AND l_ids (indx).hival)
      LOOP
         BEGIN
            UPDATE plch_employees
               SET salary = salary * 10
             WHERE employee_id = rec.employee_id;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      END LOOP;
   END LOOP;
  --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

