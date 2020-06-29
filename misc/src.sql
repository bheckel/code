
set define off;

set termout off

set pagesize 0

set linesize 4000

spool c:/temp/t.out

select text from SYS.USER_SOURCE t WHERE t.name = upper('data_maintenance') ORDER BY type, line;
/* select text from SYS.USER_SOURCE t WHERE t.name = upper('accounts') ORDER BY type, line; */

spool off

exit
