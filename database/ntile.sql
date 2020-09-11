
-- Use 2 buckets: 1-5 and then 6-10
SELECT account_id
  FROM account_base 
 WHERE account_id IN (
                      select distinct account_id
                        from ( select account_id, ntile(10) OVER (order by account_id) grp from roion_46884@sed ) 
                       where grp in(1,2,3,4,5) )
 ORDER BY 1;

---

  PROCEDURE do(p_ntilegrp number) IS
    account_id_cnt  NUMBER := 0;
		diffmin         NUMBER := 0;
		sleepcnt        NUMBER := 0;
    cv              SYS_REFCURSOR;
    cid             NUMBER;

    -- Edit cursor predicate for any FORCEs to be skipped
    CURSOR account_ids_c(p_grp number) IS  
      /* SELECT account_id */
        /* FROM account_base */
       /* WHERE account_id in ( select distinct account_id from roion_46884@sed ) */
/* and rownum<33 */
       /* ORDER BY 1; */

/*
      SELECT account_id
        FROM account_base
       WHERE account_id in ( select distinct account_id from roion_46884@sed )
         AND account_id not in (
20187810, 20151390
         )  -- skip per audit and/or LeighAnn
       ORDER BY 1;
*/

      SELECT account_id
        FROM account_base 
       WHERE account_id IN (
                            select distinct account_id
                              from ( select account_id, ntile(10) OVER (order by account_id) grp from roion_46884@sed ) 
                             where grp in(p_grp)
                            )
         AND account_id not in (
999999
         )
       ORDER BY 1;

    BEGIN
      EXECUTE IMMEDIATE 'ALTER SESSION SET ddl_lock_timeout=90';

      FOR acct IN account_ids_c(p_ntilegrp) LOOP
        account_id_cnt := account_id_cnt + 1;

        -- Capture before they cascade delete away
        OPEN cv FOR q'[
          SELECT c.contact_id
            FROM contact_base c
           WHERE c.account_name_id IN
                 (SELECT n.account_name_id
                    FROM account_name n
                   WHERE n.account_id = :1) ]'
           USING acct.account_id;

        LOOP FETCH cv INTO cid;
          EXIT WHEN cv%notfound;
          cdhub_rest.contact_drop_xrefs_rest(p_contactid => cid, p_remote_user => 'carynt\sesppt', p_send_err_email => 0, p_suppress_output => 1);
          ESTARS.sleep(2 * 1000); -- 2 second pause
        END LOOP;  -- contact_id
        CLOSE cv;

        DELETE FROM account_base ab WHERE ab.account_id = acct.account_id;
        DELETE FROM account_search a WHERE a.account_id = acct.account_id;
        COMMIT;

        -- Must come after account delete.  Wait to do this in 3 minutes in case CDHub get backed up
        send_cdhub_job_message('CDHUB_REST.account_delete_rest(' || acct.account_id || ', ''carynt\sesppt'', 0, 1)', 'DELETE_ACCOUNT_');

        IF mod(account_id_cnt, 30) = 0 THEN
          ESTARS.sleep(1 * 60 * 1000);  -- 1 min. for streams & cdhub to catch up

          IF (SYS_CONTEXT('USERENV', 'DB_NAME') = 'SEP') THEN
            SELECT r."DiffMinutes" - p."DiffMinutes" diffmin
              INTO diffmin  -- bad when SETS > SEPS
              FROM ( select "DiffMinutes" from STR_HEARTBEAT_STATUS where database = 'SER' ) r,
                   ( select "DiffMinutes" from STR_HEARTBEAT_STATUS where database = 'SEP' ) p;
          ELSIF (SYS_CONTEXT('USERENV', 'DB_NAME') = 'SEPS') THEN
            SELECT r."DiffMinutes" - p."DiffMinutes" diffmin
              INTO diffmin  -- bad when SER > SEP
              FROM ( select "DiffMinutes" from STR_HEARTBEAT_STATUS where database = 'SETS' ) r,
                   ( select "DiffMinutes" from STR_HEARTBEAT_STATUS where database = 'SEPS' ) p;
          ELSE
            diffmin := 0;
          END IF;

          IF diffmin > 4 THEN
            sleepcnt := sleepcnt + 1;
            DBMS_OUTPUT.put_line('sleeping again because diffmin: ' || diffmin || ' at ' || SYSTIMESTAMP);
            e_mail_message('replies-disabled@s.com',
                           'bob@s.com',
                           'Streams are backed up diffmin: ' || diffmin || ' total sleepcnt: ' || sleepcnt,
                           '');
            ESTARS.sleep(7 * 60 * 1000);
            diffmin := 0;
          END IF;
        END IF;  -- pause and check streams health in groups of N accounts
      end loop;  -- an account and its contacts processed

      DBMS_OUTPUT.put_line('deleted: ' || account_id_cnt);

			MAINT.logdatachange(step => 0, status => 'Deletions successful', release => 'N/A', defect => 'ROION-46884', startTime => SYSDATE, do_commit => 1); 

      e_mail_message('replies-disabled@s.com',
                     'bob@s.com',
                     'Done - accounts deleted: ' || account_id_cnt,
                     '');
		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.put_line(SQLCODE || ':' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
        e_mail_message('replies-disabled@s.com',
                       'bob@s.com',
                       'There was a problem deleting',
                       'Unexpected error while running ' || SQLCODE || ':' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
    END do;
