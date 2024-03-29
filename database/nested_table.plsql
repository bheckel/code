
-- nested_table.plsql (symlinked as collections.plsql)
-- See also associative_array_table_indexby.plsql, varray.plsql, nested_table_multiset.plsql, type.plsql
--
--  Created: 02 Aug 2019 (Bob Heckel)
-- Modified: 31-Aug-2022 (Bob Heckel)

-- Associative arrays are particularly good with sparse collections.
-- Nested tables offer lots of features for set-oriented management of collection contents.
-- Varrays - doubt you'll ever use a varray, intended more for usage as nested columns in relational tables,
-- offering some performance advantages.
-- Nested & varrays can be created in a schema object, unlike AA which can be created in a PLSQL block only

-- Collection Methods:
--
-- EXISTS: Returns TRUE if a specified element exists in a collection and can be used to avoid raising 
--         SUBSCRIPT_OUTSIDE_LIMIT exceptions. When you try to get an element at an undefined index value,
--         Oracle raises NO_DATA_FOUND but using EXISTS eliminates that possibility:
--         e.g. IF sons_t.EXISTS(index_in) THEN...
--         But you should avoid the FOR loop and instead opt for a WHILE loop and the NEXT or PRIOR methods 
--         to help you navigate from one defined index value to the next. E.g.:
--
--         DECLARE i VARCHAR2(15);
--         BEGIN
--           ...
--           i := l_union.FIRST;
--  
--           WHILE i IS NOT NULL LOOP
--             DBMS_OUTPUT.PUT_LINE(l_union(i) || '  ' || i);
--             i := l_union.NEXT(i);
--           END LOOP;
--
-- COUNT: Returns the total number of elements in a collection.
--
-- FIRST / LAST: Return subscripts of the first and last elements of a collection. If the first element of 
--               a nested table is deleted, the FIRST method returns a value greater than 1. If elements are 
--               deleted from the middle of a nested table, the LAST method returns a value greater than 
--               the COUNT method.
--
-- PRIOR / NEXT: These functions return subscripts that precede and succeed a specified collection subscript.
--
-- Methods NOT allowed with index-by associative arrays:
-- EXTEND: Increases the size of a collection.
-- TRIM: Removes either one or a specified number of elements from the end of a collection. PL/SQL does not 
--       keep placeholders for the trimmed elements.
--
-- Methods NOT allowed with varrays:
-- DELETE: deletes either all elements, just the elements in the specified range, or a particular element 
--         from a collection. PL/SQL keeps placeholders of the deleted elements.
--
-- Methods ONLY allowed with varrays:
-- LIMIT: Returns the maximum number of elements that a collection can contain

-- You can compare nested table variables to the value NULL or to each other see compare_nested_tables.plsql

-- https://docs.oracle.com/database/121/LNPLS/composites.htm#LNPLS99981

---

--  set serveroutput on size 100000
declare
  TYPE t_associativeVarcharTable IS TABLE OF VARCHAR2(32767) INDEX BY VARCHAR2(200);
  v_columnSuffixTable  t_associativeVarcharTable;

  TYPE t_varchar2Table IS TABLE OF VARCHAR2(32767);
  TYPE t_varchar2List IS TABLE OF t_varchar2Table INDEX BY VARCHAR2(200);
  v_joinColumnTable  t_varchar2List;

  v_today  VARCHAR2(11) := TO_CHAR(SYSDATE, 'DDMONYY');
begin
  v_columnSuffixTable('PRODUCT_RELEASE_' || v_today) := 'pr';    
  DBMS_OUTPUT.put_line(v_columnSuffixTable('PRODUCT_RELEASE_' || v_today));  -- pr
  
  -- Loop a hardcoded list of strings
  v_joinColumnTable('PRODUCT_RELEASE_' || v_today) := t_varchar2Table('SOFTWARE_PRODUCT_ID','FOO');  
  DBMS_OUTPUT.put_line(v_joinColumnTable('PRODUCT_RELEASE_' || v_today)(2));  -- FOO
end;

---

DECLARE
  TYPE vctable_t IS TABLE OF VARCHAR2(3);
  vctable  vctable_t;
