
CREATE OR REPLACE PACKAGE ORION37988 IS
  -- ----------------------------------------------------------------------------
  -- Author: Bob Heckel
  -- Date:   29-May-19
  -- ----------------------------------------------------------------------------
          
 failure_in_forall EXCEPTION;  
 PRAGMA EXCEPTION_INIT (failure_in_forall, -24381);  -- ORA-24381: error(s) in array DML  
 
 PROCEDURE do;
 PROCEDURE upd;

END;
/
CREATE OR REPLACE PACKAGE BODY ORION37988 IS

  PROCEDURE do IS
    BEGIN
      dbms_output.put_line('ok');
  END;

  PROCEDURE upd IS
    cnt NUMBER;
       
    CURSOR c IS
      SELECT rb.reference_id
        FROM reference_employee_base rb
       WHERE rb.territory_lov_id IN( SELECT t.territory_lov_id 
                                       FROM rs_ptg_territory_hierarchy t 
                                      WHERE upper(t.salesgroup) = 'SG' );  
    
    BEGIN
      cnt := 1;
       
      FOR rec IN c LOOP
        UPDATE reference_employee_base reb
           SET reb.employee_id = 999,
               reb.updatedby = 0
         WHERE reb.reference_id = rec.reference_id;
      
        dbms_output.put_line(rec.reference_id);

        cnt := cnt + 1;  

        IF (MOD(cnt, 100) = 0) THEN
          ROLLBACK;
          --COMMIT;
        END IF;
      END LOOP;

    -- So last group will commit
    ROLLBACK;
    --COMMIT;
  END upd;
END;
/

---

CREATE OR REPLACE PACKAGE BODY RION35058 IS

  PROCEDURE do IS
    rc pls_integer NULL;
    
    CURSOR c IS
      SELECT a.activity_id, a.contact_id, a.salesgroup
      FROM activity a
      WHERE a.contact_id=9999;
    
    BEGIN
      dbms_output.put_line('ok');
      
      -- Only for very small number of updates, otherwise see bulk_collect_forall.plsql
      FOR r IN c LOOP
        dbms_output.put_line(r.activity_id || ' ' || r.contact_id || ' ' || r.salesgroup);
        
        UPDATE activity
        SET salesgroup = 'TH'
        WHERE contact_id = r.contact_id;

      END LOOP;
     
      rc := SQL%ROWCOUNT; dbms_output.put_line('rows affected: ' || rc);
      
      COMMIT;
     
      IF ( rc IS NOT NULL ) THEN
        FOR r IN c LOOP
          dbms_output.put_line(r.activity_id);
          set_activ_match_code(r.activity_id);
          COMMIT;
        END LOOP;
      END IF;
  END do;

END;
