-- Old style Oracle
select users.user_id, users.email, classified_ads.posted
from users, classified_ads
where users.user_id = classified_ads.user_id(+)
-- The plus sign after classified_ads.user_id is our instruction to Oracle to "add NULL rows if you can't meet this JOIN constraint"
