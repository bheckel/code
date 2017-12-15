options ls=180;
libname OUTDIR '.';

%global LIMSDBNAME LIMSDBUSER LIMSDBPW ODSDBNAME ODSDBUSER ODSDBPW;
%let LIMSDBNAME=usprd259;
%let LIMSDBUSER=sasreport;
%let LIMSDBPW=sasreport;
%let ODSDBNAME=ukprd613;
%let ODSDBUSER=ods_zeb;
%let ODSDBPW=ZEBODS_ZB842;

%macro bobh1008111249; /* {{{ */
%macro pullMERPS;
  proc sql;
    CONNECT TO ORACLE(USER=&ODSDBUSER ORAPW=&ODSDBPW BUFFSIZE=25000 READBUFF=25000 PATH="&ODSDBNAME" DBINDEX=yes);
      CREATE TABLE OUTDIR.pullMERPS AS SELECT * FROM CONNECTION TO ORACLE (
        SELECT DISTINCT plant_cod, prcs_ord_num, actual_finish_dt, mat_cod, bat_num
        FROM ods_dist.vw_zeb_merps_prcs_ord_header
        WHERE plant_cod='US01' and actual_finish_dt between TO_DATE('01JAN10','DDMONYY') and TO_DATE('31DEC11','DDMONYY')
        ORDER BY bat_num
      );
    DISCONNECT FROM ORACLE;
  quit;
  %put NOTE: merps SQLXRC: &SQLXRC  SQLXMSG: &SQLXMSG;
%mend;
%pullMERPS;
%mend bobh1008111249; /* }}} */


%macro bobh1108110150; /* {{{ */
%macro pullLIMSsumm;
  proc sql;
    CONNECT TO ORACLE(USER=&LIMSDBUSER ORAPW=&LIMSDBPW BUFFSIZE=25000 READBUFF=25000 PATH="&LIMSDBNAME" DBINDEX=yes);
    CREATE TABLE OUTDIR.pullLIMS_summ AS SELECT * FROM CONNECTION TO ORACLE (
      SELECT DISTINCT
        R.SampId,
        R.SampName,
        R.ResStrVal,
        R.SampCreateTS,
        S.SpecName,
        S.DispName,
        V.Name,
        V.DispName as DispName2,
        SS.SampStatus,
        PLS.ProcStatus
      FROM
        ProcLoopStat PLS,
        Result R,
        SampleStat SS,
        Var V,
        Spec S
      WHERE R.SampId IN (SELECT DISTINCT R.SampId
                         FROM Result R, Var V 
                         WHERE (UPPER(R.ResStrVal) in('0316761','10000000007397','10000000010844','10000000010846','10000000010847','10000000010848','10000000010849',
                                                      '10000000010850','10000000010851','10000000010852','10000000011446','10000000011447','10000000011448','10000000011449',
                                                      '10000000011500','10000000012062','10000000012063','10000000012064','10000000012065','10000000012066','10000000012067',
                                                      '10000000012068','10000000012069','10000000012080','10000000012081','10000000012595','10000000021035','10000000021036',
                                                      '10000000021037','10000000021039','10000000021110','10000000021111','10000000021112','10000000021113','10000000021114',
                                                      '10000000021115','10000000021116','10000000021117','10000000021118','10000000021119','10000000021140','10000000021141',
                                                      '10000000021142','10000000021143','10000000021144','10000000021624','10000000021625','10000000021626','10000000021627',
                                                      '10000000021628','10000000024350','10000000024351','10000000024352','10000000024353','10000000024354','10000000024355',
                                                      '10000000024619','10000000024670','10000000024671','10000000024672','10000000024673','10000000024674','10000000024675',
                                                      '10000000024676','10000000024677','10000000024678','10000000024680','10000000024681','10000000024682','10000000024683',
                                                      '10000000024684','10000000026175','10000000026176','10000000026177','10000000026178','10000000026179','10000000026290',
                                                      '10000000026955','10000000027160','10000000027161','10000000027162','10000000027163','10000000028820','10000000030131',
                                                      '10000000032235','10000000040951','10000000047840','10000000047841','10000000047964','10000000054930','10000000068620',
                                                      '10000000068621','10000000068623','10000000068804','10000000068805','10000000068806','10000000068807','10000000068808',
                                                      '10000000068809','10000000068820','10000000068821','10000000068822','10000000074690','10000000074691','10000000074692',
                                                      '10000000074693','10000000074694','10000000096227','10000000096228','10000000096229','10000000096230','4159608',
                                                      '640028','640029')
                               )
                              AND R.SpecRevId=V.SpecRevId AND R.VarId=V.VarId AND V.Name='PRODUCTCODE$'
                        )
        AND R.SampCreateTS >= TO_DATE('01-JAN-11','DD-MON-YY')
        AND R.SpecRevId = S.SpecRevId
        AND R.SpecRevId = V.SpecRevId
        AND R.VarId = V.VarId
        AND R.SampId = SS.SampId
        AND R.SampId = PLS.SampId
        AND SS.CurrAuditFlag = 1
        AND SS.CurrCycleFlag = 1
        AND SS.SampStatus <> 20
        AND PLS.ProcStatus >= 16
        AND ((V.TYPE  = 'T' AND R.ResReplicateIx <> 0)  OR  (V.TYPE <> 'T' AND R.ResReplicateIx =  0)) AND  R.ResSpecialResultType <> 'C'
      );
    DISCONNECT FROM ORACLE;
  quit;
  %put NOTE: summ SQLXRC: &SQLXRC  SQLXMSG: &SQLXMSG;
