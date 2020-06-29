-- Created: 03-Nov-2019 (Bob Heckel)

select max(amt) maxamt from sales where prod = 13;
select count(units) cntunit from sales where cust = 'bob';

-- or

select max(decode(prod,13,amt,0)) maxamt,
       sum(decode(units,'bob',1,0)) cntunit
from sales;
