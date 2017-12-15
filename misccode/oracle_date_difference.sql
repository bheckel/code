SELECT material_description, mintsd, maxtsd, maxtsd - mintsd as dif
FROM (select material_description, trunc(min(test_status_date)) as mintsd, trunc(max(test_status_date)) as maxtsd
      from   gdm_dist.vw_zeb_lift_rpt_results_nl
      where mrp_mat_id in('100')
      group by material_description)
ORDER BY dif
