-- Created: 06-Jul-2020 (Bob Heckel)
-- Poll a running scheduled job

SELECT a.value, s.sid, s.serial#, s.osuser, s.machine, s.program, s.status, s.state, s.sql_id
 FROM v$sesstat a, v$statname b, v$session s
 WHERE a.statistic# = b.statistic#  AND s.sid=a.sid 
 AND b.name = 'opened cursors current' AND username ='SETARS' and status= 'ACTIVE' order by 1 desc ;

select sql_id, child_number, sql_text, sql_fulltext from v$sql where sql_id='apfjwt0sxsgj9';

declare
  x number := 0;
begin
  for i in 1..20 loop
    SELECT a.value
      into x
     FROM v$sesstat a, v$statname b, v$session s
    WHERE a.statistic# = b.statistic#  AND s.sid=a.sid 
      AND b.name = 'opened cursors current' AND username ='SETARS' and status= 'ACTIVE' and osuser='oradba' and program like 'oracle%' 
      and sql_id='d8phwqa97rkpc';
      
    if x > 100 then
      DBMS_OUTPUT.put_line('high:' || x || ' at ' || sysdate);
    end if;
    estars.sleep(10 * 1000);
  end loop;
end;