BEGIN
  -- References a constructor that takes 3 values as arguments
  vctable := vctable_t('ABC', 'DEF', 'GHI');
  FOR i IN 1 .. vctable.COUNT LOOP
    DBMS_OUTPUT.put_line(vctable(i));
  END LOOP;
END;

-- same
DECLARE
  vctable SYS.odcivarchar2list := SYS.odcivarchar2list('ABC', 'DEF', 'GHI');
BEGIN
  FOR i IN 1 .. vctable.COUNT LOOP
    DBMS_OUTPUT.put_line(vctable(i));
  END LOOP;
END;

---

-- Query a db table looping a hardcoded list of numbers
-- Schema-level declaration is ok for nested tables, not associative arrays
DECLARE
  TYPE my_ntt IS TABLE OF INTEGER;
  -- Initialized with constructor:
  my_nt my_ntt := my_ntt(1,2,3,4);
  
	foo NUMBER;
BEGIN 
  my_nt(3) := 9;  -- change a value
	dbms_output.put_line('change value of one element: ' || my_nt(3));
 
  my_nt := my_ntt(5,6,7,7499);  -- change whole table
	dbms_output.put_line('change entire table: ' || my_nt(3));

	select ename
		into foo
    from emp
	--where empno in (select column_value from table(my_nt));  -- fail
	 where empno = my_nt(4);

	dbms_output.put_line(foo);
END;

-- Dynamic table
DECLARE
	/* TYPE last_name_type IS TABLE OF VARCHAR2(50); */
  -- better
	TYPE last_name_type IS TABLE OF emp.ename%TYPE;
  -- Uninitialized at the time of declaration, it's NULL so this works:  IF last_name_tab IS NULL...
  -- but you have to have  last_name_tab := last_name_type();  prior to the FOR loop if you go this way:
	/* last_name_tab last_name_type; */

  -- Initialized at the time of declaration, it's empty but not NULL:
	last_name_tab last_name_type := last_name_type();

	i PLS_INTEGER := 0;

	CURSOR name_cur IS
		SELECT ename FROM emp WHERE rownum < 10;
BEGIN
  IF last_name_tab IS NULL THEN dbms_output.put_line('ok'); END IF;

  -- Loop cursor and load it into our empty nested table collection
	FOR rec IN name_cur LOOP
		i := i + 1;
		last_name_tab.EXTEND;
		last_name_tab(i) := rec.ename;
    DBMS_OUTPUT.PUT_LINE (' loaded last_name('||i||') with '||last_name_tab(i));
  END LOOP;

  FOR i IN 1 .. last_name_tab.COUNT LOOP
  -- same but COULD fail due to sparse collection (VALUE_ERROR):
  /* FOR i IN last_name_tab.FIRST .. last_name_tab.LAST LOOP */
    DBMS_OUTPUT.PUT_LINE ('last_name is: '||last_name_tab(i));
  END LOOP;

  last_name_tab.DELETE;
END;

---

