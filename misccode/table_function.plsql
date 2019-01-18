/* Adapted: Thu, Nov 29, 2018  2:05:03 PM (Bob Heckel -- https://devgym.oracle.com) */
/* See also call_function_from_sql.plsql */

-- To invoke a table function inside a SELECT statement, it must be defined at
-- the schema level, in the specification of a package or in the WITH clause of a
-- SELECT. It cannot be defined as a nested subprogram or a private subprogram.
-- We could have used a varray instead.

-- 1. Single columns:
CREATE OR REPLACE TYPE strings_ntt IS TABLE OF VARCHAR2(100);  /* can't use ...TABLE OF foo%ROWTYPE because we're talking to SQL not PLSQL */
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
     for i in 1 .. count_in loop
       stringx.extend();
       stringx(i) := 'abc';
     end loop;
    
    RETURN stringx;
   END;
END;
/

--     Oracle keyword
SELECT COLUMN_VALUE my_string FROM TABLE (tf.queryme(5))
/


-- 2. Multiple columns in a pseudo table:
CREATE TYPE animal_ot IS OBJECT
(
   name VARCHAR2(10),
   species VARCHAR2(20),
   date_of_birth DATE
);
/

-- Can't use foo%ROWTYPE we need an object
CREATE TYPE animals_ntt IS TABLE OF animal_ot;
/

CREATE OR REPLACE FUNCTION animal_family(dad_in IN animal_ot, mom_in IN animal_ot)
   RETURN animals_ntt
   AUTHID DEFINER
IS
   l_family   animals_ntt := animals_ntt(dad_in, mom_in);
BEGIN
   FOR i IN 1 ..
               CASE mom_in.species
                  WHEN 'RABBIT' THEN 12
                  WHEN 'DOG' THEN 4
                  WHEN 'KANGAROO' THEN 1
               END
   LOOP
      l_family.EXTEND;
      /* l_family(l_family.LAST) := animal_ot('BABY' || i, */
      l_family(i) := animal_ot('BABY' || i,
                               mom_in.species,
                               ADD_MONTHS (SYSDATE, -1 * DBMS_RANDOM.VALUE (1, 6)));
   END LOOP;

   RETURN l_family;
END;
/

SELECT * --name, species, date_of_birth
  FROM TABLE (animal_family(animal_ot('Hoppy', 'RABBIT', SYSDATE-500),
                            animal_ot('Hippy', 'RABBIT', SYSDATE-300)))
/
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
  FROM TABLE (
          animal_family(animal_ot('Hoppy', 'RABBIT', SYSDATE - 500),
                        animal_ot('Hippy', 'RABBIT', SYSDATE - 300)))
