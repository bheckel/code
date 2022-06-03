
-- Modified: 02-Jun-2022 (Bob Heckel)

SELECT *
  FROM hr.employees e, hr.departments d
 WHERE e.department_id=d.department_id 
   AND d.department_name ='Public Relations';--1rec
  
-- ORA-00904: "E"."DEPARTMENT_ID": invalid identifier
SELECT *
  FROM hr.employees e, ( SELECT * FROM hr.departments WHERE department_id=e.department_id ) x
  WHERE x.department_name ='Public Relations';
  
-- 12c+
SELECT *
  FROM hr.employees e, LATERAL ( SELECT * FROM hr.departments WHERE department_id=e.department_id ) x
 WHERE x.department_name ='Public Relations';--1rec
