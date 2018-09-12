DECLARE
   l_employee   omag_employees%ROWTYPE;
BEGIN
   l_employee.employee_id := 500;
   l_employee.last_name := ‘Mondrian’;
   l_employee.salary := 2000;
   INSERT
     INTO omag_employees 
   VALUES l_employee;
END;
/
