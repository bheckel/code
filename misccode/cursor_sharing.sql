ALTER SYSTEM FLUSH SHARED_POOL;  -- as SYSTEM user
 
 
ALTER SESSION SET cursor_sharing = 'EXACT';
--ALTER SESSION SET cursor_sharing = 'FORCE';
 
SELECT * FROM employees WHERE first_name = 'Alex';
SELECT * FROM employees WHERE first_name = 'Lex';
SELECT * FROM employees WHERE first_name = 'David';
 
SELECT * FROM employees WHERE first_name LIKE 'A%';
SELECT * FROM employees WHERE first_name LIKE 'B%';
SELECT * FROM employees WHERE first_name LIKE 'C%';
 
SELECT * FROM employees WHERE employee_id = 102;
SELECT * FROM employees WHERE employee_id = 125;
SELECT * FROM employees WHERE employee_id = 166;
SELECT * FROM employees WHERE employee_id = 102;
 
SELECT * FROM employees WHERE salary > 1500;
SELECT * FROM employees WHERE salary > 15000;
SELECT * FROM employees WHERE salary > 20000;
 
VARIABLE b NUMBER;
EXEC :b := 1000;
SELECT * FROM employees WHERE salary > :b;
EXEC :b := 20000;
SELECT * FROM employees WHERE salary > :b;
 
set linesize 2000;
 
SELECT sql_id,child_number,executions,loads,parse_calls,sql_text
FROM v$sql WHERE sql_text LIKE 'SELECT * FROM employees WHERE first_name =%';
 
SELECT sql_id,child_number,executions,loads,parse_calls,sql_text
FROM v$sql WHERE sql_text LIKE 'SELECT * FROM employees WHERE first_name LIKE%';
 
SELECT sql_id,child_number,executions,loads,parse_calls,sql_text
FROM v$sql WHERE sql_text LIKE 'SELECT * FROM employees WHERE employee_id =%';
 
SELECT sql_id,child_number,executions,loads,parse_calls,sql_text
FROM v$sql WHERE sql_text LIKE 'SELECT * FROM employees WHERE salary >%';
