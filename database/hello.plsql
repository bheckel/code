-- @"C:\cygwin64\home\bheck\code\database\hello.plsql"
-- Mandatory when using dbms_output.put_line in SQL*Plus
set serveroutput on

declare
  n  NUMBER default 0;
  d  DATE default SYSDATE;
begin
  DBMS_OUTPUT.enable(NULL);  -- max buffer
  DBMS_OUTPUT.enable(SYSTIMESTAMP);
  DBMS_OUTPUT.put_line('Hello World ' || n || ' ' || d);
end;
/
