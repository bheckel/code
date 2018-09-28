EXECUTE IMMEDIATE 'update ref_corporate_initiative set corporate_initiative = ''Customer Intelligence'' where corporate_initiative = ''CI''';
COMMIT;

---

DECLARE
  l_employee  omag_employees%ROWTYPE;
BEGIN
  l_employee.employee_id := 500;
  l_employee.last_name := 'Mondrian';
  l_employee.salary := 2000;
  UPDATE omag_employees
     SET ROW = l_employee
   WHERE employee_id = 100;
END;
