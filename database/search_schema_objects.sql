-- Modified: 27-Oct-2022 (Bob Heckel)

with v as (
  --select * from SYS.USER_SOURCE t WHERE lower(t.text) like '%get_revenue_classification%' --and t.TYPE='PACKAGE BODY'
  select view_name nm, text_vc txt from ALL_VIEWS where OWNER = 'ESTARS' and upper(text_vc) like '%OPPORTUNITY_SEARCH%'
  --SELECT * from  user_tab_columns WHERE table_name = 'FOO' AND column_name LIKE '%NEW%';
)
select nm, txt from v 
 where lower(txt) like '%account_id%'
--where lower(txt) like '%function%' ORDER BY 1
   and nm not like 'BDG%'
;

---

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

--search views
SELECT owner AS schema_name,
       name AS view_name,
       referenced_owner AS referenced_schema_name,
       referenced_name,
       referenced_type
  FROM sys.all_dependencies d
 WHERE type = 'VIEW'
   AND d.owner = 'SETARS'
   AND name LIKE 'RPT\_%' ESCAPE '\'
   AND name NOT LIKE '%BDG%'
   AND referenced_name LIKE '%\_BASE' ESCAPE '\'
 ORDER BY owner, name, referenced_name, referenced_owner, referenced_type;
