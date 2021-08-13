with v as (
	select 'abc' account_name, 5645818 account_id from dual union all
	select 'abc' account_name, 5645818 account_id from dual union all
	select 'def' account_name, 456 account_id from dual union all
	select 'ghi' account_name, 5645818 account_id from dual
) 
select *
from v;
