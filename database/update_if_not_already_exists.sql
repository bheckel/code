
-- Created: 09-Jan-19 (Bob Heckel) 

-- See also merge_upsert.sql

-- Use self-join in a correlated subquery to change all 'Viay' to 'Viay (Analytics Platform)' where it's not already 
-- set to 'Viay (Analytics Platform)'
update INITIATIVE i1
   set corporate_initiative = 'Viay (Analytics Platform)' 
 where corporate_initiative = 'Viay' 
   and not exists (select 1
                  from INITIATIVE i2
                  where i1.reference_id=i2.reference_id and i2.corporate_initiative='Viay (Analytics Platform)');

---

create table emptmp as select * from emp;

update emptmp set job='salesmanx' where empno=7499;
commit;

select count(1) from emptmp where job='SALESMAN'; -- 3

-- 3 updated
update emptmp e1
   set job='salesmanx' 
 where job='SALESMAN'
   and not exists ( select 1 
                      from emptmp e2
                     where e1.empno = e2.empno and e2.job = 'salesmanx');

select count(1) from emptmp where job='salesmanx'  -- 4;

drop table emptmp purge;
