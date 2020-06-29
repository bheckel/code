--https://docs.oracle.com/database/121/LNPLS/dynamic.htm#LNPLS01108

CREATE PROCEDURE calc_stats(w NUMBER, x NUMBER, y NUMBER, z NUMBER) IS
BEGIN
  DBMS_OUTPUT.PUT_LINE(w + x + y + z);
END;
/
DECLARE
  a NUMBER := 4;
  b NUMBER := 7;
  plsql_block VARCHAR2(100);
BEGIN
  plsql_block := 'BEGIN calc_stats(:x, :x, :y, :x); END;';
  EXECUTE IMMEDIATE plsql_block USING a, b;  -- calc_stats(a, a, b, a)
END;
/
DROP PROCEDURE calc_stats;

---

CREATE OR REPLACE PROCEDURE update_reference_owner IS

	TYPE numberTable IS TABLE OF NUMBER;

	referenceIdTable numberTable;
	referenceEmployeeIdTable numberTable;
	v_new_owner number := 9999 ;

	BEGIN
											
		EXECUTE IMMEDIATE 'select r.reference_id, re.reference_employee_id
													from reference r,
															 REFERENCE_EMPLOYEE_BASE re,
															 opportunity_employee    oe,
															 list_of_values          l
												 where r.reference_id = re.reference_id
													 and r.opportunity_id = oe.opportunity_id
													 and r.SALESGROUP = ''SA''
													 and re.employee_id ^= :1'
										BULK COLLECT INTO referenceIdTable, referenceEmployeeIdTable
										USING v_new_owner;  

		FOR i IN 1 .. referenceIdTable.COUNT LOOP
			BEGIN 
			 UPDATE reference_employee_base re2
					SET re2.EMPLOYEE_ID = v_new_owner,
							re2.UPDATED     = re2.UPDATED,
							re2.UPDATEDBY   = re2.UPDATEDBY
				WHERE re2.REFERENCE_EMPLOYEE_ID = referenceEmployeeIdTable(i);
					 
			 set_ref_match_code(referenceIdTable(i),1); 
				 
			 DBMS_OUTPUT.put_line('Owner changed for Reference ID: ' || referenceIdTable(i) );

		
			 EXCEPTION
				 /* If there is another row with the current reference_id / employee_id, delete it
					*  and re-do the update
					*/
				 WHEN OTHERS THEN
					 IF (SQLERRM LIKE '%REFERENCE_EMPLOYEE_RE_U_IX%') THEN
						 
						 DELETE FROM reference_employee_base 
							WHERE reference_id = referenceIdTable(i)
								AND employee_id = v_new_owner;
						
						 UPDATE reference_employee_base re2
								SET re2.EMPLOYEE_ID = v_new_owner,
										re2.territory_lov_id = null,
										re2.UPDATED     = re2.UPDATED,
										re2.UPDATEDBY   = re2.UPDATEDBY
							WHERE re2.REFERENCE_EMPLOYEE_ID = referenceEmployeeIdTable(i);
							
							DBMS_OUTPUT.put_line('RE_DO for Ref ID: ' || referenceIdTable(i) );
			
					END IF;
			 END; 
		END LOOP;

		COMMIT; 
END update_reference_owner;

---

EXCEPTION
WHEN OTHERS THEN
  errMsg := SQLERRM;
  ROLLBACK;
  EXECUTE IMMEDIATE 'insert into ACCOUNT_TRANSFORMATION_LOG  VALUES (:1, :2, :3)'
    USING rec.account_id, 'Add New Account Error: ' || errMsg, SYSDATE;
  COMMIT;                        
END;
