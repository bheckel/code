-- Modified: 16-May-2022 (Bob Heckel)

---

select COLUMN_NAME, DATA_LENGTH FROM all_tab_columns WHERE lower(table_name) = 'asp'
minus
select COLUMN_NAME, DATA_LENGTH FROM all_tab_columns WHERE lower(table_name) = 'asp_2021'
; --col only on asp
select COLUMN_NAME, DATA_LENGTH FROM all_tab_columns WHERE lower(table_name) = 'asp_2021'
minus
select COLUMN_NAME, DATA_LENGTH FROM all_tab_columns WHERE lower(table_name) = 'asp'
; --col only on asp_2021

---

-- Compare column names and data lengths
with v as (
  select 'f' src,COLUMN_NAME, DATA_LENGTH FROM all_tab_columns WHERE lower(table_name) = 'mkc_revenue_full'
  union
  select 'h' src,COLUMN_NAME, DATA_LENGTH FROM all_tab_columns@atlas_test_rw WHERE lower(table_name) = 'mkc_revenue_full'
  order by 2,1
)
select distinct column_name,count(column_name)
  from v
 group by column_name, data_length
having count(1)=1
ORDER BY 1 ;

-- Better - on curr db, not on remote
select COLUMN_NAME, DATA_LENGTH FROM all_tab_columns WHERE lower(table_name) = 'mkc_revenue_full'
minus
select COLUMN_NAME, DATA_LENGTH FROM all_tab_columns@rion_prod_rw WHERE lower(table_name) = 'mkc_revenue_full'
;

---

with v as( 
  select 'a' x,column_name
    from user_tab_cols
    where table_name='MKC_REVENUE_FULL'
   union all 
   select 'b' x,column_name
    from user_tab_cols@tlas_prod_rw
    where table_name='MKC_REVENUE_FULL'
)
select column_name 
  from v
 group by column_name
having count(1)=1
 order by 1;

---

--ORA-02070: database  does not support  in this context
  select 'a' x, column_name, data_default
  from user_tab_cols 
 where TABLE_NAME = 'MKC_REVENUE_FULL'
   and VIRTUAL_COLUMN = 'YES'
union all
  select 'b' x, column_name, data_default
  from user_tab_cols@atlas_test_rw 
 where TABLE_NAME = 'MKC_REVENUE_FULL'
   and VIRTUAL_COLUMN = 'YES'
   ;

--same problem
select 'a' x, column_name, data_default from user_tab_cols where TABLE_NAME = 'MKC_REVENUE_FULL' and VIRTUAL_COLUMN = 'YES'
MINUS
select 'b' x, column_name, data_default from user_tab_cols@atlas_test_rw where TABLE_NAME = 'MKC_REVENUE_FULL' and VIRTUAL_COLUMN = 'YES'
;

---

-- Compare virtual columns on two tables
DECLARE
  TYPE varcharTable IS TABLE OF VARCHAR2(32767);

  column_table varcharTable;
  full_table   varcharTable;
  uat_table    varcharTable;
  
  v_sql VARCHAR2(32767) := 'select utc1.column_name, utc1.data_default, utc2.data_default
                              from user_tab_cols utc1, user_tab_cols utc2
                             where utc1.TABLE_NAME = ''MKC_REVENUE_FULL''
                               and utc1.VIRTUAL_COLUMN = ''YES''
                               and utc2.TABLE_NAME = ''MKC_REVENUE_FULL_UAT''
                               and utc2.VIRTUAL_COLUMN = ''YES''
                               and utc1.COLUMN_NAME = utc2.COLUMN_NAME';
BEGIN
  EXECUTE IMMEDIATE v_sql BULK COLLECT
    INTO column_table, full_table, uat_table;

  FOR i IN 1 .. full_table.COUNT LOOP
    IF (UPPER(REPLACE(full_table(i), ' ', '')) != UPPER(REPLACE(uat_table(i), ' ', ''))) THEN
      DBMS_OUTPUT.put_line(column_table(i) || ' are NOT equal!');
      DBMS_OUTPUT.put_line(' ');
      
      DBMS_OUTPUT.put_line('  ' || full_table(i));
      DBMS_OUTPUT.put_line('   DOES NOT EQUAL');
      DBMS_OUTPUT.put_line('  ' || uat_table(i));
      DBMS_OUTPUT.put_line(' ');
    END IF;
  END LOOP;
END;
