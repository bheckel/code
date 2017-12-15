
%let smp=248311,252747, 257874,260411,283271,296785,299066,300270,304262,248593,297746;
%let limsid=sasreport;
%let limspsw=sasreport;
%let limspath=usprd259;
%let limsfltr = %str(AND SUBSTR(R.SampName,1,1) NOT IN ('T'));
/***%let datefltr = %str(AND SS.EntryTs >= (sysdate-&dayspast) );***/
%let datefltr =;

PROC SQL;
  CONNECT TO ORACLE(USER=&limsid ORAPW=&limspsw BUFFSIZE=32700 READBUFF=32700 PATH="&limspath" dbindex=yes);
  CREATE TABLE tsum AS SELECT * FROM CONNECTION TO ORACLE (
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
    WHERE   R.SampId IN (&smp)
      &datefltr
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
      &limsfltr
  );
  %PUT &SQLXRC;
  %PUT &SQLXMSG;
  %LET HSQLXRC  = &SQLXRC;
  %LET HSQLXMSG = &SQLXMSG;
  DISCONNECT FROM ORACLE;
  QUIT;
RUN;

 /***************/

PROC SQL;
  CONNECT TO ORACLE(USER=&limsid ORAPW=&limspsw BUFFSIZE=25000 READBUFF=25000 PATH="&limspath" dbindex=yes);
  CREATE TABLE L.lelimsindres01aRELENZA AS SELECT * FROM CONNECTION TO ORACLE (
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
    WHERE    R.SampId IN (&smp)
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
      AND  ((V.TYPE =  'T' AND R.ResReplicateIx <> 0) OR (V.TYPE <> 'T' AND R.ResReplicateIx =  0))
      AND  R.ResSpecialResultType <> 'C'
      &limsfltr
    );
  DISCONNECT FROM ORACLE;
  QUIT;
RUN;

data l.lelimssumres01aRELENZA ;
  set tsum;
  
  if samp_id eq 248311 and specname eq 'ITEMCODE' and varname eq 'PRODCODEDESC$' then do;
    resstrval = 'Relenza Canadian';
  end;
  else if samp_id eq 260411 and specname eq 'ITEMCODE' and varname eq 'PRODCODEDESC$' then do;
    resstrval = 'Relenza Rotadisk Canadian';
  end;
  else if samp_id eq 296785 and specname eq 'ITEMCODE' and varname eq 'PRODCODEDESC$' then do;
    resstrval = 'Relenza Rotadisk Can';
  end;
  else if samp_id eq 300270 and specname eq 'ITEMCODE' and varname eq 'PRODCODEDESC$' then do;
    resstrval = '(Can) Relenza Rotadisk Can';
  end;
  else if samp_id eq 248593 and specname eq 'ITEMCODE' and varname eq 'PRODCODEDESC$' then do;
    resstrval = 'RELENZA Rotadisk (Can) 500';
  end;
run;

