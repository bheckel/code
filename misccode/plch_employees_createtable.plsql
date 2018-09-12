CREATE TABLE plch_employees
(
   employee_id   INTEGER
 , last_name     VARCHAR2 (100)
 , salary        NUMBER
)
/
BEGIN
   INSERT INTO plch_employees
        VALUES (100, 'Jobs', 1000000);
   INSERT INTO plch_employees
        VALUES (200, 'Ellison', 1000000);
   INSERT INTO plch_employees
        VALUES (300, 'Gates', 1000000);
   COMMIT;
END;
/

-- ...Later requirements

-- Packages stay VALID
ALTER TABLE plch_employees ADD first_name VARCHAR2(2000)
/
-- Packages become INVALID
ALTER TABLE plch_employees MODIFY last_name VARCHAR2(2000)
/

