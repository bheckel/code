/* Adapted: Tue, Nov  6, 2018  2:47:03 PM */
PROCEDURE RUN_ALL_TESTS(toAddressOverride IN VARCHAR2 default null) is
	msgSubject VARCHAR2(100) := 'Unit testing on ' || SYS_CONTEXT('USERENV', 'DB_UNIQUE_NAME');
	msg        VARCHAR2(32767);

	CURSOR c IS
		select *
			from user_procedures p
		 where procedure_name like 'RUN%'
			 and object_name = 'UNIT_TESTING'
			 and procedure_name != 'RUN_ALL_PROCEDURES';
begin

	-- Call all procedures in this package that start with RUN%
	FOR proc IN c LOOP
		execute immediate 'begin UNIT_TESTING.' ||
											proc.procedure_name || '(:1); end;'
			USING IN OUT msg;
	END LOOP;

	IF (length(msg) > 0) THEN
    dbms_output.put_line('done ' || msgSubject || ' ' || msg);
	END IF;
end RUN_ALL_TESTS;
