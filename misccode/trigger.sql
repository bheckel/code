--Oracle PL/SQL

CREATE OR REPLACE TRIGGER ***trigger name***
***when*** ON ***which table***
FOR EACH ROW
***conditions for firing***
begin
  ***stuff to do***
end;



create trigger mailing_list_registration_date
before insert on mailing_list
for each row
when (new.registration_date is null)
begin
 :new.registration_date := sysdate;
end;



create or replace trigger mailing_list_update
before update on mailing_list
for each row
when (new.name <> old.name)
begin
  -- user is changing his or her name
  -- record the fact in an audit table
  insert into mailing_list_name_changes
    (old_name, new_name)
  values
    (:old.name, :new.name);
end;
/
show errors
