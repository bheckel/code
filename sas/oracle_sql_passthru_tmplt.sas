
 /* CONNECT indicates pass-through */

proc sql NOprint;
  /* sqlplus pks/dev123dba@sutst581  select count(*) from pks.samp; */
  CONNECT TO ORACLE(USER=pks ORAPW=dev123dba BUFFSIZE=25000 READBUFF=25000 PATH=sutst581 DBINDEX=yes);
  CREATE TABLE pullLIMS AS SELECT * FROM CONNECTION TO ORACLE (

    SELECT *
    FROM  pks.sam

  );
  %let _SQLXRC=&SQLXRC;
  %let _SQLXMSG=%superq(SQLXMSG);
  DISCONNECT FROM ORACLE;
quit;

 /* Database-specific.  Only available in passthru (&SQLOBS is always 0 in passthru). */
%put !!! &_SQLXRC &_SQLXMSG;

proc print data=sashelp.vmacro(obs=max) width=minimum; run;



endsas;

proc sql;
  CONNECT TO ORACLE(USER=sasreport ORAPW=sasreport BUFFSIZE=25000 READBUFF=25000 PATH=usprd259 DBINDEX=yes);
  CREATE TABLE pullLIMS AS SELECT * FROM CONNECTION TO ORACLE (

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
    WHERE   R.SampId IN (326652)
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

    );
    DISCONNECT FROM ORACLE;
  quit;

proc export data=pullLIMS OUTFILE= "lims.csv" DBMS=CSV replace; run;