-- Adapted: Thu, May 23, 2019 11:48:53 AM (Bob Heckel -- http://www.dba-oracle.com/plsql/t_plsql_sparse.htm) 
--create table forall_test as select * from scott.emp where 1=0

DECLARE
  bulk_dml_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(bulk_dml_error, -24381);

  TYPE t_forall_test_tab IS TABLE OF scott.emp%ROWTYPE;
  l_tab  t_forall_test_tab := t_forall_test_tab();

BEGIN
  FOR i IN 1 .. 100 LOOP
    l_tab.EXTEND;
    l_tab(l_tab.last).empno := i;
    l_tab(l_tab.last).sal   := TO_CHAR(i);
  END LOOP;

  -- Then make collection sparse
  l_tab.DELETE(31);
  l_tab.DELETE(61);
  l_tab.DELETE(91);

  EXECUTE IMMEDIATE 'TRUNCATE TABLE forall_test';

  -- This will fail due to sparse collection
 /*FORALL i IN l_tab.FIRST .. l_tab.LAST SAVE EXCEPTIONS
      INSERT INTO forall_test VALUES l_tab(i);
  END;*/

  FORALL i IN INDICES OF l_tab SAVE EXCEPTIONS
    INSERT INTO forall_test VALUES l_tab(i);

EXCEPTION
	WHEN bulk_dml_error THEN 
		FOR ix IN 1 .. SQL%BULK_EXCEPTIONS.COUNT LOOP 
			DBMS_OUTPUT.put_line(SQLERRM(-(SQL%BULK_EXCEPTIONS(ix).ERROR_CODE))); 
		END LOOP; 
END;

---

-- Load a collection using a table
declare
  type numbers_t is table of number;
  l_nums numbers_t;  -- no initialization required for bulk collect!

begin
  select line+100
    BULK COLLECT INTO l_nums
    from all_source
   where rownum<5
    ;
  dbms_output.put_line(l_nums(2));  -- 102
  dbms_output.put_line(l_nums.last);  -- 4
end;

---

-- Sort a collection
    FOR i IN 1 .. t_assign_table.COUNT LOOP
      IF t_assign_table(i).assign_error = 0 AND t_assign_table(i).new_account_team_assignment_id IS NOT NULL THEN
        v_sqltxt := q'[
                      SELECT tb.task_id,
                              a.activity_id,
                              lead_owner_id,
                              :1,
                              tb.due_date,
                              tb.number_of_hours,
                              tb.status,
                              tb.outcome,
                              tb.origin,
                              tb.category,
                              tb.origin_task_id,
                              NVL(c.list_of_values_id, 528090) outcome_lov_id,
                              tb.contact_id,
                             0 as task_error,
                             '' as task_error_msg
                        FROM ACCOUNT_TEAM_ASSIGN_ALL,
                             account_name                an,
                             activity_search             s,
                             activity                    a,
                             task_base                   tb,
                             custom_query_lov_view       c
                       WHERE an.account_name_id = s.account_name_id
                         AND s.activity_search_id = a.activity_id
                         AND a.activity_id = tb.activity_id
                         AND TB.CURRENT_TASK = 1
                         AND TB.STATUS != 'Completed'
                         AND TB.STATUS != 'Deferred'
                         AND TB.EMPLOYEE_ID = lead_owner_id
                         AND a.SALESGROUP = C.CUSTOM_LEVEL_VALUE(+)
                         AND c.list_name(+) = 'LeadOutcome'
                         AND c.VALUE(+) = 'Reassigned'
                         AND account_team_assignment_id = :2
                     ]';

         EXECUTE IMMEDIATE v_sqltxt BULK COLLECT
           INTO t_task_table
          USING t_assign_table(i).new_lead_owner_id, t_assign_table(i).new_account_team_assignment_id;

         IF t_task_table.COUNT > 0 THEN
          t_task_table_dedup := t_task_table MULTISET UNION t_task_table_dedup;

         END IF;  -- there are tasks for this account_team_assignment_id
      END IF;    -- not an error record
    END LOOP;   -- each account_team_assignment_id's task is added to t_task_table_dedup

    -- Sort collection
    FOR M in t_task_table_dedup.FIRST .. (t_task_table_dedup.LAST - 1) LOOP
      FOR N in (M+1) .. t_task_table_dedup.LAST LOOP
        IF t_task_table_dedup(M).task_id > t_task_table_dedup(N).task_id THEN
          v_tmp := t_task_table_dedup(N).task_id;
          t_task_table_dedup(N).task_id := t_task_table_dedup(M).task_id;
          t_task_table_dedup(M).task_id := v_tmp;
        END IF;
      END LOOP;
    END LOOP;

    -- Delete duplicates to avoid reprocessing
    FOR M in t_task_table_dedup.FIRST .. (t_task_table_dedup.LAST -1) LOOP
      IF t_task_table_dedup(M).task_id >= t_task_table_dedup(M+1).task_id THEN
        /* t_task_table_dedup(M).task_id := 0; */
        t_task_table_dedup.delete(M);
      END IF;
    END LOOP;

---

