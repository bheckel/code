-- Oracle organization chart traversal
-- Created: Thu 25 Oct 2018 11:13:55 (Bob Heckel)

create table employees (
  employee_id   integer,
  employee_name varchar2(30),
  manager_id    integer
);

insert into employees values ( 1, 'Big Boss', null );
insert into employees values ( 2, 'Stressed Manager', 1 );
insert into employees values ( 3, 'Lowly Worker', 2 );
insert into employees values ( 4, 'Aspiring Junior', 2 );
insert into employees values ( 5, 'The Newbie', 2 );
insert into employees values ( 6, 'Master Senior Consultant', 1 );

commit;

select level,
       lpad ( ' ', level, ' ' ) || employee_name employee
from   employees
start  with manager_id = 1
connect by prior employee_id = manager_id;  -- place PRIOR before the column with the values you're accessing from the parent 

select level,  
       lpad ( ' ', level, ' ' ) || employee_name employee,
       prior employee_name manager
from   employees 
start  with employee_name = 'Big Boss' 
connect by prior employee_id = manager_id;
-- Only sorts rows with the same parent
--order siblings by manager_id
/*
LEVEL   EMPLOYEE                     MANAGER            
      1  Big Boss                    <null>             
      2   Stressed Manager           Big Boss           
      3    Lowly Worker              Stressed Manager   
      3    Aspiring Junior           Stressed Manager   
      3    The Newbie                Stressed Manager   
      2   Master Senior Consultant   Big Boss
*/

---

select regexp_substr(ename_path, '[^/]+', 1, 1) e1,
       regexp_substr(job_path, '[^/]+', 1, 1) j1,
       regexp_substr(ename_path, '[^/]+', 1, 2) e2,
       regexp_substr(job_path, '[^/]+', 1, 2) j2,
       regexp_substr(ename_path, '[^/]+', 1, 3) e3,
       regexp_substr(job_path, '[^/]+', 1, 3) j3
from (
  select sys_connect_by_path(job, '/') job_path,sys_connect_by_path(ename, '/') ename_path
  from scott.emp
  start with mgr is null  -- root node
  connect by prior empno = mgr  -- parent row col = child row rol
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
    select sys_connect_by_path(job, '/') job_path,sys_connect_by_path(ename, '/') ename_path
    from scott.emp
    start with mgr is null
    connect by prior empno = mgr
  ) 
)

---

create table folders (
  folder_name        varchar2(128),
  parent_folder_name varchar2(128)
);

insert into folders values ( '/home', null );
insert into folders values ( '/tmp', null );
insert into folders values ( '/saxon', '/home' );
insert into folders values ( '/feuerstein', '/home' );
insert into folders values ( '/junk', '/tmp' );

with folder_tree (folder_name, parent_folder, directory_path) as ( 
  select folder_name, parent_folder_name, folder_name directory_path  
  from   folders 
  where  parent_folder_name is null 
  UNION ALL 
  select f.folder_name, f.parent_folder_name, ft.directory_path || f.folder_name directory_path
  from   folder_tree ft 
  join   folders f  on ft.folder_name=f.parent_folder_name 
) 
  select folder_name, directory_path  
  from   folder_tree 
  order  by directory_path;
/*
FOLDER_NAME	DIRECTORY_PATH
/home	      /home
/feuerstein	/home/feuerstein
/saxon	    /home/saxon
/tmp	      /tmp
/junk	      /tmp/junk
*/
