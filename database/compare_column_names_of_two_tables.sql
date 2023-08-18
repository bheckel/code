SELECT column_name, data_type
FROM all_tab_columns
WHERE table_name = 'OPPORTUNITY'
MINUS
SELECT column_name, data_type
FROM all_tab_columns@orion_prod_ro
WHERE table_name = 'OPPORTUNITY';
