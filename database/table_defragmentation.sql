-- Avoid long-running "DELETE FROM..." DML on huge tables

SELECT * FROM EMPLOYEESX;

SELECT * FROM dba_tablespaces;

SELECT DISTINCT sgm.TABLESPACE_NAME , dtf.FILE_NAME, sgm.owner
  FROM DBA_SEGMENTS sgm
  JOIN DBA_DATA_FILES dtf ON (sgm.TABLESPACE_NAME = dtf.TABLESPACE_NAME)
 --WHERE sgm.OWNER = 'ADMIN';
 ORDER BY 1;
 
 alter table employeesx move online;-- tablespace data;--sampleschema;
 
 -- Measure table defragmentation
 select table_name,avg_row_len,round(((blocks*16/1024)),2)||'MB' "total_size",
       round((num_rows*avg_row_len/1024/1024),2)||'MB' "actual_size",
       round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2) ||'MB' "fragmented_space",
       (round(((blocks*16/1024)-(num_rows*avg_row_len/1024/1024)),2)/round(((blocks*16/1024)),2))*100 "percentage"
 from all_tables 
where table_name='EMPLOYEESX';

 --  ddl employeesx
 
alter table employeesx move online including rows where employee_name != 'Stressed Manager';

SELECT index_name, status FROM user_indexes where status != 'VALID' ORDER BY 1; 

---

BEGIN
  dbms_scheduler.create_job(
    job_name => 'MANUAL_RUN_' || get_db_name,
    job_type => 'PLSQL_BLOCK',
    job_action => q'[ 
      DECLARE
        l_cnt number default 0;
      BEGIN
        for r in ( select index_name from user_indexes where index_name like 'ASP_DETAILS%' ) loop
          l_cnt := l_cnt + 1;
          execute immediate 'alter index ' || r.index_name || ' rebuild online parallel';
          execute immediate 'alter index ' || r.index_name || ' noparallel';
        end loop;
        
        execute immediate 'alter table ASP_DETAILS enable row movement';
        execute immediate 'alter table ASP_DETAILS move online parallel 8';
        execute immediate 'alter table ASP_DETAILS disable row movement';
        execute immediate 'alter table ASP_DETAILS noparallel';
        DBMS_STATS.gather_table_stats('ESTARS', 'ASP_DETAILS');
        
        e_mail_message('replies-disabled@as.com',
                       'bob.heckel@as.com',
                       'Job MANUAL_RUN done on '  || get_db_name,
                       l_cnt || ' ' || SQLCODE || ': ' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
      EXCEPTION
        WHEN OTHERS THEN
          e_mail_message('replies-disabled@as.com',
                         'bob.heckel@as.com',
                         'Manual run ERROR on ' || get_db_name,
                         SQLCODE || ': ' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
      END;
                    ]',
    start_date => systimestamp + INTERVAL '3' SECOND,
    enabled => true,
    comments => 'manual - do not kill');
END;
-- exec DBMS_SCHEDULER.drop_job(job_name => 'MANUAL_RUN_ORNDBDEV01RW');  exec DBMS_SCHEDULER.stop_job(job_name => 'MANUAL_RUN_ORNDBxRW01');
SELECT state, NEXT_RUN_DATE, job_name, job_type, job_action, start_date, repeat_interval, end_date, job_class, enabled, auto_drop, comments FROM user_scheduler_jobs WHERE job_name like 'MANUAL_RUN%';
SELECT job_name, status, error#, actual_start_date, run_duration, output, errors FROM user_scheduler_job_run_details WHERE job_name like 'MANUAL_RUN%' ORDER BY actual_start_date DESC;
