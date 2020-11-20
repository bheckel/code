--Adapted: 17-Nov-2020 (Bob Heckel--https://learning.oreilly.com/library/view/practical-oracle-sql/9781484256176/html/475066_1_En_18_Chapter.xhtml)

with ints(i) as (
    select 1 from dual union all
    select 2 from dual union all
    select 3 from dual union all
    select 6 from dual union all
    select 8 from dual union all
    select 9 from dual
 )
 select
    i
  , row_number() over (order by i)     as rn
  , i - row_number() over (order by i) as diff
  , rownum
 from ints
 order by i;
/*
         I         RN       DIFF     ROWNUM
---------- ---------- ---------- ----------
         1          1          0          1
         2          2          0          2
         3          3          0          3
         6          4          2          4
         8          5          3          5
         9          6          3          6
*/         

with ints(i) as (
    select 1 from dual union all
    select 2 from dual union all
    select 3 from dual union all
    select 6 from dual union all
    select 8 from dual union all
    select 9 from dual
 )
 select
    min(i)   as first_int
  , max(i)   as last_int
  , count(*) as ints_in_grp
 from (
    select i, i - row_number() over (order by i) as diff
    from ints
 )
 group by diff
 order by first_int;
/*
 FIRST_INT   LAST_INT INTS_IN_GRP
---------- ---------- -----------
         1          3           3
         6          6           1
         8          9           2
*/ 

-- Same
with ints(i) as (
    select 1 from dual union all
    select 2 from dual union all
    select 3 from dual union all
    select 6 from dual union all
    select 8 from dual union all
    select 9 from dual
 )
 /*select first_int, last_int, ints_in_grp*/
 -- DEBUG
select i, cast(cls as varchar(16)) as cls, first_int, last_int, ints_in_grp
from ints MATCH_RECOGNIZE (
  order by i
  measures
     first(i) as first_int
   , last(i)  as last_int
   , count(*) as ints_in_grp
   , classifier() as cls
  -- Instead of GROUP BY in tabibitosan
  /*one row per match*/
  -- DEBUG
  all rows per match
  -- Looks for any row (classified as strt) followed by zero or more one_higher rows
  pattern (strt exactly_1_higher*)
  define
     exactly_1_higher as i = prev(i) + 1
)
order by first_int;
/*
         I CLS               FIRST_INT   LAST_INT INTS_IN_GRP
---------- ---------------- ---------- ---------- -----------
         1 STRT                      1          1           1
         2 EXACTLY_1_HIGHER          1          2           2
         3 EXACTLY_1_HIGHER          1          3           3 <---
         6 STRT                      6          6           1 <---
         8 STRT                      8          8           1
         9 EXACTLY_1_HIGHER          8          9           2 <---
*/         
