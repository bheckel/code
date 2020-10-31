
-- See also nested_table.plsql, varray.plsql

CREATE TABLE my_family (str VARCHAR2(100),name VARCHAR2 (100));
INSERT INTO my_family VALUES ('foo1','Veva'); 
INSERT INTO my_family VALUES ('foo2','Steven'); 
INSERT INTO my_family VALUES ('foo3','Eli'); 
INSERT INTO my_family VALUES (null,'xEli'); 
COMMIT; 

-- Load a string-keyed hash of strings
declare
  type myaa_t is table of varchar2(99) index by varchar2(99);
  myaa myaa_t;
  
  begin
		for r in ( select * from my_family ) loop
			myaa(r.str) := r.name;
		end loop;

   dbms_output.put_line(myaa('foo1')); -- Veva
 end;


-- Load hash with a cursor column.  See also pass_cursor.plsql
DECLARE 
   i integer := 0; 

   CURSOR c is select name from my_family; 

   TYPE myaa_t IS TABLE of my_family.Name%TYPE INDEX BY binary_integer; 
   myaa myaa_t; 
BEGIN 
  FOR rec IN c LOOP 
    i := i + 1; 
    myaa(i) := rec.name; 
    dbms_output.put_line('Name('||i||'):' || myaa(i)); 
  END LOOP; 
END;


-- Load hash with a db table
DECLARE 
   i integer := 0; 

   --CURSOR c is select name, str from my_family; 

   TYPE myaa_t IS TABLE of my_family%ROWTYPE INDEX BY binary_integer; 
   myaa myaa_t; 
BEGIN 
   --FOR rec IN c LOOP 
  FOR rec IN ( select name, str from my_family ) LOOP 
    i := i + 1; 

    myaa(i).name := rec.name; 
    dbms_output.put_line('Name('||i||'):' || myaa(i).name); 

    myaa(i).str := rec.str; 
    dbms_output.put_line('Str('||i||'):' || myaa(i).str); 
  END LOOP; 
END;

-- Compare (better only if small result set): load nested table with a db table
DECLARE 
  TYPE mynt_t IS TABLE of my_family%ROWTYPE; 
  mynt mynt_t; 
BEGIN 
	select * bulk collect into mynt from my_family;
  
  FOR i in 1..mynt.COUNT LOOP 
    dbms_output.put_line('Name('||i||'):' || mynt(i).name); 

    dbms_output.put_line('Str('||i||'):' || mynt(i).str); 
  END LOOP; 
END;

-- Compare (better for loading large amounts of data) load nested table with a db table
DECLARE 
  TYPE mynt_t IS TABLE of my_family%ROWTYPE; 
  mynt mynt_t; 
  cursor c is select * from my_family;
BEGIN 
  open c;
  loop fetch c bulk collect into mynt limit 2;
    exit when mynt.count = 0;
    FOR i in 1..mynt.COUNT LOOP 
      dbms_output.put_line('Name('||i||'):' || mynt(i).name); 
      dbms_output.put_line('Str('||i||'):' || mynt(i).str); 
    END LOOP; 
  end loop;
  close c;
END;

---

-- Load hash with a query:
PROCEDURE do IS
	TYPE numtbl IS TABLE OF VARCHAR2(4000) INDEX BY PLS_INTEGER;
	mytbl numtbl;
	i NUMBER := 0;
	
	BEGIN 
		FOR r IN (
			select regexp_substr(s, '.{5}', 1, lvl) chunk
				from (select s, level lvl 
								from (select '00000111112222233333' s from dual) 
							connect by level <= length(s) / 5)
			 ) LOOP
			i := i+1;
			mytbl(i) := r.chunk;
			dbms_output.put_line(mytbl(i));
		END LOOP;
END do;

---

DECLARE
	TYPE last_name_type IS TABLE OF student.last_name%TYPE INDEX BY PLS_INTEGER;
  -- NO CONSTRUCTOR like other collection types - empty by default
	last_name_tab last_name_type;
	i PLS_INTEGER := 0;

	CURSOR name_cur IS
		SELECT last_name FROM student WHERE rownum < 10;
BEGIN
	FOR rec IN name_cur LOOP
		i := i + 1;
		last_name_tab(i) := rec.last_name;
		DBMS_OUTPUT.PUT_LINE('last_name(' || i || '): ' || last_name_tab(i));
	END LOOP;
