-- Adapted: 09-Oct-2019 (Bob Heckel -- https://oracle-base.com)

--INNER JOIN (INNER keyword is optional)

-- implicit
select d.name, l.regional_group
from department d, location l
where d.location_id=l.location_id;

-- explicit
select d.name, l.regional_group
from department d INNER JOIN location l on d.location_id=l.location_id;


--OUTER JOIN (OUTER keyword is optional)

-- implicit
select d.name, l.regional_group
from department d, location l
where d.location_id=l.location_id (+);

-- explicit
select d.name, l.regional_group
from department d LEFT OUTER JOIN location l on d.location_id=l.location_id;

---

-- Adding filters to columns returned from an outer joined table is a common cause for confusion. If you test for a specific 
-- value, for example "salary >= 2000", but the value for the SALARY column is NULL because the row is missing, a regular 
-- condition in the WHERE clause will throw the row away, therefore defeating the object of doing an outer join.
-- So use this:

-- ANSI
SELECT d.department_name,
       e.employee_name     
FROM   departments d LEFT OUTER JOIN employees e ON d.department_id = e.department_id AND e.salary >= 2000
WHERE  d.department_id >= 30
ORDER BY d.department_name, e.employee_name;

-- non-ANSI (same)
SELECT d.department_name,
       e.employee_name      
FROM   departments d, employees e
WHERE  d.department_id = e.department_id(+) AND e.salary(+) >= 2000 -- "(+)" is used to indicate a column may have a NULL as a result of an outer join
AND    d.department_id >= 30
ORDER BY d.department_name, e.employee_name;
