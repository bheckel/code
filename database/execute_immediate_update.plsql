-- ----------------------------------------------------------------------------
-- Author: Bob Heckel (boheck)
-- Date:   21-May-24
-- Usage:  See l_description   
-- JIRA:   See l_defect_num
-- ----------------------------------------------------------------------------

DECLARE
  l_defect_num  VARCHAR2(50);
  l_release_num VARCHAR2(50);
  l_description VARCHAR2(4000);
  l_start_time  DATE := SYSDATE;
  l_cnt         NUMBER := 0;
  l_upd         NUMBER := 0;

  TYPE numberTable IS TABLE OF NUMBER;
  account_id_tbl numberTable;
  industry_lov_id_tbl numberTable;
  account_attribute_id_tbl numberTable;
BEGIN
  l_defect_num  := 'DMA-1771';
  l_release_num := '24.06';
  l_description := 'Orion Account Industry (SAS Industry) updates';

  select count(1)
    into l_cnt
    from user_tables
   where table_name = 'ZDMA1771';
  
  if l_cnt = 0 then
    execute immediate 'ALTER SESSION SET ddl_lock_timeout=120';
    -- User-provided spreadsheet
    execute immediate 'create table zdma1771 (account_id number, new_account_industry varchar2(99))';
    execute immediate q'[Insert into ZDMA1771 (ACCOUNT_ID,NEW_ACCOUNT_INDUSTRY) values (699520,'2500 - Gov - Justice and Public Safety')]';
    execute immediate q'[Insert into ZDMA1771 (ACCOUNT_ID,NEW_ACCOUNT_INDUSTRY) values (5854412,'2500 - Gov - Justice and Public Safety')]';
    commit;
  end if;

  execute immediate q'[ 
    with v as (
      select d.account_id, d.new_account_industry, l.list_of_values_id as new_lov
      from zdma1771 d, list_of_values l
       where substr(d.new_account_industry, 8) = l.value_description
    ), v2 as (
      select distinct v.*, an.account_name, ab.primary_account_attribute_id
        from v, account ab, account_name an, account_attribute aa, account_name_attribute ana
       where ab.account_id = an.account_id
         and an.account_name_id = ana.account_name_id
         and ana.account_attribute_id(+) = aa.account_attribute_id
         and v.account_id = an.account_id
         and an.override_account_name = 1
    )
    select account_id, new_lov, primary_account_attribute_id from v2
  ]'
    bulk collect into account_id_tbl, industry_lov_id_tbl, account_attribute_id_tbl;  -- only expecting about 1000 updates so no LIMIT

  for i in 1..account_id_tbl.count loop
    DBMS_OUTPUT.put_line('ok '||account_id_tbl(i)||' '||industry_lov_id_tbl(i)||' '||account_attribute_id_tbl(i));
    update account_attribute set industry_lov_id=industry_lov_id_tbl(i) where account_attribute_id=account_attribute_id_tbl(i);
    ACCOUNT_ASSIGNMENTS.update_account_search(p_accountid => account_id_tbl(i), p_ignoreaudit=>1);
    l_upd := i;
  end loop;
  commit;
  DBMS_OUTPUT.put_line('Modified ' || l_upd || ' accounts');
  
  execute immediate q'[ drop table zdma1771 ]';
  
  MAINT.logdatachange(
    step      => 0,
    status    => l_description,
    release   => l_release_num,
    defect    => l_defect_num,
    startTime => l_start_time);

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line(SQLCODE || ':' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
    rollback;
END;

