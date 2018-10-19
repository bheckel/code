DECLARE
 l_now DATE;
BEGIN 
  dbms_output.put_line('ok1 wait 10 seconds');
  SELECT sysdate INTO l_now FROM DUAL; LOOP EXIT WHEN l_now +(10 * (1 / 86400)) = sysdate; END LOOP;
  dbms_output.put_line('ok2');
END;
