-- ----------------------------------------------------------------------------
-- Author:   Bob Heckel (boheck)
-- Date:     09-Nov-18
-- Usage:    Accept a comma delimited list of account ids, parse that string, 
--           then call SET_DNB_AS_INPUTSOURCE for each
-- JIRA:     ORION-33395
-- ----------------------------------------------------------------------------
PROCEDURE SET_DNB_AS_INPUTSOURCE_MULTIX(in_account_ids IN VARCHAR2, in_send_email BOOLEAN DEFAULT TRUE, request_id IN VARCHAR2 DEFAULT NULL) IS
	employee_id NUMBER;
	user_email VARCHAR(256)  := NULL;
	email_body VARCHAR(4000) := NULL;
	
	CURSOR acct_c IS
		SELECT to_number(TRIM(regexp_substr(accounts, '[^,]+', 1, LEVEL))) AS account_id
		FROM (SELECT in_account_ids AS accounts FROM dual)
		CONNECT BY regexp_substr(accounts, '[^,]+', 1, LEVEL) IS NOT NULL;

	CURSOR msg_c IS 
		SELECT msg, execute_time 
		FROM USER_ONCALL_RESULTS t 
		WHERE t.execute_user=employee_id AND t.execute_time >= (SYSTIMESTAMP - INTERVAL '1000' minute);  -- DEBUG
			
	TYPE msg_tbl_type IS TABLE OF msg_c%ROWTYPE;
	msg_tbl msg_tbl_type;
	
	BEGIN
		SELECT eb.email, eb.employee_id
		INTO user_email, employee_id
		FROM employee_base eb
		WHERE eb.employee_id = sys_context('setars_context', 'employee_id');
		
		-- Exceptions should be caught and processing should continue for all account_ids in the string, if one call fails, keep going, and just return the failure for that account as part of the messages emailed.
		FOR acct IN acct_c LOOP
			-- user_on_call.SET_DNB_AS_INPUTSOURCE(in_account_ids); --1814776
--COMMIT;  -- DEBUG
dbms_output.put_line(acct.account_id);  -- DEBUG
		END LOOP;

		-- Email the results to the person who made the call
		OPEN msg_c;
		LOOP
			FETCH msg_c BULK COLLECT INTO msg_tbl;
			EXIT WHEN msg_tbl.count =0;
			 
			FOR i IN 1 .. msg_tbl.count LOOP
				email_body := email_body || msg_tbl(i).execute_time || ': ' || msg_tbl(i).msg || '<BR>';
			END LOOP;
		END LOOP;
		CLOSE msg_c;

		IF in_send_email THEN
			e_mail_message('replies-disabled@as.com', user_email, 'Results of your SET_DNB_AS_INPUTSOURCE Task', email_body);
		END IF;
 dbms_output.put_line(email_body);  -- DEBUG
END SET_DNB_AS_INPUTSOURCE_MULTIX;

---

/* https://docs.oracle.com/database/121/LNPLS/composites.htm#LNPLS99981 */

/* You can compare nested table variables to the value NULL or to each other */

DECLARE
  TYPE Roster IS TABLE OF VARCHAR2(15);  -- nested table type
 
  -- nested table variable initialized with constructor:
 
  names Roster := Roster('D Caruso', 'J Hamil', 'D Piro', 'R Singh');
 
  PROCEDURE print_names (heading VARCHAR2) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(heading);
 
    FOR i IN names.FIRST .. names.LAST LOOP  -- For first to last element
      DBMS_OUTPUT.PUT_LINE(names(i));
    END LOOP;
 
    DBMS_OUTPUT.PUT_LINE('---');
  END;
  
BEGIN 
  print_names('Initial Values:');
 
  names(3) := 'P Perez';  -- Change value of one element
  print_names('Current Values:');
 
  names := Roster('A Jansen', 'B Gupta');  -- Change entire table
  print_names('Current Values:');
END;
/
