
select 'SMALL' name, 0 lower_bound, 29 upper_bound from dual
union all
select 'MEDIUM' name, 30 lower_bound, 79 upper_bound from dual
union all
select 'LARGE' name, 80 lower_bound, 999999 upper_bound from dual


NAME       LOWER_BOUND                            UPPER_BOUND                            
SMALL           0                                      29                                     
MEDIUM          30                                     79                                     
LARGE           80                                     999999                                 
