
-- From Mastering Oracle SQL p.94

-- select 'SMALL' name, 0 lower_bound, 29 upper_bound from dual
-- union all
-- select 'MEDIUM' name, 30 lower_bound, 79 upper_bound from dual
-- union all
-- select 'LARGE' name, 80 lower_bound, 999999 upper_bound from dual

select sizes.name, order_size, SUM(co.sale_price) tot_dollars
from cust_order co INNER JOIN
  ( select 'SMALL' name, 0 lower_bound, 29 upper_bound from dual
    union all
    select 'MEDIUM' name, 30 lower_bound, 79 upper_bound from dual
    union all
    select 'LARGE' name, 80 lower_bound, 999999 upper_bound from dual
   ) sizes
  ON co.sales_price >= sizes.lower_bound
  group by sizes.name
  ;

