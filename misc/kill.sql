--alias kil='cd && sqlplus -S setars/xxx@sed @kill.sql && cd -'
set linesize 250;
column x format a35;
column sql_text format a160;
select distinct  'exec sys.kill_session(' || sid || ',' || serial# || ');' x, q.sql_text from v$session s, v$sql q where s.sql_id=q.sql_id(+) and osuser='bheck' and sql_text is not null;
/* quit; */
