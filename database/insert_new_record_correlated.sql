-- Modified: 29-Aug-2022 (Bob Heckel)
-- see also restore_records_from_hist.sql

-- Insert new data from a query
insert into target_bricks ( brick_id, colour, shape ) 
  select sb.brick_id, sb.colour, sb.shape  
    from source_bricks sb 
   where not exists ( 
    select * 
      from target_bricks tb 
     where sb.brick_id = tb.brick_id 
  );  

---

insert into EVENT_CONTACT_BASE (event_contact_ID,        contact_ID,   event_ID, current_status,status_date) 
select                          d_event_contact.nextval, t.contact_ID, 2606480,  to_date('05/07/2018','mm/dd/yyyy')
from orion_28746_contacts t
where not exists (select 1 from EVENT_CONTACT_BASE ec where ec.contact_id = t.contact_id and ec.EVENT_ID=2606480);

---

-- Deep copy a table

SELECT dbms_metadata.get_ddl('TABLE','EMP','ADMIN') FROM DUAL;

-- Use the output to run the CREATE TABLE

-- Fill it
insert into scott.emp select * from admin.emp;

---

-- Restore from history put it back
insert into contact_base (
TYPE, DEPT, PREFIX, GENDER, SUFFIX, WM_OPTYPE
)
(select
TYPE, DEPT, PREFIX, GENDER, SUFFIX, 'DR'
from contact_hist
where contact_id=9999999 and wm_optype='D'
);

---

-- Add a new INC record for each existing matching subsidiary
insert into zbob ( SALESGROUP, SUBSIDIARY_NAME, ADMINISTERING_COUNTRY_CD, STATUS, REVSTATE, SUBSIDIARY ) 
  select s.SALESGROUP, s.SUBSIDIARY_NAME, s.ADMINISTERING_COUNTRY_CD, s.STATUS, s.REVSTATE, o.SUBSIDIARYINC
  from zbob s, rion_60387 o  -- o has the extra INCs
 where s.subsidiary = o.subsidiary
