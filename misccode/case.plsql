-- Simple, which evaluates a single expression and compares it to several potential values.
DECLARE
  grade CHAR(1);
BEGIN
  grade := 'B';

  CASE grade
    WHEN 'A' THEN DBMS_OUTPUT.PUT_LINE('Excellent');
    WHEN 'B' THEN DBMS_OUTPUT.PUT_LINE('Very Good');
    WHEN 'C' THEN DBMS_OUTPUT.PUT_LINE('Good');
    WHEN 'D' THEN DBMS_OUTPUT.PUT_LINE('Fair');
    WHEN 'F' THEN DBMS_OUTPUT.PUT_LINE('Poor');
    ELSE DBMS_OUTPUT.PUT_LINE('No such grade');
  END CASE;
END;
/

-- Searched, which evaluates multiple conditions and chooses the first one that is true.
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
    ELSE DBMS_OUTPUT.PUT_LINE('No such grade');
  END CASE;
END;
/



 /* "Simple" CASE statement */
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

 /* "Searched" CASE expression */
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


 /* If you don't specify an ELSE clause and none of the results in the WHEN
  * clauses matches the result of the CASE expression, PL/SQL will raise a
  * CASE_NOT_FOUND error. This behavior is different from that of IF
  * statements. When an IF statement lacks an ELSE clause, nothing happens when
  * the condition is not met. With CASE, the analogous situation leads to an
  * error. */
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
  END CASE;
EXCEPTION
  WHEN CASE_NOT_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No such grade');
END;
/
