-- Adapted: 30-May-2022 (Bob Heckel--https://www.udemy.com/course/sql-performance-tuning-masterclass/learn/lecture/13738874#overview)

select /*+ monitor */* 
  from sales s, customers c
 where s.cust_id = c.cust_id and channel_id = 9;
 
alter system flush shared_pool;
alter system flush buffer_cache;
 
SELECT /*+ PARALLEL(4) */ c.cust_first_name, c.cust_last_name, max(QUANTITY_SOLD), avg(QUANTITY_SOLD)
  FROM sales s, customers c, countries ct, costs cs
 WHERE s.cust_id = c.cust_id
   AND s.channel_id = :v_channel_id
   AND c.country_id = ct.country_id
--and cs.prod_id = s.prod_id
 GROUP BY c.cust_first_name, c.cust_last_name
 ORDER BY c.cust_first_name, c.cust_last_name;
