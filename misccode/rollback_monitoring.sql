
-- Adapted: 28-May-2020 (Bob Heckel -- https://oracle-base.com/articles/misc/killing-oracle-sessions)

-- SQL> ALTER SYSTEM KILL SESSION 'sid,serial#' IMMEDIATE;
-- This does not affect the work performed by the command, but it returns control back to the current session immediately, rather 
-- than waiting for confirmation of the kill.

-- If the marked session persists for some time you may consider killing the process at the operating system level. Before doing
-- this it's worth checking to see if it is performing a rollback. You can do this by running this query. If the USED_UREC value
-- is decreasing for the session in question you should leave it to complete the rollback rather than killing the session at the
-- operating system level.
SELECT s.username,
       s.sid,
       s.serial#,
       t.used_ublk,
       t.USED_UREC,
       rs.segment_name,
       r.rssize,
       r.status
FROM   v$transaction t,
       v$session s,
       v$rollstat r,
       dba_rollback_segs rs
WHERE  s.saddr = t.ses_addr
AND    t.xidusn = r.usn
AND    rs.segment_id = t.xidusn
ORDER BY t.used_ublk DESC;

