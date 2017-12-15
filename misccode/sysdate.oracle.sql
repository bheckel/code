
select to_char(sysdate, 'Dy DD-Mon-YYYY HH24:MI:SS') as "Current Time"
from dual;

-- Oracle's default date format
select to_char(sysdate, 'DD-MON-YYYY') as "Current Time"
from dual;

-- Also can use CURRENT_DATE, same output
