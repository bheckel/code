-- Created: 05-Jul-2023 (Bob Heckel)

---

-- Cursor

DECLARE
  CURSOR c1 IS
    select an.account_id, an.account_name_id,
           ana.account_name_type,
           xls.account_name_old, xls.account_name as account_name_new,
           ac.account_cdhub_id
      from account_name an, 
           account_name_attribute ana,
           ( select account_id, account_name_old, account_name from ATTACHMENT_TABLE_MACRO(11826131) ) xls,
           account_cdhub ac
     where an.account_name_id = ana.account_name_id
       and an.account_id = xls.account_id
       and an.account_name = xls.account_name_old
       and an.account_id = ac.account_cdhub_id(+)
       and ana.account_name_type='L'
  ;

  TYPE t1 IS TABLE OF c1%ROWTYPE;
  l_recs t1;
BEGIN
  OPEN c1;
    LOOP
      FETCH c1 BULK COLLECT INTO l_recs LIMIT 100;  
      EXIT WHEN l_recs.count = 0;

      FOR i IN 1 .. l_recs.COUNT LOOP
        IF l_recs(i).account_cdhub_id IS NOT NULL THEN
          CDHUB_REST.account_drop_xrefs_rest(p_accountid => l_recs(i).account_cdhub_id, p_remote_user => 'carynt\essppt', p_send_err_email => 0, p_suppress_output => 0);
          -- Lowering this pause caused a few "RAW HTTP Response: {"id":-1,"status":403,"messages":[{"type":"ERROR","summary":"Create Account in CDHub is not allowed.","developer":null,"detail":null}],"notifications":[]}"
          SYS.DBMS_SESSION.sleep(3);
        END IF;

        update account_name
           set account_name = l_recs(i).account_name_new, 
               updated = updated,
               updatedby = updatedby, 
               audit_source = 'MDMT-241'
         where account_name_id = l_recs(i).account_name_id
           and account_name = l_recs(i).account_name_old
        ;
        COMMIT;

        IF l_recs(i).account_cdhub_id IS NOT NULL THEN
          CDHUB_REST.account_save_rest(p_accountid => l_recs(i).account_cdhub_id, p_remote_user => 'carynt\essppt', p_send_err_email => 0, p_suppress_output => 0);
        END IF;

        ACCOUNT_ASSIGNMENTS.update_account_search(l_recs(i).account_id, p_ignoreaudit=>1);
        COMMIT;
      END LOOP;
    END LOOP;
  CLOSE c1;

EXCEPTION
  WHEN OTHERS THEN 
    DBMS_OUTPUT.put_line('Error: MDMT-241_data_change ' || SQLCODE || ':' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
    ROLLBACK;
END;
/

---

-- Open-For

DECLARE
  l_attachment  NUMBER := 0;
  l_sql VARCHAR2(32767);

  TYPE t_numberTable IS TABLE OF NUMBER;
  TYPE t_varchar2Table IS TABLE OF VARCHAR2(32767);
  l_account_id_tbl t_numberTable;
  l_account_name_id_tbl t_numberTable;
  l_account_name_old_tbl t_varchar2Table;
  l_account_name_new_tbl t_varchar2Table;
  l_account_cdhub_id_tbl t_numberTable;
  updateCursor SYS_REFCURSOR;
BEGIN
  l_sql := '
    select an.account_id, an.account_name_id,
           xls.account_name_old, xls.account_name as account_name_new,
           ac.account_cdhub_id
      from account_name an, 
           account_name_attribute ana,
           ( select account_id, account_name_old, account_name from ATTACHMENT_TABLE_MACRO(' || l_attachment || ') ) xls,
           account_cdhub ac
     where an.account_name_id = ana.account_name_id
       and an.account_id = xls.account_id
       and an.account_name = xls.account_name_old
       and an.account_id = ac.account_cdhub_id(+)
       and ana.account_name_type = ''L''
and rownum<3       
  ';

  l_attachment := 11826131;

  OPEN updateCursor for l_sql ;
    LOOP
      FETCH updateCursor BULK COLLECT INTO l_account_id_tbl,
                                           l_account_name_id_tbl,
                                           l_account_name_old_tbl,
                                           l_account_name_new_tbl,
                                           l_account_cdhub_id_tbl LIMIT 100;  

      EXIT WHEN l_account_id_tbl.count = 0;

      FOR i IN 1 .. l_account_id_tbl.COUNT LOOP
DBMS_OUTPUT.put_line('sysdae: ' || l_account_id_tbl(i) || ' ' || l_account_name_new_tbl(i));
--        IF l_recs(i).account_cdhub_id IS NOT NULL THEN
--          CDHUB_REST.account_drop_xrefs_rest(p_accountid => l_recs(i).account_cdhub_id, p_remote_user => 'carynt\essppt', p_send_err_email => 0, p_suppress_output => 0);
--          -- Lowering this pause caused a few "RAW HTTP Response: {"id":-1,"status":403,"messages":[{"type":"ERROR","summary":"Create Account in CDHub is not allowed.","developer":null,"detail":null}],"notifications":[]}"
--          SYS.DBMS_SESSION.sleep(3);
--        END IF;

--        update account_name
--           set account_name = l_recs(i).account_name_new, 
--               updated = updated,
--               updatedby = updatedby, 
--               audit_source = 'MDMT-241'
--         where account_name_id = l_recs(i).account_name_id
--           and account_name = l_recs(i).account_name_old
--        ;
        --COMMIT;
--        DBMS_OUTPUT.put_line('sys: ' || sql%rowcount);      

--        IF l_recs(i).account_cdhub_id IS NOT NULL THEN
--          CDHUB_REST.account_save_rest(p_accountid => l_recs(i).account_cdhub_id, p_remote_user => 'carynt\essppt', p_send_err_email => 0, p_suppress_output => 0);
--        END IF;

        --ACCOUNT_ASSIGNMENTS.update_account_search(l_recs(i).account_id, p_ignoreaudit=>1);
        --COMMIT;
      END LOOP;
    END LOOP;
  CLOSE updateCursor;

EXCEPTION
  WHEN OTHERS THEN 
    DBMS_OUTPUT.put_line('Error: MDMT-241_data_change ' || SQLCODE || ':' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
    ROLLBACK;
END;
/
