DECLARE
  v_lower  NUMBER := 1;
  v_upper  NUMBER := 1;
BEGIN
  FOR i IN v_lower .. v_upper LOOP
    INSERT INTO foo (ordid, itemid) VALUES (v_ordid, i);
  END LOOP;
END;

