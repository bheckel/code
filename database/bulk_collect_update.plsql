------------------------------------
-- Created: 24-Feb-2021 (Bob Heckel)
------------------------------------

---

-- Dynamic update version 1

create or replace PROCEDURE dynamic_update(in_table_name      VARCHAR2,
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

-- Dynamic update version 2
DECLARE
  TYPE t_numberTable IS TABLE OF NUMBER;
  TYPE t_varchar2Table IS TABLE OF VARCHAR2(32767);
  TYPE t_dateTable IS TABLE OF DATE;
  
  v_sdmbktbl    t_varchar2Table;
  v_tortbl      t_numberTable;
  v_sql         VARCHAR(32767);
  updateCursor  SYS_REFCURSOR;
            
BEGIN
  v_sql := 'select ''aa'' sdm_business_key, 2 tor_id from dual';
  
  OPEN updateCursor FOR v_sql;
    LOOP
      FETCH updateCursor BULK COLLECT INTO v_sdmbktbl, v_tortbl LIMIT 500;  
    
      EXIT WHEN v_sdmbktbl.COUNT = 0;
    
      BEGIN
        for i in 1 .. v_sdmbktbl.count loop
          dbms_output.put_line(i || ' ' || v_sdmbktbl(i) || ' ' || v_tortbl(i));
        end loop;
      
--      FORALL i IN 1 .. v_sdmbktbl.COUNT SAVE EXCEPTIONS
--        EXECUTE IMMEDIATE 'UPDATE MKC_REVENUE_FULL
--                              SET  = :2,
--                                   = :3
--                            WHERE sdm_business_key = :1'
--         USING v_sdmbktbl(i), v_tortbl(i)
--        ;
--      COMMIT;

      EXCEPTION
        WHEN OTHERS THEN
          IF SQLCODE = -24381 THEN -- error(s) in array DML
            DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_stack);   
            DBMS_OUTPUT.put_line('Updated ' || SQL%ROWCOUNT || ' rows prior to EXCEPTION');
    
            FOR ix IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP   
              DBMS_OUTPUT.put_line ('Error ' || ix || ' occurred on iteration ' || SQL%BULK_EXCEPTIONS(ix).ERROR_INDEX ||
                                    '  with error code ' || SQL%BULK_EXCEPTIONS(ix).ERROR_CODE ||
                                    ' ' || SQLERRM(-(SQL%BULK_EXCEPTIONS(ix).ERROR_CODE)));
              --log(v_main_table, 'ERROR: ' || v_message || ' (AUTO ADJUSTMENTS)');                                  
            END LOOP;
          END IF;
      END;
    END LOOP;
END ;

---

-- Static update version 1

DECLARE
  CURSOR c1 IS
    SELECT o.opportunity_id
      FROM opportunity_base o
     WHERE ROWNUM<9
    ;

  TYPE t1 IS TABLE OF c1%ROWTYPE;
  l_recs t1;
            
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 BULK COLLECT INTO l_recs LIMIT 500;  
    
    EXIT WHEN l_recs.COUNT = 0;
    
    BEGIN
      for i in 1 .. l_recs.count loop
        dbms_output.put_line(i || ' ' || l_recs(i).opportunity_id);
      end loop;
      
--      FORALL i IN 1 .. l_tab_size SAVE EXCEPTIONS
--        UPDATE OPPORTUNITY_OPT_OUT
--           SET POOR_CLOSEOUT_OPT_OUT = 1
--         WHERE OPPORTUNITY_ID = l_recs(i).opportunity_id
--        ;

    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE = -24381 THEN -- error(s) in array DML
          DBMS_OUTPUT.put_line(DBMS_UTILITY.format_error_stack);   
          DBMS_OUTPUT.put_line('Updated ' || SQL%ROWCOUNT || ' rows prior to EXCEPTION');
  
          FOR ix IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP   
            DBMS_OUTPUT.put_line ('Error ' || ix || ' occurred on iteration ' || SQL%BULK_EXCEPTIONS(ix).ERROR_INDEX ||
                                  '  with error code ' || SQL%BULK_EXCEPTIONS(ix).ERROR_CODE ||
                                  ' ' || SQLERRM(-(SQL%BULK_EXCEPTIONS(ix).ERROR_CODE)));
          END LOOP;
        END IF;
    END;
    
    --COMMIT;
  END LOOP;

  CLOSE c1;
END;

---

-- Static update version 2

DECLARE
  l_cnt PLS_INTEGER := 0;

  CURSOR c1 IS
    select distinct c.contact_id
      from contact_base c, 
           event_contact ec,
           contact_opportunity co
     where c.created >= '01JAN2020'
       and c.contact_ID = ec.contact_ID
       and c.contact_id = co.contact_id(+)
       and ec.event_id in (999, 999)
       and co.opportunity_id is null
       and ec.contact_id not in ( 
            select cae.contact_id
              from contact_activ_event cae, 
                   activity a 
             where a.activity_id = cae.activity_id
               and a.priority_int = 31 -- hot             
            )
