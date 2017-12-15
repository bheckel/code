
-- sqlplus sasreport/sasreport@usprd259 @do.sql 326652; vi do.out

set termout off;
spool u:/do.out
column SampName format a30;
column ResStrVal format a40;
column SpecName format a30;
set linesize 2000;
set pagesize 9999;

SELECT DISTINCT
    R.SampId        AS Samp_Id,
    R.SampName        ,
    R.ResEntUserid      ,
    R.ResEntTs        ,
    R.ResStrVal        ,
    R.ResNumVal        ,
    S.SpecName        ,
    S.DispName        AS SpecDispName,
    V.Name          AS VarName,
    V.DispName        AS VarDispName,
    PLS.ProcStatus      AS ProcStat,
    SS.EntryTs        ,
    SS.SampStatus      AS Samp_Status
FROM  ProcLoopStat      PLS,
    Result       R,
    SampleStat        SS,
     Var            V,
    Spec          S
WHERE   R.SampId IN (&1)
  AND   R.SpecRevId    = S.SpecRevId
  AND  R.SpecRevId    = V.SpecRevId
  AND  R.VarId        = V.VarId
  AND  R.SampId      = SS.SampId
  AND  R.SampId       = PLS.SampId
  AND  SS.CurrAuditFlag = 1
  AND  SS.CurrCycleFlag = 1
  AND  PLS.ProcStatus    > 3
  AND  ((V.TYPE  = 'T' AND R.ResReplicateIx <> 0)  OR
   (V.TYPE <> 'T' AND R.ResReplicateIx =  0))
  AND  R.ResSpecialResultType <> 'C'
;

spool off;
quit;
