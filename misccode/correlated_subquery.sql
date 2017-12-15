
SELECT *
FROM july_2010_admits a
WHERE los >= ( SELECT AVG(length_of_stay) + 2*STD(length_of_stay)
               FROM inpatient_admissions b
               WHERE a.principle_diagnosis=b.principle_diagnosis )
;
