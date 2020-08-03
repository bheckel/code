--  sqlplus -S dgm_dist_r/lsice45read@kuprd613 @oracle_sqlplus_to_csv.sql

set colsep ,
set pagesize 0
set trimspool on
-- adjust to sum of the column widths
set linesize 110

spool tom.csv

select  mrp_batch_id, material_description
from gdm_dist.vw_lift_rpt_results_nl
where rownum < 5
;

spool off

quit;
