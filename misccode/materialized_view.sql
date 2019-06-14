-- https://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:9538465900346087401

create materialized view mv as 
  select * from t;
  
create index i on mv ( c1 );

insert into t values ( 2 );

commit;

select * from mv;
/*
1
*/

exec dbms_mview.refresh ( 'MV', 'C' );

select * from mv;
/*
1
2
*/

select table_name, index_name 
from   user_indexes
where  table_name in ( 'T', 'MV' );
/*
MV           I   
*/
