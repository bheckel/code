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
