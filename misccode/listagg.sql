
-- Modified: Fri 21 Jun 2019 14:54:19 (Bob Heckel)

-- See also analytic_over_partition_order_window.sql

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
