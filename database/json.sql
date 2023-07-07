--  Created: 21-Feb-2023 (Bob Heckel)
-- Modified: 07-Jul-2023 (Bob Heckel)

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

---

/*
{
  "colState": [
    {
      "colId": "_permissions",
      "width": 84,
      "hide": false,
      "pinned": "left",
      "sort": null,
      "sortIndex": null,
      "aggFunc": null,
      "rowGroup": false,
      "rowGroupIndex": null,
      "pivot": false,
      "pivotIndex": null,
      "flex": null
    },
...
*/

SELECT *
FROM GRID_PREFERENCE t,
     JSON_TABLE(
       t.grid_pref_json,
       '$.colState[*]'
       COLUMNS (
         colId VARCHAR2(100) PATH '$.colId',
         hide VARCHAR2(5) PATH '$.hide'
       )
     ) jt
WHERE (
       (jt.colId = 'dealType' AND jt.hide = 'false')
       or
       (jt.colid = 'revenueStreams' and jt.hide = 'false')
      )
      and not
      (
       (jt.colid like 'err%' and jt.hide = 'false')
      )
;

