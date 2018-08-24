declare
  -- Boolean parameters are translated from/to integers: 
  -- 0/1/null <--> false/true/null 
  result boolean;
  result2 VARCHAR2(1);
begin
  -- Call the function
  result := boboncall.is_account_deletable(in_account_id => 4164032);
  -- Convert false/true/null to 0/1/null 
  result2 := sys.diutil.bool_to_int(result);
  dbms_output.put_line(chr(10) || result2);
end;
