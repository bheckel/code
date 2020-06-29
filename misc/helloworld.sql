-- From SQL> type this
VARIABLE g_message VARCHAR2(30)
BEGIN
:g_message := 'hlo wordl';
end;
/

-- Should see "PL/SQL procedure successfully completed." message.
-- From SQL> type this
PRINT g_message


-- This would also work if you use an external textfile:
-- variable g_mess varchar2(30)
-- begin :g_mess := 'helow';
-- end;
-- /
-- print g_mess
-- 
-- start /home/bheckel/helloworld.sql



-- TODO finish
-- Mnemonic "So Few Workers Go Home On Time"
-- SELECT
-- FROM
-- WHERE
-- ?
-- HAVING
-- ON
-- ?
