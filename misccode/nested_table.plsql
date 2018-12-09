-- See also associative_array_table_indexby.plsql, varray.plsql

DECLARE
	TYPE last_name_type IS TABLE OF student.last_name%TYPE;
  -- Initialized at the time of declaration, it's empty but not NULL
	last_name_tab last_name_type := last_name_type();

	i PLS_INTEGER := 0;

	CURSOR name_cur IS
		SELECT last_name FROM student WHERE rownum < 10;
BEGIN
	FOR rec IN name_cur LOOP
		i := i + 1;
		last_name_tab.EXTEND;
		last_name_tab(i) := rec.last_name;
    DBMS_OUTPUT.PUT_LINE ('last_name('||i||'): '||last_name_tab(i));
  END LOOP;
END;

---

/* You can compare nested table variables to the value NULL or to each other */

---

/* https://docs.oracle.com/database/121/LNPLS/composites.htm#LNPLS99981 */

-- Schema-level declaration is ok for nested tables, not associated arrays
DECLARE
  TYPE Roster IS TABLE OF VARCHAR2(15);  -- nested table type
 
  -- Initialized with constructor:
  names Roster := Roster('D Caruso', 'J Hamil', 'D Piro', 'R Singh');
 
  PROCEDURE print_names(heading VARCHAR2) IS
    BEGIN
      DBMS_OUTPUT.PUT_LINE(heading);
   
      FOR i IN names.FIRST .. names.LAST LOOP  -- For first to last element
        DBMS_OUTPUT.PUT_LINE(names(i));
      END LOOP;
   
      DBMS_OUTPUT.PUT_LINE('---');
    END;
  
BEGIN 
  print_names('Initial Values:');
 
  names(3) := 'P Perez';  -- Change value of one element
  print_names('Current Values:');
 
  names := Roster('A Jansen', 'B Gupta');  -- Change entire table
  print_names('Current Values:');
END;
/
