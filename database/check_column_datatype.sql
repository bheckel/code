 -- Check to see if column by name VARIABLE_PCT_OF_SALARY exists with a datatype of NUMBER
 SELECT COUNT(1)
 INTO   l_pct_of_sal_col_count   
 FROM   USER_TAB_COLUMNS
 WHERE  TABLE_NAME = 'OCMP_EMP_TARGET_BASE' 
 AND    COLUMN_NAME = 'VARIABLE_PCT_OF_SALARY' AND DATA_TYPE  = 'NUMBER';
