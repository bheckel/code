
CREATE sequence UID_OPPORTUNITY_OPT_OUT
  MINVALUE 1000
  MAXVALUE 999999999999999999999999999
  START WITH 1001
  INCREMENT BY 1
  CACHE 5;

---

PROCEDURE generateSeq IS
	lastSeq NUMBER;
			
	BEGIN
		--TODO add exception handler
		EXECUTE IMMEDIATE 'drop sequence seq30537';
		
		--TODO
		-- Try to avoid collisions with others committing by adding 100
		SELECT MAX(ref_corporate_initiative_id) + 100 INTO lastSeq FROM z_bob_ref_corporate_initiative;
		
		IF lastSeq IS NULL THEN lastSeq := 1; END IF;
		
		DBMS_OUTPUT.put_line('start with lastSeq: ' || lastSeq);
		
		EXECUTE IMMEDIATE 'CREATE SEQUENCE seq30537 INCREMENT BY 1 START WITH ' || lastSeq || ' MAXVALUE 999999999 MINVALUE 1 NOCACHE';
END;
