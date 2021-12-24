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
