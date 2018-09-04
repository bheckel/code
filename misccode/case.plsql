
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
 /* If you don't specify an ELSE clause and none of the results in the WHEN
  * clauses matches the result of the CASE expression, PL/SQL will raise a
  * CASE_NOT_FOUND error. This behavior is different from that of IF
  * statements. When an IF statement lacks an ELSE clause, nothing happens when
  * the condition is not met. With CASE, the analogous situation leads to an
  * error. */
/



 /* "Searched" CASE expression */

DECLARE
   grade CHAR(1);
   appraisal VARCHAR2(20);
BEGIN
   ...
   appraisal :=
      CASE
         WHEN grade = 'A' THEN 'Excellent'
         WHEN grade = 'B' THEN 'Very Good'
         WHEN grade = 'C' THEN 'Good'
         WHEN grade = 'D' THEN 'Fair'
         WHEN grade = 'F' THEN 'Poor'
         ELSE 'No such grade'
      END;
   ...
END;
/


CASE
  WHEN l_salary BETWEEN 10000 AND 20000 
  THEN
    give_bonus(l_employee_id, 1500);
  WHEN salary > 20000 
  THEN
    give_bonus(l_employee_id, 1000);
  ELSE
    give_bonus(l_employee_id, 0);    
END CASE;
