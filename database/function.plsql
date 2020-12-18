-- Modified: 04-Mar-2020 (Bob Heckel)

create function rion37678 return NUMBER
is
  v_sal number := 0;
begin
  return v_sal;
end;

declare x number; begin x := rion37678(); dbms_output.put_line(x); end;

drop function rion37678;

---

-- Return a nested table.  See also pass_cursor.plsql. Using tables we have to
-- fetch all of the rows on the PLSQL side. With a ref cursor the client gets the data right away 

CREATE TABLE mytbl AS SELECT hiredate last_ddl_time, job object_name FROM emp;
CREATE TYPE t_record IS OBJECT ( ts DATE, name VARCHAR2(50) );
CREATE TYPE t_table IS TABLE OF t_record;

CREATE OR REPLACE PACKAGE mypkg
AS
  FUNCTION tmp_fn RETURN t_table;
END;
/
CREATE OR REPLACE PACKAGE BODY mypkg
AS
   FUNCTION tmp_fn RETURN t_table
     IS
       l_table   t_table := t_table();

   BEGIN
      SELECT t_record (last_ddl_time, 'option 1: ' || object_name)
        BULK COLLECT INTO l_table
        FROM mytbl;

      RETURN l_table;
   END;
END;

SELECT * FROM TABLE(mypkg.tmp_fn);

drop type t_table
drop type t_record
drop package mypkg
drop table mytbl

---

CREATE OR REPLACE FUNCTION SUP_HAS_ACTIVE_SITES(in_account_id IN NUMBER) RETURN BOOLEAN
IS
  has_active BOOLEAN;  
  cnt        PLS_INTEGER := 0;
  
BEGIN
  SELECT SUM(a.existing_customer)
  INTO cnt
  FROM account_search a
  WHERE a.sup_account_id = in_account_id
  GROUP BY a.sup_account_id;
       
   IF cnt > 0 THEN
     has_active := TRUE;
   ELSE
     has_active := FALSE;
   END IF;
   
  RETURN has_active;
  
EXCEPTION 
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
    
END SUP_HAS_ACTIVE_SITES;

---

FUNCTION getIndustryLOVId(naics_in IN VARCHAR2) RETURN NUMBER
IS
	naics_value     VARCHAR2(10);
	industry_lov_id NUMBER := NULL;

BEGIN
	IF (length(naics_in) = 2) THEN
		naics_value := trim(naics_in) || '0000';
	ELSIF (length(naics_in) = 3) THEN
		naics_value := trim(naics_in) || '000';
	ELSIF (length(naics_in) = 4) THEN
		naics_value := trim(naics_in) || '00';
	ELSE
		naics_value := naics_in;
	END IF;

	select c.LIST_OF_VALUES_ID
		INTO industry_lov_id
		from naicsranges n, custom_query_lov_view c
	 where n.subindustry_cd = c.VALUE
		 and c.custom_list_id = 8
		 and to_number(naics_value) >= to_number(n.naics_start)
		 and to_number(naics_value) <= to_number(n.naics_end);

	return industry_lov_id;
END;

select accounts.getIndustryLOVId('334111') from dual;

---

set serveroutput on

create or replace function get_sal(p_id employees.employee_id%TYPE)
return NUMBER
is
  v_sal employees.salary%TYPE := 0;
begin
  select salary into v_sal
  from employees
  where employee_id=p_id;
  return v_sal;
end get_sal;

EXECUTE dbms_output.put_line(get_sal(100))

-- or

select last_name, employee_id, get_sal(employee_id, 1.4) "Proposed Salary"
from employees;

---

-- A function is considered to be deterministic if it returns the same result value whenever 
-- it is called with the same values for its IN and IN OUT arguments. Makes it possible to use
-- the function in a function-based index. Might improve performance by caching and reusing function
-- return values.
-- Does not apply to PROCEDUREs.
-- These are NOT deterministic:
-- * Any and every SQL statement
-- * Referencing an out-of-scope variable (aka, 'global')
-- * Invoking a non-deterministic subprogram
CREATE OR REPLACE FUNCTION betwnstr(
   string_in  IN   VARCHAR2
 , start_in   IN   PLS_INTEGER
 , end_in     IN   PLS_INTEGER
)
  RETURN VARCHAR2 deterministic
IS
BEGIN
  RETURN( SUBSTR(string_in, start_in, end_in - start_in + 1 ) );
END;

-- As long as I pass in, for example, “abcdef” for the string, 3 for the start,
-- and 5 for the end, betwnStr will always return “cde”. Now, if that is the case,
-- why not have the database save the results associated with a set of arguments?
-- Then when I next call the function with those arguments, it can return the
-- result without executing the function!
--
-- The decision to use a saved copy of the function’s return result (if such a
-- copy is available) is made by the Oracle query optimizer.  Oracle has no way
-- of reliably checking to make sure that a function you declare to be
-- deterministic actually is free of any side effects. It is up to you to use this
-- feature responsibly. Your deterministic function should not rely on package
-- variables, nor should it access the database in a way that might affect the result set.
SELECT betwnstr(ename, 3, 5) FROM emp;


CREATE OR REPLACE FUNCTION pass_number (i NUMBER)
  RETURN NUMBER
  DETERMINISTIC
IS
BEGIN
  DBMS_OUTPUT.put_line('pass_number executed');
  RETURN 0;
END;
/
DECLARE
   n  NUMBER := 0;
BEGIN
  FOR rec IN (SELECT pass_number(1)
                FROM all_objects
               WHERE ROWNUM < 6)
  LOOP
     n := n + 1;
  END LOOP;

  DBMS_OUTPUT.put_line (n + 1);
END;
/*
pass_number executed
6
*/
-- So it executed 5 time but body of the function only executed once (Oracle created a temporary cache)

---

-- RESULT_CACHE is more powerful than DETERMINISTIC:
-- 1. Tells Oracle that you want to use some memory in the SGA or Shared Global Area to cache argument 
--    values and returned values.
-- 2. From that point on, whenever the function is invoked by any session in the database instance, the
--    body of the function will only be executed if it has not already been called with those same input values.
-- 3. If there is a 'hit' in the cache for that combination of arguments, the return value(s) will simply
--    be grabbed from the cache and returned to the calling block.
-- 4. If the function relies on any database tables, when any user commits changes to that table, the cache
--    for the function will be automatically wiped out.  RESULT_CACHE is good for MVs (i.e. queried 
--    more than updated).
CREATE OR REPLACE FUNCTION betwnstr(
   string_in  IN   VARCHAR2
 , start_in   IN   PLS_INTEGER
 , end_in     IN   PLS_INTEGER
)
  RETURN VARCHAR2 result_cache
IS
BEGIN
  RETURN( SUBSTR(string_in, start_in, end_in - start_in + 1 ) );
END;

-- The caching that DETERMINISTIC leads to has a narrow scope (only your session) and
-- short lifespan (the caching occurs for the duration of the SQL statement that executes the
-- function). So the overall performance impact will likely not be too great.
--
-- Data cached by RESULT_CACHE are available to all users of a database instance and
-- that data remains cached until the cache is invalidated or flushed. It has much greater potential
-- for improving performance of your application - but it also presents more of a danger of having a
-- negative impact as well.
--
-- Any deterministic function is a good candidate for the RESULT_CACHE keyword, but not every 
-- result-cached function is deterministic.

