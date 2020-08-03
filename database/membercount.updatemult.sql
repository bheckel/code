-- On BPMS1

-- First check it...
use bpms
drop table #tmpcnt
go
select "id", month, year into #tmpcnt
from membercounts
where year='2005'
order by 2
go
select * from #tmpcnt
go

-- ...then fill in all remaining years with same cnt
use bpms
update membercounts
set "id"=172595
where year='2005' and month >= '9'
go
-- view changes
select "id", month, year
from membercounts
where year='2005'
order by 2
-- compare
select * from #tmpcnt
go
