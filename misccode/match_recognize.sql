-- Adapted: 04-May-2020 (Bob Heckel--https://learning.oreilly.com/library/view/practical-oracle-sql/9781484256176/html/475066_1_En_18_Chapter.xhtml)
-- See also start_with_connect_by_hierarchy.sql

-- Consider match_recognize as an alternative to group by for cases where you
-- cannot easily specify a grouping value from each row, but the grouping
-- criteria are relations between rows

-- Count groups between gaps in sequence
with ints(i) as (
   select 1 from dual union all
   select 2 from dual union all
   select 3 from dual union all
   select 6 from dual union all
   select 8 from dual union all
   select 9 from dual
)
select first_int, last_int, ints_in_grp, group_sum
from ints
match_recognize (
   order by i
   measures
      first(i) as first_int
    , last(i)  as last_int
    , count(*) as ints_in_grp 
    , sum(i) as group_sum
   one row per match
   pattern (strt one_higher*)
   define
      one_higher as i = prev(i) + 1
)
order by first_int;
/*
 FIRST_INT   LAST_INT INTS_IN_GRP  GROUP_SUM
---------- ---------- ----------- ----------
         1          3           3          6
         6          6           1          6
         8          9           2         17
*/

---

select
   url, from_day, to_day, days, begin, growth, daily
from web_page_counter_hist
match_recognize(
   partition by page_no
   order by day
   measures
      first(friendly_url) as url
    , first(day) as from_day
    , last(day) as to_day
    , count(*) as days
    , first(counter) as begin
    , next(counter) - first(counter) as growth
    , (next(counter) - first(counter)) / count(*)
         as daily
   one row per match
   after match skip past last row
   pattern ( peak+ )
   define
      peak as next(counter) - counter >= 200
)
order by page_no, from_day;
