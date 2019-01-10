/* Remove duplicate rows */

/* Fail, we lost both of the 30s:
D	AMT
01-JAN-00	10
02-JAN-00	11
03-JAN-00	31
04-JAN-00	10
05-JAN-00	14
*/
with v as (
          select date '2000-01-01' d, 10 amt from dual
union all select date '2000-01-02', 11 from dual
union all select date '2000-01-03', 30 from dual
union all select date '2000-01-03', 30 from dual
union all select date '2000-01-03', 31 from dual
union all select date '2000-01-04', 10 from dual
union all select date '2000-01-05', 14 from dual
)
select d, amt 
from v
group by d, amt
having count(1)=1
order by 1

/*
D	AMT	ROWNUMBYDAY
01-JAN-00	10	1
02-JAN-00	11	1
03-JAN-00	30	1
03-JAN-00	31	1
04-JAN-00	10	1
05-JAN-00	14	1
*/
with v as (
          select date '2000-01-01' d, 10 amt from dual
union all select date '2000-01-02', 11 from dual
union all select date '2000-01-03', 30 from dual
union all select date '2000-01-03', 30 from dual
union all select date '2000-01-03', 31 from dual
union all select date '2000-01-04', 10 from dual
union all select date '2000-01-05', 14 from dual
)
select * from
  (select d
        ,amt
        ,row_number() OVER (partition by d,amt order by d) rownumbyday

  FROM v
  )
where rownumbyday = 1
