-- Cursor approach
DECLARE
  CURSOR in_account_table IS
    SELECT to_number(TRIM(regexp_substr(accounts, '[^,]+', 1, LEVEL))) AS account_id
    FROM (SELECT '123,456' AS accounts FROM dual)
    CONNECT BY regexp_substr(accounts, '[^,]+', 1, LEVEL) IS NOT NULL;
BEGIN
  FOR rec IN in_account_table LOOP
    dbms_output.put_line(rec.account_id);
  END LOOP;
END;

---

-- Collection approach
DECLARE
  in_varchar2 VARCHAR2(4000) := '123,456';
  delimiter   VARCHAR2(1)    := ',';

	start_pos  NUMBER := 1;
	end_pos    NUMBER;
	numElement NUMBER;
	end_loop   BOOLEAN;

  TYPE numberTable is table of number;
  numTable numberTable;

BEGIN
	numTable := numberTable();

	LOOP
		end_loop := FALSE;
		end_pos  := instr(in_varchar2, delimiter, start_pos);

		IF (end_pos = 0) THEN
			end_pos  := length(in_varchar2) + 1;
			end_loop := TRUE;
		END IF;

		numElement := TO_NUMBER(substr(in_varchar2,
																	 start_pos,
																	 end_pos - start_pos));

		start_pos := end_pos + 1;

		numTable.extend(1);
		numTable(numTable.COUNT) := numElement;

		EXIT WHEN end_loop;
	END LOOP;

  FOR i IN 1 .. numTable.COUNT LOOP
    dbms_output.put_line(numTable(i));
  END LOOP;
END;

