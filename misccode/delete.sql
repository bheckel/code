
delete target_bricks tb 
where  exists ( 
  select * from source_bricks sb 
  where  sb.brick_id = tb.brick_id 
  and    sb.colour = 'red' 
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

---

-- Find the newest record in a duplicated pair
/* select opportunity_employee_id, opportunity_id, employee_id */
delete
  from opportunity_employee_base
 where opportunity_id in(
         select oe.opportunity_id
           from opportunity_employee_base oe
          where oe.owner_type = 'P'
          group by opportunity_id
         having count(1) > 1
)
and owner_type = 'P'
and rowid in (select max(rowid)
                from opportunity_employee_base
               group by opportunity_id, owner_type)
;
