-- Oracle SQL*Plus template

column employee_id format A7
column department_id format A7
column product_id format A7
column process_id format A7
column work_id format A7
column work_date format A9
column comments format A15

set sqlprompt "sql> "
set linesize 150

---update time_transacts hours set hours = hours + 1

---delete from time_transacts where employee_id = 'bax' 

---insert into time_transacts values (transaction_number.nextval, sysdate, (select attribute_value from users where (user_id = '1005' and attribute = 'employee_id')), '3R123', '1', '1', 'sust', to_date('7/7/2000', 'MM/DD/YYYY'), 9, 'some comments');
insert into time_transacts -
values (transaction_number.nextval, -
        sysdate, -
        (select attribute_value from users -
                   where (user_id = '1005' and attribute = 'employee_id')), -
        '3R123', -
        '1', -
        '1', -
        'sust', -
        to_date('7/7/2000', 'MM/DD/YYYY'), -
        23, -
        'some comments'
       );

---select transaction_id, to_char(time, 'fmHH:MI:SS') time from time_transacts
select * from time_transacts;
/
