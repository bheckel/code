-- Modified: 27-Mar-2020 (Bob Heckel) 

-- MINUS implements the set difference operator. This returns all the rows in the first table not in the second. 
-- MINUS is one of the few operators that consider null values equal.
-- See also intersect.sql, notexist.sql

---

-- Plan cost 7
SELECT employee_id FROM employees WHERE employee_id between 145 and 179
MINUS
SELECT employee_id FROM employees WHERE first_name LIKE 'A%';
 
-- Plan cost 3
SELECT employee_id
  FROM employees e 
 WHERE employee_id between 145 and 179
   AND NOT EXISTS ( SELECT employee_id FROM employees t WHERE first_name LIKE 'A%' and e.employee_id = t.employee_id );

-- Plan cost 2
SELECT e.employee_id 
  FROM employees e, employees e2
 WHERE e.employee_id = e2.employee_id 
   AND e.employee_id between 145 and 179
   AND e2.first_name not LIKE 'A%';

---

select toy_name from toys_for_sale 
minus 
select toy_name from bought_toys 
order  by toy_name;

-- same if no NULLs (and probably more efficient)
select toy_name  
from   toys_for_sale tofs 
where  not exists ( 
  --select 1 
  select null 
  from   bought_toys boto 
  where  tofs.toy_name = boto.toy_name 
);

-- same if NULLs
select toy_name
from   toys_for_sale tofs 
where  not exists ( 
  select null 
  from   bought_toys boto 
  where  ( tofs.toy_name = boto.toy_name or ( tofs.toy_name is null and boto.toy_name is null ))
)
order  by toy_name;

-- But if you want to see the price as well as the name of the toys you've not purchased MINUS won't work
select toy_name, price 
from   toys_for_sale tofs 
where  not exists ( 
  select null 
  from   bought_toys boto 
  where  tofs.toy_name = boto.toy_name 
);

---

-- "MINUS ALL" keep duplicates by using analytic function hack (MINUS removes duplicates of the input sets
-- first before doing the subtraction)
select
   product_id
 , product_name
 , row_number() over ( partition by product_id, product_name order by rownum) as rn
from customer_order_products
MINUS
select
   product_id
 , product_name
 , row_number() over ( partition by product_id, product_name order by rownum) as rn
from customer_order_products
order by 1;

---

select sdm_business_key, 
       tor_ind,
       0 new_tor_ind,
       91 new_kmc_exclusion_reason_id, 
       'SDM_BK no longer in source data' 
       new_kmc_exclusion_reason, 
       SYSDATE new_kmc_exclusion_reason_date, 
       'sdm_revenue' tblsrc
 from kmc_revenue_full krf
 where not exists ( select 1 
                      from ppedw.sdm_revenue@dew src
                     where krf.sdm_business_key = src.sdm_business_key
                       and extract(year from src.report_date) >= 2021 )
