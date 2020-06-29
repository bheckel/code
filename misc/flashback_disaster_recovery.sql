
update zasp2 set future_sup_account_id = null; commit;
 
SELECT count(1), future_sup_account_id FROM zasp group by future_sup_account_id;
  
-- rowids will change after the flashback occurs
ALTER TABLE zasp2 ENABLE ROW MOVEMENT;
 
FLASHBACK TABLE zasp2 TO  TIMESTAMP (SYSTIMESTAMP - INTERVAL '2' MINUTE);
