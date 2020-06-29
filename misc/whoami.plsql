-- Run this 1st SQL*Plus:
set serveroutput on

-- Then submit this:
declare
  v_usr varchar2(30);
begin
  select sys_context('userenv', 'current_user') into v_usr from dual;
  dbms_output.put_line(v_usr|| ' ran rpt at: ' || TO_CHAR(sysdate, 'dd-mon-yy hh:mipm'));
end;
