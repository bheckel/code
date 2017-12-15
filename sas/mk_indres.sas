
 /* EDIT */
%let prod=AVANDARYL;
%let prodsql='AVANDARYL%';
%let dayspast=15;

%let limsid=sasreport;
%let limspsw=sasreport;
%let limspath=Techops;
%let limsfltr = %STR(AND SUBSTR(R.SampName,1,1) NOT IN ('T') AND VC.ColName IS NOT NULL);
%let datefltr = %STR(AND SS.EntryTs >= (sysdate-&dayspast) );

PROC SQL;
  CONNECT TO ORACLE(USER=&limsid ORAPW=&limspsw BUFFSIZE=25000 READBUFF=25000 PATH="&limspath" dbindex=yes);
  CREATE TABLE L.indres01a&prod AS SELECT * FROM CONNECTION TO ORACLE (
    SELECT DISTINCT
        R.SampId        AS Samp_Id,
        R.SampName        ,
        R.ResLoopIx        AS Res_Loop       /* Modified V2*/,
        R.ResRepeatIx      AS Res_Repeat     /* Modified V2*/,
        R.ResReplicateIx    AS Res_Replicate  /* Modified V2*/,
        R.ResId          AS Res_Id         /* Added    V2*/,
        R.ResStrVal        ,
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
        Result          R,
        ProcLoopStat      PLS,
        SampleStat        SS,
        Var            V,
        VarCol          VC,
        Spec          S
    WHERE    R.SampId IN 
        (SELECT DISTINCT    R.SampId
         FROM  Result      R,
          Var          V
         WHERE  R.SpecRevId = V.SpecRevId
           AND  R.VarId     = V.VarId
           AND  V.Name = 'PRODCODEDESC$'
           AND  UPPER(R.ResStrVal) like &prodsql
        )
      &datefltr
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
      AND  ((V.TYPE =  'T' AND R.ResReplicateIx <> 0) OR
       (V.TYPE <> 'T' AND R.ResReplicateIx =  0))
      AND  R.ResSpecialResultType <> 'C'
      &limsfltr
    );
  DISCONNECT FROM ORACLE;
  QUIT;
RUN;

endsas;
proc freq data=L.indres01a&prod; table specname; run;
