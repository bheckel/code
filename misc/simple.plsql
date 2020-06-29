
CREATE OR REPLACE PACKAGE ORION34461 IS

  PROCEDURE upd;

END ORION34461;
/
CREATE OR REPLACE PACKAGE BODY ORION34461 IS

  PROCEDURE upd IS
    BEGIN
    
    UPDATE reference_employee
    SET employee_id=47150 
    WHERE employee_id = 45449 AND territory_lov_id IN(5599160, 5632630, 5632640);

    COMMIT;
    
    FOR r in ( SELECT *
               FROM reference_base r
               WHERE r.reference_id IN(SELECT reference_id FROM reference_employee WHERE employee_id IN( 45449,47150) AND territory_lov_id IN(5599160, 5632630, 5632640)) )
      LOOP
      dbms_output.put_line(r.reference_id);
    END LOOP;

  END upd;

END ORION34461;
/
