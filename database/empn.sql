
--save occasionally to :silent! w!~/onedrive/misc/bkup/%:t
set linesize 250;
set pagesize 100;
column first_last_name format a45;
column sas_empno format a10;
column deptname format a40;
select e.employee_id, e.first_last_name, e.sas_empno, e.territory_lov_id, e.gone, e.deptname
  from employee_base e, rpt_orion_terr_hierarchy_mv r, employee_base e2
 where e.territory_lov_id=r.territory_lov_id(+) and e.actual_updatedby=e2.employee_id
   and lower(e.first_last_name) like '%&1%'
 order by e.last_name, e.first_name
;
exit
