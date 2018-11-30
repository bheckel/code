
CREATE OR REPLACE TYPE strings_ntt IS TABLE OF VARCHAR2 (100);
/

CREATE OR REPLACE PACKAGE tf
IS
   FUNCTION queryme(count_in IN INTEGER) RETURN strings_ntt;
END;
/

CREATE OR REPLACE PACKAGE BODY tf
IS
   FUNCTION queryme(count_in IN INTEGER) RETURN strings_ntt
   IS

   stringx strings_ntt := strings_ntt();
   
   BEGIN
     FOR i IN 1 .. count_in LOOP
       stringx.EXTEND();
       stringx(i) := 'abc';
     END LOOP;
    
    RETURN stringx;
   END;
END;
/

SELECT COLUMN_VALUE my_string FROM TABLE (tf.queryme(5))
/

---

/* https://docs.oracle.com/database/121/LNPLS/composites.htm#LNPLS99981 */

/* You can compare nested table variables to the value NULL or to each other */

DECLARE
  TYPE Roster IS TABLE OF VARCHAR2(15);  -- nested table type
 
  -- nested table variable initialized with constructor:
 
  names Roster := Roster('D Caruso', 'J Hamil', 'D Piro', 'R Singh');
 
  PROCEDURE print_names (heading VARCHAR2) IS
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
