
/* Generically delete oldest records from a table dynamically */
/* E.g. PRUNE_TBL_GENERIC('EMAIL_MESSAGES', 'ACTUAL_UPDATED', 'EMAIL_MESSAGES_ID', 365); */
PROCEDURE PRUNE_TBL_GENERIC(tblnm VARCHAR2, datecol VARCHAR2, idcol VARCHAR2, daysback NUMBER) IS
	l_cnt      PLS_INTEGER := 0;
	l_cur      SYS_REFCURSOR;
	l_sql      VARCHAR(500);
			
	TYPE ids_t IS TABLE OF NUMBER;
	ids ids_t;
					
	BEGIN
		-- Build an expired records cursor
    -- E.g. SELECT user_oncall_results_id FROM user_oncall_results WHERE execute_time < '15FEB19'
		l_sql := 'SELECT ' || idcol || ' FROM ' || trim(tblnm) || ' WHERE ' || trim(datecol) || ' < ' || chr(39) || to_char(SYSDATE - daysback, 'DDMONYY') || chr(39);
		
		OPEN l_cur FOR l_sql;
		LOOP
			FETCH l_cur BULK COLLECT INTO ids LIMIT 100;  
			
			EXIT WHEN ids.COUNT = 0;
			
			FOR i IN 1 .. ids.COUNT LOOP
				EXECUTE IMMEDIATE 'DELETE FROM ' || tblnm || ' WHERE ' || idcol || ' = :1'
					USING ids(i);
			
				l_cnt := l_cnt + SQL%ROWCOUNT;
			END LOOP;
				
			--COMMIT;
			ROLLBACK;
		END LOOP;
		CLOSE l_cur;
		
		dbms_output.put_line(l_cnt);
END;
