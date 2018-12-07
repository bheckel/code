-- Hierarchy self join - one (181477) is is ultimate parent, other two are children

SELECT sup.account_id, sup.sup_account_id, sup.existing_customer, detail.account_id, detail.sup_account_id, detail.existing_customer
FROM account_base sup, account_base detail
WHERE sup.account_id = 181477
AND detail.sup_account_id = sup.account_id
/*
ACCOUNT_ID	SUP_ACCOUNT_ID	EXISTING_CUSTOMER	ACCOUNT_ID	SUP_ACCOUNT_ID	EXISTING_CUSTOMER
1	181477	181477	1	181477	181477	1
2	181477	181477	1	417811	181477	1
3	181477	181477	1	410735	181477	0
*/

-- Is parent or any children an existing cust?
SELECT count(1)
FROM account_base b
WHERE b.account_id = 181477
      AND EXISTS (SELECT 1
                  FROM account_base sup, account_base detail
                  WHERE sup.account_id = b.sup_account_id
                        AND detail.sup_account_id = sup.account_id)
                        AND detail.existing_customer = 1);
/*
1
*/

---

select user_id, email 
from users 
where exists (select 1
              from classified_ads
              where classified_ads.user_id = users.user_id)
;

-- But this is probably better:

select users.user_id, users.email, classified_ads.posted
from users, classified_ads
where users.user_id=classified_ads.user_id
;
