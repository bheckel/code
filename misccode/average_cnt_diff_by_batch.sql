
select w.long_test_name, w.mrp_batch_id, w.cnt, trunc(y.acnt) as tacnt, trunc(w.cnt-y.acnt) as diff from
(SELECT prod_brand_name, long_test_name, mrp_batch_id, count(mrp_batch_id) as cnt
 FROM gdm_dist.vw_zeb_lift_rpt_results_nl
 WHERE mrp_mat_id in('4104501', '4152506', '10000000069767', '10000000080112')
 GROUP BY prod_brand_name, mrp_batch_id,long_test_name
) w
left join 
(SELECT x.long_test_name, avg(x.cnt) as acnt
 FROM
 (SELECT prod_brand_name, long_test_name, mrp_batch_id, count(mrp_batch_id) as cnt
  FROM gdm_dist.vw_zeb_lift_rpt_results_nl
  WHERE mrp_mat_id in('4104501', '4152506', '10000000069767', '10000000080112')
  GROUP BY prod_brand_name, mrp_batch_id,long_test_name) x
  GROUP BY x.long_test_name
) y
on w.long_test_name=y.long_test_name
order by diff