-- Populate a table using a collection with commit intervals instead of BULK COLLECT)
FOR i IN 1 .. t_assign_table.COUNT LOOP
  INSERT /*+ APPEND */ INTO tmp_audit_sp VALUES (t_assign_table(i).account_id,
                                                 t_assign_table(i).old_account_team_assignment_id, t_assign_table(i).new_account_team_assignment_id,
                                                 t_assign_table(i).old_assign_territory_lov_id, t_assign_table(i).new_assign_territory_lov_id,
                                                 t_assign_table(i).account_site_id,
                                                 t_assign_table(i).assignment_active,
                                                 SYSDATE);
  IF mod(i, v_assign_limit) = 0 THEN
    COMMIT;
  END IF;
END LOOP;
COMMIT;

---

-- Pass collection to a function
CREATE OR REPLACE PACKAGE bob2 IS
  TYPE name_coll_type IS TABLE OF VARCHAR2(32767);
  
  FUNCTION name_coll_type_to_varchar2 (
     p_name_coll    IN name_coll_type
   , p_delimiter    IN VARCHAR2 DEFAULT ', '
  ) RETURN VARCHAR2;
  
  PROCEDURE do;
END;

CREATE OR REPLACE PACKAGE BODY bob2 IS
  FUNCTION name_coll_type_to_varchar2 (
     p_name_coll    IN name_coll_type
   , p_delimiter    IN VARCHAR2 DEFAULT ', '
  ) RETURN VARCHAR2
  IS
     v_name_string  VARCHAR2(32767);
  BEGIN
     FOR idx IN p_name_coll.first .. p_name_coll.last LOOP
      IF idx = p_name_coll.first THEN
         v_name_string := p_name_coll(idx);
      ELSE
         v_name_string := v_name_string
                       || p_delimiter
                       || p_name_coll(idx);
      END IF;
      DBMS_OUTPUT.put_line('loop ' || p_name_coll(idx));
     END LOOP;
     
     RETURN v_name_string;
  END;

  PROCEDURE do IS    
    nc name_coll_type := name_coll_type('foo','bar');
    x VARCHAR2(32767);
    
    BEGIN
      nc(1) := 'baz';
      
      x := name_coll_type_to_varchar2(p_name_coll=>nc);
      DBMS_OUTPUT.put_line('ok2 ' || x);
  END;
END;
exec bob2.do;

---

create or replace package rion56370 as
  type closeout_rec is record(
    closeout_yr  NUMBER,
    closeout_mo  NUMBER,
    closeout_dy  NUMBER
  );
  type closeout_table_t is table of closeout_rec index by binary_integer;
  closeout_table closeout_table_t := closeout_table_t();

  function get_eoy_date(in_year NUMBER DEFAULT NULL) return date RESULT_CACHE;  
end;
/
create or replace package body rion56370 as
  /* CreatedBy: Bob Heckel
  **   Created: 14-Feb-22
  **   Purpose: Get EOY date calculator
  **  Modified: 14-Feb-22 (bheck) Initial version - RION-56370
  */
  function get_eoy_date(in_year NUMBER DEFAULT NULL) return date RESULT_CACHE is
    l_dt_str varchar2(20);
    l_yr   number;
  begin
    closeout_table(2010).closeout_yr := 2011;
    closeout_table(2010).closeout_mo := 01;
    closeout_table(2010).closeout_dy := 14;

    closeout_table(2011).closeout_yr := 2012;
    closeout_table(2011).closeout_mo := 01;
    closeout_table(2011).closeout_dy := 13;

    ...

    closeout_table(2020).closeout_yr := 2021;
    closeout_table(2020).closeout_mo := 01;
    closeout_table(2020).closeout_dy := 15;

    closeout_table(2021).closeout_yr := 2022;
    closeout_table(2021).closeout_mo := 01;
    closeout_table(2021).closeout_dy := 15;
    
    closeout_table(2022).closeout_yr := 2022;
    closeout_table(2022).closeout_mo := null;
    closeout_table(2022).closeout_dy := null;
    
    if in_year is null then
      l_yr := extract(year from sysdate);
    else
      l_yr := in_year;
    end if;

    l_dt_str := nvl(closeout_table(l_yr).closeout_mo, '01') || '/' || nvl(closeout_table(l_yr).closeout_dy, '01') || '/' || closeout_table(l_yr).closeout_yr;

    return to_date(l_dt_str, 'MM/DD/YYYY'); 
  end;
