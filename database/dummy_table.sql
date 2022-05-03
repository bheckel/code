with v as (
	select 'abc' account_name, 5645818 account_id from dual union all
	select 'abc' account_name, 5645818 account_id from dual union all
	select 'def' account_name, 456 account_id from dual union all
	select 'ghi' account_name, 5645818 account_id from dual
) 
select *
from v;

---

with v as (
          select date '2000-01-01' d, 10 amt from dual
union all select date '2000-01-02',   11     from dual
union all select date '2000-01-03',   30     from dual
union all select date '2000-01-03',   30     from dual
union all select date '2000-01-04',   10     from dual
union all select date '2000-01-05',   14     from dual
)
select *
from v;
