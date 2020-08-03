CREATE OR REPLACE PACKAGE pkg39366 IS
  ----------------------------------------------------------------------------
  -- Author: Bob Heckel
  -- Date:   27-Aug-19
  -- Usage:  CREATED/UPDATED dates should not be before 1970
  -- JIRA:   pkg-39366
 ----------------------------------------------------------------------------

  PROCEDURE do_audit(col_in VARCHAR2, inputtbl_in VARCHAR2);
  PROCEDURE do_update(col_in VARCHAR2, inputtbl_in VARCHAR2);
END;
/


CREATE OR REPLACE PACKAGE BODY pkg39366 IS

  PROCEDURE do_audit(col_in VARCHAR2, inputtbl_in VARCHAR2) IS
    TYPE chartbl IS TABLE OF VARCHAR(128) INDEX BY VARCHAR2(128);

    names       charTbl;
    mindt       DATE;
    i           NUMBER := 0;
    key         VARCHAR(50);
    cnt         NUMBER := 0;
    c1          SYS_REFCURSOR;
    sqlstr      VARCHAR(500); 
    table_name  VARCHAR(99);
    low_value   RAW(32767);

    -- As a cursor this occasionally hangs so Plan B, pre-compile table names pkg39366_c@esd & pkg39366_u@esd
/*    CURSOR c1 IS
      SELECT table_name, low_value
        FROM user_tab_columns
       WHERE table_name IN(
         SELECT table_name 
           FROM user_tables
          WHERE table_name NOT LIKE 'BDG%'
            AND table_name NOT LIKE 'RIA%'
            AND table_name NOT LIKE 'pkg%'
            AND table_name NOT LIKE '%\_OLD' ESCAPE '\'
            AND table_name NOT LIKE '%\_MV' ESCAPE '\'
            AND table_name NOT LIKE '%\_V' ESCAPE '\'
            AND table_name NOT LIKE '%\_BKUP'  ESCAPE '\'
            AND NOT regexp_like(table_name, '.*\d+$')
            AND NOT regexp_like(table_name, '^S\d+')
        )
          AND column_name = col_in
        ORDER BY 1
      ;*/

      BEGIN
        --EDIT!!!!!!!!!
        --sqlstr := 'SELECT table_name, low_value FROM ' || trim(inputtbl_in) || ' WHERE rownum<19'; -- CREATED debugging
        --sqlstr := 'SELECT table_name, low_value FROM ' || trim(inputtbl_in) || ' WHERE rownum<99'; -- UPDATED debugging
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
    TYPE chartbl IS TABLE OF VARCHAR(128) INDEX BY VARCHAR2(128);

    names          charTbl;
    mindt          DATE;
    i              NUMBER := 0;
    key            VARCHAR(50);
    cnt            NUMBER := 0;
    c1             SYS_REFCURSOR;
    sqlstr         VARCHAR(500); 
    table_name     VARCHAR(99);
    low_value      RAW(32767);
    t1             INTEGER;
    t2             INTEGER;
    already_has_ix BOOLEAN;
    
    BEGIN
      EXECUTE IMMEDIATE 'ALTER SESSION SET ddl_lock_timeout=10';
      
      --EDIT!!!!!!!!!
      --sqlstr := 'SELECT table_name, low_value FROM ' || trim(inputtbl_in) || ' WHERE rownum<19'; -- CREATED debugging
      --sqlstr := 'SELECT table_name, low_value FROM ' || trim(inputtbl_in) || ' WHERE rownum<99'; -- UPDATED debugging
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
       t1 := dbms_utility.get_time();
       already_has_ix := FALSE;
       
         for tbl in ( select table_name from pkg39366_cx@esd ) loop
           if tbl.table_name = key then
             already_has_ix := TRUE;
           end if;
         end loop;

         IF already_has_ix THEN
           EXECUTE IMMEDIATE 'UPDATE ' || key ||
                               ' SET ' || col_in || ' = ''01JAN1970''
                               WHERE ' || col_in || ' < ''01JAN1970''';
  
           cnt := SQL%ROWCOUNT;
  
           t2 := (dbms_utility.get_time()-t1)/100;
           dbms_output.put_line(key || ' ' || names(key) || ' ' || cnt || ' rows in ' || t2 || ' seconds  NO TMP_IX at ' || to_char(systimestamp, 'YYYY-MM-DD HH24:MI:SS.FF'));
           COMMIT;  -- for non-DDL condition
         ELSE
           EXECUTE IMMEDIATE 'CREATE INDEX TMP_pkg39366_IX ON ' || trim(key) || '(' || trim(col_in) || ') ONLINE PARALLEL 32';
  
           EXECUTE IMMEDIATE 'UPDATE ' || key ||
                               ' SET ' || col_in || ' = ''01JAN1970''
                               WHERE ' || col_in || ' < ''01JAN1970''';
  
           cnt := SQL%ROWCOUNT;
  
           EXECUTE IMMEDIATE 'DROP INDEX TMP_pkg39366_IX';
  
           t2 := (dbms_utility.get_time()-t1)/100;
           dbms_output.put_line(key || ' ' || names(key) || ' ' || cnt || ' rows in ' || t2 || ' seconds at ' || to_char(systimestamp, 'YYYY-MM-DD HH24:MI:SS.FF'));       
         END IF;

       key := names.NEXT(key);
     END LOOP;

     EXCEPTION
       WHEN OTHERS THEN
         dbms_output.put_line(SQLCODE || ': ' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
         ROLLBACK;
  END do_update;
END;
/
