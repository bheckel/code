-- set serveroutput on size 500000
-- set long 90000
variable c clob

begin DBMS_UTILITY.expand_sql_text('select * from account', :c); end;
  
print c
