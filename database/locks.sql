Select lk.SID,
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
       ob.owner,
       ob.object_type,
       ob.object_name,
       lk.Block,
       se.lockwait
  FROM v$lock lk, dba_objects ob, v$session se
 WHERE lk.SID = se.SID
   and se.SCHEMANAME like 'SE%'
   AND lk.id1 = ob.object_id(+)
and block = 1;

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
