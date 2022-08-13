--Modified: 11-Aug-2022 (Bob Heckel)

select v.*
  from (Select lk.SID,
               se.CLIENT_IDENTIFIER,
               se.username,
               se.OSUser,
               se.Machine,
               DECODE(lk.TYPE,
                      'TX',
                      'Transaction',
                      'TM',
                      'DML',
                      'UL',
                      'PL/SQL User Lock',
                      lk.TYPE) lock_type,
               DECODE(lk.lmode,
                      0,
                      'None',
                      1,
                      'Null',
                      2,
                      'Row-S (SS)',
                      3,
                      'Row-X (SX)',
                      4,
                      'Share',
                      5,
                      'S/Row-X (SSX)',
                      6,
                      'Exclusive',
                      TO_CHAR(lk.lmode)) mode_held,
               DECODE(lk.request,
                      0,
                      'None',
                      1,
                      'Null',
                      2,
                      'Row-S (SS)',
                      3,
                      'Row-X (SX)',
                      4,
                      'Share',
                      5,
                      'S/Row-X (SSX)',
                      6,
                      'Exclusive',
                      TO_CHAR(lk.request)) mode_requested,
               TO_CHAR(lk.id1) lock_id1,
               TO_CHAR(lk.id2) lock_id2,
               CAST((select ob.OBJECT_NAME || '(' || ob.OBJECT_TYPE || ')'
                       from user_objects ob
                      where ob.object_id = lk.id1) as VARCHAR2(500)) object_name,
               lk.Block,
               se.lockwait,
               se.SERIAL#,
               se.STATUS,
               se.TERMINAL,
               se.PROGRAM,
               se.ACTION,
               se."SQL_EXEC_START",
               lk."CTIME",
               se."SQL_ID",
               l.SQL_TEXT
          FROM v$lock lk, v$session se, v$sql l
         WHERE lk.SID = se.SID
         and se.SQL_ID = l.SQL_ID(+)
           --and upper(se.Machine) != 'CARYNT\L10H540'
           --and osuser !=  'cancss'
           and se.SCHEMANAME like 'ES%'
           AND lk.ctime > 30
           and se."USERNAME" = 'SETARS') v
 where v.object_name is not null
       and v.object_name not like 'DR$%';

---

 select to_char(SESSION_ID,'99999') sid ,     
   substr(LOCK_TYPE,1,30) Type,     
   substr(lock_id1,1,20) Object_Name,     
   substr(mode_held,1,4) HELD,     
   substr(mode_requested,1,4) REQ,     
   lock_id2 lock_addr     
FROM dba_lock_internal     
WHERE    
   mode_requested <> 'None'    
   and mode_requested <> mode_held
