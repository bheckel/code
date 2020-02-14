
create or replace view janes_marketing_view as 
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

---

-- Select only the first 30k rows from base table (do no use ROWID)
CREATE OR REPLACE VIEW rion_42783 AS
  SELECT v.contact_id, v.gender
    FROM ( select o.*,
                  row_number() over (order by contact_id) as rnum
             from orion_42783_base o ) v 
   WHERE rnum BETWEEN 1 AND 30000;

