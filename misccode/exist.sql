
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