%mend pullsumm;
%pullLIMSsumm;
%mend bobh1108110150; /* }}} */

%macro bobh1108115746; /* {{{ */
%macro pullLIMSind;
  proc sql;
    CONNECT TO ORACLE(USER=&LIMSDBUSER ORAPW=&LIMSDBPW BUFFSIZE=25000 READBUFF=25000 PATH="&LIMSDBNAME" DBINDEX=yes);
    CREATE TABLE OUTDIR.pullLIMS_ind&dose AS SELECT * FROM CONNECTION TO ORACLE (
      SELECT DISTINCT
        R.SampId,
        R.SampName,
        R.SampCreateTS,
        R.ResLoopIx,
        R.ResRepeatIx,
        R.ResReplicateIx,
        S.SpecName,
        S.DispName,
        V.Name,
        E.RowIx,
        E.ColumnIx,
        E.ElemStrVal,
        VC.ColName,
        SS.SampStatus,
        PLS.ProcStatus
      FROM
        Element E,
        Result R,
        ProcLoopStat PLS,
        SampleStat SS,
        Var V,
        VarCol VC,
        Spec S
      WHERE R.SampId IN (SELECT DISTINCT R.SampId
                         FROM Result R, Var V 
                         WHERE (UPPER(R.ResStrVal) in('0316761','10000000007397','10000000010844','10000000010846','10000000010847','10000000010848','10000000010849',
                                                      '10000000010850','10000000010851','10000000010852','10000000011446','10000000011447','10000000011448','10000000011449',
                                                      '10000000011500','10000000012062','10000000012063','10000000012064','10000000012065','10000000012066','10000000012067',
                                                      '10000000012068','10000000012069','10000000012080','10000000012081','10000000012595','10000000021035','10000000021036',
                                                      '10000000021037','10000000021039','10000000021110','10000000021111','10000000021112','10000000021113','10000000021114',
                                                      '10000000021115','10000000021116','10000000021117','10000000021118','10000000021119','10000000021140','10000000021141',
                                                      '10000000021142','10000000021143','10000000021144','10000000021624','10000000021625','10000000021626','10000000021627',
                                                      '10000000021628','10000000024350','10000000024351','10000000024352','10000000024353','10000000024354','10000000024355',
                                                      '10000000024619','10000000024670','10000000024671','10000000024672','10000000024673','10000000024674','10000000024675',
                                                      '10000000024676','10000000024677','10000000024678','10000000024680','10000000024681','10000000024682','10000000024683',
                                                      '10000000024684','10000000026175','10000000026176','10000000026177','10000000026178','10000000026179','10000000026290',
                                                      '10000000026955','10000000027160','10000000027161','10000000027162','10000000027163','10000000028820','10000000030131',
                                                      '10000000032235','10000000040951','10000000047840','10000000047841','10000000047964','10000000054930','10000000068620',
                                                      '10000000068621','10000000068623','10000000068804','10000000068805','10000000068806','10000000068807','10000000068808',
                                                      '10000000068809','10000000068820','10000000068821','10000000068822','10000000074690','10000000074691','10000000074692',
                                                      '10000000074693','10000000074694','10000000096227','10000000096228','10000000096229','10000000096230','4159608',
                                                      '640028','640029')
                               )
                               AND R.SpecRevId=V.SpecRevId AND R.VarId=V.VarId AND V.Name='PRODUCTCODE$'
                        )
        AND R.SampCreateTS >= TO_DATE('01-JAN-11','DD-MON-YY')
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
        AND PLS.ProcStatus >= 16
        AND ((V.TYPE =  'T' AND R.ResReplicateIx <> 0) OR (V.TYPE <> 'T' AND R.ResReplicateIx = 0))
        AND R.ResSpecialResultType <> 'C'
      );
    DISCONNECT FROM ORACLE;
  quit;
  %put NOTE: ind SQLXRC: &SQLXRC  SQLXMSG: &SQLXMSG;
