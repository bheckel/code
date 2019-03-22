-- See also associative_array_table_indexby.plsql, varray.plsql

-- Collection Methods:
-- EXISTS: This function returns TRUE if a specified element exists in a collection
--         and can be used to avoid raising SUBSCRIPT_OUTSIDE_LIMIT exceptions.
--         When you try to get an element at an undefined index value, Oracle raises NO_DATA_FOUND
--         but using EXISTS eliminates that possibility:
--         IF sons_t.EXISTS(index_in) THEN...
--         But you should avoid the FOR loop and instead opt for a WHILE loop
--         and the NEXT or PRIOR methods to help you navigate from one defined index value
--         to the next
-- COUNT: This function returns the total number of elements in a collection.
-- FIRST and LAST: These functions return subscripts of the first and last elements of
--       a collection. If the first element of a nested table is deleted, the FIRST method
--       returns a value greater than 1. If elements are deleted from the middle of a nested
--       table, the LAST method returns a value greater than the COUNT method.
-- PRIOR and NEXT: These functions return subscripts that precede and succeed a
--       specified collection subscript.
--
-- Not allowed with associative arrays:
-- EXTEND: This procedure increases the size of a collection.
-- TRIM: This procedure removes either one or a specified number of elements from
--       the end of a collection. PL/SQL does not keep placeholders for the trimmed
--       elements.
--
-- Not allowed with varrays:
-- DELETE: This procedure deletes either all elements, just the elements in the
--         specified range, or a particular element from a collection. PL/SQL keeps
--         placeholders of the deleted elements.
-- Only allowed with varrays:
-- LIMIT: Returns the maximum number of elements that a collection can contain

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

---

-- Query select from a nested table like it was a relational table (see also 
-- nested_table_multiset.plsql and bulk_collect_forall.plsql)
DECLARE
  l_numbers1   numbers_t := numbers_t(1 , 2 , 3 , 4 , 5);
  l_numbers2   numbers_t := numbers_t(1 , 2 , 3 , NULL);
  l_numbers3   numbers_t := numbers_t();
    
  CURSOR cv is SELECT COLUMN_VALUE FROM TABLE(l_numbers1)
							 UNION
							 SELECT COLUMN_VALUE FROM TABLE(l_numbers2);
BEGIN
  FOR r IN cv LOOP
    dbms_output.put_line(r.column_value);
  END LOOP;
END;
