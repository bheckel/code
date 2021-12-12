-- @"C:\cygwin64\home\bheck\code\database\hello.plsql"
set serveroutput on

declare
  n  NUMBER default 0;
  d  DATE default SYSDATE;
begin
  DBMS_OUTPUT.disable;
  DBMS_OUTPUT.put_line('Hello World ' || n || ' ' || d);
  DBMS_OUTPUT.enable(NULL);  -- max buffer
  DBMS_OUTPUT.put_line('Hello again World ' || n || ' ' || d);
end;
/
