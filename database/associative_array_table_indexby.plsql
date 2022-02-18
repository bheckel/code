
-- See also other collections: nested_table.plsql, varray.plsql, record_type.plsql
--  Created: 13-Jul-2021 (Bob Heckel)
-- Modified: 24-Dec-2021 (Bob Heckel)

---

DECLARE
  TYPE NUM_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  nums   NUM_TYPE;
  total  number;
BEGIN
  nums(1) := 127.56;
  nums(2) := 56.79;
  nums(3) := 295.34;
  DBMS_OUTPUT.put_line(nums(3));
END;

---

 --  set serverout on size unl
 declare
   TYPE t_varchar2Table IS TABLE OF VARCHAR2(200);
   TYPE t_varchar2List IS TABLE OF t_varchar2Table INDEX BY VARCHAR2(200);
  
   v_columnTable  t_varchar2List;
   v_column_name  varchar2(50);
   v_csv          varchar2(32767);
begin
   -- Load an associative array with a list of chars
   v_columnTable('MKC_ACCT_23DEC21') := t_varchar2Table('INDUSTRY', 'SUP_ACCOUNT_ID', 'SUP_ACCOUNT_NAME');
  
  for i in 1 .. v_columntable('KMC_ACCT_23DEC21').count loop
    v_column_name := v_columntable('KMC_ACCT_23DEC21')(i);
    v_csv := v_csv || ', ' || v_column_name;
  end loop;
  
  -- Output a CSV list
  DBMS_OUTPUT.put_line(v_csv);
end;

---

CREATE TABLE my_family (str VARCHAR2(100),name VARCHAR2 (100));
INSERT INTO my_family VALUES ('foo1','Veva'); 
INSERT INTO my_family VALUES ('foo2','Steven'); 
INSERT INTO my_family VALUES ('foo3','Eli'); 
INSERT INTO my_family VALUES (null,'xEli'); 
COMMIT; 

-- Load a string-keyed hash of strings from a table
declare
  type MYAA_T is table of varchar2(99) index by varchar2(99);
  myaa MYAA_T;
  
  begin
		for r in ( select * from my_family ) loop
			myaa(r.str) := r.name;
		end loop;

   dbms_output.put_line(myaa('foo1')); -- Veva
 end;


-- Load hash with a cursor column.  See also pass_cursor.plsql.
DECLARE 
  i integer := 0;   -- must initialize to avoid NULL index error

  CURSOR c is select name from my_family; 

  TYPE MYAA_T IS TABLE of my_family.Name%TYPE INDEX BY binary_integer; 
  myaa MYAA_T; 
BEGIN 
  FOR rec IN c LOOP 
    i := i + 1; 
    myaa(i) := rec.name; 
    dbms_output.put_line('Name(' || i || '):' || myaa(i)); 
  END LOOP; 
END;


-- Load associative array hash with a db table
DECLARE 
   i integer := 0; 

   --CURSOR c is select name, str from my_family; 

   TYPE MYAA_T IS TABLE of my_family%ROWTYPE INDEX BY binary_integer; 
   myaa MYAA_T; 
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

-- Compare (better only if small result set) load nested table with a db table:
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

-- Compare (better for loading large amounts of data) load nested table with a db table:
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

-- Load associative array hash with a query:
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

  select COMP_EMP_TARGET_ID, EMPLOYEE_ID, PERCENT_ATTAINMENT_DATE
  into targettbl(1)
  from foo;

  select COMP_EMP_TARGET_ID, EMPLOYEE_ID, PERCENT_ATTAINMENT_DATE
  into targettbl(2)
  from foo;

END:

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


-- Use TABLE with Associative Arrays of RECORDs! 12c+
DECLARE  
   l_array   aa_pkg.array_t;  
BEGIN  
   l_array := aa_pkg.my_array;  
  
   -- Fails if l_return index isn't 1, 2, 3 etc -  NO_DATA_FOUND
   /* FOR ix IN l_array.first .. l_array.last LOOP */  
     /* DBMS_OUTPUT.put_line(l_array(ix).nm || ' ' || l_array(ix).sal); */  
   /* END LOOP; */  

   FOR rec IN ( SELECT * 
                  FROM TABLE(l_array)
                 ORDER BY nm ) LOOP
     DBMS_OUTPUT.put_line(rec.nm || ' ' || rec.sal);
   END LOOP;  