%mend pullind;
%pullLIMSind;
%mend bobh1108115746; /* }}} */

/* Pull summary/header, method-independent data */
%macro summ(meth, name);
  data pullLIMS_summ; set OUTDIR.pullLIMS_summ; run;

  /***********************************************************/
  data prodcodedesc;
    set pullLIMS_summ;
    if SpecName eq 'ITEMCODE' and Name in ('PRODCODEDESC$');
  run;
  proc sort data=prodcodedesc;
    by SampId SampName SpecName Name;
  run;
  proc transpose data=prodcodedesc out=tmp_desc;
    by SampId SampName SpecName;
    id Name;
    var ResStrVal;
    copy SampStatus DispName2;
  run;
  data prodcodedesc(rename=(PRODCODEDESC_=product));
    set tmp_desc(keep=SampId SampName PRODCODEDESC_);
  run;
/***  title 'wtf';proc print data=_LAST_(obs=max) width=minimum; run; title;***/
  /***********************************************************/

  /***********************************************************/
  data summ;
    set pullLIMS_summ;
    if SpecName eq "&meth" and Name in (&name);
  run;
  proc sort data=summ;
    by SampId SampName SpecName Name;
  run;
  proc transpose data=summ out=tmp_summ;
    by SampId SampName SpecName;
    id Name;
    var ResStrVal;
    copy SampStatus DispName2;
  run;
  data summ(rename=(ANALYST_=analyst) drop=_: DISPNAME2);
    set tmp_summ;

    /* There are multiple entries in LIMS, this takes out the unwanted ones */
    if _NAME_ ne '';

    length mfg_batch $40;

    /* 6ZM3225-040000254751-01 */
    if NOT verify(substr(SampName,1, 1), '0123456789X') then do;
      mfg_batch = scan(SampName, 1, '-');
    end;
    else do;
      delete;  /* stability study */
    end;
  run;
  /***********************************************************/

  data summ;
    merge summ(in=ina) prodcodedesc(in=inb);
    by SampId SampName;
    if ina;
  run;
%mend;


