
-- Use the analytic functions to detect outlying values in a range of data. https://devgym.oracle.com/pls/apex/f?p=10001:11:104026056831435::NO:11:P11_QUESTION_ID,P11_PREVIEW_ONLY,P11_CLASS_ID,P11_WORKOUT_ID,P11_COMP_EVENT_ID,P11_QUIZ_ID,P11_USER_WORKOUT_ID:27727,N,597,103523,1944153,2990325,343229&cs=19IHvSM5mbFXNArzDw-QEDXxZ9giI14Au2kZqyMw_NVammOwm-syzEzMJqWq-i3F29m4fHOt6x2zIaDgTEaW-Rg

-- Throw out the top 2 lowest and top 2 highest outlier values from trips table

-- 2. Identify the outlying values:
select avg(trip_count) realistic_avg_per_day
from 
  (
  -- 1. Use the outlying values to remove rows from consideration:
  select 
    trip_date,
    trip_count, 
    -- 2nd lowest value in trips table, e.g. low_2 == 1 for all rows
    nth_value(trip_count,2) over (
         order by trip_count
         range between unbounded preceding and unbounded following ) as low_2,
    -- 2nd highest value in trips table, e.g. hi_2 == 101 for all rows
    nth_value(trip_count,2 from last) over (
         order by trip_count
         range between unbounded preceding and unbounded following ) as hi_2
  from trips
  )
where trip_count > low_2
and   trip_count < hi_2;
