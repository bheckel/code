-- MINUS implements the set difference operator. This returns all the rows in the first table not in the second. 
-- MINUS is one of the few operators that consider null values equal.

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


---

-- http://philip.greenspun.com/sql/complex-queries.html

-- all three users love to go to Paris
insert into trip_to_paris_contest values (1,'2000-10-20');
insert into trip_to_paris_contest values (2,'2000-10-22');
insert into trip_to_paris_contest values (3,'2000-10-23');

-- only User #2 is a camera nerd
insert into camera_giveaway_contest values (2,'2000-05-01');


-- Suppose that we're going to organize a personal trip to Paris and want to
-- find someone to share the cost of a room at the Crillon. We can assume that
-- anyone who entered the Paris trip contest is interested in going. So perhaps we
-- should start by sending them all email. On the other hand, how can one enjoy a
-- quiet evening with the absinthe bottle if one's companion is constantly
-- blasting away with an electronic flash? We're interested in people who entered
-- the Paris trip contest but who did not enter the camera giveaway:

    select user_id from trip_to_paris_contest  -- larger
    MINUS
    select user_id from camera_giveaway_contest;  -- smaller

       USER_ID
    ----------
    	 1
    	 3

