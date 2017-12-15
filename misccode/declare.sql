
declare @num varchar(30)
select @num = '99'
print @num
use bpms
select top 10 *
from t_ref_bpms_prescriber_info
where specialty1=@num
