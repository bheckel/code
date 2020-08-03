--sqlplus gdm_zeb/gdm123zeb45@ukprd613 @zeb_lift_rpt_results_nl
set linesize 180;
set pagesize 9999;
column material_description format a45

SELECT max(sample_creation_date), max(test_end_date), count(*)
FROM gdm_dist.vw_zeb_lift_rpt_results_nl
;
quit;
