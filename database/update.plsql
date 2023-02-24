
-- Created: 09-Feb-2019 (Bob Heckel)
-- Modified: 23-Feb-2023 (Bob Heckel)

---

DECLARE
  BEGIN
    FOR rec IN ( select gl_date from kmc_override where gl_date is not null and rownum<999 ) LOOP
      DBMS_OUTPUT.put_line(rec.gl_date);
      /*update kmc_revenue_full set gl_date_ovr = rec.gl_date where gl_date_ovr is null;*/
    END LOOP;
  --COMMIT;
  rollback;
END;

---

-- Simple update < 5 records so no bulk collecting
PROCEDURE SYNC_SG_COUNTRY_NAMES(reportAll NUMBER) IS
	proc_name varchar2(200) := ' <B>SYNC_SG_COUNTRY_NAMES</B> Procedure<P>';
	rowsChanged PLS_INTEGER := 0;

	CURSOR c1 IS
		SELECT lov.value_description, lov.value, sg.code, sg.country_name
		FROM 
		 (select lov.value_description, lov.value
		 from list_of_values lov, custom_list cl, custom_level_list cll
		 where cl.list_name = 'Country'
		 and cll.custom_list_id = cl.custom_list_id
		 and lov.list_of_values_id = cll.list_of_values_id) lov
		LEFT JOIN 
		 (select salesgroup, code, country_name
		 from salesgroup_country) sg ON lov.value=sg.code
		WHERE DECODE(value_description, country_name, 0, 1) = 1 AND (value_description is NOT NULL AND country_name IS NOT NULL)
		;
					
	BEGIN
	
		-- Not bulk collecting because daily updates will usually be minimal or zero
		FOR l_rec IN c1 LOOP
			dbms_output.put_line('ok '||l_rec.value_description);
			
			UPDATE Zsalesgroup_country
				 SET country_name = l_rec.value_description -- e.g. should be LOV 'Bosnia and Herzegovina' not 'Bosnia-Herzegovina'
			 WHERE code = l_rec.value -- 'BA'
			;

			rowsChanged := rowsChanged + SQL%ROWCOUNT;
							
			COMMIT;
		END LOOP;

	IF ((rowsChanged > 0) AND (reportAll = 1)) THEN
		dbms_output.put_line('ok2 '||proc_name|| ' ' ||rowsChanged);
	END IF;

END SYNC_SG_COUNTRY_NAMES;

---

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

---

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
