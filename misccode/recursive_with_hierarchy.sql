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
