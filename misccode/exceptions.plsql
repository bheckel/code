
-- error_code is an integer in the range -20000..-20999 and message is a character string of at most 2048 bytes

---

BEGIN
--ORA-0000: normal, successful completion
 dbms_output.put_line(SQLERRM(0));
--User-Defined Exception
 dbms_output.put_line(SQLERRM(1));
--ORA-01855: AM/A.M. or PM/P.M. required
 dbms_output.put_line(SQLERRM(-1855));
-- -1855: non-ORACLE exception
 dbms_output.put_line(SQLERRM(1855));
END;

---

-- Execution continues
DECLARE
  sal_calc NUMBER(8,2);
BEGIN
  INSERT INTO employees_temp (employee_id, salary, commission_pct)
  VALUES (301, 2500, 0);
 
  BEGIN
    SELECT (salary / commission_pct) INTO sal_calc
    FROM employees_temp
    WHERE employee_id = 301;
  EXCEPTION
    WHEN ZERO_DIVIDE THEN
      DBMS_OUTPUT.PUT_LINE('Substituting 2500 for undefined number.');  -- reaches
      sal_calc := 2500;
  END;
 
  INSERT INTO employees_temp VALUES (302, sal_calc/100, .1);
  DBMS_OUTPUT.PUT_LINE('Enclosing block: Row inserted.');  -- reaches
EXCEPTION
  WHEN ZERO_DIVIDE THEN 
    DBMS_OUTPUT.PUT_LINE('Enclosing block: Division by zero.');
END;
/

---

DECLARE 
   c_id customers.id%type := 8; 
   c_name customerS.Name%type; 
   c_addr customers.address%type; 
BEGIN 
   SELECT  name, address INTO  c_name, c_addr 
   FROM customers 
   WHERE id = c_id;  
   DBMS_OUTPUT.PUT_LINE ('Name: '||  c_name); 
   DBMS_OUTPUT.PUT_LINE ('Address: ' || c_addr); 

EXCEPTION 
   WHEN no_data_found THEN 
      dbms_output.put_line('No such customer!'); 
   WHEN others THEN 
      dbms_output.put_line(SQLCODE || ':' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
      -- Reraising the exception passes it to the enclosing block, which can handle it further
      RAISE;
END;

---

DECLARE 
   c_id customers.id%type := &cc_id; 
   c_name customerS.Name%type; 
   c_addr customers.address%type;  
   -- user defined exception 
   ex_invalid_id  EXCEPTION; 
BEGIN 
   IF c_id <= 0 THEN 
      RAISE ex_invalid_id; 
   ELSE 
      SELECT  name, address INTO  c_name, c_addr 
      FROM customers 
      WHERE id = c_id;
      DBMS_OUTPUT.PUT_LINE ('Name: '||  c_name);  
      DBMS_OUTPUT.PUT_LINE ('Address: ' || c_addr); 
   END IF; 

EXCEPTION 
   WHEN ex_invalid_id THEN 
      dbms_output.put_line('ID must be greater than zero!'); 
   WHEN no_data_found THEN 
      dbms_output.put_line('No such customer!'); 
   WHEN others THEN 
      dbms_output.put_line('Error!');  
END; 

---

-- Naming Internally Defined Exception
-- Things like NO_DATA_FOUND and TOO_MANY_ROWS have this predefined by the STANDARD package
DECLARE
  deadlock_detected EXCEPTION;
  -- ORA-00060 (deadlock detected while waiting for resource) 
  PRAGMA EXCEPTION_INIT(deadlock_detected, -60);
BEGIN
  ...
EXCEPTION
  WHEN deadlock_detected THEN
    ...
END;
/

---

CREATE PROCEDURE account_status (
  due_date DATE,
  today    DATE
) AUTHID DEFINER
IS
BEGIN
  IF due_date < today THEN  -- explicitly raise exception 
    RAISE_APPLICATION_ERROR(-20000, 'Account past due.');
  END IF;
END;
/
 
DECLARE
  past_due  EXCEPTION;                       -- declare exception
  PRAGMA EXCEPTION_INIT (past_due, -20000);  -- assign error code to exception
BEGIN
  account_status (TO_DATE('01-JUL-2010', 'DD-MON-YYYY'),
                  TO_DATE('09-JUL-2010', 'DD-MON-YYYY'));   -- invoke procedure

EXCEPTION
  WHEN past_due THEN                         -- handle exception
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(SQLERRM(-20000)));
END;
/

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
