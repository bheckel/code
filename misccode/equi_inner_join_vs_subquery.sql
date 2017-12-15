-- Subquery approach
SELECT *
FROM claim_detail
WHERE memberno IN (SELECT memberno
                   FROM diabetic_population)
;



-- Equi-join approach
SELECT a.*
FROM claim_detail a diabetic_population b
WHERE a.memberno=b.memberno
;
