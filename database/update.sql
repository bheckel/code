--  Created: 01-May-2020 (Bob Heckel)
-- Modified: 03-Jul-2023 (Bob Heckel)

---

update account_name
   set account_name = 'M-Team BV',
       updated = updated,
       updatedby = updatedby, 
       audit_source = 'MDMT-241'
 where account_name_id = (
    select distinct an.account_name_id
      from account_name an, account_name_attribute ana
     where an.account_name_id =10215333
       and ana.account_name_type = 'L'
    )
;

---

update user_role
set user_status='I', updated_by_patron_id='sh86800'
where user_status='A' and user_patron_id in('qm97071')

commit;

---

-- Update target tbl (tb) using another source tbl (sb). CTEs won't work here.
update target_bricks tb 
set ( tb.colour, tb.shape ) = ( 
  select sb.colour, sb.shape  
  from   source_bricks sb 
  where  sb.brick_id=tb.brick_id 
) 
where exists ( 
  select * from source_bricks sb 
  where  sb.brick_id=tb.brick_id 
); 


-- Setup data to damage
create table z_emp as select * from emp;
create table z_dept as select * from dept;
update z_emp set job=null;

-- For no good reason, update the job description with the user's location if they're new hires
UPDATE z_emp tb 
SET tb.job  = (
  select sb.loc  
    from z_dept sb 
   where sb.deptno=tb.deptno
) 
WHERE EXISTS ( 
  select 1 
    from z_dept sb 
   where sb.deptno=tb.deptno and tb.hiredate>'01JAN82'
); 
COMMIT;

---

-- When you run an update it locks the rows defined by your where clause. No
-- other sessions can change these rows until your update completes and you
-- commit it or roll it back.

-- Update a table using a query to represent the table instead of the table name
update (
  select * from bricks 
   where  shape = 'circle'
)
set width = NULL;

---

-- Optimistic Locking - Stops lost updates
-- Verify cols you're not updating are same in WHERE clause.

-- Pessimistic Locking - Stops deadlocks
-- If this is the first statement in your transaction it will lock both of these rows.
-- Session 2 must wait until the first commits. Thus deadlock is impossible if your 
-- application is STATEFUL (unlike web apps where reading and writing the data
-- are separate transactions).
select * from accounts where account_id in (1, 2) FOR UPDATE;

---

-- For all movies that have an average rating of 4 stars or higher, add 25 to
-- the release year
update movie
  set year=year+25
  where mid in(
    select distinct a.mid
    from movie a, rating b
    where a.mid=b.mid 
    group by a.mid
    having avg(stars)>=4
  )

---

 /* Update the pharmacy field of claims_pharmacy using temporary lookup table
  * vapharm 
  */
use bpms_va
update claims_pharmacy
set claims_pharmacy.pharmacy = b.pharmacy
from [WNETBPMS1\Production].sandbox.rheckel.vapharm b
where claims_pharmacy.claim_id = b.claim_id

 /* Update the prescriber_id using the DEA table if there is no prescriber_id
  * already 
  */
update #tmpclp
set #tmpclp.prescriber_id = b.prescriber_dea_num
from claims_more_info b
where #tmpclp.claim_id = b.claim_id and prescriber_id is null

 /* Replace, substitute, 2 consecutive spaces with a single space (can run
  * multiple times to remove 3+ spaces).  SQL Server.  
  * Subselect is unnecessary (on Oracle at least).
  */
update claims_pharmacy
set insured_name = (select replace(insured_name, '  ', ' '))

---

update pks_extraction_control 
set pks_cntrl_notes_txt=REPLACE(pks_extraction_cntrl_notes_txt,'GEN','Gen') 
where pks_extraction_cntrl_notes_txt like '%GEN%';

---

update retain.fnsh_prod
  set prod_sel_dt = to_date('01-APR-10 01:30:00', 'DD-MON-YY HH24:MI:SS')
  where prod_sel_dt > to_date('01-APR-10 01:31:00', 'DD-MON-YY HH24:MI:SS')

commit;

---

-- Update two columns tb=target sb=source
UPDATE task_base tb 
SET  (tb.owner_territory_lov_id, tb.updatedby)  = (
  select sb.territory_lov_id, sb.updatedby
    from employee_base sb 
   where sb.employee_id=tb.employee_id
) 
WHERE EXISTS ( 
  select 1
    from employee_base sb 
   where sb.employee_id=tb.employee_id
     and tb.actual_updated>'19JAN20'
     and (tb.audit_source='me' or tb.actual_updatedby=4488)
     and tb.current_task=1 and tb.owner_territory_lov_id is null
);
