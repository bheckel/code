PROCEDURE FLEXFIELD_DUPS_REMOVE IS
  send_email BOOLEAN := FALSE;
  header     VARCHAR2(275) := '<?xml version="1.0" encoding="UTF-8"?><html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>' ||
                              '</head><body><h3>Flexfield duplicates were removed by Daily_data_maintenance.FLEXFIELD_DUPS_CHECK, here are the first 100 for each table type:</h3>';
  msgbody    VARCHAR2(32767) := '<table border=1 cellspacing=0 cellpadding=2 width="95%"<tr><td>Count<td>Table<td>account_id<td>account_flex_field_id<td>updated</tr><br>';
  dupcnt     NUMBER := 0;
  duptbl     VARCHAR2(30);
  
  CURSOR account_c IS
    WITH v AS (
      SELECT aff.account_flex_field_id, aff.updated, aff.actual_updated, aff.account_id
        FROM account_flex_field aff
       WHERE aff.account_id IN (
              select ff.account_id
                from account_flex f, account_flex_field ff
              where f.account_flex_field_id = ff.account_flex_field_id
                 and (ff.account_id, ff.custom_area_property_id) in
                     (select ffl.account_id, ffl.custom_area_property_id
                        from account_flex fl, account_flex_field ffl
                       where fl.account_flex_field_id = ffl.account_flex_field_id
                       group by ffl.account_id, ffl.custom_area_property_id
                      having count(*) > 1)
              )
      )
    SELECT *
      FROM ( SELECT updated, account_id, account_flex_field_id, row_number() OVER (PARTITION BY account_id ORDER BY UPDATED DESC) rownumber FROM v)
      -- These accounts have multiple dups to delete...
     WHERE rownumber <> 1  -- ...but delete only the older duplicates
    ;
    
  TYPE account_t IS TABLE OF account_c%ROWTYPE;
  account account_t;

BEGIN
    IF SYS_CONTEXT('USERENV', 'DB_NAME') NOT IN ('EST','ESP') THEN
    RETURN;
  END IF;
  
  duptbl := 'ACCOUNT_FLEX_FIELD';

  OPEN account_c;
  LOOP
    FETCH account_c BULK COLLECT INTO account LIMIT 100;
    EXIT WHEN account.count = 0;
    FOR i IN 1..account.count LOOP
dbms_output.put_line(i || ': ' || account(i).account_id || ' ' || account(i).account_flex_field_id || ' ' || account(i).updated);
      DELETE FROM account_flex_field a
            WHERE a.account_id = account(i).account_id
              AND a.account_flex_field_id = account(i).account_flex_field_id
            ;
      dupcnt := dupcnt + 1;
      IF dupcnt <= 100 THEN
        msgbody := msgbody || '<tr><td>' || dupcnt || '<td>' || duptbl || '<td>' || account(i).account_id || '<td>' || account(i).account_flex_field_id || '<td>' || account(i).updated || '</tr>';
      END IF;
    END LOOP;
dbms_output.put_line(dupcnt);
--    COMMIT;
ROLLBACK;
  END LOOP;
  CLOSE account_c;

  IF dupcnt > 0 THEN                 
    send_email := TRUE;
  END IF;
  
  dupcnt := 0;

  IF send_email THEN
    e_mail_message('replies-disabled@foo.com',
                   'bob.heckel@foo.com',
                   'Duplicate flexfield records were found on ' || SYS_CONTEXT('USERENV', 'DB_NAME'),
                   header || '<br>' || msgbody);
  END IF;
END FLEXFIELD_DUPS_REMOVE;
