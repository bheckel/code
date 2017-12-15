-- For all time_transacts rows, find user's real name (via the
-- users/employee_data tbls) and sum the hours (from time_transacts tbl).
--
-- So the link is employee number in time_transacts, to employee_id in users
-- tbl to last_name, first_name in employee_data tbl.

select e.first_name||' '||e.last_name, SUM(t.hours) 
from users u, employee_data e, time_transacts t
where u.module_name     = 'IWS' 
  and u.attribute       = 'employee_id' 
  and u.attribute_value = e.employee_id
  and t.employee_id     = e. employee_id
  and t.time between TO_DATE('7/10/2001', 'mm/dd/yyyy')
                 and TO_DATE('7/24/2001', 'mm/dd/yyyy')
group by e.first_name||' '||e.last_name

-- users tbl sample:
-- 1006|IWS|role||dev
-- 1006|phone|permissions|0|fullview
-- 1006|IWS|employee_id||15833

-- employee_data tbl sample:
-- HECKEL|ROBERT|3R1610|224-5146|MA-2107|||919-844-0641|RobertHeckel@solectron.com|15833|5/22/2001 10:28:44 AM

-- time_transacts tbl sample:
-- 103|7/12/2001 11:18:42 AM|15833|3R1610|1|2|vaca|7/5/2001|9|ok
-- 125|7/23/2001 4:27:01 PM|15833|3R1610|1|1|sust|7/16/2001|0.5|
-- 149|7/11/2001 12:59:41 PM|12345|3r9999|1|2|vaca|7/25/2001|0.5|
-- 150|7/12/2001 12:59:41 PM|12345|3r9999|1|2|vaca|7/25/2001|1|
