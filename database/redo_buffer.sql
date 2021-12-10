SELECT * FROM  v$sysstat s;

 select round(t.value/s.value,5) "Redo Log Space Request Ratio"
 from v$sysstat s, v$sysstat t
where s.name = 'redo log space requests'
and t.name = 'redo entries';

select name,value from V$SYSSTAT
where name= 'redo buffer allocation retries';