and rownum<3  
     ;
    
  TYPE t1 IS TABLE OF c1%ROWTYPE;
  l_recs t1;
          
  BEGIN
    OPEN c1;
    LOOP
      FETCH c1 BULK COLLECT INTO l_recs LIMIT 50;  

      l_cnt := l_cnt + l_recs.COUNT;
      
      EXIT WHEN l_recs.COUNT = 0;
      
--      for i in 1 .. l_recs.count loop
--        dbms_output.put_line(i || ' ' || l_recs(i).contact_id);
--      end loop;
      
      FORALL i IN 1 .. l_recs.COUNT
        UPDATE contact_base 
           SET usedinestars = 0,
               updated = updated,
               updatedby = updatedby,
               audit_source = 'ORION-49860'
         WHERE contact_id = l_recs(i).contact_id
         ;
        
        --COMMIT;
rollback;
    END LOOP;
    CLOSE c1;
    
    dbms_output.put_line(l_cnt);
END;

---

-- Static update version 3

CREATE OR REPLACE PACKAGE ROION99999
IS
  -- ----------------------------------------------------------------------------
  --    Name: 
  -- Purpose: 
  --  Change: 
  -- ----------------------------------------------------------------------------
  PROCEDURE do;
END;
/
CREATE OR REPLACE PACKAGE BODY ROION99999
IS
  PROCEDURE do
  IS
    cv  SYS_REFCURSOR;

    TYPE t IS TABLE OF nightly_cae_assign%ROWTYPE;
    mytbl t;
  BEGIN
    -- Must use '*'
    OPEN cv FOR 'select * from nightly_cae_assign where rownum<9';
  
    LOOP
      FETCH cv BULK COLLECT INTO mytbl LIMIT 50;
      EXIT WHEN mytbl.count=0;
  
      FOR i IN 1..mytbl.count LOOP
        DBMS_OUTPUT.put_line(mytbl(i).account_site_id);
      END LOOP;
    END LOOP;
    --rc := SQL%ROWCOUNT; dbms_output.put_line('rows affected: ' || rc);
  END do;
END;

---

DECLARE
  l_cnt PLS_INTEGER := 0;

  CURSOR c1 IS
    select distinct c.contact_id
      from contact_base c, 
           event_contact ec,
           contact_opportunity co
     where c.created >= '01JAN2020'  -- "unless [contact] existed in our systems prior to 2020"
       and c.contact_ID = ec.contact_ID
       and c.contact_id = co.contact_id(+)
       and ec.event_id in (4345100, 4358090, 4387790, 4448790)  -- "[delete] contacts associated to Interaction IDs 4345100, 4358090, 4387790, 4448790"
       and co.opportunity_id is null  -- "or are attached to an opportunity"
       and ec.contact_id not in (  -- "or a lead with a priority of 'Hot'"
            select cae.contact_id
              from contact_activ_event cae, 
                   activity a 
             where a.activity_id = cae.activity_id
               and a.priority_int = 31 -- hot             
            )
and rownum<60  
     ;
    
  TYPE t1 IS TABLE OF c1%ROWTYPE;
  l_recs t1;
          
  BEGIN
    OPEN c1;
    LOOP
      FETCH c1 BULK COLLECT INTO l_recs LIMIT 50;  

      l_cnt := l_cnt + l_recs.COUNT;
      
      EXIT WHEN l_recs.COUNT = 0;
      
--      for i in 1 .. l_recs.count loop
--        dbms_output.put_line(i || ' ' || l_recs(i).contact_id);
--      end loop;
      
--      FORALL i IN 1 .. l_recs.COUNT
--        UPDATE contact_base 
--           SET usedinestars = 0,
--               updated = updated,
--               updatedby = updatedby,
--               audit_source = 'ORION-49860'
--         WHERE contact_id = l_recs(i).contact_id;
--        DELETE
--          FROM contact_base
--         WHERE contact_id = l_recs(i).contact_id;
        
--        COMMIT;

      for i in 1 .. l_recs.count loop
        dbms_output.put_line(i || ' : ' || l_recs(i).contact_id);
        --cdhub_jms.contact_drop_xrefs_jms_msg(contactid => l_recs(i).contact_id, remoteUser => 'carynt\essppt', supress_output => 1);
      end loop;
      
      for i in 1 .. l_recs.count loop
        dbms_output.put_line(i || ' ! ' || l_recs(i).contact_id);
        --exec set_contact_match_code(l_recs(i).contact_id);
      end loop;
      DBMS_OUTPUT.put_line('committing');
      COMMIT;
      
    END LOOP; --cursor
    CLOSE c1;
    
    dbms_output.put_line(l_cnt);
END;
