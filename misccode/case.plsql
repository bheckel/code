
DECLARE
   grade CHAR(1) := 'B';
   appraisal VARCHAR2(20);
BEGIN
   appraisal :=
      CASE grade
         WHEN 'A' THEN 'Excellent'
         WHEN 'B' THEN 'Very Good'
         WHEN 'C' THEN 'Good'
         WHEN 'D' THEN 'Fair'
         WHEN 'F' THEN 'Poor'
         ELSE 'No such grade'
      END;
END;
/


 /* "Searched" Case expression */

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
