-- Simple
select st as State, yr as Year, mergef as File, hirange as HighestCertNo
from tmp
group by st, yr
having hirange=max(hirange)
order by yr


SELECT MAX(population), continent
FROM Country
GROUP BY continent;


-- Complex - return single row with max date for a material & 'Content per' long test name
-- combination plus bring along batch id
SELECT DISTINCT material_description, long_test_name, mfg_dt, mrp_batch_id
FROM dgm_dist.vw_lift_rpt_results_nl
WHERE mfg_dt in (

  select max(mfg_dt) 
  from dgm_dist.vw_lift_rpt_results_nl
  where long_test_name like 'Content per%' and MRP_MAT_ID in('4a04501','41a2506','a0000000069767','1a000000080112') and UPPER(test_status)='APPROVED' and UPPER(site_name)='ZEBULON' 
  group by material_description, long_test_name

) AND long_test_name LIKE 'Content per%' AND MRP_MAT_ID IN('4a04501','41a2506','a0000000069767','1a000000080112') and UPPER(test_status)='APPROVED' AND UPPER(site_name)='ZEBULON'
