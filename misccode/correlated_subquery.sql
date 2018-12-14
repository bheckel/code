SELECT o.opportunity_id, o.status_achieved_date, ooo.POOR_CLOSEOUT_OPT_OUT
FROM opportunity_base o, ( SELECT opportunity_id, POOR_CLOSEOUT_OPT_OUT FROM OPPORTUNITY_OPT_OUT ) ooo
WHERE o.opportunity_id=ooo.opportunity_id 
  AND o.status_achieved_date < ADD_MONTHS(sysdate,-3) 
  AND o.opportunity_id IN ( SELECT opportunity_id FROM OPPORTUNITY_OPT_OUT WHERE NVL(POOR_CLOSEOUT_OPT_OUT,0) != 1 )
  AND ROWNUM<600
;

---

SELECT *
FROM july_2010_admits a
WHERE los >= ( SELECT AVG(length_of_stay) + 2*STD(length_of_stay)
               FROM inpatient_admissions b
               WHERE a.principle_diagnosis=b.principle_diagnosis )
;
