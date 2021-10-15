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

---

select utc1.column_name, utc1.data_default vc_contents
  from user_tab_cols utc1
 where utc1.TABLE_NAME = 'MKC_REVENUE_FULL_HIST'
   and utc1.VIRTUAL_COLUMN = 'YES';

---

-- Compare VCs
select utc1.column_name, utc1.data_default, utc2.data_default
  from user_tab_cols utc1, user_tab_cols utc2
 where utc1.TABLE_NAME = 'MKC_REVENUE_FULL'
   and utc1.VIRTUAL_COLUMN = 'YES'
   and utc2.TABLE_NAME = 'MKC_REVENUE_FULL_UAT'
   and utc2.VIRTUAL_COLUMN = 'YES'
   and utc1.COLUMN_NAME = utc2.COLUMN_NAME
and utc1.column_name='AMTPD'
 order by 1;
