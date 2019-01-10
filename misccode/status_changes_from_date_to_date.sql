
-- Use Analytic SQL windowing to find change dates https://devgym.oracle.com/pls/apex/f?p=10001:11:104026056831435::NO:RP:P11_QUESTION_ID,P11_RESULT_ID,P11_QUIZ_ID:28686,,3048078&cs=12xhtW40XHZys-hTTBZ1OYcom9PPnN44uTqhY4zKus7AR5lOxlA2KER4Zm25jZb6xqFMaEclWC_JcMHhXCi02Fg

create table ORDERS 
( order_id     int,
  status_date  date,
  status       varchar2(20)
);

insert into ORDERS values (11700, date '2016-01-03', 'New');
insert into ORDERS values (11700, date '2016-01-04', 'Inventory Check');
insert into ORDERS values (11700, date '2016-01-05', 'Inventory Check');
insert into ORDERS values (11700, date '2016-01-06', 'Inventory Check');
insert into ORDERS values (11700, date '2016-01-07', 'Inventory Check');
insert into ORDERS values (11700, date '2016-01-08', 'Inventory Check');
insert into ORDERS values (11700, date '2016-01-09', 'Awaiting Signoff');
insert into ORDERS values (11700, date '2016-01-10', 'Awaiting Signoff');
insert into ORDERS values (11700, date '2016-01-11', 'Awaiting Signoff');
insert into ORDERS values (11700, date '2016-01-12', 'In Warehouse');
insert into ORDERS values (11700, date '2016-01-13', 'In Warehouse');
insert into ORDERS values (11700, date '2016-01-14', 'In Warehouse');
insert into ORDERS values (11700, date '2016-01-15', 'Awaiting Signoff');
insert into ORDERS values (11700, date '2016-01-16', 'Awaiting Signoff');
insert into ORDERS values (11700, date '2016-01-17', 'Payment Pending');
insert into ORDERS values (11700, date '2016-01-18', 'Payment Pending');
insert into ORDERS values (11700, date '2016-01-19', 'Awaiting Signoff');
insert into ORDERS values (11700, date '2016-01-20', 'Awaiting Signoff');
insert into ORDERS values (11700, date '2016-01-21', 'Delivery');
insert into ORDERS values (11700, date '2016-01-22', 'Delivery');

/*
  ORDER_ID STATUS               FROM_DATE TO_DATE
---------- -------------------- --------- ---------
     11700 New                            03-JAN-16
     11700 Inventory Check      03-JAN-16 08-JAN-16
     11700 Awaiting Signoff     08-JAN-16 11-JAN-16
     11700 In Warehouse         11-JAN-16 14-JAN-16
     11700 Awaiting Signoff     14-JAN-16 16-JAN-16
     11700 Payment Pending      16-JAN-16 18-JAN-16
     11700 Awaiting Signoff     18-JAN-16 20-JAN-16
     11700 Delivery             20-JAN-16 22-JAN-16
*/
select 
  order_id, 
  status, 
  lag(status_date) over (partition by order_id order by status_date) from_date,
  status_date to_date
from (
  select 
    order_id,
    status_date,
    status,
    lag(status) over (partition by order_id order by status_date) lag_status,
    lead(status) over (partition by order_id order by status_date) lead_status
  from ORDERS
  )
where (lag_status is null or lead_status is null)
   or lead_status <> status
order by 1,3 nulls first;
