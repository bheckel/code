insert into target_bricks ( brick_id, colour, shape ) 
  select sb.brick_id, sb.colour, sb.shape  
  from   source_bricks sb 
  where  not exists ( 
    select * from target_bricks tb 
    where  sb.brick_id = tb.brick_id 
  );  

---

insert into EVENT_CONTACT_BASE (event_contact_ID, contact_ID,  event_ID, requestedInformation, created,createdBy,updated,updatedBy,h_version,current_status,status_date) 
select                   d_event_contact.nextval, t.contact_ID, 2606480,                    0,   sdate,        0,sysdate,        0,0         ,1,            to_date('05/07/2018','mm/dd/yyyy')
from orion_28746_contacts t
where not exists(select 1 from event_contact ec where ec.contact_id = t.contact_id and ec.EVENT_ID=2606480);
