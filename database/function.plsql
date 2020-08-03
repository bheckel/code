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

CREATE OR REPLACE PACKAGE mypkg AS
  FUNCTION tmp_fn RETURN t_table;
END;

CREATE OR REPLACE PACKAGE BODY mypkg AS
   FUNCTION tmp_fn RETURN t_table IS
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

CREATE OR REPLACE FUNCTION SUP_HAS_ACTIVE_SITES(in_account_id IN NUMBER) RETURN BOOLEAN IS
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
    
end SUP_HAS_ACTIVE_SITES;

---

FUNCTION getIndustryLOVId(naics_in IN VARCHAR2) RETURN NUMBER IS
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
/



EXECUTE dbms_output.put_line(get_sal(100))

-- or

select last_name, employee_id, get_sal(employee_id, 1.4) "Proposed Salary"
from employees;
