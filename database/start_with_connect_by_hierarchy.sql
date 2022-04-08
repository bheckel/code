-- Oracle hierarchy (e.g. organization chart) traversal
-- Modified: Wed 06-May-2020 (Bob Heckel)

---

with v as (            
select e.employee_id, e.full_name, e.last_name, e.sas_empno, e.MANAGER_SAS_EMPNO, e.gone, e.hire_date
  from employee_base e start with e.manager_sas_empno is null
 connect by e.manager_sas_empno=prior e.sas_empno
order siblings by e.full_name
)
select v.*, e.full_name mgr
  from v, employee_base e
 where v.manager_sas_empno = e.sas_empno
  --and lower(v.full_name) like '%donna trice%' and e.gone = 'N'  --search as emp
  and lower(e.full_name) like '%donna trice%' and v.gone = 'N'  --search as mgr
 order by v.last_name;

---

select
   e.empno
 , lpad(' ', 2*(level-1)) || e.ename
 , e.job
 , e.mgr
from scott.emp e
start with e.mgr is null
--where foo=42
connect by e.mgr = prior e.empno
order siblings by e.ename;

---

-- Adapted from Practical Oracle SQL (unit_test_repos schema)
select
   e.id
 , lpad(' ', 2*(level-1)) || e.name as name
 , e.title as title
 , e.supervisor_id as super
from employees e
start with e.supervisor_id is null
connect by e.supervisor_id = prior e.id
order siblings by e.name;
/*
ID   NAME                TITLE              SUPER
142  Harold King         Managing Director
144    Axel de Proef     Product Director   142
151      Jim Kronzki     Sales Manager      144
150        Laura Jensen  Bulk Salesman      151
154        Simon Chang   Retail Salesman    151
148      Maria Juarez    Purchaser          144
147    Ursula Mwbesi     Operations Chief   142
146      Lim Tok Lo      Warehouse Manager  147
152        Evelyn Smith  Forklift Operator  146
149        Kurt Zollman  Forklift Operator  146
155        Susanne Hoff  Janitor            146
143      Mogens Juel     IT Manager         147
153        Dan Hoeffler  IT Supporter       143
145        Zoe Thorston  IT Developer       143
*/

WITH hierarchy AS (
   select
      lvl, id, name, rownum as rn
   from (
      select
         level as lvl, e.id, e.name
      from employees e
      start with e.supervisor_id is null
      connect by e.supervisor_id = prior e.id
      order siblings by e.name
   )
)
SELECT
   id
 , lpad(' ', (lvl-1)*2) || name as name
 , subs
 , cls
FROM hierarchy
MATCH_RECOGNIZE (
   order by rn
   MEASURES
      strt.rn           as rn
    , strt.lvl          as lvl
    , strt.id           as id
    , strt.name         as name
    , count(higher.lvl) as subordinate_cnt
    , classifier()      as cls  -- STRT or HIGHER
   ONE ROW PER MATCH
   AFTER MATCH SKIP TO NEXT ROW
   PATTERN (
      strt higher*  -- higher+ to just get the manager count rows
   )
   DEFINE
      higher as higher.lvl > strt.lvl
)
order by rn;

---

create table employeesx (
  employee_id   integer,
  employee_name varchar2(30),
  manager_id    integer
);

insert into employeesx values ( 1, 'Big Boss', null );
insert into employeesx values ( 2, 'Stressed Manager', 1 );
insert into employeesx values ( 3, 'Lowly Worker', 2 );
insert into employeesx values ( 4, 'Aspiring Junior', 2 );
insert into employeesx values ( 5, 'The Newbie', 2 );
insert into employeesx values ( 6, 'Master Senior Consultant', 1 );

commit;

select level,
       lpad ( ' ', level, ' ' ) || employee_name employee
from   employeesx
start  with manager_id = 1
connect by prior employee_id = manager_id;  -- place PRIOR before the column with the values you're accessing from the parent 

select level,  
       lpad ( ' ', level, ' ' ) || employee_name employee,
       prior employee_name manager
from   employeesx
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

---

create table folders (
  folder_name        varchar2(128),
  parent_folder_name varchar2(128)
);

insert into folders values ( 'home', 'junk' );
insert into folders values ( 'saxon', 'home' );
insert into folders values ( 'junk', 'saxon' );

commit;

select folder_name,  
       sys_connect_by_path ( folder_name, '/' ) path 
from   folders 
start  with folder_name = 'home' 
connect by nocycle prior folder_name = parent_folder_name;
/*
FOLDER_NAME	PATH
home				/home
saxon				/home/saxon
junk				/home/saxon/junk

*/

/* Same using Recursive With */
with tree ( folder_name, path ) as ( 
  select folder_name,  
         '/' || folder_name path 
  from   folders 
  where  folder_name = 'home' 
  union all 
  select f.folder_name, 
         t.path || '/' || f.folder_name 
  from   tree t 
  join   folders f 
  on     f.parent_folder_name = t.folder_name 
) cycle folder_name set is_loop to 'Y' default 'N' 
  select folder_name, path  
  from   tree 
  where  is_loop = 'N';

drop table folders cascade constraints purge;

/* This fixes the broken table's cycle errors: */
update folders
set    parent_folder_name = null
where  folder_name = 'home';

