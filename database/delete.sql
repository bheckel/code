-- Modified: Wed 15-Apr-2020 (Bob Heckel)

delete target_bricks tb 
 where  exists ( 
          select *
            from source_bricks sb 
           where sb.brick_id = tb.brick_id 
             and sb.colour = 'red' 
);

---

-- Remove all records
delete from foo

delete foo

---

-- Oracle - remove one of two duplicates - first find unique identifier:
select ROWID
from pks_extraction_control
where meth_spec_nm='AM0735CUHPLC' and meth_var_nm='PEAKINFO';

-- then remove one of them
delete
from pks_extraction_control
where rowid='AAB5QNACDAAARalAAo';

COMMIT;

-- better

-- Find the newest record in a duplicated pair
with v as (        
	select opportunity_employee_id, opportunity_id, employee_id, actual_updated
		from opportunity_employee_base
	 where (opportunity_id, employee_id) in( select oe.opportunity_id, oe.employee_id
																						 from opportunity_employee_base oe
																						where oe.owner_type = 'S' and actual_updated > '01JAN20'
																						group by opportunity_id, employee_id
																					 having count(1) > 1 )
)
select *
  from v
 where exists ( select /*+PARALLEL*/ 1
                  from v v2
                 where v.opportunity_id = v2.opportunity_id
                   and v.actual_updated > v2.actual_updated)
;

-- or delete records with duplicate owners
delete from risk_employee where risk_employee_id in(
  with errs as (       
		select risk_id, employee_id
		from risk_employee
		group by risk_id, employee_id
		having count(1)>1
  )
  select risk_employee_id 
  from risk_employee r, errs e
  where r.risk_id=e.risk_id
);

-- or delete the older oldest record in a duplicated pair
delete
  from opportunity_employee_base 
 where opportunity_employee_id in (
         with v as (        
               select opportunity_employee_id, opportunity_id, employee_id, actual_updated
                 from opportunity_employee_base
                where (opportunity_id, employee_id) in(
                        select oe.opportunity_id, oe.employee_id
                          from opportunity_employee_base oe
                         where oe.owner_type = 'S' and actual_updated > '01JAN20'
                         group by opportunity_id, employee_id
                        having count(1) > 1
                      )
         )
         select opportunity_employee_id
           from v
          where exists ( select /*+PARALLEL(4)*/ 1
                         from v v2
                         where v.opportunity_id = v2.opportunity_id
                         and v.actual_updated < v2.actual_updated )
       );

-- or if more than one column criteria to use for deletions
delete 
--SELECT * 
  from risk_employee re
 where exists ( 
        select 1 from (
          with errs as (       
            SELECT risk_id, employee_id
            FROM risk_employee
            group by risk_id, employee_id
            having count(1)>1
          ), dups as (
            select r.risk_id, r.risk_employee_id, r.employee_id, row_number() OVER (PARTITION BY r.risk_id, trunc(r.employee_id) ORDER BY r.risk_id, r.actual_updated DESC) rownbr
            from risk_employee r, errs e
           where r.risk_id=e.risk_id
          )
          select d.risk_id, d.risk_employee_id, d.employee_id
            from dups d
           where rownbr >= 2
        )
        where re.risk_id = risk_id and re.risk_employee_id = risk_employee_id and re.employee_id = employee_id
);--delete the 2nd, 3rd... oldest dups
