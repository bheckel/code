
-- Run this then diff the resulting .LST files:
-- $ sqlplus gdm_dist_r/xxxce45read@xxxrd613 @compare_schemas.sql

set termout off
spool u:/tmp/gdmschemaCURR1;
describe gdm_dist.vw_xxxt_rpt_results_nl;
spool off;

exit;

