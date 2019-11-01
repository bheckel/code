ALTER SESSION SET ddl_lock_timeout=200;

create table zasp as select * from asp where rownum<99;
ALTER TABLE zasp MODIFY FUTURE_SUP_ACCOUNT_ID  NUMBER; -- fail

SELECT count(1), future_sup_account_id FROM zasp group by future_sup_account_id;--pin

alter table zasp add future_sup_account_id1 number;

update zasp set future_sup_account_id1 = future_sup_account_id;
commit;

update zasp set future_sup_account_id = null;
commit;

ALTER TABLE zasp MODIFY FUTURE_SUP_ACCOUNT_ID  NUMBER;

update zasp set future_sup_account_id = future_sup_account_id1;
commit;

SELECT count(1), future_sup_account_id FROM zasp group by future_sup_account_id;
SELECT count(1), future_sup_account_id1 FROM zasp group by future_sup_account_id1;

ALTER TABLE zasp drop column future_sup_account_id1;
