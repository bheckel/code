create table dummy_table as
  select date '2010-01-01'+rownum x, rownum y from dual connect by level <= 365*5;

---

-- See also plch_employees_createtable.plsql

CREATE TABLE tmpbobh (
  fooN  NUMBER,
  fooC  VARCHAR2(5),
  fooD  DATE
);

INSERT INTO tmpbobh (fooN,fooC,fooD) VALUES (66,'one','01-JAN-1960');
INSERT INTO tmpbobh (fooN,fooC,fooD) VALUES (67,'two','01-FEB-1960');
INSERT INTO tmpbobh (fooN,fooC,fooD) VALUES (68,'three','01-MAR-1960');

DROP TABLE tmpbobh;

---

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

-- 10k records
INSERT INTO stocks
       SELECT 'STK' || LEVEL,
              SYSDATE,
              LEVEL,
              LEVEL + 15
         FROM DUAL
   CONNECT BY LEVEL <= 10000
/   
