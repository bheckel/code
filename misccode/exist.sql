
-- Modified: Tue 03-Mar-2020 (Bob Heckel)
-- See also csv_list_to_table_xmltable.sql

---

-- Find employees who manage others:

select * 
from emp e1
where 1 <= (select count(*)
            from emp e2
            where e2.mgr=e1.empno);

-- same
select * 
from emp e1
where exists (select 1
              from emp e2
              where e2.mgr=e1.empno);
              

---

-- Hierarchy self join - one (181477) is is ultimate parent, other two are children

SELECT sup.account_id, sup.sup_account_id, sup.existing_customer, detail.account_id, detail.sup_account_id, detail.existing_customer
FROM account_base sup, account_base detail
WHERE sup.account_id = 181477
AND detail.sup_account_id = sup.account_id
/*
ACCOUNT_ID	SUP_ACCOUNT_ID	EXISTING_CUSTOMER	ACCOUNT_ID	SUP_ACCOUNT_ID	EXISTING_CUSTOMER
1	181477	181477	1	181477	181477	1
2	181477	181477	1	417811	181477	1
3	181477	181477	1	410735	181477	0
*/

-- Is parent or any children an existing cust?
SELECT count(1)
FROM account_base b
WHERE b.account_id = 181477
      AND EXISTS (SELECT 1
                  FROM account_base sup, account_base detail
                  WHERE sup.account_id = b.sup_account_id
                        AND detail.sup_account_id = sup.account_id);
/*
1
*/


select level, lov.value_description as value, lov.*
from list_of_values lov
where lov.retired = 0
connect by prior lov.list_of_values_id = lov.parent_id
start with lov.list_of_values_id in ( 1234)
order siblings by lov.value_description

---

select user_id, email 
from users 
where exists (select 1
              from classified_ads
              where classified_ads.user_id = users.user_id)
;

-- But this is probably better:
select users.user_id, users.email, classified_ads.posted
from users, classified_ads
where users.user_id=classified_ads.user_id
;

---

-- Adapted from Oracle DevGym

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

/*  Want depts with no employees:
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
   (select null  -- 1 also works
    from plch_employees emp
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

-- On one not on another:
select a.view_name from all_views a, all_views@seuat b where a.view_name like '%ASP%' and a.view_name=b.view_name(+) and b.view_name is null;
select b.view_name from all_views a, all_views@seuat b where b.view_name like '%ASP%' and a.view_name(+)=b.view_name and a.view_name is null;

---

-- Don't need this...
DELETE FROM OPP_FUN_ACTIVITY G WHERE NOT EXISTS (SELECT 1 FROM OPPORTUNITY_BASE B WHERE B.OPPORTUNITY_ID = G.OPPORTUNITY_ID)

-- ...if have this
alter table OPP_FUN_ACTIVITY
  add constraint OPPORTUNITY_OFA_FK foreign key (OPPORTUNITY_ID)
  references OPPORTUNITY_BASE (OPPORTUNITY_ID) on delete cascade;

