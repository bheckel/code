--Created: 05-Jul-2022 (Bob Heckel)
BEGIN
  sys.dbms_scheduler.create_job(
    job_name => 'JOB_ROION59407_' || get_db_name,
    job_type => 'PLSQL_BLOCK',
    job_action => q'[ 
                      declare
                        jobnm varchar2(99);
                      begin
                        select job_name
                          into jobnm
                          from user_scheduler_jobs
                         where job_name like 'KMC_REVENUE_LOAD_AUTOEXCLUDE_RNDB_RW01'
                           and state in('SCHEDULED','RUNNING');
                          
                        if jobnm is not null then
                          DBMS_OUTPUT.put_line(jobnm);
                          --EDIT!!!
                          --DBMS_SCHEDULER.drop_job(job_name => 'KMC_REVENUE_LOAD_AUTOEXCLUDE_RNDBTRW01');
                          DBMS_SCHEDULER.drop_job(job_name => 'KMC_REVENUE_LOAD_AUTOEXCLUDE_RNDBPRW01');
                          
                          e_mail_message@ROION_PROD_RW('replies-disabled@as.com',
                                                       --'bob.heckel@as.com',
                                                       'Oracle JOB_ROION59407_' || get_db_name || ' killed an autoexclude job',
                                                       SQLCODE || ': ' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
                        end if;
                        
                        exception
                          when NO_DATA_FOUND then
                            NULL;
                      end;
                    ]',
    repeat_interval =>'Freq=Minutely;Interval=30',
    enabled => true,
    comments => 'Kill any KMC auto exclude jobs (avoid code changes)');
END;
 exec sys.DBMS_SCHEDULER.drop_job('JOB_ROION59407_RNDBTRW01');
--scheduled/running?
SELECT state, NEXT_RUN_DATE,job_name, job_type, job_action, start_date, repeat_interval, end_date, job_class, enabled, auto_drop, comments FROM user_scheduler_jobs WHERE job_name like 'JOB_ROION59407_RNDB_RW01';
--job finished status
SELECT output,job_name, status, error#, actual_start_date, run_duration FROM user_scheduler_job_run_details WHERE job_name like 'JOB_ROION59407_RNDB_RW01' ORDER BY actual_start_date DESC;
