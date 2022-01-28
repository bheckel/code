
-- Compare column names and data lengths
with v as (
  select 'f' src,COLUMN_NAME, DATA_LENGTH FROM all_tab_columns WHERE lower(table_name) = 'mkc_revenue_full'
  union
  select 'h' src,COLUMN_NAME, DATA_LENGTH FROM all_tab_columns WHERE lower(table_name) = 'mkc_revenue_full_hist'
  order by 2,1
)
select column_name,count(column_name)
  from v
 group by column_name
having count(1)=1;

-- Better - on curr db, not on remote
select COLUMN_NAME, DATA_LENGTH FROM all_tab_columns WHERE lower(table_name) = 'mkc_revenue_full'
minus
select COLUMN_NAME, DATA_LENGTH FROM all_tab_columns@rion_prod_rw WHERE lower(table_name) = 'mkc_revenue_full'
;
