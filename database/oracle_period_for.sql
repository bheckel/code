-- Adapted: 30-Nov-2020 (Bob Heckel--https://learning.oreilly.com/library/view/practical-oracle-sql/9781484256176/html/475066_1_En_19_Chapter.xhtml)

--unit_test_repos@rshdb1
create table emp_hire_periods (
   emp_id         not null constraint emp_hire_periods_emp_fk
                     references employees
 , start_date     date not null
 , end_date       date
 , title          varchar2(20 char) not null
 , constraint emp_hire_periods_pk primary key (emp_id, start_date)
 , period for employed_in (start_date, end_date)
);

-- Oracle treats it as a type of constraint – it will not let you insert data with an end_date that is before start_date
select
    ehp.emp_id
  , e.name
  , ehp.start_date
  , ehp.end_date
  , ehp.title
 from emp_hire_periods
         as of period for employed_in date '2010-07-01'
      ehp
 join employees e
    on e.id = ehp.emp_id
 order by ehp.emp_id, ehp.start_date;
 
-- same

 select
    ehp.emp_id
  , e.name
  , ehp.start_date
  , ehp.end_date
  , ehp.title
 from emp_hire_periods
      ehp
 join employees e
    on e.id = ehp.emp_id
    where trunc(start_date) = '01jul10'
 order by ehp.emp_id, ehp.start_date;
