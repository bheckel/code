--search pkgs
with v as (
  select * from SYS.USER_SOURCE t WHERE lower(t.text) like '%get_revenue_classification%' --and t.TYPE='PACKAGE BODY'
)
select * from v --where lower(text) like '%function%' ORDER BY 1
;
--search tables
SELECT * from  user_tab_columns WHERE table_name = 'FOO' AND column_name LIKE '%NEW%';
--search views
select * from ALL_VIEWS where OWNER = 'ESTARS' and TEXT_VC like '%boheck%';
