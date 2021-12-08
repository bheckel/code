-- Adapted: 30-Nov-2021 (Bob Heckel--https://connor-mcdonald.com/2021/11/14/the-big-table-dilemma-what-about-transaction-rates/)

create table user_likes (
  user_id int not null,
  post_id int not null,
  dt      date default sysdate not null
) ;

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
  from u,p
  where mod(user_id+post_id,3) = 0;
-- 666666667 rows created.
