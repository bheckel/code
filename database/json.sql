-- Modified: 21-Feb-2023 (Bob Heckel)

with raw_data as (
  select qtr, player, pts
    from ( select quarter, player, sum(points) pts
              from basketball
             group by quarter, player ) b
         PARTITION BY (b.player)
         right outer join
         ( select rownum qtr from dual connect by level <= 4 ) q
           on q.qtr = b.quarter
)
select json_arrayagg(json_object(key player value pts ) order by qtr ) as results
  from raw_data;

---

{
    "value": [
        {
            "userId": "887d963500db",
            "flaggedSpam": 0,
            "timestampMs": 1661400000000,
            "upvotes": 0,
            "reads": 1,
            "views": 2,
            "claps": 0,
            "updateNotificationSubscribers": 0
        },
        {
            "userId": "887d963500db",
            "flaggedSpam": 0,
            "timestampMs": 1661403600000,
            "upvotes": 0,
            "reads": 2,
            "views": 2,
            "claps": 0,
            "updateNotificationSubscribers": 0
        },
        {
            "userId": "887d963500db",
            "flaggedSpam": 0,
            "timestampMs": 1661407200000,
            "upvotes": 0,
            "reads": 1,
            "views": 1,
            "claps": 0,
            "updateNotificationSubscribers": 0
        }
            ]
}

