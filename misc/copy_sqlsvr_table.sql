-- On bpms1
use sandbox
select * into rheckel.ncpresc
from [wnetbpms1\production].bpms.dbo.t_ref_bpms_prescriber_info
where [plancode]='nc'
