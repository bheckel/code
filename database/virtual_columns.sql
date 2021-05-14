-- Compare virtual columns
select utc1.column_name, utc1.data_default, utc2.data_default
  from user_tab_cols utc1, user_tab_cols utc2
 where utc1.TABLE_NAME = 'MKC_REVENUE_FULL'
   and utc1.VIRTUAL_COLUMN = 'YES'
   and utc2.TABLE_NAME = 'MKC_REVENUE_FULL_UAT'
   and utc2.VIRTUAL_COLUMN = 'YES'
   and utc1.COLUMN_NAME = utc2.COLUMN_NAME
 order by 1;
