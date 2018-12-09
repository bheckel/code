CREATE OR REPLACE FUNCTION SUP_HAS_ACTIVE_SITES(in_account_id IN NUMBER) RETURN BOOLEAN IS
----------------------------------------------------------------------------
-- Author:  Bob Heckel (boheck)
-- Date:    12-Nov-18
-- Purpose: Determine if any account in SUP hierarchy has active sites
-- JIRA:    ORION-33077
----------------------------------------------------------------------------
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
