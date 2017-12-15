-- 2006-11-20 does not work.  See for.plsql

CREATE OR REPLACE PROCEDURE do_insert AS
DECLARE
  v_fooc1  tmpbobh.fooc1%TYPE := 'test';
  v_n  number := 1;
BEGIN 
  LOOP
    INSERT INTO tmpbobh(foon1, fooc1) VALUES (v_n, v_fooc1);
	v_n := v_n+1;
	EXIT WHEN v_n > 5; 
  END LOOP;
END;
/	
