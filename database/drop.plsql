
begin
  for r in ( select table_name from user_tables where table_name like 'MKC_REVENUE2_%2JUL21' ) loop
    DBMS_OUTPUT.put_line(r.table_name);
    execute immediate 'drop table ' || r.table_name || ' purge';
  end loop;
end; 
