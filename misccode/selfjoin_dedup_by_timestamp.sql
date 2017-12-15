
-- Dedup:  

select a.pkey,                                      -- 2. get latest event value
       a.tstamp,
       max(a.event)                                 -- 3. only want 1 rec per tstamp so keep only the highest one if find >1
from tbl a join (select pkey as mypkey,             -- 1. get latest tstamp for all pkey recs
                        max(tstamp) as mytstamp
                        from tbl
                        group by pkey) b
where a.pkey=b.mypkey and a.tstamp=b.mytstamp
group by a.pkey, a.tstamp
