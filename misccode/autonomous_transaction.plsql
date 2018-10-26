
PROCEDURE LOG(request_id IN VARCHAR2, msg IN VARCHAR2) AS
	PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
	IF (request_id IS NULL) THEN
		DBMS_OUTPUT.put_line(msg);
	ELSE
		INSERT INTO MYTBL
		VALUES
			(UID_USER_MYTBL.NEXTVAL,
			 msg,
			 request_id,
			 sysdate,
			 sys_context('my_context', 'employee_id'));
		COMMIT;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		RAISE;
END LOG;

