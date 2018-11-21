
-- It is important to understand the interaction between aggregates and SQL's
-- WHERE and HAVING clauses. 

-- WHERE selects input rows BEFORE groups and aggregates are computed (thus, it
-- controls which rows go into the aggregate computation), whereas HAVING selects
-- group rows after groups and aggregates are computed. 

-- Thus, the WHERE clause must not contain aggregate functions; it makes no sense
-- to try to use an aggregate to determine which rows will be inputs to the
-- aggregates. 

-- On the other hand, HAVING clauses always contain aggregate functions.
-- (Strictly speaking, you are allowed to write a HAVING clause that doesn't use
-- aggregates, but it's wasteful: The same condition could be used more
-- efficiently at the WHERE stage.) 

-- want patients with only 1 drug
proc sql NOprint;
  create table ntfct_upids as
  select upid
  from ntct
  group by upid
  having count(*)=1
  ;
quit;

proc sql NOprint;
  create table t1 as
  select upid, count(distinct ndc)
  from mdf
  group by upid
  having count(distinct ndc)>1
  ;
quit;

-- Some recorded_value averages produce missing values, this Oracle skips those:
select long_test_name, avg(recorded_value)
from gdm_dist.vw_lift_rpt_results_nl
where mrp_batch_id='3Z8207' 
group by long_test_name
having avg(recorded_value) is not null
--having nvl(avg(recorded_value),0) != 0


-- List all the plants that produce a prod:
select distinct gen_name_of_mat,  plant_cod
from gdm_dist.vw_merps_material_info
where gen_name_of_mat='AMICTAL'  --shows 1 prod, 5 different plants
group by gen_name_of_mat, plant_cod 

-- Summary number of plants that produce lami - for 1 prod, shows count of 5 plants:
select distinct gen_name_of_mat, count(distinct plant_cod)
from gdm_dist.vw_merps_material_info
where gen_name_of_mat='AMICTAL'
group by gen_name_of_mat--, plant_cod 

-- Find all the prods that are produced in more than 1 plant:
select distinct gen_name_of_mat, count(distinct plant_cod)
from gdm_dist.vw_merps_material_info
group by gen_name_of_mat--, plant_cod 
having count(distinct plant_cod)>1

-- Find lami mat codes shared across plants:
select distinct gen_name_of_mat,  mat_cod, plant_cod
from gdm_dist.vw_merps_material_info
where gen_name_of_mat='AMICTAL'
group by gen_name_of_mat, mat_cod , plant_cod
having count(distinct mat_cod)>1


-- Find entire duplicate rows
select *, count(*) as myCount
from Duplicates
group by LastName, FirstName, City, State
-- Can't use alias 'myCount' here!
having count(*) > 1;


-- Count the number of times a single occnum (may occur many times) has a
-- related restriction then show those that have less than 4 restrictions.
--
-- The HAVING clause is a restriction on groups in much the same way that the
-- WHERE clause is a restriction on rows.  It's always performed AFTER the 
-- GROUP BY clause.
SELECT occnum, count(restriction) as a 
FROM occxls 
GROUP BY occnum 
HAVING a < 4;


-- Check for duplicates:
SELECT state, COUNT(*)
FROM authors
GROUP BY state
HAVING COUNT(*) > 1


-- Find pairs of guids to see where they differ using subquery
select *
from crc_arch_log
where guid in (select distinct guid
               from crc_arch_log
               group by guid
               having count(guid)=2)
order by guid

---

select shape, 
       sum ( case when colour = 'red' then weight end ) red_tot_weight, 
       sum ( case when colour = 'blue' then weight end ) blue_tot_weight
from   bricks 
group  by shape
having sum ( case when colour = 'red' then weight end ) +
       sum ( case when colour = 'blue' then weight end ) > 5
order  by shape;

-- same (better)
select shape,  
       sum ( case when colour = 'red' then weight end ) red_tot_weight,  
       sum ( case when colour = 'blue' then weight end ) blue_tot_weight 
from   bricks  
group  by shape 
having sum ( weight ) > 5 
order  by shape;
