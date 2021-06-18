-- Do things in partial chunks of records based on another table

SELECT account_id
  FROM ( select account_id, row_number() OVER (order by account_id) rn from rion_51396@esd )
 WHERE rn between 1 and 9
 ORDER BY 1;

-- same
  SELECT account_id, input_source
    FROM account_base 
   WHERE account_id IN (
                        select distinct account_id
                          from ( select account_id, ntile(4) OVER (order by account_id) grp from rion_51396@esd ) 
                         where grp = 1
                        )
   ORDER BY 1;
