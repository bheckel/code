
--/home/boheck/bin/sqlcl/bin/sql -S setars/mypw@rondbuat01rw @t.sql
--  while true; do sqlplus -S setars/mypw@esr @t.sql; sleep 20; done
--set echo on
set termout off

spool c:\orion\workspace\orion-data\Source\SQL_Views\RPT_PLAN_TO_GOAL_BELGIUM.sql
ddl RPT_PLAN_TO_GOAL_BELGIUM
spool off
spool c:\orion\workspace\orion-data\Source\SQL_Views\RPT_PLAN_TO_GOAL_CANADA.sql
ddl RPT_PLAN_TO_GOAL_CANADA
spool off
spool c:\orion\workspace\orion-data\Source\SQL_Views\RPT_PLAN_TO_GOAL_CZECH.sql
ddl RPT_PLAN_TO_GOAL_CZECH
spool off

set termout on
exit;
