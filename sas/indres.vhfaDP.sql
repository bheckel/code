SELECT DISTINCT
  R.SampId,
  R.SampName,
  R.SampCreateTS,
  S.SpecName,
  S.DispName,
  V.Name,
  E.RowIx,
  E.ColumnIx,
  E.ElemStrVal,    
  VC.ColName,
  SS.SampStatus
FROM  Element E,
      Result R,
      ProcLoopStat PLS,
      SampleStat SS,
      Var V,
      VarCol VC,
      Spec S
WHERE R.SampId IN (SELECT DISTINCT R.SampId
                   FROM Result R, Var V 
                   WHERE ( UPPER(R.ResStrVal)='VENTOLIN HFA (ALBUTEROL 134A) INHALERS, 200 ACT' 
                        OR UPPER(R.ResStrVal)='VENTOLIN HFA INHALERS, 200 ACT' 
                        OR UPPER(R.ResStrVal)='ALBUTEROL 134A INHALERS 200 ACT' 
                        OR UPPER(R.ResStrVal)='ALBUTEROL 134A INHALERS 200 ACTN' )
                        AND R.SpecRevId=V.SpecRevId AND R.VarId=V.VarId AND V.Name='PRODCODEDESC$'
                  )
  AND R.SampCreateTS >= TO_DATE('01-JAN-06','DD-MON-YY')
  AND R.SpecRevId = V.SpecRevId
  AND R.VarId = V.VarId
  AND R.ResId = E.ResId
  AND VC.ColNum = E.ColumnIx
  AND R.SpecRevId = VC.SpecRevId
  AND R.VarId = VC.TableVarId
  AND R.SampId = PLS.SampId
  AND R.ProcLoopId = PLS.ProcLoopId
  AND R.SampId = SS.SampId
  AND R.SpecRevId = S.SpecRevId
  AND SS.CurrAuditFlag = 1
  AND SS.CurrCycleFlag = 1
  AND SS.SampStatus <> 20
  AND PLS.ProcStatus = 16
  AND ((V.TYPE =  'T' AND R.ResReplicateIx <> 0) OR (V.TYPE <> 'T' AND R.ResReplicateIx =  0))
  AND R.ResSpecialResultType <> 'C'
