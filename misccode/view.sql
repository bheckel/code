
create or replace view janes_marketing_view 
as 
select u.user_id, 
       u.email, 
       count(ucm.page_id) as n_pages,
       count(bb.msg_id) as n_msgs,
       count(c.comment_id) as n_comments
from users u, user_content_map ucm, bboard bb, comments c
where u.user_id = ucm.user_id(+)
and u.user_id = bb.user_id(+)
and u.user_id = c.user_id(+)
group by u.user_id, u.email
order by upper(u.email)
