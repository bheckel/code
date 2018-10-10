DECLARE
  TYPE a_ids IS VARRAY(42) OF PLS_INTEGER;
  ids a_ids := a_ids(11470305,5637043,5560096,2214131,124543,8170020);
    
  runprod NUMBER(1) := 0;
  ignoreauditflag NUMBER(1) := 0;
BEGIN
  /********************************* 1 **********************************************/  
  dbms_output.put_line('1.........account_search_id does exist:');
  
  FOR i IN 1 .. ids.COUNT LOOP
    FOR rec IN (select * FROM account_search WHERE account_search_id = ids(i)) LOOP
      dbms_output.put_line('BEFORE account_search_id: ' || rec.account_search_id || ' updated: ' || rec.updated || ' updatedby: ' || rec.updatedby || ' search_match_code: ' || rec.SEARCH_MATCH_CODE || ' bada: ' || rec.badabingle);
    END LOOP;
    
    IF runprod = 1 THEN
      set_account_match_code(inaccount_id => ids(i), ignore_audit => ignoreauditflag);
    ELSE
      z_set_account_match_code(inaccount_id => ids(i), ignore_audit => ignoreauditflag);
    END IF;
    
    FOR rec IN (select * FROM account_search WHERE account_search_id = ids(i)) LOOP
      dbms_output.put_line('AFTER  account_search_id: ' || rec.account_search_id || ' updated: ' || rec.updated || ' updatedby: ' || rec.updatedby || ' search_match_code: ' || rec.SEARCH_MATCH_CODE || ' bada: ' || rec.badabingle);
    END LOOP;
    
    dbms_output.put_line(chr(10));
  END LOOP;

  ROLLBACK;
END:
