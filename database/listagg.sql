
--  Created: Fri 21 Jun 2019 14:54:19 (Bob Heckel)
-- Modified: 04-Aug-2022 (Bob Heckel)

-- Select as a comma separated list value. See also analytic_over_partition_order_window.sql

---

 SELECT DISTINCT NOTIFICATION_OWNER, JOB_NAME, RECIPIENT,
                  LISTAGG(event, ', ' ON OVERFLOW TRUNCATE '...' WITHOUT COUNT) WITHIN GROUP (ORDER BY recipient) over ( partition by recipient ) event_list
FROM user_scheduler_notifications  WHERE job_name = 'JOB_LOAD_NB_POC';

---

 SELECT DISTINCT rlc.*,
                  LISTAGG(rlcc.fullname, ', ' ON OVERFLOW TRUNCATE '...' WITHOUT COUNT) WITHIN GROUP (ORDER BY rlcc.fullname) over ( partition by rlcc.lifecycle_id ) lifecycle_op_owners
    FROM rlc,
         rlcc
    WHERE rlc.lifecycle_id = rlcc.lifecycle_id

---

-- 12345 | prod 1, prod 2, prod3
-- 45678 | prod 2, prod 9, prod99
SELECT distinct o.opportunity_id, listagg(offering_name, ', ') WITHIN GROUP (ORDER BY offering_name) OVER ( PARTITION by o.opportunity_id) AS csvlist
  FROM opportunity o,
       opportunity_component oc,
       component c,
       offering ofname
 WHERE o.opportunity_id = oc.opportunity_id
   AND oc.component_id = c.component_id
   AND c.offering_id = ofname.offering_id

---

SELECT DISTINCT account_name_id,
                listagg(eb.event_id,',') WITHIN GROUP(ORDER BY eb.event_id) OVER(PARTITION BY eb.account_name_id) event_id_list,
                listagg(eb.eventname,',') WITHIN GROUP(ORDER BY eb.event_id) OVER(PARTITION BY eb.account_name_id) eventname_list
           -- Rank by account & event to use as a limit to avoid >4000 chars.  Won't work in the WHERE clause.
           FROM ( SELECT account_name_id, event_id, eventname, dense_rank() OVER (PARTITION BY account_name_id order by event_id) rownbr FROM event_base ) eb 
          WHERE eb.account_name_id IS NOT NULL -- without this we will overflow with virtually any rownum limit
            AND rownbr < 50  -- avoid 4000 byte char max on the CSV list

---

-- 1234 | product 1, product 2, product 3
-- 5678 | product 9
SELECT DISTINCT x.opportunity_id, listagg(x.offering_name, ', ') WITHIN GROUP (ORDER BY x.offering_name) OVER ( PARTITION by x.opportunity_id) 
FROM (
  SELECT  o.opportunity_id, offering_name, dense_rank() OVER (PARTITION BY o.opportunity_id order BY ofname.offering_name) rownbr
            FROM opportunity_base o,
                 opportunity_component oc,
                 component             c,
                 offering              ofname
           where o.opportunity_id = oc.opportunity_id
             and oc.component_id  = c.component_id
             and c.offering_id    = ofname.offering_id
) x
WHERE rownbr<4

---

-- Avoid using a collection and looping it to append an email message based on multiple rows:
-- Make sure ASP and Orion agree on number of current sites to avoid update mismatch failures
WITH asp_list AS (
  SELECT DISTINCT a.account_id, account_site_id
    FROM asp a,
         asp_processing_territory asp_pt,
         asp_territory_placeholder atp
   WHERE a.future_territory_lov_id = asp_pt.territory_lov_id
     AND asp_pt.asp_processing_request_id = in_asp_processing_request_id
     AND a.future_tsr_owner_id * - 1 = atp.asp_territory_placeholder_id (+)
     AND a.future_tsr_owner_id IS NOT NULL
     AND a.future_territory_lov_id IS NOT NULL
     AND a.future_tsr_owner_gone != 'Y'
     AND a.account_site_id IS NOT NULL
), orion_list AS (
  SELECT account_id,
         account_site_id
    FROM account_name an,
         account_site ast,
         site s
   WHERE an.account_name_id = ast.account_name_id
     AND ast.site_id = s.site_id
     AND an.account_id IN (
    SELECT account_id
      FROM asp_list
  )
), moreorion AS (
  SELECT account_id, account_site_id FROM orion_list
  MINUS
  SELECT account_id, account_site_id FROM asp_list
), moreasp AS (
  SELECT account_id, account_site_id FROM asp_list
  MINUS
  SELECT account_id, account_site_id FROM orion_list
), problems AS (
  SELECT 'acct:' || account_id || ' site:' || account_site_id || ' only on Orion' x
    FROM moreorion
  UNION
  SELECT 'acct:' || account_id || ' site:' || account_site_id || ' only on ASP' x
    FROM moreasp
)
SELECT LISTAGG(x, '<BR>' ON OVERFLOW TRUNCATE '...')
  INTO l_site_mismatch
  FROM problems
;

IF l_site_mismatch is not null THEN
...
