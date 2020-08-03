--Adapted: 08-Aug-19 (Bob Heckel -- https://stackoverflow.com/questions/2298550/oracle-any-vs-in) 

-- Employees who earn the same salary as the minimum salary for each department:
SELECT last_name, salary,department_id
FROM employees
WHERE salary IN (SELECT MIN(salary)
                 FROM employees
                 GROUP BY department_id);

-- Employees who are not IT Programmers and whose salary is less than that of any IT programmer:
SELECT employee_id, last_name, salary, job_id
FROM employees
WHERE salary <ANY
                (SELECT salary
                 FROM employees
                 WHERE job_id = 'IT_PROG')
AND job_id <> 'IT_PROG';

-- Employees whose salary is less than the salary of all employees with a job ID of IT_PROG and whose job is not IT_PROG:
SELECT employee_id,last_name, salary,job_id
FROM employees
WHERE salary <ALL
                (SELECT salary
                 FROM employees
                 WHERE job_id = 'IT_PROG')
AND job_id <> 'IT_PROG';
