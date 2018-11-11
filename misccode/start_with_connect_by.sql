-- Oracle organization chart traversal
-- Created: Thu 25 Oct 2018 11:13:55 (Bob Heckel)

select regexp_substr(ename_path, '[^/]+', 1, 1) e1,
       regexp_substr(job_path, '[^/]+', 1, 1) j1,
       regexp_substr(ename_path, '[^/]+', 1, 2) e2,
       regexp_substr(job_path, '[^/]+', 1, 2) j2,
       regexp_substr(ename_path, '[^/]+', 1, 3) e3,
       regexp_substr(job_path, '[^/]+', 1, 3) j3
from (
  select sys_connect_by_path (job, '/') job_path,sys_connect_by_path (ename, '/') ename_path
  from scott.emp
  start with mgr is null
  connect by prior empno = mgr
)



select decode(j1, 'PRESIDENT', e1) president,
       decode(j2, 'MANAGER', e2) manager,
       decode(j3, 'ANALYST', e3) analyst,
       decode(j3, 'SALESMAN', e3) salesman
from (
  select regexp_substr(ename_path, '[^/]+', 1, 1) e1,
         regexp_substr(job_path, '[^/]+', 1, 1) j1,
         regexp_substr(ename_path, '[^/]+', 1, 2) e2,
         regexp_substr(job_path, '[^/]+', 1, 2) j2,
         regexp_substr(ename_path, '[^/]+', 1, 3) e3,
         regexp_substr(job_path, '[^/]+', 1, 3) j3
  from (
    select sys_connect_by_path (job, '/') job_path,sys_connect_by_path (ename, '/') ename_path
    from scott.emp
    start with mgr is null
    connect by prior empno = mgr
  ) 
)
