

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
