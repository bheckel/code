
%global BCH SQ;
%let BCH=9ZM7174;
%let SQ=%str(%');

/****************/

proc sql;
  CONNECT TO ORACLE(USER=pmx ORAPW=pmx BUFFSIZE=25000 READBUFF=25000 PATH=pmxzebd2 DBINDEX=yes);
  CREATE TABLE pullDISY AS SELECT * FROM CONNECTION TO ORACLE (

    select distinct identifier, teilestamm_nummer, log_aend_zeit
    from pmx_super.batch
    where identifier = &SQ.&BCH&SQ.

  );
  DISCONNECT FROM ORACLE;
quit;

proc format;
  picture oradtt other='%0d-%b-%0y %0H:%0M:%0S' (datatype=datetime);
run;

data _null_;
  set pullDISY;

  call symput('DISYTS', log_aend_zeit);

  s = log_aend_zeit+(4*60*60);
  call symput('IP21START', "'"||trim(left(put(s, oradtt.)))||"'");

  e = log_aend_zeit+(13*60*60);
  call symput('IP21END', "'"||trim(left(put(e, oradtt.)))||"'");
run;
%put _all_;

/***data; x= put(&IP21END,DATETIME.); put x=; run;***/

proc export data=pullDISY OUTFILE= "disy.csv" DBMS=CSV replace; run;


/****************/


filename X21 'C:\cygwin\home\bheckel\tmp\26Apr10_1272301893\WSIP21.qry';

data _null_;
  file X21;
  put 'SELECT NAME, IP_TREND_TIME, IP_TREND_VALUE FROM "23034794.Vessel.Pres.PV" WHERE IP_TREND_TIME BETWEEN ' @; *** '02-APR-10 00:00:00' AND '21-APR-10 15:00:00';
  put "&IP21START and &IP21END";
run;


/****************/

libname myscl 'C:\cygwin\home\bheckel\tmp\26Apr10_1272301893';
%let DLIPATH=C:\cygwin\home\bheckel\tmp\26Apr10_1272301893\;
proc display c=myscl.catalog.ip21.scl;run;

libname myxml XML 'WSIP21.xml' /*xmlmap=t4.map*/ access=READONLY;
/***proc contents data=myxml._ALL_; run;***/
/***proc print data=myxml.table(obs=10) width=minimum; run;***/
/***data t; set myxml.table(where=(name='23034794.VESSEL.PRES.PV'));run;***/
proc export data=myxml.table OUTFILE= "dlip21.csv" DBMS=CSV replace; run;

/****************/


/****************/
proc sql feedback;
  CONNECT TO ORACLE(USER=sasreport ORAPW=sasreport BUFFSIZE=25000 READBUFF=25000 PATH=usprd259 DBINDEX=yes);
  CREATE TABLE pullLIMS AS SELECT * FROM CONNECTION TO ORACLE (

/***
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
    WHERE   R.SampName LIKE '9ZM7174%'
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
***/

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
          SS.SampStatus,
          PLS.ProcStatus
    FROM  Element E,
          Result R,
          ProcLoopStat PLS,
          SampleStat SS,
          Var V,
          VarCol VC,
          Spec S
    WHERE R.SampName LIKE &SQ.&BCH.%&SQ
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
/***      AND SS.SampStatus <> 20***/
      AND PLS.ProcStatus >= 16
      AND ((V.TYPE =  'T' AND R.ResReplicateIx <> 0) OR (V.TYPE <> 'T' AND R.ResReplicateIx =  0))
      AND R.ResSpecialResultType <> 'C'
      and name = 'PEAKINFO' and colname in ('NAME$','AMOUNT$','PEAKNAME$','ACQDATETIME$')

  );
  DISCONNECT FROM ORACLE;
  quit;

proc export data=pullLIMS OUTFILE= "lims.csv" DBMS=CSV replace; run;

/****************/




endsas;

filename GOUT './junk.gif';
goptions reset=all ftext='Andale Mono' htext=3 gunit=pct ctext=green gsfname=GOUT;
symbol value=dot /*interpol=join color=cyan height=3*/;
 /* Y axis.  proc must be told to use this statement */
***axis1 label=(angle=90 'Amt (in billions)') minor=(n=2);
 /* X axis */
 /*                        tick marks between majors    */
 /*                             ___________             */
***axis2 order=(1960 to 2010 by 5) minor=(n=4);
title j=left height=4 'title SAS/GRAPH';
proc gplot data=t;
  /*    Y by X */
  plot value*ts / /*vaxis=axis1 haxis=axis2*/ caxis=purple;
  ***format sales COMMA.;
run;
