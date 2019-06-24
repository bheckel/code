
-- Modified: Fri 21 Jun 2019 14:54:19 (Bob Heckel)

-- See also analytic_over_partition_order_window.sql

SELECT DISTINCT account_name_id,
                listagg(eb.event_id,',') WITHIN GROUP(ORDER BY eb.event_id) OVER(PARTITION BY eb.account_name_id) event_id_list,
                listagg(eb.eventname,',') WITHIN GROUP(ORDER BY eb.event_id) OVER(PARTITION BY eb.account_name_id) eventname_list
           -- Rank by account & event to use as a limit.  Won't work in the WHERE clause.
           FROM ( SELECT account_name_id, event_id, eventname, dense_rank() OVER (PARTITION BY account_name_id order by event_id) rownbr FROM event_base ) eb 
          WHERE eb.account_name_id IS NOT NULL 
            AND rownbr < 50  -- avoid 4000 byte char max on the CSV list
