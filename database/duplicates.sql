/* Remove delete duplicate rows keeping just the newest */

--Best
DELETE FROM kmc_deal_summary_full_prod_17oct24 a
WHERE a.ROWID > (
    SELECT MIN(b.ROWID)
    FROM kmc_deal_summary_full_prod_17oct24 b
    WHERE a.kmc_deal_summary_id = b.kmc_deal_summary_id
);

---

/* Fail, we lost both of the 30s: */
with v as (
          select date '2000-01-01' d, 10 amt from dual
union all select date '2000-01-02', 11 from dual
union all select date '2000-01-03', 30 from dual
union all select date '2000-01-03', 30 from dual
union all select date '2000-01-03', 31 from dual
union all select date '2000-01-04', 10 from dual
union all select date '2000-01-05', 14 from dual
)
select d, amt 
from v
group by d, amt
having count(1)=1
order by 1
/*
D	AMT
01-JAN-00	10
02-JAN-00	11
03-JAN-00	31
04-JAN-00	10
05-JAN-00	14
*/


--same

with v as (
          select date '2000-01-01' d, 10 amt from dual
union all select date '2000-01-02', 11 from dual
union all select date '2000-01-03', 30 from dual
union all select date '2000-01-03', 30 from dual
union all select date '2000-01-03', 31 from dual
union all select date '2000-01-04', 10 from dual
union all select date '2000-01-05', 14 from dual
)
select * from
  (select d
        ,amt
        ,row_number() OVER (partition by d,amt order by d) r

  FROM v
  )
where r = 1
/*
D	AMT	r
01-JAN-00	10	1
02-JAN-00	11	1
03-JAN-00	30	1
03-JAN-00	31	1
04-JAN-00	10	1
05-JAN-00	14	1
*/


/* Add a younger amt of 30 and keep only that i.e. keep the most recent of the dups */
with v as (
          select date '2000-01-01' d, 10 amt from dual
union all select date '2000-01-04', 10 from dual
union all select date '2000-01-02', 11 from dual
union all select date '2000-01-05', 14 from dual
union all select date '2000-01-03', 30 from dual
union all select date '2000-01-03', 30 from dual
union all select date '2000-01-04', 30 from dual  -- <---keep
union all select date '2000-01-03', 31 from dual
)
select * from
  (select d
         ,amt
         ,row_number() OVER (partition by amt order by d DESC) r
   from v
  )
where r = 1
/*
D	AMT	r
1/2/2000	11	1
1/3/2000	31	1
1/4/2000	30	1
1/4/2000	10	1
1/5/2000	14	1
*/

---

-- Dedup deduplicate by timestamp - where there are multiple event ids, take the latest tstamp:  
with tbl as (
          select 1 as num, TIMESTAMP '2000-01-01 08:26:50' tstamp, 10 event from dual
union all select 2, TIMESTAMP '2000-01-02 08:26:51', 11 from dual
union all select 3, TIMESTAMP '2000-01-03 08:26:52', 30 from dual
union all select 3, TIMESTAMP '2000-01-03 08:26:53', 30 from dual
union all select 5, TIMESTAMP '2000-01-03 08:26:54', 31 from dual
union all select 1, TIMESTAMP '2000-01-04 08:26:55', 10 from dual
union all select 7, TIMESTAMP '2000-01-05 08:26:56', 14 from dual
)
select a.num,                 -- 2. get latest event value
       a.tstamp,
       max(a.event)           -- 3. only want 1 rec per tstamp so keep only the highest one if find >1
from tbl a JOIN (select num,  -- 1. get latest tstamp for all num recs
                        max(tstamp) as mytstamp
                        from tbl
                        group by num) b ON a.num=b.num and a.tstamp=b.mytstamp
group by a.num, a.tstamp

-- same

with tbl as (
          select 1 as num, TIMESTAMP '2000-01-01 08:26:50' tstamp, 10 event from dual
union all select 2, TIMESTAMP '2000-01-02 08:26:51', 11 from dual
union all select 3, TIMESTAMP '2000-01-03 08:26:52', 30 from dual
union all select 3, TIMESTAMP '2000-01-03 08:26:53', 30 from dual
union all select 5, TIMESTAMP '2000-01-03 08:26:54', 31 from dual
union all select 1, TIMESTAMP '2000-01-04 08:26:55', 10 from dual
union all select 7, TIMESTAMP '2000-01-05 08:26:56', 14 from dual
)
select *
from (
  select num, 
         tstamp,
         event,
         row_number() OVER (partition by num order by tstamp DESC) r
  from tbl 
)
where r=1
order by event
/*
   	NUM	TSTAMP	EVENT	R
1	1	04-JAN-00 08.26.55.000000000 AM	10	1
2	2	02-JAN-00 08.26.51.000000000 AM	11	1
3	7	05-JAN-00 08.26.56.000000000 AM	14	1
4	3	03-JAN-00 08.26.53.000000000 AM	30	1
5	5	03-JAN-00 08.26.54.000000000 AM	31	1
*/
