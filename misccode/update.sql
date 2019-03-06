
update user_role
set user_status='I', updated_by_patron_id='sh86800'
where user_status='A' and user_patron_id in('qm97071')

commit;

---

-- Update target tbl using source tbl
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

-- If this is the first statement in your transaction it will lock both of these rows.
-- Session 2 must wait until the first commits. Thus deadlock is impossible.
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
