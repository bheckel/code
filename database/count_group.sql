
-- Group counts by month for tot and subset
WITH v1 AS (SELECT to_char(TRUNC(o.updated, 'MONTH'),'YYYY-MM') AS mo, COUNT(o.updated) AS COUNT FROM cdhub_error_hist@esp o /*WHERE o.updated  > ADD_MONTHS(SYSDATE,-85)*/ GROUP BY TRUNC(o.updated, 'MONTH')),
     v2 AS (SELECT to_char(TRUNC(o.updated, 'MONTH'),'YYYY-MM') AS mo, COUNT(o.updated) AS COUNT FROM cdhub_error_hist@esp o WHERE o.wm_optype='I' GROUP BY TRUNC(o.updated, 'MONTH'))
SELECT v1.mo, v1.count AS totcnt, v2.count AS icnt
FROM v1 JOIN v2 ON v1.mo=v2.mo
ORDER BY 1 DESC;
