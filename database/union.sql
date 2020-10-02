
-- Don't keep dups
create table rion47175 as select * from (
  SELECT * FROM rion47175_1
  union
  SELECT * FROM rion47175_2
  union
  SELECT * FROM rion47175_3
);

---

-- Keep dups
select 'SMALL' name, 0 lower_bound, 29 upper_bound from dual
union all
select 'MEDIUM' name, 30 lower_bound, 79 upper_bound from dual
union all
select 'LARGE' name, 80 lower_bound, 999999 upper_bound from dual
union all
select 'LARGE' name, 80 lower_bound, 999999 upper_bound from dual
/*
NAME       LOWER_BOUND                            UPPER_BOUND                            
SMALL           0                                      29                                     
MEDIUM          30                                     79                                     
LARGE           80                                     999999                                 
LARGE           80                                     999999                                 
*/


select 'SMALL' name, 0 lower_bound, 29 upper_bound from dual
union 
select 'MEDIUM' name, 30 lower_bound, 79 upper_bound from dual
union 
select 'LARGE' name, 80 lower_bound, 999999 upper_bound from dual
/*
NAME	LOWER_BOUND	UPPER_BOUND
LARGE	80	999999
MEDIUM	30	79
SMALL	0	29
*/

---

select 
  'today - ' || to_char(trunc(sysdate),'Mon FMDDFM'),
  trunc(sysdate) as deadline
from dual 
UNION
select 
  'tomorrow - '|| to_char(trunc(sysdate+1),'Mon FMDDFM'), 
  trunc(sysdate+1) as deadline
from dual 
UNION
select
  'next week - '|| to_char(trunc(sysdate+7),'Mon FMDDFM'), 
  trunc(sysdate+7) as deadline
from dual 
UNION
select 
  'next month - '|| to_char(trunc(ADD_MONTHS(sysdate,1)),'Mon FMDDFM'), 
  trunc(ADD_MONTHS(sysdate,1)) as deadline 
from dual
/*
   next month - Jun 8  06/8/2019
   next week - May 15  05/15/2019
   today - May 8       05/8/2019
   tomorrow - May 9    05/9/2019
*/


