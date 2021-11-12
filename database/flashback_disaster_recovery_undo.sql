-- Created: 12-Nov-2021 (Bob Heckel)

---

SELECT account_team_assignment_id, actual_updated, actual_updatedby
from account_team_assign_all
where actual_updated = ( select max(actual_updated) FROM account_team_assign_all);

---

-- Recover update

create table ztest as select 1 x from dual;

update ztest set x=2; commit;
SELECT * FROM ztest;--2

SELECT row_movement FROM user_tables WHERE table_name='ZTEST';--DISABLED
ALTER TABLE ztest ENABLE ROW MOVEMENT; -- rowids will now be able to change after the flashback occurs

FLASHBACK TABLE ztest TO TIMESTAMP (SYSTIMESTAMP - INTERVAL '2' minute);

SELECT * FROM ztest;--1

---

-- Recover drop

ALTER SESSION SET recyclebin = ON;

drop table JS_INVOICE_16FEB21;

show recyclebin
--or
SELECT * FROM user_recyclebin;

flashback table JS_INVOICE_16FEB21 to before drop;
--or
flashback table JS_INVOICE_16FEB21 to before drop rename to JS_INVOICE_16FEB21_OLD;
