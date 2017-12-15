-- sumres
SELECT DISTINCT
    R.SampId        AS Samp_Id,
    R.SampName        ,
    R.ResEntUserid      ,
    R.ResEntTs        ,
    R.ResStrVal        ,
    R.ResNumVal        ,
    SUBSTR(R.SampTag2,1,18) AS Matl_Nbr,
    S.SpecName        ,
    S.DispName        AS SpecDispName,
    V.Name          AS VarName,
    V.DispName        AS VarDispName,
    PLS.ProcStatus      AS ProcStat,
    SS.EntryTs        ,
    SS.SampStatus      AS Samp_Status
FROM  ProcLoopStat      PLS,
    ResultALL       R,
    SampleStat        SS,
     Var            V,
    Spec          S
WHERE   R.SampId IN (248311,252747, 257874,260411,283271,296785,299066,300270,304262,248593,297746)
  AND   R.SpecRevId    = S.SpecRevId
  AND  R.SpecRevId    = V.SpecRevId
  AND  R.VarId        = V.VarId
  AND  R.SampId      = SS.SampId
  AND  R.SampId       = PLS.SampId
  AND  SS.CurrAuditFlag = 1
  AND  SS.CurrCycleFlag = 1
  AND   SS.SampStatus   <> 20
  AND  PLS.ProcStatus    > 3
  AND  ((V.TYPE  = 'T' AND R.ResReplicateIx <> 0)  OR  (V.TYPE <> 'T' AND R.ResReplicateIx =  0))
  AND  R.ResSpecialResultType <> 'C'
  AND SUBSTR(R.SampName,1,1) NOT IN ('T')
