-- Modified: Mon 02-Sep-2019 (Bob Heckel)

/*
CASE expressions make it possible to implement conditional logic within a
PL/SQL expression or from inside a SQL statement.

CASE expressions are terminated with "END" while CASE statements are terminated
with END CASE.

CASE expressions do not require an ELSE clause. If none of the WHEN clauses are
executed, then NULL is returned
*/

---

-- Simple expression, which evaluates a single expression and compares it to several potential values
DECLARE
   grade CHAR(1) := 'B';
   appraisal VARCHAR2(20);
BEGIN
   appraisal :=
      CASE grade
         WHEN 'A' THEN 'Excellent';
         WHEN 'B' THEN 'Very Good';
         WHEN 'C' THEN 'Good';
         WHEN 'D' THEN 'Fair';
         WHEN 'F' THEN 'Poor';
         ELSE RAISE CASE_NOT_FOUND;
      END;
END;
/

-- Searched expression, which evaluates multiple conditions and chooses the first one that is true
DECLARE
   grade CHAR(1);
   appraisal VARCHAR2(20);
BEGIN
   grade := 'A';
   appraisal :=
      CASE
         WHEN grade = 'A' THEN 'Excellent'
         WHEN grade = 'B' THEN 'Very Good'
         WHEN grade = 'C' THEN 'Good'
         WHEN grade = 'D' THEN 'Fair'
         WHEN grade = 'F' THEN 'Poor'
         ELSE 'No such grade'
         -- Same as no ELSE:
         --ELSE NULL
      END;

  dbms_output.put_line(appraisal);
END;
/

---

 /* If you don't specify an ELSE clause and none of the results in the WHEN
  * clauses matches the result of the CASE expression, PL/SQL will raise a
  * CASE_NOT_FOUND error. This behavior is different from that of IF
  * statements. When an IF statement lacks an ELSE clause, nothing happens when
  * the condition is not met. With CASE, the analogous situation leads to an
  * error.
  */
DECLARE
  grade CHAR(1);

BEGIN
  grade := 'B';
  
  CASE
    WHEN grade = 'A' THEN DBMS_OUTPUT.PUT_LINE('Excellent');
    WHEN grade = 'B' THEN DBMS_OUTPUT.PUT_LINE('Very Good');
    WHEN grade = 'C' THEN DBMS_OUTPUT.PUT_LINE('Good');
    WHEN grade = 'D' THEN DBMS_OUTPUT.PUT_LINE('Fair');
    WHEN grade = 'F' THEN DBMS_OUTPUT.PUT_LINE('Poor');
  END CASE;  -- not 'END' so it's a statement not an expression

EXCEPTION
  WHEN CASE_NOT_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No such grade');
END;
/

---

-- Adapted from DevGym 

CREATE OR REPLACE FUNCTION grade_translator(grade_in IN VARCHAR2)
   RETURN VARCHAR2
IS
  retval   VARCHAR2 (100);
BEGIN
  IF grade_in = 'A'
  THEN
     retval := 'Excellent';
  ELSIF grade_in = 'B'
  THEN
     retval := 'Very Good';
  ELSIF grade_in = 'C'
  THEN
     retval := 'Good';
  ELSIF grade_in = 'D'
  THEN
     retval := 'Fair';
  ELSIF grade_in = 'F'
  THEN
     retval := 'Poor';
  ELSE
     retval := 'No such grade';
  END IF;

  RETURN retval;
END

-- better, using CASE expression:
CREATE OR REPLACE FUNCTION grade_translator(grade_in IN VARCHAR2)
  RETURN VARCHAR2
IS
BEGIN
  RETURN CASE grade_in
           WHEN 'A' THEN 'Excellent'
           WHEN 'B' THEN 'Very Good'
           WHEN 'C' THEN 'Good'
           WHEN 'D' THEN 'Fair'
           WHEN 'F' THEN 'Poor'
           ELSE 'No such grade'
         END;  -- not 'END CASE' so it's an expression, not statement
END;
/
