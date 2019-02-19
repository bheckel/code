-- $ sqlplus -S estars/pw@sed @t.sql
--
-- or if this file has been saved as ~/src.sql:
--
--#!/bin/bash
--
--vim ~/bin/src.sql
--echo 'now run:'
--echo 'cd ~/bin && sqlplus -S estars/mypw@sed @src.sql && vi $c/temp/t.out'

set termout off

set pagesize 0

set linesize 4000

spool c:/temp/t.out

select * from SYS.USER_SOURCE t WHERE t.name = upper('user_on_call') ORDER BY type, line;

spool off

exit
