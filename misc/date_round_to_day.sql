-- SQL Server
-- Allow a GROUP BY query to not be distracted by time minutes/seconds
use bpms_nc
select cast(insert_date as char(11)), count(cast(insert_date as char(11)))
from Claims_More_Info
group by cast(insert_date as char(11))
