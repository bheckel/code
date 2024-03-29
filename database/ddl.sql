-- Oracle DDL
-- Modified: 01-Sep-2022 (Bob Heckel)

alter table mkc_revenue_full drop column ACCOUNT_ID;
--                               !!no COLUMN keyword!!
alter table mkc_revenue_full add ACCOUNT_ID NUMBER GENERATED ALWAYS AS (COALESCE("ACCOUNT_ID_ADJ",TO_NUMBER("ACCOUNT_ID_CW"),"ACCOUNT_ID_AS")) VIRTUAL;
alter table mkc_revenue_full add USD_CC_RATE_XRC number;
alter table mkc_revenue modify "PRODUCT" VARCHAR(15) COLLATE "USING_NLS_COMP" GENERATED ALWAYS AS (CAST(UPPER(COALESCE("PRODUCT_OVR","PRODUCT_NAME_CODE_ADJ","PRODUCT_IDZ","PRODUCT_NAME_CODE_SR","PRODUCT_9BYTE_ID")) AS CHAR(15))) VIRTUAL;
alter table bricks modify ( colour NULL, weight NULL );
alter table user_role1 rename to user_role2;
alter table roion35282 rename column a3 to a4;
rename mkc_revenue_vw to mkc_revenue_old;

alter table js_invoice add constraint JS_INVOICE_PK PRIMARY KEY (INVOICE_NUMBER_SR,INVOICE_SUBSIDIARY_SR)
alter table mkc_revenue_adj add constraint NN_SDM_BUSINESS_KEY CHECK (SDM_BUSINESS_KEY IS NOT NULL);
alter table mkc_revenue_full drop constraint KRF_REVENUE_ID;
alter table mkc_revenue_full drop constraint KRF_REVENUE_ID drop index;
alter table mkc_revenue_full modify task_desc_pb invisible;--hide hidden column
ALTER TABLE SETARS.ASP_DETAILS MODIFY CONSTRAINT NN_SUP_SW_PIPELINE_AMOUNT_YR_C disable;
ALTER TABLE LOG_MASTER add INIT_FORECAST_LIKELY_FINISH NUMBER(1) default ON NULL 0;

drop table kr27mar2021170440 PURGE;
truncate table mkc_revenue_full_bob

create or replace trigger mkc_revenue_full_iud before INSERT OR UPDATE OR DELETE ON MKC_REVENUE_FULL FOR EACH ROW
  declare bypass_flag varchar2(6); constantSystimestamp TIMESTAMP(6) := systimestamp; begin ... end;

alter trigger MKC_REVENUE_FULL_IUD enable;
alter trigger MKC_REVENUE_FULL_IUD disable;
drop trigger MKC_REVENUE_FULL_IUD;

create index KRF_ASSIGN_LOV_ID_IX ON MKC_REVENUE_FULL (ASSIGN_TERR_LOV_ID);
alter index CONTACT_FIRSTNAME_LIST_IX rebuild online tablespace SE_01;
alter index CONTACT_FIRSTNAME_LIST_IX rename to CONTACT_FIRSTNAME_IX;
alter index "SETARS"."KRB_9BYTE_CD_IX" nologging;  -- won't be able to use from backup after media failure
drop index KRF_ACCT_ID_4_JOINS_IX;

create sequence UID_RION_37551 MINVALUE 2 MAXVALUE 999999999999999999999999999 INCREMENT BY 10  START WITH 12 CACHE 20 NOORDER NOCYCLE;

alter table mkc_revenue_full DISABLE ROW MOVEMENT;
alter table mkc_revenue_full PARALLEL 16;
SELECT table_name, degree FROM user_tables WHERE table_name='MKC_REVENUE_FULL';
alter table mkc_revenue_full NOPARALLEL;

EXECUTE IMMEDIATE 'CREATE INDEX KRB_HC_XR_CIX ON MKC_REVENUE_FULL(KMC_REVENUE_ID,HASH_COLUMN_xr) PARALLEL 16 NOLOGGING';
EXECUTE IMMEDIATE 'ALTER INDEX KRB_HC_XR_CIX NOPARALLEL LOGGING';

alter index KRH_KMC_REVENUE_ID_IX shrink space;
-- did it work to reduce BYTES?:
select * from user_segments where SEGMENT_NAME not like 'BIN$%';

create table mkc_years ( year number, start_day number, end_day number);
insert into mkc_years values (2019, 1, 31);

-- Add a primary key
alter table zbob add SALESGROUP_SUBSIDIARY_id number;
create sequence uid_salesgroup_subsidiary minvalue 10 maxvalue 999999999999999999 increment by 10 cache 20 nocycle noorder;
update zbob set SALESGROUP_SUBSIDIARY_id=uid_salesgroup_subsidiary.nextval;
alter table zbob  add constraint SALESGROUP_SUBSIDIARY_pk primary key (SALESGROUP_SUBSIDIARY_id);

comment on column t.account_id is 'foo';

