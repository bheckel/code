
-- Table operator

-- Adapted: Thu, Nov 29, 2018  2:05:03 PM (Bob Heckel -- https://devgym.oracle.com)
-- Modified: 04-Dec-2020 (Bob Heckel)
-- See also call_function_from_sql.plsql

-- To invoke a table function inside a SELECT statement, it must be defined at
-- the schema level, in the specification of a package or in the WITH clause of a
-- SELECT. It cannot be defined as a nested subprogram or a private subprogram.
-- We could have used a varray instead.

-- Single column pseudo-table:
CREATE OR REPLACE TYPE t_str_nt IS TABLE OF VARCHAR2(100);  /* can't use ...TABLE OF foo%ROWTYPE because we're talking to SQL not PLSQL */
/
CREATE OR REPLACE PACKAGE tf_pkg IS
  FUNCTION qry(p_cnt IN INTEGER) RETURN t_str_nt;
END;
/
CREATE OR REPLACE PACKAGE BODY tf_pkg
IS
  FUNCTION qry(p_cnt IN INTEGER) RETURN t_str_nt IS
    l_str t_str_nt := t_str_nt();
  
    BEGIN
      for i in 1 .. p_cnt loop
        l_str.extend();
        l_str(i) := 'abc';
      end loop;
     
     RETURN l_str;
    END;
END;
/
-- Call the function in SQL
--     Oracle keyword
SELECT COLUMN_VALUE AS my_string FROM TABLE(tf_pkg.qry(5))

select count(COLUMN_VALUE) from table(tf_pkg.qry(5));

create or replace view vw as select * from TABLE(tf_pkg.qry(5));


-- Multiple column pseudo-table:
CREATE TYPE t_animal_o IS OBJECT (
  name           VARCHAR2(10),
  species        VARCHAR2(20),
  date_of_birth  DATE
);
/
-- Can't use foo%ROWTYPE or TYPE RECORD, we need an object
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
-- a T_ANIMAL_O type, as the parameters
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

INSERT INTO animals
  SELECT name, species, date_of_birth
    FROM TABLE ( animal_family(t_animal_o('Hoppy', 'RABBIT', SYSDATE - 500),
                               t_animal_o('Hippy', 'RABBIT', SYSDATE - 300)) );

