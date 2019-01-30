EXPLAIN PLAN FOR
  SELECT *
  FROM email_messages t 
--WHERE  t.execute_time BETWEEN to_date('2019-01-16:09:00','YYYY-MM-DD:HH24:MI') AND to_date('2019-01-16:11:00','YYYY-MM-DD:HH24:MI'); --debug 
  WHERE t.actual_updated > (SYSTIMESTAMP - INTERVAL '444' minute);
 
select plan_table_output
--from table(dbms_xplan.display('plan_table',null,'basic'));
--from table(dbms_xplan.display('plan_table',null,'basic +predicate +cost'));
from table(dbms_xplan.display('plan_table',null,'typical'));

ROLLBACK;
