-- Adapted: 01-Sep-2021 (Bob Heckel--https://www.orafaq.com/wiki/Unusable_indexes)

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
