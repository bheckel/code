
-- Collapse to single day for counting
-- 01/Aug/07 01:30:08
-- 01/Aug/07 01:33:08
-- ...
select distinct trunc(prod_sel_dt) psd, count(*)
from RETAIN.FNSH_PROD 
where prod_sel_dt is not null
group by trunc(prod_sel_dt) 
order by psd desc
