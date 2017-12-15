
%macro m(prd, matnum);
  proc sql;
    CONNECT TO ORACLE AS myoralims (USER=asreport ORAPW=asreport PATH=suprd259);

    SELECT * FROM CONNECTION TO myoralims (
      SELECT count(R.SampId) as &prd
      FROM ProcLoopStat PLS, Result R, SampleStat SS, Var V, Spec S
      WHERE R.SampId IN (SELECT R.SampId
                         FROM Result R, Var V
                         WHERE R.ResStrVal in (&matnum)
                         AND R.SpecRevId=V.SpecRevId AND R.VarId=V.VarId AND V.Name='PRODUCTCODE$')
        AND R.SampCreateTS > sysdate-1080
        AND R.SpecRevId = S.SpecRevId
        AND R.SpecRevId = V.SpecRevId
        AND R.VarId = V.VarId
        AND R.SampId = SS.SampId
        AND R.SampId = PLS.SampId
        AND R.ProcLoopId = PLS.ProcLoopId
        AND SS.CurrAuditFlag = 1
        AND SS.CurrCycleFlag = 1
        AND SS.SampStatus <> 20
        AND PLS.ProcStatus >= 16
        AND ((V.TYPE  = 'T' AND R.ResReplicateIx <> 0)  OR  (V.TYPE <> 'T' AND R.ResReplicateIx =  0))
        AND  R.ResSpecialResultType <> 'C'
    );

    DISCONNECT FROM myoralims;
  quit;
%mend;
/***%m(avandamet, %str('10000000047840'));***/
%m(vaandaryl, %str('10000000017466','10000000064097','10000000017467','10000000017468','10000000064171','10000000064098','10000000017468','10000000064099', '10000000017501','10000000024705'));
%m(yzban, %str('4146344'));

