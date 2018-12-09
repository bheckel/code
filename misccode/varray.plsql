-- See also associative_array_table_indexby.plsql, nested_table.plsql

DECLARE
	TYPE last_name_type IS VARRAY(10) OF student.last_name%TYPE;
  -- Initialized at the time of declaration, it's empty but not NULL
	last_name_varr last_name_type := last_name_type();

	i PLS_INTEGER := 0;

	CURSOR name_cur IS
		SELECT last_name FROM student WHERE rownum < 10;
BEGIN
	FOR rec IN name_cur LOOP
		i := i + 1;
		last_name_varr.EXTEND;
		last_name_varr(i) := rec.last_name;
    DBMS_OUTPUT.PUT_LINE ('last_name('||i||'): '||last_name_varr(i));
  END LOOP;
END;

---

DECLARE

 iter NUMBER := 10;
 
BEGIN
 
  FOR i IN 1 .. iter LOOP 
    DECLARE

      rc NUMBER := 0;
      t1 timestamp;
      t2 timestamp;
      TYPE sup_arr IS VARRAY(6) OF NUMBER;
      sups sup_arr := sup_arr(615,111,1117,112,715,130);

    BEGIN 

      SELECT SYSTIMESTAMP INTO t1 FROM DUAL;

      FOR i IN 1..sups.COUNT LOOP
        dbms_output.put(i || ' ' || sups(i) || ' ');
        
        rc := SUP_HAS_ACTIVE_SITES_t2(sups(i));
        
        IF rc = 1 THEN
          dbms_output.put('true ');
        ELSE
          dbms_output.put('false ');
        END IF;
      END LOOP;
      
      SELECT SYSTIMESTAMP INTO t2 FROM DUAL;
      
      dbms_output.put_line(t2 - t1);
    END;
  END LOOP;
END;

---

/* You can compare varray variables to the value NULL or to each other */
/* Always dense */

DECLARE
  TYPE Foursome IS VARRAY(4) OF VARCHAR2(15);
  team Foursome := Foursome();  -- initialize to empty
 
  PROCEDURE print_team (heading VARCHAR2)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(heading);
 
    IF team.COUNT = 0 THEN
      DBMS_OUTPUT.PUT_LINE('Empty');
    ELSE 
      FOR i IN 1..4 LOOP
        DBMS_OUTPUT.PUT_LINE(i || '.' || team(i));
      END LOOP;
    END IF;
 
    DBMS_OUTPUT.PUT_LINE('---'); 
  END;
 
BEGIN
  print_team('Team:');
  team := Foursome('John', 'Mary', 'Alberto', 'Juanita');
  print_team('Team:');
END;
/
