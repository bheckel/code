-- https://github.com/connormcd/misc-scripts/blob/master/database_world_2021.sql

-- Pad sparse data with zeros

select qtr, player, nvl(pts,0)
  from ( select quarter, player, sum(points) pts
        from basketball
        group by quarter, player ) b
       partition by (b.player)
    right outer join
       ( select rownum qtr from dual connect by level <= 4 ) q
    on ( q.qtr = b.quarter )
 order by 2,1;
 /*
QTR PLAYER   NVL(PTS,0) 
--- -------- ---------- 
  1 Campbell          9 
  2 Campbell          3 
  3 Campbell          0 
  4 Campbell          0 
  1 Matt              1 
  2 Matt              2 
  3 Matt              0 
  4 Matt              0 
  1 Max               6 
  2 Max               3 
  3 Max               0 
  4 Max               0 
  1 Robbie           11 
  2 Robbie            9 
  3 Robbie            0 
  4 Robbie            0 
  1 Rory              3 
  2 Rory              1 
  3 Rory              0 
  4 Rory              0 
  1 Will              4 
  2 Will              0 
  3 Will              0 
  4 Will              0 
  1 Zack              6 
  2 Zack              6 
  3 Zack              0 
  4 Zack              0 
*/
