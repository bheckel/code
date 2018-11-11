/* https://docs.oracle.com/database/121/LNPLS/composites.htm#LNPLS99969 */

/* You cannot compare associative array variables to the value NULL or to each other */

DECLARE
  -- Associative array indexed by string:
  
  TYPE population IS TABLE OF NUMBER  -- associative array type
    INDEX BY VARCHAR2(64);            --   indexed by string
  
  city_population  population;        -- associative array variable value e.g. 2000
  mykey  VARCHAR2(64);                -- scalar variable holds e.g. 'Smallville'
  
BEGIN
  -- Add elements (key-value pairs) to associative array:
  city_population('Smallville')  := 2000;
  city_population('Midland')     := 750000;
  city_population('Megalopolis') := 1000000;
 
  -- Change value associated with key 'Smallville':
  city_population('Smallville') := 2001;
 
  mykey := city_population.FIRST;  -- get first element of array
 
  WHILE mykey IS NOT NULL LOOP
    DBMS_Output.PUT_LINE('Population of ' || mykey || ' is ' || city_population(mykey));
    mykey := city_population.NEXT(mykey);  -- get next element of array
  END LOOP;
END;
/

---

/* You cannot declare an associative array type at schema level. Therefore, to
 * pass an associative array variable as a parameter to a standalone
 * subprogram, you must declare the type of that variable in a package
 * specification. Doing so makes the type available to both the invoked
 * subprogram (which declares a formal parameter of that type) and to the
 * invoking subprogram or anonymous block (which declares a variable of that
 * type).
 */
CREATE OR REPLACE PACKAGE aa_pkg AUTHID DEFINER IS
  TYPE aa_type IS TABLE OF INTEGER INDEX BY VARCHAR2(15);
END;
/

CREATE OR REPLACE PROCEDURE print_aa(aa aa_pkg.aa_type) AUTHID DEFINER IS
  i  VARCHAR2(15);
BEGIN
  i := aa.FIRST;
 
  WHILE i IS NOT NULL LOOP
    DBMS_OUTPUT.PUT_LINE (aa(i) || '  ' || i);
    i := aa.NEXT(i);
  END LOOP;
END;
/

DECLARE
  aa_var  aa_pkg.aa_type;
BEGIN
  /* Populate hash key/value pairs */
  aa_var('zero') := 0;
  aa_var('one') := 1;
  aa_var('two') := 2;

  print_aa(aa_var);
END;
/
