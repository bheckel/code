
create or replace trigger mailing_list_registration_date
  before insert on mailing_list
    for each row
    when (new.registration_date is null)
  begin
   :new.registration_date := sysdate;
end;

---

create or replace trigger mailing_list_update
  before update on mailing_list
    for each row
    when (new.name <> old.name)
  begin
    -- user is changing his or her name record the fact in an audit table
    insert into mailing_list_name_changes (old_name, new_name)
    values (:old.name, :new.name);
end;
/
show errors

---

CREATE OR REPLACE TRIGGER CONTACT_NOTE_IUD
  BEFORE INSERT OR UPDATE OR DELETE ON CONTACT_NOTE
  FOR EACH ROW declare bypass_flag varchar2(6);
  begin
		if (INSERTING) then
			if (:new.AUDIT_SOURCE is null) then
				:new.AUDIT_SOURCE := nvl(sys_context('USERENV', 'HOST'), 'Unknown');
			end if; 
			
			if (:new.updated is null) then
				:new.updated := sysdate;
			end if;

			if (:new.updatedby is null) then
				:new.updatedby := nvl(sys_context('setars_context', 'employee_id'),
															0);
			end if;
		end if;

		if (UPDATING) Then 
			if ((:old.ACTUAL_UPDATED is null) or
				 (nvl(:new.ACTUAL_UPDATED, :old.ACTUAL_UPDATED) =
				 :old.ACTUAL_UPDATED)) Then
				:new.ACTUAL_UPDATED := systimestamp;
			end if;

			if ((:old.ACTUAL_UPDATEDBY is null) or
				 (nvl(:new.ACTUAL_UPDATEDBY, :old.ACTUAL_UPDATEDBY) =
				 :old.ACTUAL_UPDATEDBY)) Then
				:new.ACTUAL_UPDATEDBY := nvl(sys_context('setars_context',
																								 'actual_employee_id'),
																		 nvl(sys_context('setars_context',
																								 'employee_id'),0));
			end if;

			if NOT UPDATING('H_VERSION') Then
				:new.H_VERSION := nvl(:old.H_VERSION, 0) + 1;
			end if;

			if NOT UPDATING('UPDATED') then
				:new.updated := sysdate;
			end if;

			if NOT UPDATING('UPDATEDBY') then
				:new.updatedby := nvl(sys_context('setars_context', 'employee_id'),
															0);
			end if;  

			INSERT /*+ append */ INTO CONTACT_NOTE_HIST (TASK_ID, UPDATED, CREATED, NOTE_ID, H_VERSION, UPDATEDBY, CREATEDBY, CONTACT_ID, ACTIVITY_ID, AUDIT_SOURCE, RETIRED_TIME, ACTUAL_UPDATED, CONTACT_NOTE_ID, ACTUAL_UPDATEDBY, ORIGINAL_CONTACT_ID,WM_OPTYPE)
      VALUES(:old.TASK_ID, :old.UPDATED, :old.CREATED, :old.NOTE_ID, :old.H_VERSION, :old.UPDATEDBY, :old.CREATEDBY, :old.CONTACT_ID, :old.ACTIVITY_ID, :old.AUDIT_SOURCE, (systimestamp - INTERVAL '0.001' SECOND), :old.ACTUAL_UPDATED, :old.CONTACT_NOTE_ID, :old.ACTUAL_UPDATEDBY, :old.ORIGINAL_CONTACT_ID,decode(:old.H_VERSION,0,'I','U')); end if; if (DELETING) then /*Deleting*/         INSERT /*+ append */ INTO CONTACT_NOTE_HIST (TASK_ID, UPDATED, CREATED, NOTE_ID, H_VERSION, UPDATEDBY, CREATEDBY, CONTACT_ID, ACTIVITY_ID, AUDIT_SOURCE, RETIRED_TIME, ACTUAL_UPDATED, CONTACT_NOTE_ID, ACTUAL_UPDATEDBY, ORIGINAL_CONTACT_ID,WM_OPTYPE) VALUES(:old.TASK_ID, :old.UPDATED, :old.CREATED, :old.NOTE_ID, :old.H_VERSION, :old.UPDATEDBY, :old.CREATEDBY, :old.CONTACT_ID, :old.ACTIVITY_ID, :old.AUDIT_SOURCE, (systimestamp - INTERVAL '0.001' SECOND), :old.ACTUAL_UPDATED, :old.CONTACT_NOTE_ID, :old.ACTUAL_UPDATEDBY, :old.ORIGINAL_CONTACT_ID,decode(:old.H_VERSION,0,'I','U'));         INSERT /*+ append */ INTO CONTACT_NOTE_HIST (TASK_ID, UPDATED, CREATED, NOTE_ID, H_VERSION, UPDATEDBY, CREATEDBY, CONTACT_ID, ACTIVITY_ID, AUDIT_SOURCE, RETIRED_TIME, ACTUAL_UPDATED, CONTACT_NOTE_ID, ACTUAL_UPDATEDBY, ORIGINAL_CONTACT_ID,WM_OPTYPE) VALUES(:old.TASK_ID, sysdate, :old.CREATED, :old.NOTE_ID, :old.H_VERSION, nvl(sys_context('setars_context','employee_id'),0), :old.CREATEDBY, :old.CONTACT_ID, :old.ACTIVITY_ID, nvl(sys_context('USERENV', 'HOST'), 'Unknown'), (systimestamp + INTERVAL '0.001' SECOND), systimestamp, :old.CONTACT_NOTE_ID, nvl(sys_context('setars_context','actual_employee_id'),nvl(sys_context('setars_context','employee_id'),0)), :old.ORIGINAL_CONTACT_ID,'D');
		end if;
end;

