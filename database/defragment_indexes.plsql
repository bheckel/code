
BEGIN
  sys.dbms_scheduler.create_job(
    job_name => 'ATLAS_MANUAL_' || get_db_name,
    job_type => 'PLSQL_BLOCK',
    job_action => q'[ 
                      declare
                        a number; b number; c number; d number;
                      begin
                        for r in ( select distinct uic.INDEX_NAME ix from user_ind_columns uic where uic.TABLE_NAME = 'MKC_REVENUE_FULL_BOB' ) loop
                          execute immediate 'ANALYZE index ' || r.ix || ' VALIDATE STRUCTURE';
                          
                          SELECT DECODE(LF_ROWS, 0, 0, ROUND((DEL_LF_ROWS/LF_ROWS)*100,2)) RATIO, HEIGHT, LF_BLKS, LF_ROWS
                            into a, b, c, d
                            FROM INDEX_STATS I;
                          
                          if a > .5 then
                            DBMS_OUTPUT.put_line(r.ix || ' ratio:'||a || ' height:'||b || ' lf_blks:'||c || ' lf_rows:'||d);
                            EXECUTE IMMEDIATE('ALTER INDEX ' || r.ix || ' REBUILD PARALLEL 8'); 
                            EXECUTE IMMEDIATE('ALTER INDEX ' || r.ix || ' NOPARALLEL'); 
                          end if;
                        end loop;
                      end;
                    ]',
    start_date => systimestamp + INTERVAL '10' SECOND,    
    enabled => true,
    comments => 'manual by boheck');
END;
--scheduled/running?
SELECT state, NEXT_RUN_DATE, job_name, job_type, job_action, start_date, repeat_interval, end_date, job_class, enabled, auto_drop, comments FROM user_scheduler_jobs WHERE job_name like 'ATLAS_MANUAL_%';
--finished status
SELECT job_name, status, error#, errors, actual_start_date, run_duration, output, errors FROM user_scheduler_job_run_details WHERE job_name like 'ATLAS_MANUAL_%' ORDER BY actual_start_date DESC;

