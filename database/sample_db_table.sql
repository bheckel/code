--------------------------------------------
-- Build dummy tables for testing
-- Modified: 08-Jan-2021 (Bob Heckel)
--------------------------------------------

---

-- A mixture of positive and negative numbers that are around zero
create table pos_neg_around_one as
  select
    mod(rownum,10) wtf,
    owner,
    decode(mod(rownum,10),
           0, dbms_random.value(1,1.5),  -- every 10th rec is a 0 so make it a small positive
           1, -dbms_random.value(1,1.5), -- every 1st rec is a small negative
              dbms_random.value(0.8,1.1) -- the rest are smaller positives
    ) x
  from dba_objects;

---

-- Modified: 29-Sep-2020 (Bob Heckel)
-- Dummy database table

with v(d, t, amt) as (
          select date '2000-01-01', 'a', 10 from dual
union all select date '2000-01-02', 'b', 11 from dual
union all select date '2000-01-03', 'c', 30 from dual
union all select date '2000-01-03', 'c', 30 from dual
union all select date '2000-01-04', 'd', 10 from dual
union all select date '2000-01-05', 'e',  5 from dual
union all select date '2000-01-05', 'e',  7 from dual
union all select date '2000-01-05', 'e', NULL from dual
union all select date '2000-01-05', 'e',  3 from dual
union all select date '2000-01-05', 'e',  4 from dual
union all select date '2000-01-05', 'e',  null from dual
union all select date '2000-01-06', 'f', 10 from dual
union all select date '2000-01-06', 'f', 11 from dual
union all select date '2000-01-06', 'f', 12 from dual
union all select date '2000-01-06', 'f', null from dual
union all select date '2000-01-06', 'f', 13 from dual
)
select d
       ,t
       ,amt
       ,last_value(amt IGNORE NULLS) over (partition by t order by d rows between unbounded preceding and current row) filldown_amt
from v
order by 1,2;

---

CREATE TABLE rion_48987 AS 
  SELECT to_number(COLUMN_VALUE) account_id,
         1 to_be_deleted,
         to_date('01DEC1969','DDMONYYYY') created 
    FROM xmltable(('"' || REPLACE(
'6190448,6277610',
    ',', '","') || '"'));

---

begin
  drop table deptx;
  drop table empx;

  create table deptx(deptx_id number(10) PRIMARY KEY, dname varchar2(20));

  -- Implicit FK on empx constraint
  create table empx(empxid number(20) PRIMARY KEY, ename varchar2(20), sal number(10,2), deptx_id number(10) REFERENCES deptx(deptx_id) ON DELETE CASCADE);

  insert into deptx values(10,'IT');
  insert into deptx values(20,'HR');
  insert into deptx values(30,'MAT');

  insert into empx values(1,'MIKE',20000,10);
  insert into empx values(2,'JOHN',30000,20);
  insert into empx values(3,'SUE',20000,20);
  insert into empx values(4,'TOM',40000,30);

  commit;
end;

---

CREATE TABLE bulk_collect_test AS
SELECT owner,
       object_name,
       object_id
FROM   all_objects;

---

DROP TABLE plch_employees

CREATE TABLE plch_employees
(
   employee_id   INTEGER PRIMARY KEY
 , last_name     VARCHAR2(100)
 , salary        NUMBER(7)
)
/
BEGIN
   INSERT INTO plch_employees
        VALUES (100, 'Jobs', 1000);
   INSERT INTO plch_employees
        VALUES (200, 'Ellison', 2000);
   INSERT INTO plch_employees
        VALUES (300, 'Gates', 3000);
   COMMIT;
END;
/

-- ...Later requirements:

ALTER TABLE plch_employees ADD first_name VARCHAR2(2000)
/
-- Packages stay VALID

ALTER TABLE plch_employees MODIFY last_name VARCHAR2(2000)
/
-- Packages become INVALID

---

create table t1 as
  select date '2010-01-01'+rownum x, rownum y from dual connect by level <= 10;

/*
-- or if want gaps
with ints(y) as (
   select 1 from dual union all
   select 2 from dual union all
   select 3 from dual union all
   select 6 from dual union all
   select 8 from dual union all
   select 9 from dual
) select * from ints
*/

select * from t1;

drop table t1;

---

CREATE TABLE t1 (
  fooN  NUMBER,
  fooC  VARCHAR2(5),
  fooD  DATE
);

INSERT INTO t1 (fooN,fooC,fooD) VALUES (66,'one','01-JAN-1960');
INSERT INTO t1 (fooN,fooC,fooD) VALUES (67,'two','01-FEB-1960');
INSERT INTO t1 (fooN,fooC,fooD) VALUES (68,'three','01-MAR-1960');

DROP TABLE t1;

---

-- Pseudo table:
with v as (
          select date '2000-01-01' d, 10 amt from dual
union all select date '2000-01-02', 11 from dual
union all select date '2000-01-03', 30 from dual
union all select date '2000-01-04', 10 from dual
union all select date '2000-01-05', 14 from dual
)
select d
      ,amt
      ,avg(amt) over (order by d rows between 1 preceding and 1 following) moving_window_avg
      ,sum(amt) over (order by d rows between unbounded preceding and current row) cumulative_sum
FROM v;

---

-- Want a new large 10k record table
CREATE TABLE plxx as
       SELECT 'STK' || LEVEL stkname,
              SYSDATE        created,
              LEVEL          level1,
              LEVEL + 15     level2
         FROM DUAL
   CONNECT BY LEVEL <= 10000
/*
STKNAME	CREATED	LEVEL1	LEVEL2
STK1	01-FEB-19	1	16
STK2	01-FEB-19	2	17
STK3	01-FEB-19	3	18
*/

-- or if table already exists
INSERT INTO stocks
       SELECT 'STK' || LEVEL,
              SYSDATE,
              LEVEL,
              LEVEL + 15
         FROM DUAL
   CONNECT BY LEVEL <= 10000
/   