/* Pull method-specific data */
%macro ind(meth, name, colname, component);
/***  data pullLIMS_ind; set OUTDIR.pullLIMS_ind; run;***/
  data ind;
    set OUTDIR.pullLIMS_ind;

    if SpecName eq "&meth" 
       and Name eq "&name"
       and ColName in (&colname)
       ;
  run;

  proc sort data=ind;
    by SampId SampName SpecName Name RowIx ResLoopIx ResReplicateIx;
  run;

  proc transpose data=ind out=tmp_ind;
    by SampId SampName SpecName Name RowIx ResLoopIx ResReplicateIx;
    id ColName;
    var ElemStrVal;
    copy SampStatus DispName;
  run;

  data ind(rename=(AMOUNT_=result &component=component) drop= NAME_ _:);
    set tmp_ind;

    /* There are multiple entries in LIMS, this takes out the unwanted ones */
    if _NAME_ eq 'ELEMSTRVAL';

    /* 6ZM3225-040000254751-01 */
    if NOT verify(substr(SampName,1, 1), '0123456789X') then do;
      mfg_batch = scan(SampName, 1, '-');
    end;
    else do;
      delete;  /* stability study */
    end;
  run;
%mend;


%macro mergeIndOthMERPS(meth);
  proc sort data=ind; by SampId mfg_batch; run;
  proc sort data=summ; by SampId mfg_batch; run;
  data &meth;
    merge ind summ;
    by SampId mfg_batch;
  run;

  /* Use proc sql to avoid re-sorting */
  proc sql;
    create table &meth as
    select *
    from &meth a left join OUTDIR.pullMERPS b on a.mfg_batch=b.bat_num
    ;
  quit;
/***proc print data=_last_(obs=max) width=minimum; run;***/
%mend;

%summ(ATM02069IMPHPLC, %str('TESTDATE', 'ANALYST$'));
%ind(ATM02069IMPHPLC, PEAKINFO, %str('NAME$', 'PEAKNAME$', 'AMOUNT$'), PEAKNAME_);
%mergeIndOthMERPS(impurities);

%summ(ATM02067ASSAYHPLC, %str('TESTDATE', 'ANALYST$'));
%ind(ATM02067ASSAYHPLC, PEAKINFO, %str('NAME$', 'PEAKNAME$', 'AMOUNT$'), PEAKNAME_);
%mergeIndOthMERPS(assay);

%summ(ATM02061CUHPLC, %str('TESTDATE', 'ANALYST$'));
%ind(ATM02061CUHPLC, PEAKINFO, %str('NAME$', 'PEAKNAME$', 'AMOUNT$'), PEAKNAME_);
%mergeIndOthMERPS(cu);

%summ(ATM02135ATM02068DISSHPLC, %str('TESTDATE', 'ANALYST$'));
%ind(ATM02135ATM02068DISSHPLC, PEAKINFO, %str('NAME$', 'PEAKNAME$', 'AMOUNT$'), PEAKNAME_);
%mergeIndOthMERPS(disso);

data stack;
  set impurities assay cu disso;
  keep product mfg_batch actual_finish_dt dispname testdate analyst result sampstatus mat_cod component specname resreplicateix test_result_type_desc;
  rename product=material_description
         mfg_batch=batch_number
         mat_cod=material_number
         specname=method_id
         dispname=test_description
         actual_finish_dt=mfg_date
         dispname=test_description
         resreplicateix=replicate
         testdate=test_date
         sampstatus=test_status
         ;
  test_result_type_desc='';  /* N/A in LIMS */
  unit='';  /* N/A in LIMS */
run;

 /* Reorder to resemble LIFT Extracts */
data OUTDIR.avandamet;
  retain batch_number material_number test_date method_id test_description component test_result_type_desc replicate result unit test_status mfg_date material_description analyst;
  set stack;
run;
proc export data=OUTDIR.avandamet OUTFILE="avandamet.csv" DBMS=CSV REPLACE; run;
proc print data=_last_(obs=max) width=minimum; run;

data _null_;
  put 'NOTE: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++';
  put "NOTE: SYSCC: &SYSCC";
  put 'NOTE: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++';
run;
