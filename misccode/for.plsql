-- Any kind of FOR loop is saying, implicitly, “I am going to execute the loop
-- body for all iterations defined by the loop header” (N through M or SELECT).
-- Conditional exits mean the loop could terminate in multiple ways, resulting in
-- code that is hard to read and maintain.  Use a WHILE loop instead.
DECLARE
   CURSOR plch_parts_cur
   IS
      SELECT * FROM plch_parts;
BEGIN
   FOR rec IN plch_parts_cur
   LOOP
      DBMS_OUTPUT.put_line (rec.partname);
   END LOOP;
END;
/
--Better if you only use the "cursor" once
BEGIN
   FOR rec IN (SELECT * FROM plch_parts)
   LOOP
      DBMS_OUTPUT.put_line (rec.partname);
   END LOOP;
END;
/



DECLARE
  v_lower  NUMBER := 1;
  v_upper  NUMBER := 1;
BEGIN
  FOR i IN v_lower .. v_upper LOOP
    INSERT INTO foo (ordid, itemid) VALUES (v_ordid, i);
  END LOOP;
END;

