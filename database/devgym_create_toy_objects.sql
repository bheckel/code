-- Adapted: 04-Aug-2020 (Bob Heckel -- Oracle DevGym)

-- See also explain_plan.sql

alter session set statistics_level = all;

create table bricks (
  brick_id         integer not null primary key,
  colour_rgb_value varchar2(10) not null,
  shape            varchar2(10) not null,
  weight           integer not null
);

create table colours (
  colour_rgb_value varchar2(10) not null,
  colour_name      varchar2(10) not null
);

insert into colours values ( 'FF0000', 'red' );
insert into colours values ( '00FF00', 'green' );
insert into colours values ( '0000FF', 'blue' );

insert into bricks
  select rownum,
         case mod ( level, 3 )
           when 0 then 'FF0000'
           when 1 then '00FF00'
           when 2 then '0000FF'
         end,
         case mod ( level, 3 )
           when 0 then 'cylinder'
           when 1 then 'cube'
           when 2 then 'pyramid'
         end,
         floor ( 100 / rownum )
  from   dual
  connect by level <= 100;
  
insert into bricks
  select rownum + 1000,
         case mod ( level, 3 )
           when 0 then 'FF0000'
           when 1 then '00FF00'
           when 2 then '0000FF'
         end,
         case mod ( level, 3 )
           when 0 then 'cylinder'
           when 1 then 'cube'
           when 2 then 'pyramid'
         end,
         floor ( 200 / rownum )
  from   dual
  connect by level <= 200;

commit;

-- Break the statistics
declare
  stats dbms_stats.statrec;
  distcnt  number; 
  density  number;
  nullcnt  number; 
  avgclen  number;
begin
  dbms_stats.gather_table_stats ( null, 'colours' );
  dbms_stats.gather_table_stats ( null, 'bricks' );
  dbms_stats.set_table_stats ( null, 'bricks', numrows => 30 );
  dbms_stats.set_table_stats ( null, 'colours', numrows => 3000 );
  dbms_stats.get_column_stats ( null, 'colours', 'colour_rgb_value', 
    distcnt => distcnt, 
    density => density,
    nullcnt => nullcnt, 
    avgclen => avgclen,
    srec => stats
  );
  stats.minval := utl_raw.cast_to_raw ( '0000FF' );
  stats.maxval := utl_raw.cast_to_raw ( 'FF0000' );
  dbms_stats.set_column_stats ( null, 'colours', 'colour_rgb_value', distcnt => 10, srec => stats );
  dbms_stats.set_column_stats ( null, 'bricks', 'colour_rgb_value', distcnt => 10, srec => stats );
end;
/

-- Prove how bad the stats are by autotracing this:
select /*+ gather_plan_statistics */ c.colour_name, count (*)
from   bricks b
join   colours c
on     c.colour_rgb_value = b.colour_rgb_value
group  by c.colour_name;

-- CARDINALITY x LAST_STARTS should be ~ LAST_OUTPUT_ROWS. Also shows the larger table before the smaller - not 
-- good for performance, want small read first in the execution plan

--or running this:
select * from table(dbms_xplan.display_cursor(null, format => 'ROWSTATS LAST'));
/*
--------------------------------------------------------------------------
| Id  | Operation                   | Name    | Starts | E-Rows | A-Rows |
--------------------------------------------------------------------------
|   0 | SELECT STATEMENT            |         |      1 |        |      3 |
|   1 |  HASH GROUP BY              |         |      1 |      3 |      3 |
|*  2 |   HASH JOIN                 |         |      1 |   9000 |    300 |
|   3 |    TABLE ACCESS STORAGE FULL| BRICKS  |      1 |     30 |    300 |
|   4 |    TABLE ACCESS STORAGE FULL| COLOURS |      1 |   3000 |      3 |
--------------------------------------------------------------------------
 
 Predicate Information (identified by operation id):
 ---------------------------------------------------
  
     2 - access("C"."COLOUR_RGB_VALUE"="B"."COLOUR_RGB_VALUE")
*/     

-- Statistics may be stale. So gather statistics:
exec dbms_stats.gather_table_stats( null, 'colours' ) ;

-- And do it automatically more often:
select dbms_stats.get_prefs('STALE_PERCENT', null, 'colours') from dual; -- default is 10% fragmented (changed)
exec dbms_stats.set_table_prefs( null, 'colours', 'STALE_PERCENT', 1 );

-- May need to force it to discard cached cursors:
exec dbms_stats.gather_table_stats(null, 'colours', no_invalidate => false) ;
-- But invalidating cursors when gathering stats this will cause the optimizer to reparse all queries on this 
-- table. Use with caution in production environments!

-- Also check Value Skew:
-- There are 300 rows in the bricks table. And 27 unique values. So these optimizer estimates ( 300 / 27 ) ~ 11 rows 
-- for both of these queries. But the weight=1 returns 150 rows and the weight=200 just one!

