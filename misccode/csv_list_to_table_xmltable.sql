-- Modified: Wed 19 Jun 2019 13:55:54 (Bob Heckel) 
-- Use a CSV comma-separated list like a table

---

-- Find records in list that are not in table.  See better example on_one_table_missing_from_other.sql
SELECT a.interaction_id, b.ids
FROM rpt_caeinteractions a,
(
WITH DATA AS (
SELECT '9999999, 318387999, 320438999, 321588999' ids FROM dual
)
SELECT trim(COLUMN_VALUE) ids
FROM DATA, xmltable(('"' || REPLACE(ids, ',', '","') || '"'))
) b
WHERE a.interaction_id(+)=b.ids AND a.interaction_id is NULL

---

SELECT ids, ab.account_id 
FROM (SELECT to_number(column_value) ids
      FROM xmltable(('"' || REPLACE('432803,434768', ',', '","') || '"'))) csv
     LEFT JOIN account ab ON csv.ids=ab.account_id

---

SELECT ids, ab.account_id 
FROM (WITH DATA AS
      (SELECT '432803,434768,439324' ids FROM dual)
      SELECT to_number(TRIM(regexp_substr(ids, '[^,]+', 1, LEVEL))) ids
      FROM DATA
      CONNECT BY instr(ids, ',', 1, LEVEL - 1) > 0) csv
LEFT JOIN account_base ab ON csv.ids=ab.account_id

---

WITH DATA AS
  (SELECT '409065,93254,1000493402' ids FROM dual)
SELECT trim(COLUMN_VALUE) ids
FROM DATA, xmltable(('"' || REPLACE(ids, ',', '","') || '"'))

---

CREATE OR REPLACE PACKAGE ORION36736 IS
 failure_in_forall EXCEPTION;  
 PRAGMA EXCEPTION_INIT (failure_in_forall, -24381);  -- ORA-24381: error(s) in array DML  
 
 PROCEDURE upd(in_ids VARCHAR2);

END;
/
CREATE OR REPLACE PACKAGE BODY ORION36736 IS

  PROCEDURE upd(in_ids VARCHAR2) IS
    l_limit_group  PLS_INTEGER := 0;
    l_tab_size     PLS_INTEGER := 0;
    l_tab_size_tot PLS_INTEGER := 0;
    l_cnt          PLS_INTEGER := 0;

    CURSOR c1 IS
      SELECT account_id
        FROM account_base
       WHERE account_id IN (SELECT in_id
                              FROM (SELECT TO_NUMBER(COLUMN_VALUE) in_id
                                      FROM XMLTABLE(TRIM(in_ids))))
      ;

    TYPE t1 IS TABLE OF c1%ROWTYPE;
    l_recs t1;
            
    BEGIN
      IF (in_ids IS NULL) THEN
        RETURN;
      END IF;
  
      OPEN c1;
      LOOP
        FETCH c1 BULK COLLECT INTO l_recs LIMIT 100;  
        
        l_limit_group := l_limit_group + 1;
        l_tab_size := l_recs.COUNT;
        l_tab_size_tot := l_tab_size_tot + l_tab_size;
        
        dbms_output.put_line(to_char(sysdate, 'DD-Mon-YYYY HH24:MI:SS') || ': iteration ' || l_limit_group || ' processing ' || l_tab_size || ' records' || ' total ' || l_tab_size_tot);
                
        EXIT WHEN l_tab_size = 0;
        
        BEGIN
          FORALL i IN 1 .. l_tab_size SAVE EXCEPTIONS
            UPDATE account_base a
               SET a.usedinestars = 1
             WHERE account_id = l_recs(i).account_id
            ;
          
        EXCEPTION
          WHEN failure_in_forall THEN   
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_stack);   
            DBMS_OUTPUT.put_line('Updated ' || SQL%ROWCOUNT || ' rows prior to EXCEPTION');
   
            FOR ix IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP   
              DBMS_OUTPUT.put_line ('Error ' || ix || ' occurred on iteration ' || SQL%BULK_EXCEPTIONS(ix).ERROR_INDEX || '  with error code ' || SQL%BULK_EXCEPTIONS(ix).ERROR_CODE ||
                                    ' ' || SQLERRM(-(SQL%BULK_EXCEPTIONS(ix).ERROR_CODE)));
            END LOOP;
        END;
        
        COMMIT;
        --ROLLBACK;
      END LOOP;
      dbms_output.put_line(to_char(sysdate, 'DD-Mon-YYYY HH24:MI:SS') || ': END iteration ' || l_limit_group || ' processing ' || l_tab_size || ' records' || ' total ' || l_tab_size_tot);
      CLOSE c1;
      
      FOR r IN c1 LOOP
        ACCOUNT_ASSIGNMENTS.update_account_search(r.account_id);
        l_cnt := l_cnt + 1;
        dbms_output.put_line(r.account_id);
        IF (mod(l_cnt, 100) = 0) THEN
          COMMIT;
          --ROLLBACK;
        END IF;
      END LOOP;
      COMMIT;
      --ROLLBACK;

      MAINT.logdatachange(step => 0, status => 'ORION-36736: MM Account to Flag as Used in Orion 3-19-19', release => 'N/A', defect => 'N/A', startTime => SYSDATE, do_commit => 1); 
    END upd;
END;
/
