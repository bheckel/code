/* https://devgym.oracle.com */

create table toys (
  toy_name varchar2(20),
  price    number(10, 2)
);

insert into toys values ( 'Baby Turle', 0.01 );
insert into toys values ( 'Miss Snuggles', 10.01 );
insert into toys values ( 'Green Rabbit', 14.03 );
insert into toys values ( 'Pink Rabbit', 14.22 );
insert into toys values ( 'Purple Ninja', 15.55 );

commit;

with avg_prices as ( 
  select avg(price) mean from toys 
) 
  select t.*, ( select mean from avg_prices ) mean_price 
  from   toys t 
  where  price > ( select mean from avg_prices ) 
  order  by price;

-- same
with avg_prices as ( 
  select avg(price) mean from toys 
) 
  select t.*, mean mean_price 
  from   toys t 
  join   avg_prices ap 
  on     price > mean  
  order  by price;

-- same (best, access toys once) using analytic function
with avg_prices as (
  select t.*, avg(price) over () mean
  from   toys t
)
  select toy_name, price, mean mean_price
  from   avg_prices ap
  where  price > mean
  order  by price;
/*
TOY_NAME	    PRICE	MEAN_PRICE
Green Rabbit	14.03	10.764
Pink Rabbit	  14.22	10.764
Purple Ninja	15.55	10.764
*/
