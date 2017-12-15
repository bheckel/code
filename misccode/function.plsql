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
