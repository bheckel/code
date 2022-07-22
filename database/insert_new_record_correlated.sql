-- Modified: 04-Feb-2020 (Bob Heckel)
-- see also restore_records_from_hist.sql

-- Insert data from a query

insert into target_bricks ( brick_id, colour, shape ) 
  select sb.brick_id, sb.colour, sb.shape  
  from   source_bricks sb 
  where  not exists ( 
    select * from target_bricks tb 
    where  sb.brick_id = tb.brick_id 
  );  

---

insert into EVENT_CONTACT_BASE (event_contact_ID,        contact_ID,   event_ID, current_status,status_date) 
select                          d_event_contact.nextval, t.contact_ID, 2606480,  to_date('05/07/2018','mm/dd/yyyy')
from orion_28746_contacts t
where not exists(select 1 from event_contact ec where ec.contact_id = t.contact_id and ec.EVENT_ID=2606480);

---

-- Deep copy a table

SELECT dbms_metadata.get_ddl('TABLE','EMP','ADMIN') FROM DUAL;

-- Use the output to run the CREATE TABLE

-- Fill it
insert into scott.emp select * from admin.emp;

---

-- Restore from history put it back
insert into contact_base (
TYPE, DEPT, PREFIX, GENDER, SUFFIX, CREATED, UPDATED, DATEGONE, NICKNAME, UPDATEDBY, CREATEDBY, PDBSOURCE, LAST_NAME
)
(select
TYPE, DEPT, PREFIX, GENDER, SUFFIX, CREATED, UPDATED, DATEGONE, NICKNAME, UPDATEDBY, CREATEDBY, PDBSOURCE, LAST_NAME
from contact_hist
where contact_id=9999999 and wm_optype='D'
);

---

-- Insert the parent row. Unless the parent has already been added.
INSERT INTO xsp_processing_territory (xsp_processing_territory_id, xsp_processing_request_id, territory_lov_id, CREATED, CREATEDBY)
     SELECT UID_XSP_PROCESSING_TERRITORY.NEXTVAL, process_request_id, terr_id, process_date, employee_id
       FROM DUAL
      WHERE terr_id NOT IN (SELECT t.territory_lov_id FROM xsp_processing_territory t);
