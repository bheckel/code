
--save occasionally to :silent! w!~/onedrive/misc/bkup/%:t
set linesize 250;
set pagesize 100;
column first_last_name format a55;
column deptname format a50;
select first_last_name, gone, deptname from employee where employee_id=&1;
exit
