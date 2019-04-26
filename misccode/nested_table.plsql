-- Modified: Tue 23 Apr 2019 10:29:17 (Bob Heckel)
-- nested_table.plsql (symlinked as collections.plsql) see also 
-- associative_array_table_indexby.plsql, varray.plsql, nested_table_multiset.plsql

-- Collection Methods:
-- EXISTS: Returns TRUE if a specified element exists in a collection
--         and can be used to avoid raising SUBSCRIPT_OUTSIDE_LIMIT exceptions.
--         When you try to get an element at an undefined index value, Oracle raises NO_DATA_FOUND
--         but using EXISTS eliminates that possibility:
--         IF sons_t.EXISTS(index_in) THEN...
--         But you should avoid the FOR loop and instead opt for a WHILE loop
--         and the NEXT or PRIOR methods to help you navigate from one defined index value
--         to the next
-- COUNT: Returns the total number of elements in a collection.
-- FIRST and LAST: Return subscripts of the first and last elements of
--       a collection. If the first element of a nested table is deleted, the FIRST method
--       returns a value greater than 1. If elements are deleted from the middle of a nested
--       table, the LAST method returns a value greater than the COUNT method.
-- PRIOR and NEXT: These functions return subscripts that precede and succeed a
--       specified collection subscript.
--
-- Methods not allowed with associative arrays:
-- EXTEND: Increases the size of a collection.
-- TRIM: Removes either one or a specified number of elements from
--       the end of a collection. PL/SQL does not keep placeholders for the trimmed elements.
--
-- Methods not allowed with varrays:
-- DELETE: deletes either all elements, just the elements in the
--         specified range, or a particular element from a collection. PL/SQL keeps
--         placeholders of the deleted elements.
-- Methods only allowed with varrays:
-- LIMIT: Returns the maximum number of elements that a collection can contain

-- You can compare nested table variables to the value NULL or to each other
-- see nested_table_multiset.plsql

---

DECLARE
	TYPE last_name_type IS TABLE OF student.last_name%TYPE;
  -- Uninitialized at the time of declaration, it's NULL so this is ok:  IF last_name_tab IS NULL...
	/* last_name_tab last_name_type; */
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

/* https://docs.oracle.com/database/121/LNPLS/composites.htm#LNPLS99981 */

-- Schema-level declaration is ok for nested tables, not associated arrays
DECLARE
  TYPE Roster_ntt IS TABLE OF VARCHAR2(15);  -- nested table type
 
  -- Initialized with constructor:
  names Roster_ntt := Roster_ntt('D Caruso', 'J Hamil', 'D Piro', 'R Singh');
 
  PROCEDURE print_names(heading VARCHAR2) IS
    BEGIN
      DBMS_OUTPUT.PUT_LINE(heading);
   
      FOR i IN names.FIRST .. names.LAST LOOP  -- first (i=1) to last (i=4) element
        DBMS_OUTPUT.PUT_LINE(names(i));
      END LOOP;
   
      DBMS_OUTPUT.PUT_LINE('---');
    END;
  
BEGIN 
  print_names('Initial Values:');
 
  names(3) := 'P Perez';  -- change value of one element
  print_names('Current Values:');
 
  names := Roster_ntt('A Jansen', 'B Gupta');  -- change entire table
  print_names('Current Values:');
END;
/
