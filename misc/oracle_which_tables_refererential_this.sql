select * --constraint_name 
from all_constraints 
where constraint_type in ('P','U') 
and table_name like '%USCU%';
