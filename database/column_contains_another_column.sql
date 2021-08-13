
-- Created: 12-Aug-2021 (Bob Heckel)
-- Cross column comparison

--new contains current
with v as (
	select 1 num, 'abc' rev_class_current, 'one' rev_class_new from dual union all 
	select 2 num, 'ghi' rev_class_current, 'ghi' rev_class_new from dual union all 
	select 3 num, 'ghi' rev_class_current, 'ghii' rev_class_new from dual union all
	select 4 num, 'ghiii' rev_class_current, 'ghi' rev_class_new from dual
) 
select *
from v
where regexp_like(rev_class_new, rev_class_current, 'i');
/*
       NUM REV_C REV_
---------- ----- ----
         2 ghi   ghi 
         3 ghi   ghii

*/


--new does not contain current
with v as (
	select 1 num, 'abc' rev_class_current, 'one' rev_class_new from dual union all
	select 2 num, 'ghi' rev_class_current, 'ghi' rev_class_new from dual union all
	select 3 num, 'ghi' rev_class_current, 'ghii' rev_class_new from dual union all
	select 4 num, 'ghiii' rev_class_current, 'ghi' rev_class_new from dual
) 
select *
from v
where not regexp_like(rev_class_current, rev_class_new, 'i')
/*
       NUM REV_C REV_
---------- ----- ----
         1 abc   one 
         3 ghi   ghii
*/         
