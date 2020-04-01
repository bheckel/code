-- Oracle hierarchy (e.g. organization chart) traversal
-- Modified: 30-Mar-2020 (Bob Heckel)

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

---

-- Recursive subquery factoring Practical Oracle SQL - Kim Berg Hansen

-- Fail
select
   connect_by_root p.id as p_id
 , connect_by_root p.name as p_name
 , c.id as c_id
 , c.name as c_name
 , ltrim(sys_connect_by_path(pr.qty, '*'), '*') as qty_expr
 , qty * prior qty as qty_mult
from packaging_relations pr
join packaging p
   on p.id = pr.packaging_id
join packaging c
   on c.id = pr.contains_id
where connect_by_isleaf = 1
start with pr.packaging_id not in (
   select c.contains_id from packaging_relations c
)
connect by pr.packaging_id = prior pr.contains_id
order siblings by pr.contains_id;

-- Success
WITH v AS (
  SELECT line,  col, name, LOWER(type) type, LOWER(usage) usage, usage_id, usage_context_id
    FROM user_identifiers
   WHERE object_name = 'AWARD_BONUS'
     AND object_type = 'PROCEDURE'
)
  SELECT line, RPAD(LPAD(' ', 2*(level-1)) ||name, 25, '.')||' '||  RPAD(type, 15)|| RPAD(usage, 15)  IDENTIFIER_USAGE_CONTEXTS
    FROM v
   START WITH usage_context_id = 0
 CONNECT BY PRIOR usage_id = usage_context_id
  ORDER SIBLINGS BY line, col
/

---

with recursive_pr (
   root_id, packaging_id, contains_id, qty, lvl
) as (
   select
      pr.packaging_id as root_id
    , pr.packaging_id
    , pr.contains_id
    , pr.qty
    , 1 as lvl
   from packaging_relations pr
   where pr.packaging_id not in (
      select c.contains_id from packaging_relations c
   )
   union all
   select
      rpr.root_id
    , pr.packaging_id
    , pr.contains_id
    , rpr.qty * pr.qty as qty
    , rpr.lvl + 1      as lvl
   from recursive_pr rpr
   join packaging_relations pr
      on pr.packaging_id = rpr.contains_id
)
   search depth first by contains_id set rpr_order
select
   p.id as p_id
 , p.name as p_name
 , c.id as c_id
 , c.name as c_name
 , leaf.qty
from (
   select
      root_id, contains_id, sum(qty) as qty
   from (
      select
         rpr.*
       , case
            when nvl(
                    lead(rpr.lvl) over (order by rpr.rpr_order)
                  , 0
                 ) > rpr.lvl
            then 0
            else 1
         end as is_leaf
      from recursive_pr rpr
   )
   where is_leaf = 1
   group by root_id, contains_id
) leaf
join packaging p
   on p.id = leaf.root_id
join packaging c
   on c.id = leaf.contains_id
order by p.id, c.id;
