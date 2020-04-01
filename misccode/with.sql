-- Modified: Wed 19 Jun 2019 08:45:28 (Bob Heckel)

-- Common table expression CTE

with account_name as (
	select 5645818 account_name_id, 5645818 account_id from dual union all
	select 7934046 account_name_id, 5645818 account_id from dual union all
	select 123 account_name_id, 456 account_id from dual union all
	select 14036780 account_name_id, 5645818 account_id from dual
) 
select w.account_id, cw, cwo, cw-cwo diff
from 
	(select account_id, count(*) cw
	from account_name 
	group by account_id) w,
	(select account_id, count(*) cwo
	from account_name 
	where account_name_id <> account_id
	group by account_id) wo
where w.account_id=wo.account_id

---

-- Compare table to csv list (4K max len) of numbers

SELECT ids, ab.account_id 
FROM (WITH DATA AS
      (SELECT '432803,434768' ids FROM dual)
      SELECT to_number(TRIM(regexp_substr(ids, '[^,]+', 1, LEVEL))) ids
      FROM DATA
      CONNECT BY instr(ids, ',', 1, LEVEL - 1) > 0) csv LEFT JOIN account_base ab ON csv.ids=ab.account_id

-- or better
SELECT aid, ab.account_id 
FROM (SELECT to_number(column_value) aid
      FROM xmltable(('"' || REPLACE('432803,434768', ',', '","') || '"'))) csv LEFT JOIN account_base ab ON csv.aid=ab.account_id

---

-- Subquery factoring to determine which color brick has a greater than average count
with brick_colour_counts as (
  select colour, count(*) colour_count
  from   bricks
  group  by colour
), avg_bricks_per_colour as (
  select avg ( colour_count ) mean_colours 
  from   brick_colour_counts
)
  select colour
  from   brick_colour_counts bcc join   avg_bricks_per_colour abpc on     bcc.colour_count > abpc.mean_colours;

---

-- Dummy up data
with v as (
          select date '2000-01-01' d, 10 amt from dual
union all select date '2000-01-02', 11 from dual
union all select date '2000-01-03', 30 from dual
union all select date '2000-01-04', 10 from dual
union all select date '2000-01-05', 14 from dual
)
select d
      ,amt
      ,avg(amt) over (order by d rows between 1 preceding and 1 following) moving_window_avg
      ,sum(amt) over (order by d rows between unbounded preceding and current row) cumulative_sum
FROM v;

-- same
with v (d, amt) as (
          select date '2000-01-01', 10 from dual
union all select date '2000-01-02', 11 from dual
union all select date '2000-01-03', 30 from dual
union all select date '2000-01-04', 10 from dual
union all select date '2000-01-05', 14 from dual
)
select d
      ,amt
      ,avg(amt) over (order by d rows between 1 preceding and 1 following) moving_window_avg
      ,sum(amt) over (order by d rows between unbounded preceding and current row) cumulative_sum
FROM v;

---

with a as(
  select sys_connect_by_path(job, '/') job_path, sys_connect_by_path(ename, '/') ename_path
  from scott.emp
  start with mgr is null
  connect by prior empno = mgr)
select regexp_substr(ename_path, '[^/]+', 1, 1) e1,
       regexp_substr(job_path, '[^/]+', 1, 1) j1,
       regexp_substr(ename_path, '[^/]+', 1, 2) e2,
       regexp_substr(job_path, '[^/]+', 1, 2) j2,
       regexp_substr(ename_path, '[^/]+', 1, 3) e3,
       regexp_substr(job_path, '[^/]+', 1, 3) j3
from a

-- same

select regexp_substr(ename_path, '[^/]+', 1, 1) e1,
       regexp_substr(job_path, '[^/]+', 1, 1) j1,
       regexp_substr(ename_path, '[^/]+', 1, 2) e2,
       regexp_substr(job_path, '[^/]+', 1, 2) j2,
       regexp_substr(ename_path, '[^/]+', 1, 3) e3,
       regexp_substr(job_path, '[^/]+', 1, 3) j3
from (
  select sys_connect_by_path(job, '/') job_path,sys_connect_by_path(ename, '/') ename_path
  from scott.emp
  start with mgr is null
  connect by prior empno = mgr
)

-- same

select *
from (
  select regexp_substr(ename_path, '[^/]+', 1, 1) e1,
         regexp_substr(job_path, '[^/]+', 1, 1) j1,
         regexp_substr(ename_path, '[^/]+', 1, 2) e2,
         regexp_substr(job_path, '[^/]+', 1, 2) j2,
         regexp_substr(ename_path, '[^/]+', 1, 3) e3,
         regexp_substr(job_path, '[^/]+', 1, 3) j3
  from (
    select sys_connect_by_path(job, '/') job_path,sys_connect_by_path(ename, '/') ename_path
    from scott.emp
    start with mgr is null
    connect by prior empno = mgr
  ) 
)

---

with val as (
values ('1003033101'),	('1003048109'),	('1003109422')
)
select column1 as npi, 
       count(*),
       count(distinct cardholderid) as distinct_count,
       sum(case when h.atebpatientid is null then 1 else 0 end) as no_match,
       sum(case when h.atebpatientid is not null then 1 else 0 end) as match
from val v
left join healthplan_mdf_uhc h on h.npi=v.column1 and h.importsourceid in (14167,14171,15339)
group by 1
order by 1
;

---

-- Practical Oracle SQL Kim Berg Hansen
-- 12c+
with
   function gram_alcohol (
      p_volume in number
    , p_abv    in number
   ) return number deterministic
   is
   begin
      return p_volume * p_abv / 100 * 0.789;
   end;
   function gram_body_fluid (
      p_weight in number
    , p_gender in varchar2
   ) return number deterministic
   is
   begin
      return p_weight * 1000 * case p_gender
                                  when 'M' then 0.68
                                  when 'F' then 0.55
                               end;
   end;
   function bac (
      p_volume in number
    , p_abv    in number
    , p_weight in number
    , p_gender in varchar2
   ) return number deterministic
   is
   begin
      return round(
         100 * gram_alcohol(p_volume, p_abv)
          / gram_body_fluid(p_weight, p_gender)
       , 3
      );
   end;
select
   p.id as p_id
 , p.name
 , pa.sales_volume as vol
 , pa.abv
 , bac(pa.sales_volume, pa.abv, 80, 'M') bac_m
 , bac(pa.sales_volume, pa.abv, 60, 'F') bac_f
from products p
join product_alcohol pa
   on pa.product_id = p.id
where p.group_id = 142
order by p.id
/

