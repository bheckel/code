
-- MINUS implements the set difference operator. This returns all the rows in the first table not in the second. 
-- MINUS is one of the few operators that consider null values equal.
-- See also intersect.sql

select toy_name from toys_for_sale 
minus 
select toy_name from bought_toys 
order  by toy_name;

-- same if no NULLs

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
