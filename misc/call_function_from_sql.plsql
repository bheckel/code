/* Adapted from https://livesql.oracle.com/apex/livesql/s/GQPQJOE8SHBUNIZSQ2DVLVRHT */
/* See also table_function.plsql */

DROP TABLE my_family
/
CREATE TABLE my_family (name VARCHAR2 (100))
/
BEGIN
   INSERT INTO my_family VALUES ('Veva');
   INSERT INTO my_family VALUES ('Steven');
   INSERT INTO my_family VALUES ('Eli');
   INSERT INTO my_family VALUES ('Chris');
   INSERT INTO my_family VALUES ('Lauren');
   INSERT INTO my_family VALUES ('Loey');
   COMMIT;
END;
/


CREATE OR REPLACE FUNCTION double_name (NAME_IN IN VARCHAR2)
   RETURN VARCHAR2
IS
BEGIN
   RETURN NAME_IN || NAME_IN;
END double_name;
/
SELECT double_name(name) FROM my_family
/
SELECT *
  FROM my_family
 WHERE name <> double_name('ABC')
/
SELECT *
  FROM my_family
 WHERE double_name(name) = 'VevaVeva'
/
UPDATE my_family
   SET name = double_name(name)
/
ROLLBACK
/


DROP TYPE names_t FORCE
/
CREATE OR REPLACE TYPE names_t IS TABLE OF VARCHAR2 (100)
/
CREATE OR REPLACE FUNCTION names_like(NAME_IN IN VARCHAR2)
   RETURN names_t
IS
   l_names   names_t;
BEGIN
   SELECT name
     BULK COLLECT INTO l_names
     FROM my_family
    WHERE name LIKE NAME_IN;

   RETURN l_names;
END names_like;
/
-- Table function
SELECT COLUMN_VALUE foo FROM TABLE(names_like('%e%'))
/
