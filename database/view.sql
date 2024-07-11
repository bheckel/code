-- Does view exist?
SELECT COUNT(1)
  --INTO cnt
  FROM user_objects
 WHERE object_name = 'RPT_ERR_RISK_AMOUNT_HIST'
   AND object_type = 'VIEW';
