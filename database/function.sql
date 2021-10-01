
-- Adapted: 01-Oct-2021 (Bob Heckel--https://connor-mcdonald.com/2021/09/30/integration-with-sql/)

-- Embedded function in SQL

with
  function f(x number) return number is
  begin
    return 3*x*x + 2*x;
  end;
boundaries as (
  select 1 x_start, 5 x_end, 0.000001 delta from dual
)
select
  sum(case when level in (1, ( x_end - x_start ) / delta) then 1 else 2 end * f(x_start + (level-1)*delta))
     * delta/2 integ
from boundaries
connect by level <= ( x_end - x_start ) / delta;

-- Compare ANSI approach. Slightly faster.
with
  function f(x number) return number is
  begin
    return 3*x*x + 2*x;
  end;
boundaries as ( 
  select 1 x_start, 5 x_end, 0.00001 delta from dual
),
integral(seq,fnc,inp) as (
    select 1 seq, f(x_start) fnc, x_start inp  from boundaries
    union all
    select seq+1, f(inp+delta), inp+delta
    from integral, boundaries
    where inp+delta <= x_end
)
select
  sum(decode(seq,1,1,x_end,1,2)*fnc) * delta/2
from integral, boundaries;
