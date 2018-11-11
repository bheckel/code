-- Avoid clumsy IF statements such as:

IF new_balance < minimum_balance THEN
  overdrawn := TRUE;
ELSE
  overdrawn := FALSE;
END IF;

-- Instead, assign the value of the BOOLEAN expression directly to a BOOLEAN variable:

overdrawn := new_balance < minimum_balance;


---

IF v_can_update = TRUE THEN
  dbms_output.put_line('account ' || in_account_id || 'is deletable');
  RETURN TRUE;
ELSIF v_can_update = FALSE THEN
  dbms_output.put_line('account ' || in_account_id || 'not deletable');
  RETURN FALSE;
ELSE 
  dbms_output.put_line('account ID not found');
  RETURN FALSE;
END IF;
