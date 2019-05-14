DECLARE
  dbg boolean := sys.diutil.int_to_bool(1);
  ids maint_types.numbertable;
BEGIN maint.get_unique_id_across_all_db(seq_name => 'uid_orion_37551',
                                        num_seqs_requested => 2,
                                        ids => ids,
                                        dbg => dbg);
END;

---

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
