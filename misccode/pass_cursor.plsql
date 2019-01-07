DECLARE
   cv   sys_refcursor;  -- weak REF CURSOR type can be used in an OPEN FOR statement with either a static or dynamic SQL statement
BEGIN
   -- Dynamic works for weak or strong
   OPEN cv FOR 'select * from SYS.dual';
   CLOSE cv;

   -- Static works for weak only
   OPEN cv FOR SELECT * FROM SYS.dual;
   CLOSE cv;
END;

---

FUNCTION pass_cursor RETURN sys_refcursor
  IS
    l_contactCursor SYS_REFCURSOR;
  BEGIN
    OPEN l_contactCursor FOR q'[SELECT contact_id, gonereason FROM base c WHERE ROWNUM <10]';
    RETURN l_contactCursor;
END;


PROCEDURE print_cursor IS
  gonereason BOOLEAN;
  l_contact_id NUMBER;
  l_gonereason NUMBER;
  l_c SYS_REFCURSOR;  -- weakly typed
   
  BEGIN
    l_c := pass_cursor();
    LOOP
      FETCH l_c INTO l_contact_id, l_gonereason;
      gonereason := (l_gonereason = 0);
      IF gonereason THEN
        DBMS_OUTPUT.PUT_LINE ('not gone: ' || l_contact_id);
      ELSE
        DBMS_OUTPUT.PUT_LINE ('gone: ' || l_contact_id); 
      END IF;
      EXIT WHEN l_c%NOTFOUND;
    END LOOP;
END;
