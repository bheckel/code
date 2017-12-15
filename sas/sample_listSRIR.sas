
options fullstimer noxwait;

***%let smp=208430,210633,210641,210646,210652,211261,213033,213035,213036,213037,216589,216592,216596,216598,219228;
***%let smp=165852,167396,169231,169254,172682,173611,175778,175792,181862,181867,189758,206966,224769;
***%let smp=188400,189367,189762,190299,191968,192004,202182,204455,208279,208430,216442,224995,225318,234725,244243,198164,199580,208358,210255,210257;
***%let smp=230294,236205,248622,235178,223277;
%let smp=230294,236205,235178,223277;  /* relenza studies */
%let nm=MULTrel;
%let limsid=sasreport;
%let limspsw=sasreport;
%let limspath=usprd259;
%let limsfltr = %str(AND SUBSTR(R.SampName,1,1) NOT IN ('T'));
/***%let datefltr = %str(AND SS.EntryTs >= (sysdate-&dayspast) );***/
%let datefltr =;

PROC SQL;
  CONNECT TO ORACLE(USER=&limsid ORAPW=&limspsw BUFFSIZE=32700 READBUFF=32700 PATH="&limspath" dbindex=yes);
  CREATE TABLE l.lelimssumres01a&nm AS SELECT * FROM CONNECTION TO ORACLE (
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
        Result          R,
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
/***      AND   SS.SampStatus   <> 20***/
      AND  PLS.ProcStatus    > 3
      AND  ((V.TYPE  = 'T' AND R.ResReplicateIx <> 0)  OR  
       (V.TYPE <> 'T' AND R.ResReplicateIx =  0))
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
  CREATE TABLE L.lelimsindres01a&nm AS SELECT * FROM CONNECTION TO ORACLE (
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
/***      AND   SS.SampStatus   <> 20***/
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
x "start lelimssumres01a&nm..sas7bdat";
x "start lelimsindres01a&nm..sas7bdat";
