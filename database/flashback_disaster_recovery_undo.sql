--  Created: 12-Nov-2021 (Bob Heckel)
-- Modified: 17-Aug-2022 (Bob Heckel)

---

-- Restore undo a table update

ALTER SESSION SET recyclebin = ON;
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

PURGE RECYCLEBIN;

