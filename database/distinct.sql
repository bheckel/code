create table test1(
 id number,
 name varchar2(20)
);
insert into test1 values (1,'abc');
insert into test1 values (1,'abc');
insert into test1 values (1,NULL);
select * from test1;
select count(*) from test1;  /* 3 */
select count(1) from test1;  /* 3 */
select count(ALL 1) from test1;  /* 3 */
select count(DISTINCT 1) from test1;  /* 1 */
select count(name) from test1;  /* 2 */
DROP TABLE test1;
