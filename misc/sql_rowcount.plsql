
IF (SQL%ROWCOUNT = 0) THEN
	DBMS_OUTPUT.put_line('    No addition of TSR owner to risk - ' ||
											 riskAccountRec.tsr_owner ||
											 ' already there...');
ELSE
	rowsChanged := rowsChanged + SQL%ROWCOUNT;
	DBMS_OUTPUT.put_line('    Adding TSR owner ' ||
											 riskAccountRec.tsr_owner ||
											 ' to risk...');
END IF;