END; 

---

-- Before 18c
DECLARE   
   TYPE ints_t IS TABLE OF INTEGER   
      INDEX BY PLS_INTEGER;   
   
   l_ints   ints_t;   
BEGIN   
   l_ints(1) := 55;  
   l_ints(2) := 555;  
   l_ints(3) := 5555;  
  
   FOR indx IN 1 .. l_ints.COUNT   
   LOOP   
      DBMS_OUTPUT.put_line (l_ints (indx));   
   END LOOP;   
END;
/

-- 18c+
DECLARE  
   TYPE ints_t IS TABLE OF INTEGER  
      INDEX BY PLS_INTEGER;  
  
   l_ints   ints_t := ints_t (1 => 55, 2 => 555, 3 => 5555);  
BEGIN  
   FOR indx IN 1 .. l_ints.COUNT  
   LOOP  
      DBMS_OUTPUT.put_line(l_ints (indx));  
   END LOOP;  
END;
/

---

CREATE OR REPLACE PACKAGE use_sql_on_aa AS
  -- Have to use a package, schema-level TYPE then DECLARE won't work for AAs
  TYPE employees_t IS TABLE OF emp%rowtype INDEX BY PLS_INTEGER;

  PROCEDURE do;
END;
/
CREATE OR REPLACE PACKAGE BODY use_sql_on_aa AS
  PROCEDURE do IS
    l_employees employees_t;

  BEGIN
    SELECT * BULK COLLECT
      INTO l_employees
      FROM emp;

    FOR e IN (
      SELECT *
        FROM TABLE (l_employees)
       WHERE job = 'SALESMAN'
       ORDER BY ename
    ) LOOP
      dbms_output.put_line(e.job
                           || '-'
                           || e.ename);
    END LOOP;
  END do;
END use_sql_on_aa;
/
EXEC use_sql_on_aa.do;
/*
SALESMAN-ALLEN
SALESMAN-MARTIN
SALESMAN-TURNER
SALESMAN-WARD
*/

---

DECLARE
  CURSOR cur IS
    SELECT ee.employee_id, ee.first_name, ee.last_name, ee.salary, d.department_name
      FROM departments d,
           employees ee
     WHERE d.department_id = ee.department_id;

  TYPE TOTAL_T IS TABLE OF NUMBER INDEX BY departments.department_name%TYPE;
  -- A collection of numbers that is indexed by the department name. Indexing by department name has
  -- the advantage of automatically sorting the results by department name.
  totals TOTAL_T;

  dept departments.department_name%TYPE;
BEGIN
  FOR rec IN cur LOOP
    -- process paycheck
    if NOT totals.EXISTS(rec.department_name) then  -- create element in the array
      totals(rec.department_name) := 0; -- initialize to zero
    end if;

    totals(rec.department_name) := totals(rec.department_name) + nvl (rec.salary, 0);
  END LOOP;

  dept := totals.FIRST;
  LOOP
     EXIT WHEN dept IS NULL;
     DBMS_OUTPUT.PUT_LINE(to_char(totals(dept),  '999,999.00') || ' ' || dept);
     dept := totals.NEXT(dept);
  END LOOP;

END;

---

-- Complex collection to traverse manager / employee hierarchy using both associative array and RECORD types
-- Adapted https://learning.oreilly.com/library/view/oracle-and-plsql/9781430232070/creating_and_accessing_complex_collections.html
DECLARE
  TYPE    person_type IS RECORD (
                  employee_id     hr.employees.employee_id%TYPE,
                  first_name      hr.employees.first_name%TYPE,
                  last_name       hr.employees.last_name%TYPE);

    -- a collection of people
  TYPE    direct_reports_type IS TABLE OF person_type INDEX BY BINARY_INTEGER;

    -- the main record definition, which contains a collection of records
  TYPE    rec_type IS RECORD (
                  mgr             person_type,
                  emps            direct_reports_type);

  TYPE    recs_type IS TABLE OF rec_type INDEX BY BINARY_INTEGER;
  recs    recs_type;

  CURSOR  mgr_cursor IS  -- finds all managers
    SELECT  employee_id, first_name, last_name
    FROM    hr.employees
    WHERE   employee_id IN
            (       SELECT  distinct manager_id
                    FROM    hr.employees)
    ORDER BY last_name, first_name;

  CURSOR  emp_cursor (mgr_id integer) IS  -- finds all direct reports for a manager
    SELECT  employee_id, first_name, last_name
    FROM    hr.employees
    WHERE   manager_id = mgr_id
    ORDER BY last_name, first_name;

    -- temporary collection of records to hold the managers.
  TYPE            mgr_recs_type IS TABLE OF emp_cursor%ROWTYPE INDEX BY BINARY_INTEGER;
  mgr_recs        mgr_recs_type;

