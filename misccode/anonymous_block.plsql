-- Modified: Thu 09 May 2019 13:29:23 (Bob Heckel)

DECLARE
  acct_ids VARCHAR2(32767) := '1234,5678';

BEGIN
 FOR c IN ( SELECT an.account_id, c.contact_id
              FROM contact c, account_name an
             WHERE an.account_name_id = c.account_name_id 
               AND an.account_id IN( SELECT to_number(COLUMN_VALUE) FROM xmltable(('"' || REPLACE(acct_ids, ',', '","') || '"')) ) ) LOOP
   dbms_output.put_line(c.account_id || ' ' || c.contact_id);
 END LOOP;
END;
