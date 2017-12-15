
-- (Sub)Query the long list of products to see which Serevents exist today
SELECT rr 
FROM (SELECT DISTINCT r.resstrval as rr FROM Result R, Var V WHERE R.SpecRevId=V.SpecRevId AND R.VarId=V.VarId AND V.Name='PRODCODEDESC$' )
WHERE UPPER(rr) LIKE '%SEREV%'
;
quit;



SELECT DISTINCT aa.*, bb.work_cntr_desc, bb.work_cntr_cod from (
 SELECT b.mat_desc as MATERIAL_DESCRIPTION, a.mrp_mat_id, a.mrp_batch_id, TO_CHAR(a.MFG_DT, 'YYYY-MM-DD') AS MFG_DT, 
        TO_CHAR(a.last_goods_receipt_dt, 'YYYY-MM-DD') AS last_goods_receipt_dt, a.sample_status, a.test_status as TEST_STATUS, a.long_test_name, 
        a.SHORT_TEST_NAME_LEVEL1, a.SHORT_TEST_NAME_LEVEL2, a.SHORT_TEST_NAME_LEVEL3, a.data_type, a.test_instance, a.replicate_id, a.recorded_text,
        a.reported_value, a.recorded_value, a.test_result_uom, TO_CHAR(a.test_end_date, 'YYYY-MM-DD') AS test_date, a.trend_flag, a.instrument_id, 
        a.sample_disposition, a.test_disposition, a.result_number, a.method_id, a.test_id, a.component_id, a.test_result_type, a.test_result_datatype, b.no_of_doses_size, b.prod_strength
 FROM gdm_dist.vw_zeb_lift_rpt_results_nl a, gdm_dist.vw_zeb_merps_material_info b         
 WHERE a.mrp_mat_id=b.mat_cod
 AND a.test_status in('Approved')
 AND a.MRP_MAT_ID in ('10000000059062','10000000060721','10000000059064','10000000059066','10000000058960','10000000058961')
 AND test_end_date BETWEEN TO_DATE('&STARTDT','DDMONYY:HH24:MI:SS') AND TO_DATE('&ENDDT','DDMONYY:HH24:MI:SS')
) aa LEFT JOIN gdm_dist.VW_ZEB_MERPS_prcs_ord_material bb ON aa.mrp_batch_id=bb.bat_num and aa.mrp_mat_id=bb.mat_cod



SELECT * FROM
  (select matl_nbr, count(*) ca
  from RETAIN.FNSH_PROD 
  where prod_sel_dt is null
  group by matl_nbr) aa
JOIN
  (select matl_nbr, count(*) cb
  from RETAIN.FNSH_PROD 
  where prod_sel_dt is not null
  group by matl_nbr) bb
ON aa.matl_nbr=bb.matl_nbr
ORDER BY aa.matl_nbr


SELECT aa.matl_nbr, bb.cb, aa.ca, bb.cb+aa.ca  FROM
  (select matl_nbr, count(*) ca
  from RETAIN.FNSH_PROD 
  where prod_sel_dt is null
  group by matl_nbr) aa
JOIN
  (select matl_nbr, count(*) cb
  from RETAIN.FNSH_PROD 
  where prod_sel_dt is not null
  group by matl_nbr) bb
ON aa.matl_nbr=bb.matl_nbr
ORDER BY aa.matl_nbr
