--  Adapted: 01-Sep-2021 (Bob Heckel--https://www.orafaq.com/wiki/Unusable_indexes)
-- Modified: 11-Oct-2022 (Bob Heckel)

-- Loop a command

-- set serveroutput on size unlimited
BEGIN
	FOR x IN (
		SELECT 'ALTER INDEX '||OWNER||'.'||INDEX_NAME||' REBUILD ONLINE PARALLEL' comm
		  FROM dba_indexes
		 WHERE status = 'UNUSABLE'
		UNION ALL
		SELECT 'ALTER INDEX '||index_owner||'.'||index_name||' REBUILD PARTITION '||partition_name||' ONLINE PARALLEL'
		  FROM dba_ind_PARTITIONS
		 WHERE status = 'UNUSABLE'
		UNION ALL
		SELECT 'ALTER INDEX '||index_owner||'.'||index_name||' REBUILD SUBPARTITION '||subpartition_name||' ONLINE PARALLEL'
		  FROM dba_ind_SUBPARTITIONS
		 WHERE status = 'UNUSABLE'
	) LOOP
		dbms_output.put_line(x.comm);
		EXECUTE IMMEDIATE x.comm;
	END LOOP;
END;

---

--  set serverout on size 100000
DECLARE
  l_cnt number default 0;
BEGIN
  for r in ( select distinct uic.INDEX_NAME  from user_ind_columns uic  where uic.TABLE_NAME = 'MKC_REVENUE_FULL_BH' and index_name  like 'krfbh%' ) loop
    l_cnt := l_cnt + 1;
    DBMS_OUTPUT.put_line(l_cnt || ' ' || r.index_name);
    -- Uppercase is important because indexes have been double quoted when they were created
    execute immediate 'ALTER INDEX ' || chr(34) || r.index_name || chr(34) || ' rename to ' || chr(34) || upper(r.index_name) || chr(34);
  end loop;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(SQLCODE || ':' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
END;

