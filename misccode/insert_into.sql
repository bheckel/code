-- Two records from one
INSERT ALL
 INTO plch_tickers (ticker, pricetype, price)
VALUES (ticker, 'O', open_price)
 INTO plch_tickers (ticker, pricetype, price)
VALUES (ticker, 'C', close_price)
	SELECT ticker, open_price, close_price FROM plch_stocks;

---

insert into mailing_list (name, email) values ('Philip Greenspun','philg@mit.edu');

-- Evil shortcut without specifying phone_numbers fields but instead assuming their order
insert into phone_numbers values ('ogrady@fastbuck.com','work','(800) 555-1212');

---

-- Insert 5-star ratings by James Cameron (207) for all movies in the database.
-- Leave the review date as NULL.
insert into rating
select 207, mid, 5, NULL
from movie
where mid in(select distinct mid from movie)

---

insert all  
  into teddies values ('Dinosaur King', 'red')  
  into bricks values ('sphere', 'green', 100)  
  select * from dual;


insert all
  into people values (full_name)
  when hire_date is not null then 
    into staff values (hire_date)
  when nhs_number is not null then 
    into patients values (nhs_number)
  select * from people_details;


-- E.g. 4 rows in toys gets distributed to these 3 tables: total of 4 rows will exist across those 3 tables
insert first 
  when colour = 'blue' then 
    into blue_toys values (toy_id, toy_name, price)
  when price >= 0 then 
    into cheap_toys values (toy_id, toy_name, price, colour)
  when price > 20 then 
    into expensive_toys values (toy_id, toy_name, price, colour)
  select toy_id, toy_name, price, colour from toys;
