
-- TABLE operator
-- See also pipelined_table_functions.plsql

-- Adapted: Thu, Nov 29, 2018  2:05:03 PM (Bob Heckel -- https://devgym.oracle.com)
-- Modified: Tue 15-Dec-2020 (Bob Heckel)
-- See also call_function_from_sql.plsql

-- To invoke a table function inside a SELECT statement, it must be defined at
-- the schema level, in the specification of a package or in the WITH clause of a
-- SELECT. It cannot be defined as a nested subprogram or a private subprogram.
-- We could have used a varray instead.

-- Single column pseudo-table:
CREATE OR REPLACE TYPE t_str_nt IS TABLE OF VARCHAR2(100);  -- can't use ...TABLE OF foo%ROWTYPE because we're talking to SQL not PLSQL
/
CREATE OR REPLACE PACKAGE tf_pkg IS
  FUNCTION qry(p_cnt IN INTEGER) RETURN t_str_nt;  -- Only IN is allowed
END;
/
CREATE OR REPLACE PACKAGE BODY tf_pkg
IS
  FUNCTION qry(p_cnt IN INTEGER)
    RETURN t_str_nt  -- must be a collection
  IS
    l_retval t_str_nt := t_str_nt();  -- initialize the collection to be RETURNed
  
    BEGIN
      FOR i IN 1 .. p_cnt LOOP
        l_retval.extend();
        l_retval(i) := 'abc' || i;
      END LOOP;
     
     RETURN l_retval;
    END;
END;
/
-- Then call the function in SQL
--     Oracle keyword                                   11g+
--     ____________                                    _____
select COLUMN_VALUE as my_string from TABLE(tf_pkg.qry(p_cnt => 5));

select count(COLUMN_VALUE) from table(tf_pkg.qry(5));

create or replace view myvw as select * from TABLE(tf_pkg.qry(5));

create table mytbl as select * from TABLE(tf_pkg.qry(5));


-- If you are executing queries inside functions that are called inside SQL, you need to be 
-- acutely aware of read consistency issues. If these functions are called in long-running queries 
-- or transactions, you will probably need to issue the following command to enforce read 
-- consistency between SQL statements in the current transaction:
-- SET TRANSACTION READ ONLY


-- Multiple column pseudo-table:
CREATE TYPE t_animal_o IS OBJECT (
  name           VARCHAR2(10),
  species        VARCHAR2(20),
  date_of_birth  DATE
);
/
-- Can't use table ANIMAL: animal%ROWTYPE or TYPE RECORD because those aren't SQL-recognized types so we need an object
CREATE TYPE t_animals_nt IS TABLE OF t_animal_o;
/
CREATE OR REPLACE FUNCTION animal_family(p_dad IN t_animal_o, p_mom IN t_animal_o)
  RETURN t_animals_nt
  AUTHID DEFINER
IS
  l_family t_animals_nt := t_animals_nt(p_dad, p_mom);
BEGIN
  FOR i IN 1 .. CASE p_mom.species
                  WHEN 'RABBIT' THEN 12
                  WHEN 'DOG' THEN 4
                  WHEN 'KANGAROO' THEN 1
                END
  LOOP
    l_family.EXTEND;
    l_family(i) := t_animal_o('BABY' || i,
                              p_mom.species,
                              ADD_MONTHS(SYSDATE, -1 * DBMS_RANDOM.VALUE(1, 6)));
  END LOOP;

  RETURN l_family;
END;

-- Call the table function ANIMAL_FAMILY with a dad & a mom object i.e. 
-- a T_ANIMAL_O type, as the parameters and start breeding. The TABLE operator 
-- translates the collection into a relational table format that can be queried.
SELECT * --name, species, date_of_birth
  FROM TABLE(animal_family(t_animal_o('Hoppy', 'RABBIT', SYSDATE-500),  -- dad
                           t_animal_o('Hippy', 'RABBIT', SYSDATE-300))) -- mom
/*
NAME	SPECIES	DATE_OF_BIRTH
Hoppy	RABBIT	17-JUL-17
Hippy	RABBIT	02-FEB-18
BABY1	RABBIT	29-SEP-18
BABY2	RABBIT	29-OCT-18
BABY3	RABBIT	29-OCT-18
BABY4	RABBIT	29-SEP-18
BABY5	RABBIT	29-SEP-18
BABY6	RABBIT	29-JUN-18
BABY7	RABBIT	29-OCT-18
BABY8	RABBIT	29-JUL-18
BABY9	RABBIT	29-JUL-18
BABY10	RABBIT	29-OCT-18
BABY11	RABBIT	29-OCT-18
BABY12	RABBIT	29-SEP-18
*/

-- Then for use by Java consumers of cursor variables:
FUNCTION pet_family_cv
  RETURN SYS_REFCURSOR
IS
  retval SYS_REFCURSOR;  -- weak
BEGIN
  OPEN retval FOR
    SELECT *
      FROM TABLE( animal_family(t_animal_o('Hoppy', 'RABBIT', SYSDATE),
                                t_animal_o('Hippy', 'RABBIT', SYSDATE)) );

   RETURN retval;
END pet_family_cv;                              

-- or

INSERT INTO animals
  SELECT name, species, date_of_birth
    FROM TABLE( animal_family(t_animal_o('Hoppy', 'RABBIT', SYSDATE - 500),
                              t_animal_o('Hippy', 'RABBIT', SYSDATE - 300)) );

---

-- Slightly different - use custom functions in SQL:
CREATE OR REPLACE FUNCTION betwnstr(
   string_in  IN   VARCHAR2
 , start_in   IN   PLS_INTEGER
 , end_in     IN   PLS_INTEGER
)
  RETURN VARCHAR2
IS
BEGIN
  RETURN( SUBSTR(string_in, start_in, end_in - start_in + 1 ) );
END;

-- Downside is context switching
SELECT BETWNSTR(ename, 3, 5) FROM emp;

-- 12c+ allows this to reduce context switching (at the expense of reusability):
WITH
  FUNCTION betwnstr(string_in IN VARCHAR2, start_in IN PLS_INTEGER, end_in IN PLS_INTEGER)
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN( SUBSTR(string_in, start_in, end_in - start_in + 1 ) );
  END;
SELECT BETWNSTR(ename, 3, 5) FROM emp;

