-- Drop temp tables
begin
  for r in ( select TABLE_NAME from user_tables where table_name like '%27SEP21' and last_analyzed>sysdate-interval '1' hour ) loop
    DBMS_OUTPUT.put_line(r.table_name);
    execute immediate 'drop table ' || r.table_name ;
    --execute immediate 'drop table ' || r.table_name || ' purge';
  end loop;
end;
