------------------------------------
-- Created: 24-Feb-2021 (Bob Heckel)
------------------------------------

---

create or replace PROCEDURE zupd(in_table_name      VARCHAR2,
                                 in_column_name     VARCHAR2,
                                 in_commit_interval NUMBER DEFAULT 500)
IS
  TYPE t_numberTable IS TABLE OF NUMBER;
  v_numtbl  t_numberTable;

  TYPE t_varchar2Table IS TABLE OF VARCHAR2(32767);
  v_chartbl  t_varchar2Table;
  
  v_main_table VARCHAR2(50) := 'MKC_REVENUE_FULL';

  c1  SYS_REFCURSOR;
BEGIN
  OPEN c1 FOR 'SELECT MKC_REVENUE_ID, ' || in_column_name || ' FROM ' || v_main_table;

  LOOP
    FETCH c1 BULK COLLECT INTO v_numtbl, v_chartbl LIMIT in_commit_interval;

    EXIT WHEN v_numtbl.COUNT = 0;

    BEGIN
      FORALL i IN 1 .. v_numtbl.COUNT SAVE EXCEPTIONS
        EXECUTE IMMEDIATE
        'UPDATE ' || in_table_name || ' SET ' || in_column_name ||
        ' = :1 WHERE MKC_REVENUE_ID = :2'
        USING v_chartbl(i), v_numtbl(i)
      ;
  
      COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
        FOR i IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP
          DBMS_OUTPUT.put_line(SQLERRM(-(SQL%BULK_EXCEPTIONS(i).ERROR_CODE))); 
        END LOOP;
    END;
  END LOOP;

  CLOSE c1;
END;

---

DECLARE
    l_limit_group  PLS_INTEGER := 0;
    l_tab_size     PLS_INTEGER := 0;
    l_tab_size_tot PLS_INTEGER := 0;

    CURSOR c1 IS
      SELECT o.opportunity_id
        FROM opportunity_base o
       WHERE 
AND ROWNUM<9
      ;

    TYPE t1 IS TABLE OF c1%ROWTYPE;
    l_recs t1;
            
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 BULK COLLECT INTO l_recs LIMIT 500;  
    
    l_limit_group := l_limit_group + 1;
    l_tab_size := l_recs.COUNT;
    l_tab_size_tot := l_tab_size_tot + l_tab_size;

    -- Only print every 100K records
    IF (MOD(l_limit_group, 1000) = 0) THEN
      dbms_output.put_line(to_char(sysdate, 'DD-Mon-YYYY HH24:MI:SS') || ': iteration ' || l_limit_group || ' processing ' || l_tab_size || ' records' || ' total ' || l_tab_size_tot);
    END IF;
    
    EXIT WHEN l_tab_size = 0;
    
    BEGIN
      FORALL i IN 1 .. l_tab_size SAVE EXCEPTIONS
        UPDATE OPPORTUNITY_OPT_OUT
           SET POOR_CLOSEOUT_OPT_OUT = 1
         WHERE OPPORTUNITY_ID = l_recs(i).opportunity_id
        ;
      
    EXCEPTION
      WHEN  SQLCODE = -24381 THEN -- error(s) in array DML
        DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_stack);   
        DBMS_OUTPUT.put_line('Updated ' || SQL%ROWCOUNT || ' rows prior to EXCEPTION');

        FOR ix IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP   
          DBMS_OUTPUT.put_line ('Error ' || ix || ' occurred on iteration ' || SQL%BULK_EXCEPTIONS(ix).ERROR_INDEX ||
                                '  with error code ' || SQL%BULK_EXCEPTIONS(ix).ERROR_CODE ||
                                ' ' || SQLERRM(-(SQL%BULK_EXCEPTIONS(ix).ERROR_CODE)));
        END LOOP;
        -- Now keep going with the next l_limit_group...
    END;
    
    COMMIT;
  END LOOP;

  CLOSE c1;
END;
