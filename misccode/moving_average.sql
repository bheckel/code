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
