-- SQL Server example runs on BPMS1
use bpms
select  A.prescriber_id, B.*
from [W23PSQL02\Production].bpms_mo.dbo.bpmsoutliers A left join t_ref_bpms_prescriber_info B  on A.prescriber_id=B.prescriber_id
order by a.prescriber_id
