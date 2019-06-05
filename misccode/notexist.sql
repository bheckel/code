-- Adapted: Tue, Jun  4, 2019 10:29:08 AM (Bob Heckel -- DevGym) 

-- Anti-join

create table plch_departments(
    department_id   number(6, 0) primary key
  , department_name varchar2(30) not null
);

insert into plch_departments values ( 10, 'Administration');
insert into plch_departments values ( 20, 'Marketing');
insert into plch_departments values ( 30, 'Purchasing');
insert into plch_departments values ( 40, 'Human Resources');
insert into plch_departments values ( 50, 'Shipping');
insert into plch_departments values ( 60, 'IT');
insert into plch_departments values ( 70, 'Public Relations');
insert into plch_departments values ( 80, 'Sales');
insert into plch_departments values ( 90, 'Executive');
insert into plch_departments values (100, 'Finance');
insert into plch_departments values (110, 'Accounting');
commit;

create table plch_employees(
    employee_id     number(6, 0) primary key
  , first_name      varchar2(10)
  , last_name       varchar2(10)
  , department_id   number(6, 0)
);

insert into plch_employees values ( 10, 'Alexander', 'Khoo',     10);
insert into plch_employees values ( 20, 'Neena',     'Khochar',  10);
insert into plch_employees values ( 30, 'Adam',      'Fripp',    20);
insert into plch_employees values ( 40, 'Den',       'Raphaely', 30);
insert into plch_employees values ( 50, 'Steven',    'King',     30);
insert into plch_employees values ( 60, 'Bruce',     'Ernst',    40);
insert into plch_employees values ( 70, 'Matthew',   'Weiss',    50);
insert into plch_employees values ( 80, 'Lex',       'De Haan',  50);
insert into plch_employees values ( 90, 'Alexander', 'Hunold',   60);
insert into plch_employees values (100, 'Kimberly',  'Grant',  null);
commit;

/*  Want:
Public Relations
Sales
Executive
Finance
Accounting
*/

-- FAILS on dept 110 null
select dept.department_name
from plch_departments dept
where dept.department_id not in
   (select emp.department_id from plch_employees emp)
;

-- Would have to use this mess
select dept.department_name
from plch_departments dept
where dept.department_id not in
   (select nvl(emp.department_id, 1) from plch_employees emp)
;

-- or this one
select dept.department_name
from plch_departments dept
where dept.department_id not in
   (select emp.department_id from plch_employees emp
    where emp.department_id IS NOT NULL)
;

-- or this one
select dept.department_name
from plch_departments dept
where dept.department_id in
   (select department_id from plch_departments
    MINUS
    select department_id from plch_employees)
;

-- But this is better.  Correlated subquery is mandatory.
select dept.department_name
from plch_departments dept
where not exists
   (select null from plch_employees emp
    where emp.department_id = dept.department_id)
;

-- Best
select dept.department_name
from plch_departments dept left outer join plch_employees emp on dept.department_id=emp.department_id
where emp.department_id is null
;

-- Same
select dept.department_name
from plch_departments dept, plch_employees emp
where dept.department_id = emp.department_id (+)
and emp.department_id is null
order by department_name;