END;

---

/* https://docs.oracle.com/database/121/LNPLS/composites.htm#LNPLS99969 */
/* You cannot compare associative array variables to the value NULL or to each other */
DECLARE
  -- Associative array indexed by string:
  
  TYPE population IS TABLE OF NUMBER  -- associative array type
    INDEX BY VARCHAR2(64);            --   indexed by string
  
  city_population  population;        -- associative array variable value e.g. 2000
  mykey  VARCHAR2(64);                -- scalar variable to hold e.g. 'Smallville'
  
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

/* You CANNOT declare an associative array type at schema level. Therefore, to
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

---

DECLARE
  TYPE R_TARGET IS RECORD(
    COMP_EMP_TARGET_ID            COMP_EMP_TARGET_BASE.COMP_EMP_TARGET_ID%TYPE,
    EMPLOYEE_ID                   COMP_EMP_TARGET_BASE.EMPLOYEE_ID%TYPE,
    PERCENT_ATTAINMENT_DATE       CHAR(6));

  TYPE T_TARGET_TABLE IS TABLE OF R_TARGET INDEX BY PLS_INTEGER;
BEGIN
  target R_TARGET; 

  select COMP_EMP_TARGET_ID, EMPLOYEE_ID, PERCENT_ATTAINMENT_DATE
  into target
  from foo;

  targettbl T_TARGET_TABLE;

  select 1234 COMP_EMP_TARGET_ID, EMPLOYEE_ID, PERCENT_ATTAINMENT_DATE
  into targettbl(1)
  from foo;

  select 5678 COMP_EMP_TARGET_ID, EMPLOYEE_ID, PERCENT_ATTAINMENT_DATE
  into targettbl(2)
  from foo;

END:

---

DECLARE
  i binary_integer := 0;
  --type aa_t is table of scott.emp.deptno%type index by binary_integer;
  type aa_t is table of scott.emp%rowtype index by binary_integer;
  aa aa_t;
  
  type numbers_t is table of number index by binary_integer;
  l_numbers  numbers_t;

BEGIN
 -- 1. Load table into hash
 for r in ( select * from scott.emp where rownum<4) loop
   i := i +1;
   --aa(i) := r.deptno;
   aa(i).deptno := r.deptno;
   --dbms_output.put_line(aa(i));
   dbms_output.put_line(aa(i).deptno);
 end loop;
 
 -- 2. Iterate hash
 for ix in aa.first .. aa.last loop
   l_numbers(ix) := aa(ix).deptno;
   dbms_output.put_line(l_numbers(ix));
 end loop;
END;

---

-- https://github.com/oracle/oracle-db-examples/blob/master/plsql/collections/accessing-collection-index-in-sql.sql

CREATE OR REPLACE PACKAGE aa_pkg AUTHID DEFINER IS  
  TYPE record_t IS RECORD (  
    nm  VARCHAR2(100), 
    sal NUMBER
   );
  
  -- Build a collection (hash, associative array) of RECORDs
  TYPE array_t IS TABLE OF record_t INDEX BY PLS_INTEGER;  
  
  FUNCTION my_array RETURN array_t;  
END;

CREATE OR REPLACE PACKAGE BODY aa_pkg IS  
  FUNCTION my_array RETURN array_t IS  
    l_return   array_t;  
  BEGIN  
    -- Populate a sparse array
    l_return(1).nm := 'Me';  
    l_return(1).sal := 1000;  
    l_return(200).nm := 'You';  
    l_return(200).sal := 2;  
  
    RETURN l_return;  
  END my_array;  
END;


-- Use TABLE with Associative Arrays of Records! 12c+
DECLARE  
   l_array   aa_pkg.array_t;  
BEGIN  
   l_array := aa_pkg.my_array;  
  
   -- Fails if l_return index isn't 1, 2, 3 etc -  NO_DATA_FOUND
   /* FOR ix IN l_array.first .. l_array.last LOOP */  
     /* DBMS_OUTPUT.put_line(l_array(ix).nm || ' ' || l_array(ix).sal); */  
   /* END LOOP; */  

   FOR rec IN ( SELECT * FROM TABLE(l_array) ORDER BY nm) LOOP
     DBMS_OUTPUT.put_line(rec.nm || ' ' || rec.sal);
   END LOOP;  
END; 
