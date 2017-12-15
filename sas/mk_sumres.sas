options fullstimer;

 /* EDIT */
%let prod=AVANDARYL;
%let prodsql='AVANDARYL%';
%let dayspast=15;

%let limsid=sasreport;
%let limspsw=sasreport;
%let limspath=Techops;
%let limsfltr = %str(AND SUBSTR(R.SampName,1,1) NOT IN ('T'));
%let datefltr = %str(AND SS.EntryTs >= (sysdate-&dayspast) );

PROC SQL;
  CONNECT TO ORACLE(USER=&limsid ORAPW=&limspsw BUFFSIZE=32700 READBUFF=32700 PATH="&limspath" dbindex=yes);
  CREATE TABLE l.sumres01a&prod AS SELECT * FROM CONNECTION TO ORACLE (
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
    WHERE   R.SampId IN 
        (SELECT DISTINCT    R.SampId
         FROM  Result      R,
          Var          V
         WHERE  R.SpecRevId = V.SpecRevId
           AND  R.VarId     = V.VarId
           AND  V.Name = 'PRODCODEDESC$'
           AND  UPPER(R.ResStrVal) like &prodsql
        )
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

/***proc freq data=L.sumres01a&prod; table specname; run;***/
