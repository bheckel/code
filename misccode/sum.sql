-- Sum 3 stages together by device
select indvl_tst_rslt_device,sum(indvl_tst_rslt_val_num) from indvl_tst_rslt 
where samp_id=214577 and indvl_meth_stage_nm in('THROAT','PRESEPARATOR','0')
group by indvl_tst_rslt_device



SELECT EMPLOYEE_ID, SUM(HOURS) HRTOT_ALIAS
FROM TIME_TRANSACTS 
WHERE TIME BETWEEN TO_DATE('7/10/2001', 'mm/dd/yyyy') 
               AND TO_DATE('7/24/2001', 'mm/dd/yyyy')
GROUP BY EMPLOYEE_ID; --mandatory if using SUM
