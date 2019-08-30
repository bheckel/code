
/* Dynamically delete oldest records from a table */
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

---

  -- Accept a table name as parameter dynamically
  PROCEDURE do_audit(col_in VARCHAR2, inputtbl_in VARCHAR2) IS
    TYPE chartbl IS TABLE OF VARCHAR(128) INDEX BY VARCHAR2(128);

    names       charTbl;
    mindt       DATE;
    i           NUMBER := 0;
    key         VARCHAR(50);
    cnt         NUMBER;
    c1          SYS_REFCURSOR;
    sqlstr      VARCHAR(500); 
    table_name  VARCHAR(99);
    low_value   RAW(32767);

		BEGIN        
			--sqlstr := 'SELECT table_name, low_value FROM ' || trim(inputtbl_in) || ' WHERE rownum<99';
			sqlstr := 'SELECT table_name, low_value FROM ' || trim(inputtbl_in);
			
			OPEN c1 FOR sqlstr;
			LOOP
				FETCH c1 INTO table_name, low_value;
				EXIT WHEN c1%NOTFOUND;
				
				-- Avoid looking for MIN() in each table in schema
				dbms_stats.convert_raw_value(hextoraw(LOW_VALUE), mindt);
				
				IF mindt < '01JAN1970' THEN
					i := i + 1;

					names(table_name) := to_char(mindt, 'DD-MON-YYYY');

					--dbms_output.put_line(table_name || ' ' || to_char(mindt, 'DD-MON-YYYY'));
				END IF;
			END LOOP;

			key := names.FIRST;

			WHILE key IS NOT NULL LOOP
				EXECUTE IMMEDIATE 
					'select count(1) from ' || key || ' where ' || col_in || ' < ''01JAN1970'''
				INTO cnt;

				dbms_output.put_line(key || ' ' || names(key) || ' ' || cnt);

				key := names.NEXT(key);
			END LOOP;
  END do_audit;


  PROCEDURE do_update(col_in VARCHAR2, inputtbl_in VARCHAR2) IS
      --exec RION39366.do_update('CREATED', 'rion39366_c@sed');
    --exec RION39366.do_update('UPDATED', 'rion39366_u@sed');
    TYPE chartbl IS TABLE OF VARCHAR(128) INDEX BY VARCHAR2(128);
    TYPE varcharTbl is TABLE OF VARCHAR2(100);

    names       charTbl;
    rowids      varcharTbl;
    mindt       DATE;
    i           NUMBER := 0;
    key         VARCHAR(50);
    cnt         NUMBER;
    c1          SYS_REFCURSOR;
    c2          SYS_REFCURSOR;
    sqlstr      VARCHAR(500);
    sqlstr2     VARCHAR(500);
    sqlstr3     VARCHAR(500); 
    table_name  VARCHAR(99);
    low_value   RAW(32767);
    t1          INTEGER;
    t2          INTEGER;

    BEGIN
      sqlstr := 'SELECT table_name, low_value FROM ' || trim(inputtbl_in);
      
      OPEN c1 FOR sqlstr;
      LOOP
        FETCH c1 INTO table_name, low_value;
        EXIT WHEN c1%NOTFOUND;
        
        -- Avoid looking for MIN() in each table in schema
        dbms_stats.convert_raw_value(hextoraw(LOW_VALUE), mindt);
        
        IF mindt < '01JAN1970' THEN
          i := i + 1;

          names(table_name) := to_char(mindt, 'DD-MON-YYYY');

          --dbms_output.put_line(table_name || ' ' || to_char(mindt, 'DD-MON-YYYY'));
        END IF;
      END LOOP;

     key := names.FIRST;

     -- For each table with >0 bad dates...
     WHILE key IS NOT NULL LOOP
       t1 := dbms_utility.get_time();

       sqlstr2 := 'SELECT rowid FROM ' || key || ' WHERE created < ''01JAN1970''';
      
       cnt := 0;
       
       -- ...update it 100 recs at a time
       OPEN c2 FOR sqlstr2;
         LOOP
           FETCH c2 BULK COLLECT INTO rowids LIMIT 100;
           EXIT WHEN rowids.COUNT = 0;
           FOR i IN 1..rowids.COUNT LOOP
             cnt := cnt + 1;
             sqlstr3 := 'UPDATE ' || key || ' SET ' || col_in || ' = ''01JAN1970'' WHERE rowid = ''' || trim(rowids(i)) || '''';
             EXECUTE IMMEDIATE sqlstr3;
           END LOOP;
           --COMMIT; 
           rollback;
         END LOOP; 
       --COMMIT;
       rollback;
       CLOSE c2;

       t2 := (dbms_utility.get_time()-t1)/100;
       dbms_output.put_line(key || ' ' || names(key) || ' ' || cnt || ' ' || t2);

       key := names.NEXT(key);
     END LOOP;

     EXCEPTION
       WHEN OTHERS THEN
         dbms_output.put_line(SQLCODE || ': ' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
         ROLLBACK;
  END do_update;
