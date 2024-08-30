--Modified: 29-Aug-2024 (Bob Heckel) 

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

---

drop table MKC_REVENUE_FULL_bob2;

create table MKC_REVENUE_FULL_bob2 as select * from MKC_REVENUE_FULL@tlas_prod_rw where sdm_business_key in( /*invoice='70000548FRA'*/'24581880229661286','784883511240450007');

SELECT sdm_business_key,streams_category,newren FROM MKC_revenue where sdm_business_key in( /*invoice='70000548FRA'*/'24581880229661286','784883511240450007');

alter table MKC_revenue_full_bob2 drop column newren;

alter table MKC_REVENUE_FULL_bob2 add newren varchar2(1) generated always as (
    CASE
      WHEN "NEWREN_OVR" IS NOT NULL THEN
        "NEWREN_OVR"
      WHEN "NEWREN_ADJ" IS NOT NULL THEN
        "NEWREN_ADJ"
      WHEN "NEWREN_IDZ" IS NOT NULL THEN
        "NEWREN_IDZ"
      WHEN ( substr("PRODUCT_NAME_CODE_SR", 1, 3) = 'JMP'
             AND coalesce("YEAR_TYPE_FLAG_SR", "YEAR_TYPE_FLAG_F") IS NULL
             AND coalesce("CONTEXT_LINE_SR", "CONTEXT_F") = 'ONLINE SOFTWARE' ) THEN
        'N'
      WHEN "PRODUCT_NAME_CODE_SR" = 'INFLATN_N' THEN
        'N'
      WHEN "PRODUCT_NAME_CODE_SR" = 'INFLATN_R' THEN
        'R'
      WHEN ( coalesce("YEAR_TYPE_FLAG_SR", "YEAR_TYPE_FLAG_F") = 'EDUC'
             OR coalesce("YEAR_TYPE_FLAG_SR", "YEAR_TYPE_FLAG_F") = 'FIRSTYR'
             OR coalesce("YEAR_TYPE_FLAG_SR", "YEAR_TYPE_FLAG_F") = 'FIRST YEAR'
             OR coalesce("YEAR_TYPE_FLAG_SR", "YEAR_TYPE_FLAG_F") = 'CONSULT'
             OR coalesce("YEAR_TYPE_FLAG_SR", "YEAR_TYPE_FLAG_F") = 'OTHER'
             OR coalesce("YEAR_TYPE_FLAG_SR", "YEAR_TYPE_FLAG_F") = 'FEE'
             OR coalesce("YEAR_TYPE_FLAG_SR", "YEAR_TYPE_FLAG_F") = 'PUBS' ) THEN
        'N'
      WHEN ( coalesce("YEAR_TYPE_FLAG_SR", "YEAR_TYPE_FLAG_F") = 'RENEWAL'
             OR coalesce("YEAR_TYPE_FLAG_SR", "YEAR_TYPE_FLAG_F") = 'FEER' ) THEN
        'R'
      WHEN coalesce("YEAR_TYPE_FLAG_SR", "YEAR_TYPE_FLAG_F") IS NULL THEN
        'N'
    END
) virtual;
