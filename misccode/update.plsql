
create or replace package body ORION32721 is
  /*
  CREATE TABLE zorion32721 AS
    SELECT ref_corporate_initiative_id,
           corporate_initiative,
           CASE WHEN corporate_initiative = 'Viay' THEN 'Viay (Analytics Platform)'
                WHEN corporate_initiative = 'Other - Academics' THEN 'Other'
                --ELSE 'Mid-Market Channel'
           END AS corporate_initiative_fixed
     FROM REF_CORPORATE_INITIATIVE WHERE corporate_initiative NOT IN( 'Analytics', 'IoT', 'Viay (Analytics Platform)', 'Non-Viay SAS Platform', 'Artificial Intelligence', 'Fraud', 'Risk', 'Customer Intelligence', 'Data Management', 'Mid-Market Channel', 'Partners', 'Cloud', 'Data for Good', 'Academic Outreach', 'Other')
  */
      
  PROCEDURE upd IS
    TYPE ref_t IS TABLE OF zorion32721%ROWTYPE;
    
    l_refs ref_t;
    rc PLS_INTEGER;
    
    BEGIN  
    
      SELECT * BULK COLLECT INTO l_refs
      FROM zorion32721
      ;
      
      /* Expecting around 15 updates so no periodic COMMITs, LIMIT etc. needed */
      FOR i IN 1 .. l_refs.COUNT LOOP
        dbms_output.put_line(l_refs(i).ref_corporate_initiative_id || ' ' || l_refs(i).corporate_initiative || ' ' || l_refs(i).corporate_initiative_fixed);

        UPDATE REF_CORPORATE_INITIATIVE
           SET corporate_initiative = l_refs(i).corporate_initiative_fixed,
               updated = SYSDATE,
               updatedby = cast(sys_context('tars_context', 'actual_employee_id') AS NUMBER)
        WHERE ref_corporate_initiative_id = l_refs(i).ref_corporate_initiative_id
        ;
          
      END LOOP;
      
      rc := SQL%ROWCOUNT;
      dbms_output.put_line(rc || ' rows affected');
      
      --MAINT.logdatachange(0, 'ORION-32721', 'N/A', 'N/A', SYSDATE, 0);

  END;
  
  
  PROCEDURE upd_test IS
    BEGIN

      FOR rec IN ( select * FROM REF_CORPORATE_INITIATIVE WHERE ref_corporate_initiative_id IN (SELECT ref_corporate_initiative_id FROM zorion32721) ) LOOP
        dbms_output.put_line('BEFORE: ' || rpad(rec.ref_corporate_initiative_id,10,' ') || ' ' || rec.corporate_initiative || ' updated: ' || rec.updated || ' updatedby: ' || rpad(rec.updatedby,8,' '));
      END LOOP;
            
      upd;
 
      FOR rec IN ( select * FROM REF_CORPORATE_INITIATIVE WHERE ref_corporate_initiative_id IN (SELECT ref_corporate_initiative_id FROM zorion32721) ) LOOP
        dbms_output.put_line(' AFTER: ' || rpad(rec.ref_corporate_initiative_id,10,' ') || ' ' || rec.corporate_initiative || ' updated: ' || rec.updated || ' updatedby: ' || rpad(rec.updatedby,8,' '));
      END LOOP;
      
      ROLLBACK;
      --COMMIT;
  
  END;
end ORION32721;


---


EXECUTE IMMEDIATE 'update ref_corporate_initiative set corporate_initiative = ''Customer Intelligence'' where corporate_initiative = ''CI''';
COMMIT;


---


DECLARE
  l_employee  omag_employees%ROWTYPE;
BEGIN
  l_employee.employee_id := 500;
  l_employee.last_name := 'Mondrian';
  l_employee.salary := 2000;
  UPDATE omag_employees
     SET ROW = l_employee
   WHERE employee_id = 100;
END;

