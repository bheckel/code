-- Oracle

alter table mkc_revenue_full drop column ACCOUNT_ID;
alter table mkc_revenue_full add ACCOUNT_ID NUMBER GENERATED ALWAYS AS (COALESCE("ACCOUNT_ID_ADJ",TO_NUMBER("ACCOUNT_ID_CW"),"ACCOUNT_ID_AS")) VIRTUAL;
alter table mkc_revenue_full add USD_CC_RATE_XRC number;
alter table mkc_revenue modify "PRODUCT" VARCHAR(15) COLLATE "USING_NLS_COMP" GENERATED ALWAYS AS (CAST(UPPER(COALESCE("PRODUCT_OVR","PRODUCT_NAME_CODE_ADJ","PRODUCT_IDZ","PRODUCT_NAME_CODE_SR","PRODUCT_9BYTE_ID")) AS CHAR(15))) VIRTUAL;
alter table user_role1 rename to user_role2;
alter table roion35282 rename column a3 to a4;
alter table js_invoice_bob_31mar21 add constraint JS_INVOICE_BOB_31MAR21_PK PRIMARY KEY (INVOICE_NUMBER_SR,INVOICE_SUBSIDIARY_SR)
alter table mkc_revenue_full drop constraint KRF_REVENUE_ID;
alter table mkc_revenue_full drop constraint KRF_REVENUE_ID drop index;
drop table kr27mar2021170440 purge;
truncate table mkc_revenue_full_bob

create or replace trigger mkc_revenue_full_iud before INSERT OR UPDATE OR DELETE ON MKC_REVENUE_FULL FOR EACH ROW
  declare bypass_flag varchar2(6); constantSystimestamp TIMESTAMP(6) := systimestamp; begin ... end;

alter trigger MKC_REVENUE_FULL_IUD enable;
drop trigger MKC_REVENUE_FULL_IUD;

create index KRF_ASSIGN_LOV_ID_IX ON MKC_REVENUE_FULL (ASSIGN_TERR_LOV_ID);
alter index CONTACT_FIRSTNAME_LIST_IX rebuild online tablespace SE_01;
alter index CONTACT_FIRSTNAME_LIST_IX rename to CONTACT_FIRSTNAME_IX;
drop index KRF_ACCT_ID_4_JOINS_IX;