BEGIN
   OPEN mgr_cursor;
   FETCH mgr_cursor BULK COLLECT INTO mgr_recs;
   CLOSE mgr_cursor;

   FOR i IN 1..mgr_recs.COUNT LOOP
      recs(i).mgr := mgr_recs(i);  -- move the manager record into the final structure

        -- moves direct reports directly into the final structure
      OPEN emp_cursor (recs(i).mgr.employee_id);
      FETCH emp_cursor BULK COLLECT INTO recs(i).emps;
      CLOSE emp_cursor;
   END LOOP;

   -- traverse the data structure to display the manager and direct reports
   -- note the use of dot notation within the data structure
   FOR i IN 1..recs.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE ('Manager: ' || recs(i).mgr.last_name);
      FOR j IN 1..recs(i).emps.count LOOP
         DBMS_OUTPUT.PUT_LINE ('***   Employee: ' || recs(i).emps(j).last_name);
      END LOOP;
   END LOOP;

END;
/*
Manager: Cambrault
***   Employee: Bates
***   Employee: Bloom
***   Employee: Fox
***   Employee: Kumar
***   Employee: Ozer
***   Employee: Smith
Manager: De Haan
***   Employee: Hunold
Manager: Errazuriz
***   Employee: Ande
***   Employee: Banda
***   Employee: Greene
***   Employee: Lee
***   Employee: Marvins
***   Employee: Vishney
*/

---

create or replace package rion56370 as
  type days_table_t_rec is record(
    closeout_yr  NUMBER,
    closeout_mo  NUMBER,
    closeout_dy  NUMBER
  );
  type days_table_t is table of days_table_t_rec index by binary_integer;
  l_days_table days_table_t := days_table_t();

  function get_eoy_date(in_year NUMBER DEFAULT NULL) return date RESULT_CACHE;  
end;
/
create or replace package body orion56370 as
  function get_eoy_date(in_year NUMBER DEFAULT NULL) return date RESULT_CACHE is
    l_dt_str varchar2(20);
    l_yr   number;
  begin
    l_days_table(2019).closeout_yr := 2020;
    l_days_table(2019).closeout_mo := 01;
    l_days_table(2019).closeout_dy := 18;

    l_days_table(2020).closeout_yr := 2021;
    l_days_table(2020).closeout_mo := 01;
    l_days_table(2020).closeout_dy := 15;

    l_days_table(2021).closeout_yr := 2022;
    l_days_table(2021).closeout_mo := 01;
    l_days_table(2021).closeout_dy := 15;
    
    l_days_table(2022).closeout_yr := 2022;
    l_days_table(2022).closeout_mo := null;
    l_days_table(2022).closeout_dy := null;
    
    if in_year is null then
      l_yr := extract(year from sysdate);
    else
      l_yr := in_year;
    end if;

    l_dt_str := nvl(l_days_table(l_yr).closeout_mo, '01') || '/' || nvl(l_days_table(l_yr).closeout_dy, '01') || '/' || l_days_table(l_yr).closeout_yr;

    return to_date(l_dt_str, 'MM/DD/YYYY'); 
  end;
end;
/
alter package orion56370 compile debug;
--  set serverout on size 100000
declare 
  x date; 
  y number;
begin 
  x:= rion56370.get_eoy_date(2014);
  DBMS_OUTPUT.put_line(x);
  y:= extract(year from rion56370.get_eoy_date());
  DBMS_OUTPUT.put_line('get_current_reporting_year version: ' || y);
end;
