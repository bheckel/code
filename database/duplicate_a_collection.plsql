--Created: 19-Aug-2022 (Bob Heckel)
--  set serveroutput on size 100000
declare
  type team_r is record (
    account_team_employee_id  number,
    employee_id number,
    function_lov_id number,
    old_account_team_id number,
    new_account_team_id number
    );
  type team_table is table of team_r;
  l_team_table team_table;
  
  acct_team_emp_fn_list ASP_PKG_TYPES.account_team_employee_va;
  l_newtid number;  
begin
  EXECUTE IMMEDIATE q'[ 
    SELECT account_team_employee_id, employee_id, function_lov_id, :1 as old_account_team_id, null as new_account_team_id
      FROM account_team@roion_prod_rw at, account_team_employee@roion_prod_rw ate
     WHERE at.account_team_id=ate.account_team_id and at.account_team_id=:2
  ]'
  BULK COLLECT INTO l_team_table
  USING 1038760,1038760 /* 173851, 173851*/;

  acct_team_emp_fn_list := ASP_PKG_TYPES.account_team_employee_va();

  for j in 1 .. l_team_table.COUNT loop
    acct_team_emp_fn_list.extend;
    acct_team_emp_fn_list(j).employee_id := l_team_table(j).employee_id;
    acct_team_emp_fn_list(j).function_lov_id := l_team_table(j).function_lov_id;
    DBMS_OUTPUT.put_line(l_team_table(j).account_team_employee_id || ' ' || l_team_table(j).employee_id || ' ' || l_team_table(j).function_lov_id);
  end loop;

  l_newtid := ASP_PKG.create_account_team(0, acct_team_emp_fn_list);
  DBMS_OUTPUT.put_line('l_newtid ' || l_newtid);

  for l in 1 .. l_team_table.COUNT loop
    l_team_table(l).new_account_team_id := l_newtid;
    DBMS_OUTPUT.put_line('eid: ' || l_team_table(l).employee_id || ' (' || l_team_table(l).function_lov_id || ') ' 
                          || ' oldtid: ' || l_team_table(l).old_account_team_id || ' newtid: ' || l_team_table(l).new_account_team_id);
  end loop;

EXCEPTION
WHEN OTHERS THEN
  rollback;
  DBMS_OUTPUT.put_line(SQLCODE || ':' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
end;
