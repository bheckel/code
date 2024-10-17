select ut.table_name, ut.num_rows, 
       utcs.column_name, utcs.num_distinct, 
       case utc.data_type
         when 'VARCHAR2' then
           utl_raw.cast_to_varchar2 ( utcs.low_value ) 
        when 'NUMBER' then
           to_char ( utl_raw.cast_to_number ( utcs.low_value ) )
       end low_val, 
       case utc.data_type
         when 'VARCHAR2' then
           utl_raw.cast_to_varchar2 ( utcs.high_value ) 
         when 'NUMBER' then
           to_char ( utl_raw.cast_to_number ( utcs.low_value ) )
       end high_val
from   user_tables ut
join   user_tab_cols utc
on     ut.table_name = utc.table_name
join   user_tab_col_statistics utcs
on     ut.table_name = utcs.table_name
and    utc.column_name = utcs.column_name
where ut.table_name in('BRICKS','COLOURS')
order  by ut.table_name, utcs.column_name
;

---

--ORA-01723: zero-length columns are not allowed
--find the offenders - they're 0
SELECT data_length FROM user_tab_cols where table_name='SALES_CREDIT_VIEW';
