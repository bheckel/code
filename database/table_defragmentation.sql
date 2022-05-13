-- Avoid long-running "DELETE FROM..." DML on huge tables

SELECT * FROM EMPLOYEESX;

SELECT * FROM dba_tablespaces;

SELECT DISTINCT sgm.TABLESPACE_NAME , dtf.FILE_NAME, sgm.owner
  FROM DBA_SEGMENTS sgm
  JOIN DBA_DATA_FILES dtf ON (sgm.TABLESPACE_NAME = dtf.TABLESPACE_NAME)
 --WHERE sgm.OWNER = 'ADMIN';
 ORDER BY 1;
 
 alter table employeesx move online;-- tablespace data;--sampleschema;
 
 select table_name,avg_row_len,round(((blocks*16/1024)),2)||'MB' "total_size",
       round((num_rows*avg_row_len/1024/1024),2)||'MB' "actual_size",
       round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2) ||'MB' "fragmented_space",
       (round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2)/round(((blocks*16/1024)),2))*100 "percentage"
 from all_tables 
where table_name='EMPLOYEESX';

 --  ddl employeesx
 
alter table employeesx move online including rows where employee_name != 'Stressed Manager';

SELECT index_name, status FROM user_indexes where status != 'VALID' ORDER BY 1; 

