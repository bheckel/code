CREATE TABLE myemp (
	myempid  NUMBER PRIMARY KEY,
	ename  VARCHAR2(30),
	salary NUMBER(8,2),
  bonus NUMBER(8,2),
	deptno NUMBER
  );
create index myemp_idx on myemp (ename);
insert into myemp values (1, 'Frank',  15000, 99, 10);
insert into myemp values (2, 'Willie',  10000, null, 20);
alter table myemp add vc number generated always as (coalesce(bonus,salary)) virtual;