end;
/
alter package rion56370 compile debug;
--  set serverout on size 100000
declare 
  x date; 
  y number;
begin 
  x:= rion56370.get_eoy_date(2014);
  DBMS_OUTPUT.put_line(x);
  y:= extract(year from rion56370.get_eoy_date());
  DBMS_OUTPUT.put_line('get_current_reporting_year version: ' || y);
end;

---

-- Compare three approaches to load populate fill a collection using BULK COLLECT:

-- 1.  EXECUTE IMMEDIATE BULK COLLECT INTO specific defined numberTables
create or REPLACE PACKAGE bob as
  PROCEDURE cae_auto_assign;
end;
/
create or replace PACKAGE body bob as
  PROCEDURE cae_auto_assign
  IS
    TYPE numberTable IS TABLE OF NUMBER;
    acctIdTable     numberTable;
    acctSiteIdTable numberTable;
    employeeIdTable numberTable;

    BEGIN
      EXECUTE IMMEDIATE 'select account_id, account_site_id, cae_emp_id from nightly_cae_assign where rownum<9'
        BULK COLLECT INTO acctIdTable, acctSiteIdTable, employeeIdTable;

      FOR i IN 1 .. acctIdTable.count LOOP
        DBMS_OUTPUT.put_line('assigning CAE ' || employeeIdTable(i) || ' to account site id : ' || acctSiteIdTable(i));
      END LOOP;
  END;
END;

-- 2. Fetch from a cursor variable, allows LIMIT instead of relying on the default limit of 100
create or REPLACE PACKAGE bob as
  PROCEDURE cae_auto_assign;
end;
/
create or replace PACKAGE body bob as
  PROCEDURE cae_auto_assign
  IS
    cv  SYS_REFCURSOR;

    TYPE t IS TABLE OF nightly_cae_assign%ROWTYPE;
    mytbl t;
  BEGIN
    -- Must use "*"
    open cv for 'select * from nightly_cae_assign where rownum<9';
  
    LOOP
      fetch cv bulk collect into mytbl LIMIT 50;
      exit when mytbl.COUNT=0;
  
      for i in 1..mytbl.COUNT loop
        DBMS_OUTPUT.put_line(mytbl(i).account_site_id);
      end loop;
    END LOOP;
  END cae_auto_assign;
END bob;

-- 3. Use a TABLE of type RECORD
create or replace function get_eoy_date(in_year NUMBER) return number deterministic as
  type days_table_rec is record(
    year      mkc_years.year%type,
    start_day mkc_years.start_day%type,
    end_day   mkc_years.end_day%type
    );
  type days_table is table of days_table_rec;

  l_days_table days_table;
  
  --x number := EXTRACT(YEAR FROM SYSDATE);
begin
  --x:=in_year;
  select year, start_day, end_day
    BULK COLLECT into l_days_table
    from mkc_years;
  
  return(l_days_table(2).start_day);
end;

-- A double loop version of #1:
declare
  TYPE t_varchar2Table IS TABLE OF VARCHAR2(32767);
  siteTbl t_varchar2Table;
  sdmbkTbl t_varchar2Table;
begin
  execute immediate q'[ 
                        select '960227' siten from dual
                        union
                        select '914689' siten from dual
                      ]' bulk collect into siteTbl
  ;

  for i in 1 .. siteTbl.count loop
    DBMS_OUTPUT.put_line(siteTbl(i));

    execute immediate q'[
                          select sdm_business_key
                            from MC_REVENUE_FULL
                           where site_id=:1
                           and nvl(account_id_for_joins,0) not in ( 
                                 select account_id
                                from account_name an, account_site ast, site s
                               where an.account_name_id = ast.account_name_id
                                 and ast.site_id = s.site_id
                                 and s.site_number=:2
                            )
                        ]' bulk collect into sdmbkTbl
                           using siteTbl(i), siteTbl(i)
      ;
     
    for j in 1 .. sdmbkTbl.count loop
      DBMS_OUTPUT.put_line(sdmbkTbl(j));
    --delete from mc_revenue_full where
    end loop;
  end loop;
end;

