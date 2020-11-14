
CREATE OR REPLACE VIEW rpt_leads_summary AS
/* CreatedBy: Bob Heckel
** Date:      05-Nov-20
** Purpose:   Input data for VA 2.0 report 'Lead Summary'
** Change:    
*/
  WITH anames AS (
    SELECT DISTINCT account_id,
                    LISTAGG(account_name, ' | ' ON OVERFLOW TRUNCATE '...' WITHOUT COUNT) WITHIN GROUP( ORDER BY account_name) OVER(PARTITION BY account_id) AS account_names_aka
      FROM account_name
     WHERE override_account_name != 1 
  ), notes AS (
    SELECT n.note_id,
           dbms_lob.substr(n.note, 100, 1) AS note,
           n.updated,
           c.activity_id
      FROM note n,
           contact_note c
     WHERE n.note_id = c.note_id
       AND n.type_8 = 'Lead'
  ), cont AS (
    SELECT ca.activity_id,
           c.contact_id,
           decode(c.gonereason,3,'GONE - ','') || c.first_name || ' ' || c.last_name as contact,
           c.dept,
           c.prefix,
           c.type,
           cp.phone,
           ce.email,
           cad.state_province_non_us_co
      FROM contact_activity ca,
           contact c,
           contact_phone cp,
           contact_email ce,
           contact_address cad
     WHERE ca.contact_id = c.contact_id
       AND c.contact_id = cp.contact_id(+)
       AND c.contact_id = ce.contact_id(+)
       AND c.contact_id = cad.contact_id(+)
       AND cp.primary_phone(+) = 1
       AND ce.primary_email(+) = 1
       AND cad.primary_address(+) = 1
  ), v AS (
    SELECT a.activity_id,
           t.due_date,
           t.employee_id,
           decode(e.gone,'Y', 'GONE - ' || e.first_name || ' ' || e.last_name, e.first_name || ' ' || e.last_name) AS lead_owner,
           r.territory_desc as owner_territory,
           a.status,
           an.account_id,
           an.account_name,
           ans.account_names_aka,
           decode(a.priority_int, 10, 'Low', 11, 'Cold', 20, 'Normal', 21, 'Warm', 30, 'High', 31, 'Hot') AS priority,
           cq2.value_description AS type,
           cq.value_description AS outcome,
           a.description,
           n.note,
           n.updated AS note_updated,
           a.cbo_group_cd,
           a.cbo_id,
           c.contact,
           c.dept,
           c.prefix AS title,
           c.phone,
           c.email,
           c.state_province_non_us_co,
           c.type AS contact_type
      FROM activity_search s,
           activity a,
           task t,
           anames ans,
           account_name an,
           notes n,
           cont c,
           employee e,
           --contact_activ_opp ca,
           rpt_orion_terr_hierarchy_mv r,
           custom_query_lov_view cq,
           custom_query_lov_view cq2
     WHERE an.account_name_id = s.account_name_id
       AND an.account_id = ans.account_id
       AND s.activity_search_id = a.activity_id
       AND a.activity_id = t.activity_id
       AND a.activity_id = c.activity_id
       AND t.employee_id = e.employee_id(+)
       AND e.territory_lov_id = r.territory_lov_id(+)
       AND c.activity_id = n.activity_id
       AND cq.list_of_values_id = t.outcome_lov_id
       AND cq2.list_of_values_id = a.type_lov_id
       AND t.current_task = 1
       AND an.override_account_name = 1
  ), v2 as (
  -- Hints did not improve performance. Separatng this query did (Nov. 2020).
  SELECT *
    FROM ( SELECT v.*, ROW_NUMBER() OVER(PARTITION BY v.activity_id ORDER BY v.note_updated DESC) AS rnum FROM v )
   WHERE rnum = 1
 ), opleads1 as (
    SELECT ca.activity_id,
           o.opportunity_ID,
           o.opportunity_name,
           o.forecasted_sale_amount,
           ev.eventname,
           -- Transpose long-to-wide with new column names
           decode(owner_type, 'P', decode(e.gone,'Y', 'GONE - ' || e.first_name || ' ' || e.last_name, e.first_name || ' ' || e.last_name), NULL) as prim,
           decode(owner_type, 'S', decode(e.gone,'Y', 'GONE - ' || e.first_name || ' ' || e.last_name, e.first_name || ' ' || e.last_name), NULL) as sec,
           decode(owner_type, 'N', decode(e.gone,'Y', 'GONE - ' || e.first_name || ' ' || e.last_name, e.first_name || ' ' || e.last_name), NULL) as ip
    FROM   contact_activity ca, 
           contact_activ_opp cao,
           contact_activ_event cae, 
           opportunity o,
           opportunity_employee oe,
           employee e,
           event ev
    WHERE  ca.activity_ID = cao.activity_ID
      AND  ca.activity_ID = cae.activity_ID(+)
      AND  cao.opportunity_ID = o.opportunity_ID
      AND  o.opportunity_ID = oe.opportunity_ID
      AND  oe.employee_id = e.employee_id
      AND  cae.event_id = ev.event_id
), opleads2 as (
    SELECT DISTINCT activity_ID,
                    opportunity_id,
                    opportunity_name,
                    forecasted_sale_amount,
                    eventname,
                    -- Collapse to a single row
                    first_value(prim IGNORE NULLS) over (partition by activity_id, opportunity_id order by prim) prim2,
                    first_value(sec IGNORE NULLS) over (partition by activity_id, opportunity_id order by sec) sec2,
                    first_value(ip IGNORE NULLS) over (partition by activity_id, opportunity_id order by ip) ip2
      FROM opleads1
)
SELECT v2.activity_id as lead_id,
       v2.due_date,
       v2.status,
       v2.account_id,
       v2.account_name,
       v2.account_names_aka,
       v2.priority,
       v2.type,
       v2.outcome,
       v2.description,
       v2.note,
       v2.note_updated,
       v2.cbo_group_cd as value_prop_group,
       v2.cbo_id as value_prop,
       v2.contact,
       v2.dept,
       v2.title,
       v2.state_province_non_us_co as state,
       v2.phone,
       v2.email,
       v2.contact_type,
       ol.opportunity_id,
       ol.opportunity_name,
       ol.forecasted_sale_amount,
       ol.prim2 as primary_opp_owner,
       ol.sec2 as secondary_opp_owner,
       ol.ip2 as ip_opp_owner,
       ol.eventname
from v2, opleads2 ol
where v2.activity_id = ol.activity_id(+)
;
