
DECLARE
  -- Declare a record variable that represents either a full or partial row of
  -- a database table or view
  emp_rec emp%ROWTYPE;
BEGIN
  SELECT * INTO emp_rec FROM emp WHERE ...
  IF emp_rec.deptno = 20 THEN
    emp_rec.ename := 'JOHNSON';
  END IF;
END;

---

-- Sadly, Oracle PL/SQL does not offer built-in support for equality
-- comparisons of records. If you want to compare records, you must write your own
-- code to do so, usually involving a field-by-field comparison of values.

DECLARE
   childlabor   sweatshops%ROWTYPE;
   bigprofits   sweatshops%ROWTYPE;
BEGIN
   IF childlabor.avg_wages = bigprofits.avg_wages
   THEN
      DBMS_OUTPUT.put_line('Race to the bottom');
   END IF;
END;
/

---

CREATE OR REPLACE FUNCTION maximized_profits (
   sweatshop_in IN sweatshops%ROWTYPE)
   RETURN NUMBER
IS
BEGIN
   RETURN 1000000;
END maximized_profits;
/
DECLARE
   childlabor       sweatshops%ROWTYPE;
   unconscionable   NUMBER;
BEGIN
   -- Pass a record as an argument
   unconscionable := maximized_profits(childlabor);
END;
/

---

DECLARE
   life_sentence   sweatshops%ROWTYPE;
BEGIN
   life_sentence.factory_name := 'Consumption=Happiness';
   life_sentence.country := 'United States';
   life_sentence.min_age := 16;
   life_sentence.avg_wages := 6;

   INSERT INTO sweatshops
        VALUES life_sentence;  -- no parenthesis!
END;
/
