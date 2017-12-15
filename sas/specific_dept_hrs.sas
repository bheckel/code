 /*
  *---------------------------------------------------------------------------
  *   Program Name:  specific_dept_hrs.sas
  *
  *        Summary:  Find if dept has had any hours charged to it in '98.
  *                  Criteria provided by Elaine G.
  *
  *      Generated:  Tue 11/10/98 12:40:42 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
option linesize=80 pagesize=32767 nodate source source2 notes mprint
       symbolgen mlogic obs=max errors=3 nostimer number;

title; footnote;

libname master '/disc/data/master/';
%include '~/tabdelim.sas';

proc sql;
  create table work.tmp as
    select job_id, emp_dept, lname, prod_wk, hours, time_cd
      from master.costtime
      where emp_dept = '7429' and prod_wk > 199751;
quit;

%tabdelim(work.tmp, '~/Todel/tmpelaine.xls');
