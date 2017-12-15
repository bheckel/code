-- Determine spid
-- UNIX95= ps -eo user,pid,pcpu,comm | sort -nrbk3 | head -10
-- then
-- sqlplus limsarch/Ag00dpa55w0rd@usprd259 @oracle_process_id.sql 29312
SELECT a.username, 
       a.osuser, 
       a.program, 
       spid, 
       sid, 
       a.serial#
FROM   v$session a,
       v$process b
WHERE  a.paddr = b.addr
AND    spid = '&1';

exit;
