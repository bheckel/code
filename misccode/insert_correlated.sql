
insert into EVENT_CONTACT_BASE (event_contact_ID, contact_ID,  event_ID, requestedInformation, created,createdBy,updated,updatedBy,h_version,current_status,status_date) 
select                   d_event_contact.nextval, t.contact_ID,2606480,  0,                    sysdate,        0,sysdate, 0,0,1,to_date('05/07/2018','mm/dd/yyyy')
from orion_28746_contacts t
where not exists(select 1 from event_contact ec where ec.contact_id = t.contact_id and ec.EVENT_ID=2606480); --36117 inserted (1 dup, for contact id 10215186, cleaned up after...)
