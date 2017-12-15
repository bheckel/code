SELECT DISTINCT
    R.SampId        AS Samp_Id,
    R.SampName        ,
    R.ResLoopIx        AS Res_Loop       /* Modified V2*/,
    R.ResRepeatIx      AS Res_Repeat     /* Modified V2*/,
    R.ResReplicateIx    AS Res_Replicate  /* Modified V2*/,
    R.ResId          AS Res_Id         /* Added    V2*/,
    SUBSTR(R.SampTag2,1,18) AS Matl_Nbr,
    S.SpecName        ,
    V.Name          AS VarName,
    V.DispName        AS VarDispName,
    E.RowIx          ,
    E.ColumnIx        ,
    E.ElemStrVal      ,    
    E.ElemNumVal      ,
    SS.EntryTs        ,
    VC.ColName        ,
    PLS.ProcStatus      AS ProcStat,
    SS.SampStatus      AS Samp_Status
FROM  Element          E,
    Result       R,
    ProcLoopStat      PLS,
    SampleStat        SS,
    Var            V,
    VarCol          VC,
    Spec          S
WHERE   R.SampId IN (248311,252747, 257874,260411,283271,296785,299066,300270,304262,248593,297746)
  AND  R.SpecRevId    = V.SpecRevId
  AND  R.VarId      = V.VarId
  AND  R.ResId      = E.ResId
  AND  VC.ColNum      = E.ColumnIx
  AND  R.SpecRevId    = VC.SpecRevId
  AND  R.VarId      = VC.TableVarId
  AND  R.SampId    = PLS.SampId
  AND  R.ProcLoopId  = PLS.ProcLoopId
  AND  R.SampId    = SS.SampId
  AND  R.SpecRevId    = S.SpecRevId
  AND  SS.CurrAuditFlag = 1
  AND  SS.CurrCycleFlag = 1
  AND   SS.SampStatus   <> 20
  AND  PLS.ProcStatus  > 3
  AND  ((V.TYPE =  'T' AND R.ResReplicateIx <> 0) OR (V.TYPE <> 'T' AND R.ResReplicateIx =  0))
  AND  R.ResSpecialResultType <> 'C'
  AND SUBSTR(R.SampName,1,1) NOT IN ('T')

