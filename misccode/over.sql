/* See also greater_than_average.sql */

with v as (
          select date '2000-01-01' d, 10 amt from dual
union all select date '2000-01-02', 11 from dual
union all select date '2000-01-03', 30 from dual
union all select date '2000-01-04', 10 from dual
union all select date '2000-01-05', 14 from dual
)
select d
      ,amt
      ,avg(amt) OVER (order by d rows between 1 preceding and 1 following) moving_window_avg
      ,sum(amt) OVER (order by d rows between unbounded preceding and current row) cumulative_sum
      ,sum(amt) OVER () grand_sum
      ,avg(amt) OVER () grand_avg
      --,dense_rank() over (order by d) orderbydt -- 1,2,3...
      ,rank() over (order by d) orderbydt -- 1,3,3...
FROM v;
