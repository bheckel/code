-- Mandatory when using dbms_output.put_line in SQL*Plus
set serveroutput on

declare
  x number;
begin
  dbms_output.enable;
  dbms_output.put_line('Hello World');
end;
/

---

declare
  x number := 0;
begin
  for i in 1..20 loop
    SELECT a.value
      into x
     FROM v$sesstat a, v$statname b, v$session s
    WHERE a.statistic# = b.statistic#  AND s.sid=a.sid 
      AND b.name = 'opened cursors current' AND username ='ESTARS' and status= 'ACTIVE' and osuser='oradba' and program like 'oracle%' 
      and sql_id='d8phwqa97rkpc';
      
    if x > 100 then
      DBMS_OUTPUT.put_line('high:' || x || ' at ' || sysdate);
    end if;
    setars.sleep(10 * 1000);
  end loop;
end;
