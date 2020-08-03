
SELECT *
  FROM hr.employees e, hr.departments d
 WHERE e.department_id=d.department_id 
  and d.department_name ='Public Relations';
  
-- Fail
SELECT *
  FROM hr.employees e, (SELECT * FROM hr.departments WHERE department_id = e.department_id) x
  WHERE x.department_name ='Public Relations';
  
-- 12c+
SELECT *
  FROM hr.employees e, LATERAL (SELECT * FROM hr.departments WHERE department_id = e.department_id) x
 WHERE x.department_name ='Public Relations';
