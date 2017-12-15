
-- cd $u; sqlplus sasreport/sasreport@usprd259 @do.sql 326652; vi do.csv

spool u:/do.csv
column SampName format a30;
column ResStrVal format a40;
column SpecName format a30;

set term off;
set trimspool on;
set verify off;
set linesize 350;
set pagesize 9999;
set wrap off;
set feedback off;
set colsep ',';


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
