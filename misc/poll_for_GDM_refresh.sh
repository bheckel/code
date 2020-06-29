#!/bin/sh

cd $u/gsk; while true; do date; sqlplus -S m_dist_r/ice45read@prd613 @lift_rpt_results_nl_all_minmaxteststatusdt.sql; sleep 10000; done;

#
# lift_rpt_results_nl_all_minmaxteststatusdt.sql:
# set linesize 180;
# set pagesize 9999;
# 
# select to_char(min(test_status_date), 'DDMONYY HH24:MI:SS') as mintsd, to_char(max(test_status_date), 'DDMONYY HH24:MI:SS') as maxtsd, count(*) as cntalljustdp
# from   gdm_dist.vw_lift_rpt_results_nl
# where mrp_mat_id in(
# '0695009', '0695017', '0695025', '0696005', '0696013', '0696021', '0697001',
# '60000000002596', '60000000002597', '60000000003256', '60000000004088')
# ;
# exit;
