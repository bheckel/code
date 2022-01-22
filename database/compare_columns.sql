
with v as( 
  select 't' x,column_name
    from user_tab_cols
    where table_name='MKC_REVENUE_FULL'
   union all 
   select 'p' x,column_name
    from user_tab_cols@tlas_prod_rw
    where table_name='MKC_REVENUE_FULL'
)
select column_name 
  from v
 group by column_name
having count(1)=1
 order by 1;

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
