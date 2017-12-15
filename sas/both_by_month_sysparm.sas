
options fullstimer;

 /* c:/PROGRA~1/SASINS~1/SAS/V8/sas.exe -sysin both_by_month.sas -sysparm Feb05_01-FEB-05_28-FEB-05; vi both_by_month.log */
libname L '.';
%let q=%str(%');
%let dsnm=%scan(&SYSPARM, 1, '_');
%let d1=%scan(&SYSPARM, 2, '_');
%let d2=%scan(&SYSPARM, 3, '_');
%let limsid=sasreport;
%let limspsw=sasreport;
%let limspath=Techops;
%let prodsql=%str('ADVAIR','COMBIV','IMITRE','ONDANS','RETROV','SAL/FP','WELLBU','ZANTAC','ZIAGEN','ZOFRAN','RELENZ');
%let datefltr=%str(AND R.ResEntTs>=TO_DATE(&q.&d1 00:00:00&q.,'DD-MON-YY HH24:MI:SS') AND R.ResEntTs<=TO_DATE(&q.&d2 23:59:59&q.,'DD-MON-YY HH24:MI:SS'));
%let limsfltr=%str(AND SUBSTR(R.SampName,1,1) NOT IN ('T'));

PROC SQL;
  CONNECT TO ORACLE(USER=&limsid ORAPW=&limspsw BUFFSIZE=32700 READBUFF=32700 PATH="&limspath" dbindex=yes);
  CREATE TABLE l.lelimssumres01a&dsnm AS SELECT * FROM CONNECTION TO ORACLE (
    SELECT DISTINCT
        R.SampId        AS Samp_Id,
        R.SampName        ,
        R.ResEntUserid      ,
        R.ResEntTs        ,
        R.ResStrVal        ,
        R.ResNumVal        ,
R.ResLoopIx                             AS Res_Loop,   
R.ResRepeatIx                           AS Res_Repeat, 
R.ResReplicateIx                        AS Res_Replicat,
        SUBSTR(R.SampTag2,1,18) AS Matl_Nbr,
        S.SpecName        ,
        S.DispName        AS SpecDispName,
        V.Name            AS VarName,
        V.DispName        AS VarDispName,
        PLS.ProcStatus    AS ProcStat,
        SS.EntryTs        ,
        SS.SampStatus     AS Samp_Status
    FROM  ProcLoopStat  PLS,
        Result          R,
        SampleStat      SS,
        Var             V,
        Spec            S
    WHERE   R.SampId IN 
        (SELECT DISTINCT    R.SampId
         FROM  Result      R,
               Var         V
         WHERE  R.SpecRevId = V.SpecRevId
           AND  R.VarId     = V.VarId
           AND  V.Name = 'PRODCODEDESC$'
           AND	SUBSTR(UPPER(R.ResStrVal),1,6) IN (&prodsql)
           &datefltr
        )
      AND  R.SpecRevId    = S.SpecRevId
      AND  R.SpecRevId    = V.SpecRevId
      AND  R.VarId        = V.VarId
      AND  R.SampId       = SS.SampId
      AND  R.SampId       = PLS.SampId
      AND  SS.CurrAuditFlag = 1
      AND  SS.CurrCycleFlag = 1
      AND  SS.SampStatus   <> 20
      AND  PLS.ProcStatus    > 3
      AND  ((V.TYPE  = 'T' AND R.ResReplicateIx <> 0)  OR  (V.TYPE <> 'T' AND R.ResReplicateIx =  0))
      AND  R.ResSpecialResultType <> 'C'
      &limsfltr
  );
  %PUT &SQLXRC;
  %PUT &SQLXMSG;
  %LET HSQLXRC  = &SQLXRC;
  %LET HSQLXMSG = &SQLXMSG;
  DISCONNECT FROM ORACLE;
  QUIT;
RUN;


 /**************************************************************************************/


PROC SQL;
  CONNECT TO ORACLE(USER=&limsid ORAPW=&limspsw BUFFSIZE=25000 READBUFF=25000 PATH="&limspath" dbindex=yes);
  CREATE TABLE L.lelimsindres01a&dsnm AS SELECT * FROM CONNECTION TO ORACLE (
    SELECT DISTINCT
        R.SampId        AS Samp_Id,
        R.SampName        ,
        R.ResLoopIx        AS Res_Loop       /* Modified V2*/,
        R.ResRepeatIx      AS Res_Repeat     /* Modified V2*/,
        R.ResReplicateIx    AS Res_Replicate  /* Modified V2*/,
        R.ResId          AS Res_Id         /* Added    V2*/,
        R.ResEntUserid      ,
        R.ResEntTs        ,
        R.ResStrVal        ,
        R.ResNumVal        ,
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
           AND	SUBSTR(UPPER(R.ResStrVal),1,6) IN (&prodsql)
           &datefltr
        )
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

%put _all_;
