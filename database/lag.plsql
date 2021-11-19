--  Created: 06-May-2019 (Bob Heckel) 
-- Modified: 19-Nov-2021 (Bob Heckel)

---

with v as (
  select MSG, REQUEST_ID, EXECUTE_TIME, EXECUTE_USER, lag(execute_time,1,execute_time) over (partition by 1 order by user_oncall_results_id) as prev_execute_time
  from user_oncall_results
  where 1=1
  and request_id like 'MKC_REVENUE_%'
  and execute_time > sysdate - interval '12' hour
  order by execute_time desc, user_oncall_results_id desc
)
select MSG, REQUEST_ID, EXECUTE_TIME, case when (msg not like 'CREATE TIME:%') then round((EXECUTE_TIME-PREV_EXECUTE_TIME)* 1440, 2) else NULL end as runtime_min
from v;

---

-- Determine history changes for a 3 month period

WITH AP_Salesgroups AS (
  SELECT distinct c.custom_level_value as salesgroup
  from custom_query_lov_view c,
       territory_hierarchy h
  where h.parent_territory_lov_id = 39238  -- AP countries
    and h.sub_territory_lov_id = c.list_of_values_id
  and c.retired = 0
  and c.custom_level_value != 'EU'
),
CONTACT_UPDATES as (
--select /*+ MATERIALIZE */
  SELECT x.*, trim(x.first_name || ' ' || x.middle_name || DECODE(x.middle_name, NULL, '', ' ') || x.last_name) as contact_name
    FROM (select * from 
            (select c1.contact_id, c1.salesgroup, c1.prefix, c1.first_name, c1.middle_name, c1.last_name,
                    c1.account_name_id, 
                    c1.updated, c1.updatedby, c1.h_version, '  ' as wm_optype
               from contact_base c1
              where extract(year from c1.updated) = 2019
                and extract(month from c1.updated) in (3,4,5)
                and c1.salesgroup in (select SALESGROUP from AP_Salesgroups) 
            ) 
      UNION ALL 
      (select c2.contact_id, c2.salesgroup, c2.prefix, c2.first_name, c2.middle_name, c2.last_name,
              c2.account_name_id,
              c2.updated, c2.updatedby, c2.h_version, c2.wm_optype
         from contact_hist c2
        where extract(year from c2.updated) = 2019
          and extract(month from c2.updated) in (3,4,5)
          and c2.salesgroup in (select SALESGROUP from AP_Salesgroups) 
      )
    ) x
)
SELECT contact_id, account_id, wm_optype AS action, UPDATED AS last_updated, updatedby AS last_updatedby, lagrec AS contact_name_previous, contact_name AS contact_name_current
FROM (
select asrch.account_id, asrch.primary_name as account_name, c.*, LAG(contact_name) OVER (PARTITION BY account_id, contact_id ORDER BY c.h_version) lagrec
  from CONTACT_UPDATES c,
       account_search  asrch
 where c.contact_id in (select distinct cu1.contact_id
                          from CONTACT_UPDATES cu1,
                               CONTACT_UPDATES cu2
                          where cu1.contact_id    = cu2.contact_id
                            and cu1.h_version    != cu2.h_version
                            and cu1.contact_name != cu2.contact_name
                        )
   and c.account_name_id = asrch.account_search_id
-- order by account_id, c.contact_id, c.updated DESC, c.h_version DESC
)
WHERE contact_id in(9999999)
  AND upper(lagrec) != upper(contact_name)  -- skip case-only changes
ORDER BY account_id, contact_id, last_updated
