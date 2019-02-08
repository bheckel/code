
-- See also plch_employees_createtable.plsql

---

create table t1 as
  select date '2010-01-01'+rownum x, rownum y from dual connect by level <= 10;

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
