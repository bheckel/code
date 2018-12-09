DECLARE

  rc BOOLEAN;
  t1 timestamp;
  t2 timestamp;

BEGIN 

  SELECT SYSTIMESTAMP INTO t1 FROM DUAL;
  
  rc := SUP_HAS_ACTIVE_SITES(2124);
--  rc := SUP_HAS_ACTIVE_SITES(930);
  
  IF rc THEN
    dbms_output.put_line('y');
  ELSE
    dbms_output.put_line('n');
  END IF;
  
  SELECT SYSTIMESTAMP INTO t2 FROM DUAL;
  
  dbms_output.put_line(t2 - t1);
END;
