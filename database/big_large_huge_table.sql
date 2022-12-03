--  Adapted: 11-Feb-2022 (Bob Heckel--https://connor-mcdonald.com/2022/02/11/vsession_longops-and-parallel-query/) 
-- Modified: 30-Nov-2022 (Bob Heckel)

create table bigtab as select d.* from dba_objects d, ( select 1 from dual connect by level <= 1000 );

select bytes/1024/1024/1024 size_in_GB
  from dba_segments
 where segment_name = 'BIGTAB';

-- Start a long query running against this 12gigabyte table
set timing on
select owner, sum(object_id)
  from bigtab
 group by owner;

select * 
  from v$session_longops
 where username = 'MCDONAC'
/*
TIME_REMAINING                : 64
ELAPSED_SECONDS               : 32
MESSAGE                       : Table Scan:  MCDONAC.BIGTAB: 783196 out of 1622079 Blocks done
*/


-- Parallel calculations:

select  /*+ parallel(8) */ owner, sum(object_id)
  from bigtab
 group by owner;
/*
TIME_REMAINING                : 5
ELAPSED_SECONDS               : 7
MESSAGE                       : Rowid Range Scan:  MCDONAC.BIGTAB: 9853 out of 15568 Blocks done
*/
select blocks
  from   user_tables
 where  table_name = 'BIGTAB';--1622079 

select 1622079 / 15568 from dual;--104.193153

-- 5 + 7
select 104*12 from dual;--1248

-- 8 workers
select 1248 / 8 from dual;--estimate 156 seconds to complete

---

-- Adapted: 30-Nov-2021 (Bob Heckel--https://connor-mcdonald.com/2021/11/14/the-big-table-dilemma-what-about-transaction-rates/)
create table user_likes (
  user_id int not null,
  post_id int not null,
  dt      date default sysdate not null
);

insert /*+ APPEND */ into user_likes
  with u as (
    select /*+ MATERIALIZE */ rownum user_id from dual
    connect by level <= 200000
    order by dbms_random.value )
    , p as (
    select /*+ MATERIALIZE */ rownum post_id from dual
    connect by level <= 10000
    order by dbms_random.value )
select user_id, post_id, sysdate
  from u,p;  -- 2,000,000,000 rows created.
-- where mod(user_id+post_id,3) = 0; -- 666,666,667 rows created.

alter table user_likes add constraint user_likes_pk primary key ( user_id, post_id );

CREATE INDEX user_likes_ix on user_likes ( post_id, user_id , dt) PARALLEL 16 NOLOGGING;
ALTER INDEX user_likes_ix NOPARALLEL LOGGING; 

---

-- create 1 billion record table
create table tx nologging pctfree 0 tablespace demo as
  select d.*
    from ( select rownum x, rownum y from dual connect by level <= 100000 ) d,
         ( select 1 from dual connect by level <= 10000 )
;

