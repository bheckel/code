--Modified: Thu 20 Jun 2019 16:11:31 (Bob Heckel) 

---

CREATE TABLE rion_37551 AS SELECT * FROM email_messages WHERE 1 = 0;

-- DB always has 2 as the last digit of NEXTVAL
CREATE SEQUENCE UID_RION_37551 MINVALUE 2 MAXVALUE 999999999999999999999999999 INCREMENT BY 10  START WITH 12 CACHE 20 NOORDER NOCYCLE;

INSERT INTO RION_37551 (EMAIL_MESSAGES_ID, subject) VALUES (uid_RION_37551.NEXTVAL, 'test'); COMMIT;

SELECT UID_RION_37551.NEXTVAL FROM dual -- 12 22 32 42...
SELECT * FROM RION_37551;
DROP SEQUENCE UID_RION_37551;
DROP TABLE RION_37551;

---

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
