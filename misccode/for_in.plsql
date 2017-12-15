set serveroutput on;

DECLARE
  num  tmpbobh.fooN1%TYPE;
  cnt  NUMBER;
  low  NUMBER := 65;
  hi   NUMBER;
BEGIN
  DBMS_OUTPUT.ENABLE;
  select fooN1 into num from tmpbobh where fooC1 = 'one';
  select count(*) into cnt from tmpbobh;
  hi := cnt + low;
  for i in low .. hi loop
    if num = i then
      DBMS_OUTPUT.PUT_LINE('found '||low||' '||hi||' '||cnt);
    end if;
  end loop;
END;
/



 /* Unrelated nesting example */

<<outer>>
FOR i IN 1..5 LOOP
   ...
   FOR j IN 1..10 LOOP
      FETCH c1 INTO emp_rec;
      EXIT outer WHEN c1%NOTFOUND;  -- exit both FOR loops
      ...
   END LOOP;
END LOOP outer;
-- control passes here
/
