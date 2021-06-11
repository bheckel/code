 --  set serveroutput on
 declare
   TYPE t_nested_tbl IS TABLE OF number;
   id_table t_nested_tbl;

   cursor c1 is 
     select opportunity_id from opportunity where rownum<9;
 begin
   open c1; 
   loop
       fetch c1 BULK COLLECT into id_table;
       exit when id_table.COUNT = 0;
       for i IN 1 .. id_table.COUNT loop
         DBMS_OUTPUT.put_line('x ' || id_table(i));
       end loop;
   end loop;
end;     
