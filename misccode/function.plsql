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
