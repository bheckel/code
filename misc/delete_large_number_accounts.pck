CREATE OR REPLACE PACKAGE RION44166 IS
  -- ----------------------------------------------------------------------------
  -- DROP PACKAGE RION44166;
  -- ----------------------------------------------------------------------------
  PROCEDURE linkage_audit;
  PROCEDURE do;
END;
/
CREATE OR REPLACE PACKAGE BODY RION44166 IS

  PROCEDURE linkage_audit IS
    in_out_info VARCHAR(32767);
    account_id_cnt NUMBER := 0;
    rc NUMBER;

    CURSOR c1 IS
      SELECT account_id, input_source
        FROM account_base 
       WHERE account_id IN ( select distinct account_id from RION_44166@esd )
/* and rownum<9 */
       ORDER BY 1;

    BEGIN
      DBMS_OUTPUT.enable(NULL);

      FOR acct IN c1 LOOP
        in_out_info := NULL;
        account_id_cnt := account_id_cnt + 1;

        rc := accounts.CHECK_ACCOUNT_CONNECTIONS(in_account_id => acct.account_id,
                                                 in_force      => 0,
                                                 in_out_info   => in_out_info);

        dbms_output.put_line(acct.input_source || chr(9) || in_out_info);

      END LOOP;

      DBMS_OUTPUT.put_line(account_id_cnt);

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line(SQLCODE || ':' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);

  END;
   /*   linkage report
    181  %s: \{2,}: :g
    182  se list
    183  %s:Failure\: Account \(\d\+\) :\1^I:g
    184  %s:Success\: Account \(\d\+\) :\1^I:g
    185  %s:<br>\s*:^I:g
    186  w! esp_2.out   
   */


  --compile kill_old_sessions with this
  --AND upper(s.Machine) != 'CARYNT\L10G279'
  PROCEDURE do IS
    in_out_info     VARCHAR(32767);
    account_id_cnt  NUMBER := 0;
		diffmin         NUMBER;
    sleepcnt        NUMBER := 0;

    CURSOR account_ids_c IS  
      SELECT account_id
        FROM account_base
       WHERE account_id in ( select distinct account_id from RION_44166@esd )
         AND account_id not in (999,888);

    BEGIN
      EXECUTE IMMEDIATE 'ALTER SESSION SET ddl_lock_timeout=90';

      FOR acct IN account_ids_c LOOP
        in_out_info := NULL;
        account_id_cnt := account_id_cnt + 1;

        accounts.EXECUTE_ACCOUNT_DELETE(in_account_id => acct.account_id,
                                        in_force      => 2,  -- (FORCED - IGNORE ALL)
                                        in_out_info   => in_out_info);

        COMMIT;

        DBMS_OUTPUT.enable(NULL);  -- accounts.pck shuts down output occasionally

        IF mod(account_id_cnt, 20) = 0 THEN  -- could probably handle 50
          ESTARS.sleep(2 * 60 * 1000);  -- 2 min. for streams but could probably handle 1 min.
          DBMS_OUTPUT.put_line('sleeping ' || SYSTIMESTAMP);

          IF (SYS_CONTEXT('USERENV', 'DB_NAME') = 'ESP') THEN
            SELECT r."DiffMinutes" - p."DiffMinutes" diffmin
              INTO diffmin  -- bad when ESR > ESP
              FROM ( select "DiffMinutes" from STR_HEARTBEAT_STATUS where database = 'ESR' ) r,
                   ( select "DiffMinutes" from STR_HEARTBEAT_STATUS where database = 'ESP' ) p;
          ELSIF (SYS_CONTEXT('USERENV', 'DB_NAME') = 'ESPS') THEN
            SELECT r."DiffMinutes" - p."DiffMinutes" diffmin
              INTO diffmin  -- bad when ESR > ESP
              FROM ( select "DiffMinutes" from STR_HEARTBEAT_STATUS where database = 'ESTS' ) r,
                   ( select "DiffMinutes" from STR_HEARTBEAT_STATUS where database = 'ESPS' ) p;
          ELSE
            diffmin := 0;
          END IF;

          DBMS_OUTPUT.put_line(' diffmin: ' || diffmin || ' sleepcnt: ' || sleepcnt);
    
          IF diffmin > 2 THEN
            DBMS_OUTPUT.put_line('sleeping again (3 min)' || diffmin || ' ' || SYSTIMESTAMP);
            sleepcnt := sleepcnt + 1;
            IF sleepcnt >= 4 THEN
              e_mail_message('replies-disabled@sas.com',
                             'bob.heckel@sas.com',
                             'Slept ' || sleepcnt || ' times so far',
                             '');
            END IF;
            ESTARS.sleep(3 * 60 * 1000);
          END IF;
          sleepcnt := 0;
        END IF;  -- group of 20

        DBMS_OUTPUT.put_line(acct.account_id || ' ' || in_out_info);  -- a null in_out_info is success
      END LOOP;

      DBMS_OUTPUT.put_line(account_id_cnt);

			MAINT.logdatachange(step => 0, status => 'RION-44166', release => 'N/A', defect => 'N/A', startTime => SYSDATE, do_commit => 1); 

		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.put_line(SQLCODE || ':' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
    END do;
END;
/

