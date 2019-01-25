CREATE OR REPLACE PACKAGE BODY ORION35058 IS

  PROCEDURE do IS
    rc pls_integer NULL;
    
    CURSOR c IS
      SELECT a.activity_id, a.contact_id, a.salesgroup
      FROM activity a
      WHERE a.contact_id=9999;
    
    BEGIN
      dbms_output.put_line('ok');
      
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

END ORION35058;
