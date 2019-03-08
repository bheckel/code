
-- Any other fields get NULLs
insert into mailing_list (name, email) values ('Philip Greenspun','philg@foo.edu');

-- Shortcut without specifying phone_numbers fields but instead assuming their
-- order - the number of values must match the number of columns in the table
-- which in Oracle can be first verified:
select column_name 
from   user_tab_columns
where  table_name = 'PHONE_NUMBERS'
order  by column_id;

insert into phone_numbers values ('ogrady@foo.com','work','(800) 555-1212');

---

-- Insert 5-star ratings by James Cameron (207) for all movies in the database.
-- Leave the review date as NULL.
insert into rating
  select 207, mid, 5, NULL
  from movie
  where mid in(select distinct mid from movie)

---

-- INSERT ALL the shorthand multi-table INSERT

INSERT ALL  
  into teddies values ('Dinosaur King', 'red')  
  into bricks values ('sphere', 'green', 100)  
  select * from dual;


-- Two records from one
INSERT ALL
 INTO plch_tickers (ticker, pricetype, price)
VALUES (ticker, 'O', open_price)
 INTO plch_tickers (ticker, pricetype, price)
VALUES (ticker, 'C', close_price)
	SELECT ticker, open_price, close_price FROM plch_stocks;

---

/* Adapted from Oracle Dev Gym Class */

create table toys ( 
  toy_id   integer,  
  toy_name varchar2(30), 
  price    number, 
  colour   varchar2(30) 
);

create table blue_toys ( toy_id integer, toy_name varchar2(30), price number, colour varchar2(30) );

create table cheap_toys ( toy_id integer, toy_name varchar2(30), price number, colour varchar2(30) );

create table expensive_toys ( toy_id integer, toy_name varchar2(30), price number, colour varchar2(30) );

insert into toys values (1, 'Cheapasaurus Rex', 0.99, 'blue');
insert into toys values (2, 'Cheapasaurus Rex', 0.99, 'red');
insert into toys values (3, 'Costsalottasaurs', 99.99, 'green');
insert into toys values (4, 'Bluesaurus', 21.99, 'blue');
commit;

INSERT FIRST 
	-- Insert first will only add rows to the first table where the when clause
  -- is true. This works from top to bottom. A row that has blue for the color and
  -- price > 20 meets all three criteria. But it will only go in blue_toys, because
  -- that is the top clause in the statement.

	-- Blue_toys is at the top of the insert. So any rows that meet this (toy_ids
  -- 1 and 4) will go in this table
  when colour = 'blue' then 
    into blue_toys values (toy_id, toy_name, price, colour)
  -- Any non-blue rows with a price >= 0 will go in cheap_toys
  when price >= 0 then 
    into cheap_toys values (toy_id, toy_name, price, colour)
	-- Toy_id 3 costs 99.99. So it meets the criterion for expensive_toys. But
  -- cheap_toys appears above this in the insert. So it goes in that table and this
  -- is skipped. Any row where the price is > 20 also has a price >= 0. So the
  -- insert will never add any rows to this table!
  when price > 20 then 
    into expensive_toys values (toy_id, toy_name, price, colour)
  select toy_id, toy_name, price, colour from toys;

select * from blue_toys
/*
TOY_ID	TOY_NAME	PRICE
1	Cheapasaurus Rex	.99
4	Bluesaurus	21.99
*/
select * from cheap_toys
/*
TOY_ID	TOY_NAME	PRICE	COLOUR
2	Cheapasaurus Rex	.99	red
3	Costsalottasaurs	99.99	green
*/
select * from expensive_toys
/*
*/

---

DECLARE
   l_employee   omag_employees%ROWTYPE;
BEGIN
   l_employee.employee_id := 500;
   l_employee.last_name := ‘Mondrian’;
   l_employee.salary := 2000;
   INSERT
     INTO omag_employees 
   VALUES l_employee;
END;
/
