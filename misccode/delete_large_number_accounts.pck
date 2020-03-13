
CREATE OR REPLACE PACKAGE RION43311 IS
  -- ----------------------------------------------------------------------------
  -- DROP PACKAGE RION43311;
  -- whitelist this in "C:\RION\workspace\data\Source\SQL\kill_old_sessions.prc"
  -- ----------------------------------------------------------------------------
  PROCEDURE do;
END;
/
CREATE OR REPLACE PACKAGE BODY RION43311 IS

  PROCEDURE do IS
    in_out_info     VARCHAR(32767);
    account_id_cnt  NUMBER := 0;
		diffmin         NUMBER;
    sleepcnt        NUMBER := 0;

    CURSOR account_ids_c IS  
      select account_id from account_base where account_id in ( select distinct account_id from ria_AP_acct_chk_del_03052020@esp )
/* where rownum<65 */
      ;

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
          ESTARS.sleep(3 * 60 * 1000);  -- 3 min. for streams but could probably handle 1 min.
          DBMS_OUTPUT.put_line('sleeping ' || SYSTIMESTAMP);

				 SELECT r."DiffMinutes" - p."DiffMinutes" diffmin
					 INTO diffmin  -- bad when ESR > ESP
					 FROM ( select "DiffMinutes" from STR_HEARTBEAT_STATUS where database = 'ESR' ) r,
                ( select "DiffMinutes" from STR_HEARTBEAT_STATUS where database = 'ESP' ) p;
					 /* FROM ( select "DiffMinutes" from STR_HEARTBEAT_STATUS where database = 'ESTS' ) r, */
                /* ( select "DiffMinutes" from STR_HEARTBEAT_STATUS where database = 'ESPS' ) p; */
    
          IF diffmin > 2 THEN
            DBMS_OUTPUT.put_line('sleeping again ' || diffmin || ' ' || SYSTIMESTAMP);
            sleepcnt := sleepcnt + 1;
            IF sleepcnt >= 4 THEN
              e_mail_message('replies-disabled@sas.com',
                             'bob.heckel@s.com',
                             'Slept ' || sleepcnt || ' times so far',
                             '');
            END IF;
            ESTARS.sleep(3 * 60 * 1000);  -- 3 min. for streams but could probably handle 1 min.
          END IF;
          sleepcnt := 0;
        END IF;  -- group of 20

        DBMS_OUTPUT.put_line(acct.account_id || ' ' || in_out_info);  -- a null in_out_info is success
      END LOOP;

      DBMS_OUTPUT.put_line(account_id_cnt);

			MAINT.logdatachange(step => 0, status => 'RION-43311', release => 'N/A', defect => 'N/A', startTime => SYSDATE, do_commit => 1); 

		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.put_line(SQLCODE || ':' || SQLERRM || ': ' || DBMS_UTILITY.format_error_backtrace);
    END do;
END;
/
