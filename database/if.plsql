-- Modified: Tue 14-Jan-2020 (Bob Heckel)

-- See also case.plsql

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

---

IF TO_CHAR (SYSDATE, 'DY') IN ('SAT', 'SUN') THEN
  l_day_type := 'Weekend';
ELSE
  l_day_type := 'Weekday';
END IF;

-- better, all in one statement
l_day_type :=
  CASE
    WHEN TO_CHAR (SYSDATE, 'DY') IN ('SAT', 'SUN') THEN 'Weekend'
    ELSE 'Weekday'
  END;

---

-- Avoid clumsy IF statements such as:

IF new_balance < minimum_balance THEN
  overdrawn := TRUE;
ELSE
  overdrawn := FALSE;
END IF;

-- Instead, assign the value of the BOOLEAN expression directly to a BOOLEAN variable:

overdrawn := new_balance < minimum_balance;

---

if x in(1,2,3) then
  ...
end if;
