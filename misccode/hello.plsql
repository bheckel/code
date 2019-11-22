-- Mandatory when using dbms_output.put_line in SQL*Plus
set serveroutput on

declare
  x number;
begin
  dbms_output.enable;
  dbms_output.put_line('Hello World');
end;
/
