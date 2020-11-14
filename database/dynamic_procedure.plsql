-- Modified: 09-Nov-2020 (Bob Heckel)

-- see also cursor.plsql

---

CREATE OR REPLACE PACKAGE RION39939 IS
 
 PROCEDURE bkuptbl(tblnm VARCHAR2);

END;
/


CREATE OR REPLACE PACKAGE BODY RION39939 IS

  PROCEDURE bkuptbl(tblnm VARCHAR2) IS
    sqlstr VARCHAR2(4000);

    BEGIN
      dbms_output.put_line(tblnm);
      
      sqlstr := 'create table ' || trim(tblnm) || '_2 as select * from ' || tblnm;
      
      execute immediate sqlstr;
  END;
  
END;
/

---

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
CREATE OR REPLACE PACKAGE rion39366 IS
  -- ----------------------------------------------------------------------------
  -- Purpose: CREATED/UPDATED dates should not be before 1970
  -- Created 23Aug19 bheck
  --
  -- DROP PACKAGE RION39366
  -- ----------------------------------------------------------------------------
 
  PROCEDURE do_audit(col_in VARCHAR2, inputtbl_in VARCHAR2);
  PROCEDURE do_update(col_in VARCHAR2, inputtbl_in VARCHAR2);
END;
/


CREATE OR REPLACE PACKAGE BODY rion39366 IS

  --exec RION39366.do_audit('CREATED', 'rion39366_c@esd');
  --exec RION39366.do_audit('UPDATED', 'rion39366_u@esd');
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

    -- As a cursor this occasionally hangs for a very long time so Plan B, precompile table names rion39366_c@sed & rion39366_u@sed
/*    CURSOR c1 IS
      SELECT table_name, low_value
        FROM user_tab_columns
       WHERE table_name IN(
         SELECT table_name 
           FROM user_tables
          WHERE table_name NOT LIKE 'BDG%'
            AND table_name NOT LIKE 'RIA%'
            AND table_name NOT LIKE 'CMK%'
            AND table_name NOT LIKE '%\_BKUP'  ESCAPE '\'
            AND NOT regexp_like(table_name, '.*\d+$')
            AND NOT regexp_like(table_name, '^S\d+')
        )
          AND column_name = col_in
        ORDER BY 1
      ;*/

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

        WHILE key IS NOT NULL LOOP
          EXECUTE IMMEDIATE 
            'select count(1) from ' || key || ' where ' || col_in || ' < ''01JAN1970'''
          INTO cnt;

          dbms_output.put_line(key || ' ' || names(key) || ' ' || cnt);

          key := names.NEXT(key);
        END LOOP;
  END do_audit;


  --exec RION39366.do_update('CREATED', 'rion39366_c@esd');
  --exec RION39366.do_update('UPDATED', 'rion39366_u@esd');
  PROCEDURE do_update(col_in VARCHAR2, inputtbl_in VARCHAR2) IS
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
     
     cnt := 0;

     -- For each table with >0 bad dates...
     WHILE key IS NOT NULL LOOP
       t1 := dbms_utility.get_time();

      -- Use rowid for identifying bad dates
       sqlstr2 := 'SELECT rowid FROM ' || key || ' WHERE ' || col_in || ' < ''01JAN1970''';
                                                                                                                                         
       OPEN c2 FOR sqlstr2;
         cnt := 0;
         LOOP
           FETCH c2 bulk collect INTO rowids limit 100;
           EXIT WHEN rowids.COUNT = 0;
           -- Update those bad date rowids to 01JAN1970
           FOR i IN 1..rowids.COUNT LOOP
             sqlstr3 := 'UPDATE ' || key || ' SET ' || col_in || ' = ''01JAN1970'' WHERE rowid = ''' || trim(rowids(i)) || '''';
             EXECUTE IMMEDIATE sqlstr3;
             cnt := cnt + 1;
           END LOOP;
           COMMIT;
           --rollback;
         END LOOP;
       CLOSE c2;

       t2 := (dbms_utility.get_time()-t1)/100;
       dbms_output.put_line(key || ' ' || names(key) || ' cnt ' || cnt || ' seconds ' || t2);

       key := names.NEXT(key);
     END LOOP;

     EXCEPTION
       WHEN OTHERS THEN
         dbms_output.put_line(SQLCODE || ': ' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
         ROLLBACK;
  END do_update;
END;
/
