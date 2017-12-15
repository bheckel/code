
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  PROGRAM NAME:     FreeWeigh.sas
 *
 *  CREATED BY:       Bob Heckel (rsh86800)
 *                                                                            
 *  DATE CREATED:     15-Sep-09
 *                                                                            
 *  SAS VERSION:      8.2
 *
 *  PURPOSE:          Extract FreeWeigh data from the FreeWeigh system using
 *                    DataLink Integrator (or manual override).
 *
 *  INPUT:            DataLink Integrator (ADO Adapter 1.0.0.1 or higher) XML,
 *                    INI file.
 *
 *  PROCESSING:       Read control files, extract, translate, load
 *
 *                    Sample call:
 *                    %FreeWeigh(valtrex_caplets, valtrex, ADO_FW);
 *
 *  OUTPUT:           Min, max, average SAS dataset and CSV file pairs.
 *------------------------------------------------------------------------------
 *                     HISTORY OF CHANGE
 *-------------+---------+--------------------+---------------------------------
 *     Date    | Version | Modification By    | Nature of Modification
 *-------------+---------+--------------------+---------------------------------
 *  15-Sep-09  |    1.0  | Bob Heckel         | Original. CCF 84180.
 *-------------+---------+--------------------+---------------------------------
 *******************************************************************************
 */
%macro FreeWeigh(prodname, prefixnm, configprefix);
  %put NOTE: FreeWeigh.sas %sysfunc(getoption(SYSIN)) started: &SYSDATE &SYSTIME;

  %local fwstart; %let fwstart=%sysfunc(time());

  %local utilpath ocdpath;
  /* Location of product-specific .ini, .con, .sql, .xml files */
  %let utilpath=&SYSPARM\&prodname\CODE\util;
  %let ocdpath=&SYSPARM\&prodname\OUTPUT_COMPILED_DATA;

  /* DLIPATH is used by ado.sas7bcat, displays as p= in DLI debugging info */
  %let DLIPATH=&utilpath\;

  /* If DP SR Sect 10 Contingency Planning file is to be used during a DLI
   * outage, this will hold '1'
   */
  %local overridefileexists;
  %local fwdb fwsvr;  /* for source data tracking purposes only */

  %global FWDEBUGON CONSTRAINTS;  /* populated by .ini */

  libname OUTDIR "&ocdpath";

  %macro LookForOverride(dir, fn);
    %if %sysfunc(fileexist("&dir\&fn")) %then %do;
      /* Usually produced by something like:
       * sqlcmd -S zebsamoc007 -d usprd1208 -i ADO_FW.qry -o ADO_FW.txt
       */
      %put NOTE: &dir\&fn contingency recovery override file exists;
      %let overridefileexists=1;
    %end;
    %else %do;
      %put NOTE: &dir\&fn contingency recovery override file does not exist, running normally;
      %let overridefileexists=0;
    %end;
  %mend;
  %LookForOverride(&utilpath, &configprefix..txt);

  %macro GetXMLviaDLI;
    libname SCLCAT "&utilpath";

    filename INI "&utilpath\&configprefix..ini";
    data _null_;
      if not fexist('INI') then do;
        put "ERROR: INI file &utilpath\&configprefix..ini is missing.  Exiting.";
        %put _all_;
        abort abend 008;
      end;
    run;

    data _null_;
      infile INI DLM='=' MISSOVER;
      input key :$40. val :$180.;
      if substr(key, 1, 1) ne ';';  /* skip comments */
      call symput(key, val);
    run;

    data _null_;
      if (not fileexist("&utilpath\&configprefix..con")) or (not fileexist("&utilpath\&configprefix..qry")) then do;
        put "ERROR: .con and/or .qry file(s) are missing in &utilpath.  Exiting.";
        put _all_;
        abort abend 008;
      end;
    run;

    /* Execute compiled SCL code */
    /* 03-Jun-09 The ADO Adapter must have an input file e.g. ADO_FW.xml or it fails silently (but writes to Windows eventvwr) */
    proc display c=SCLCAT.ADO.FW.scl; run;

    data _null_;
      if not fileexist("&utilpath\&configprefix..xml") then do;
        put "ERROR: &configprefix..xml file is missing in &utilpath.  Exiting.";
        put _all_;
        abort abend 008;
      end;
    run;

    /* Be sure that a new file was just produced - read 8 lines of output from Windows DIR command */
    filename p PIPE "dir &utilpath\&configprefix..xml";
    data diroutput;
      list;
      infile p;
      input cmdoutputline $256.;  /* arbitrary but hopefully long enough to avoid Log warnings */
    run;

    data diroutput;
      set diroutput;  /* should be 1 record */

      if index(cmdoutputline, "&configprefix..xml");  /* save the DIR output containing the date info only */

      dateoffile = input(scan(cmdoutputline, 1, ' '), DATE9.);

      /* This is used by UTC: */
      if dateoffile ne today() then do;
        put "ERROR: &utilpath\&configprefix..xml is old.  Exiting.";
        abort abend 008;
      end;
      else do;
        put "NOTE: &configprefix..xml datestamp is " dateoffile DATE9.;
      end;
    run;
  %mend GetXMLviaDLI;

  %macro BuildDSFromXML;
     /* No XMLMAP .map file required due to the simplicity of the XML returned by the FW query */
    libname INXML XML "&utilpath\&configprefix..xml" access=READONLY;

    data tmp; set INXML.table; run;

  %mend BuildDSFromXML;

  %macro BuildDSFromTXT;
    /* Will generally be a query like this one (ADO_FW.qry):
        SELECT     fwn.BatchList.sBatchNbr, fwn.Product.sProdName, fwn.TestItem.sItemName, fwn.VariableStp.dtSplTakenTime, fwn.IndValues.rValue1, 
                              fwn.IndValues.rValue2, fwn.IndValues.rValue3, fwn.IndValues.rValue4, fwn.IndValues.rValue5, fwn.ProdItemMach.nItemID
        FROM         fwn.VariableStp INNER JOIN
                              fwn.IndValues ON fwn.VariableStp.nSplRecID = fwn.IndValues.nSplRecID INNER JOIN
                              fwn.BatchList ON fwn.VariableStp.nBatch1ID = fwn.BatchList.nBatchID LEFT OUTER JOIN
                              fwn.ProdItemMach INNER JOIN
                              fwn.TestItem ON fwn.ProdItemMach.nItemID = fwn.TestItem.nItemID ON fwn.VariableStp.nID = fwn.ProdItemMach.nID AND 
                              fwn.BatchList.nItemID = fwn.TestItem.nItemID LEFT OUTER JOIN
                              fwn.Product ON fwn.ProdItemMach.nProdID = fwn.Product.nProdID
        WHERE fwn.Product.sProdName like 'Valtrex%' and fwn.BatchList.bBatchFinished = 1
        ORDER BY fwn.BatchList.sBatchNbr, fwn.VariableStp.dtSplTakenTime
     */
    filename TXT "&utilpath/&configprefix..txt";

    data tmp;
      infile TXT LRECL=256 FIRSTOBS=3;
      input
        @1 sBatchNbr $CHAR22.
        @32 sProdName $CHAR30.
        @64 sItemName $CHAR12.
        @95 dtSplTakenTime $CHAR29.
        @119 rValue1 :8.
        @144 rValue2 :8.
        @169 rValue3 :8.
        @194 rValue4 :8.
        @219 rValue5 :8.
        @244 nItemID :8. 
      ;
    run;
  %mend BuildDSFromTXT;

  %if &overridefileexists eq 1 %then %do;
    %put WARNING: using override file &utilpath\&configprefix..txt;
    %BuildDSFromTXT;
  %end;
  %else %do;  /* normal DLI run */
    %GetXMLviaDLI;
    %BuildDSFromXML;
  %end;

  data tmp;
    set tmp;

    /* FW holds much bad data.  Want only normal looking PO-Batch numbers e.g. 2000740340-9zm5570 */
    if not index(upcase(SBATCHNBR), 'ZM') then do;
      put 'WARNING: SBATCHNBR is not a normal PO-batch: ' SBATCHNBR= nItemID= dtSplTakenTime= sProdName=;
      delete;
    end;
    SBATCHNBR = compress(SBATCHNBR);
  run;

  proc sort data=tmp; by sbatchnbr sitemname;run;

  %if &FWDEBUGON eq 1 %then %do;
    data OUTDIR.freeweigh_DEBUGON;
      set tmp(where=(&CONSTRAINTS));
      /* 2000820596/9zm8358 */
      if length(SBATCHNBR) < 19 then delete;  /* avoid bad batches filtered out later from Tester's random selection choices */
      SITEMNAME = tranwrd(SITEMNAME, '-10', '');  /* remove suffixes */
    run;
  %end;

   /* 'min' 'max' 'ave' naming convention and output order by Kevin Ely */
  data tmp(drop= rvaluex nItemID DTSPLTAKENTIME i RVALUE:);
    retain min max;
    set tmp(where=(&CONSTRAINTS));
    by SBATCHNBR SITEMNAME;

    if first.SITEMNAME then do;
      i=0;
      rvaluex=0;
    end;

    i+1;

    min = min(min, rvalue1);
    max = max(max, rvalue1);
    min = min(min, rvalue2);
    max = max(max, rvalue2);
    min = min(min, rvalue3);
    max = max(max, rvalue3);
    min = min(min, rvalue4);
    max = max(max, rvalue4);
    min = min(min, rvalue5);
    max = max(max, rvalue5);

    rvaluex+rvalue1;
    rvaluex+rvalue2;
    rvaluex+rvalue3;
    rvaluex+rvalue4;
    rvaluex+rvalue5;

    if last.SITEMNAME then do;
      ave = rvaluex/(i*5);
      output;
      min = .;
      max = .;
    end;

    /* For debugging only */
    if "&FWDEBUGON" eq 1 and _N_ < 100 then put _all_;
  run;

  data tmp;
    length mfg_batch process_order $40;  /* for merge with other DP data */
    set tmp;
    mfg_batch = scan(SBATCHNBR, 2, '\-/');
    process_order = scan(SBATCHNBR, 1, '\-/');

    /* Remove all "-10" suffixes per the Business */
    SITEMNAME = tranwrd(SITEMNAME, '-10', '');
    
    if mfg_batch eq '' or process_order eq '' then do;
      put 'WARNING: empty batch or PO: ' _all_;
      delete;
    end;

    if not index(upcase(mfg_batch), 'ZM') then do;
      put 'WARNING: bad batch: ' _all_;
      delete;
    end;
  run;

   /*
                                                                                                                   mfg_       process_
  Obs        min        max    SITEMNAME              SPRODNAME                    SBATCHNBR              ave     batch         order

    1      25.40      36.50    Hardness     Valtrex 1g Caplets (Fldr-DIVI)    2000785205 - 9zm2581      30.07    9zm2581    2000785205 
    2       7.33       7.52    Thickness    Valtrex 1g Caplets (Fldr-DIVI)    2000785205 - 9zm2581       7.44    9zm2581    2000785205 
    3    1373.40    1416.50    Weight       Valtrex 1g Caplets (Fldr-DIVI)    2000785205 - 9zm2581    1395.10    9zm2581    2000785205 
    4       0.00      38.40    Hardness     Valtrex 1g Caplets (Fldr-DIVI)    2000725940-8ZM3272        29.47    8ZM3272    2000725940 
    5       7.28       7.58    Thickness    Valtrex 1g Caplets (Fldr-DIVI)    2000725940-8ZM3272         7.45    8ZM3272    2000725940 
    6    1368.60    1413.00    Weight       Valtrex 1g Caplets (Fldr-DIVI)    2000725940-8ZM3272      1392.01    8ZM3272    2000725940 
    */
  proc sort data=tmp; by mfg_batch process_order sProdName; run;

  %macro tran(typ);
    proc transpose data=tmp out=tmp_&typ(drop=_NAME_);
      by mfg_batch process_order sProdName;
      id SITEMNAME;
      var &typ;
    run;

    data tmp_&typ;
      format hard_&typ thick_&typ wgt_&typ 8.2;
      set tmp_&typ(rename=(Hardness=hard_&typ Thickness=thick_&typ Weight=wgt_&typ));
    run;
  %mend;
  %tran(min);
  %tran(max);
  %tran(ave);

  /* Parse to fill SOURCE field in output dataset */
  /* Provider=SQLOLEDB.1;Integrated Security=SSPI;Persist Security Info=False;Initial Catalog=usprd1208;Data Source=zebsamoc007 */
  filename DLICON "&utilpath\&configprefix..con";
  data _null_;
    infile DLICON DLM='=';
    input @'Initial Catalog=' db $CHAR9.  @'Data Source=' svr $CHAR11.;
    call symput('fwdb', db);
    call symput('fwsvr', svr);
  run;

  /* This temporary dataset is consumed by 0_MAIN callers */
  data freeweigh;
    length source $100;  /* same as all DP product's length */
    merge tmp_min tmp_max tmp_ave;
    by mfg_batch process_order sProdName;

    mfg_batch = upcase(left(trim(mfg_batch)));
    source = "FreeWeigh &fwsvr:&fwdb";
  run;

  data OUTDIR.&prefixnm._freeweigh;
    retain mfg_batch process_order sProdName hard_min hard_max hard_ave thick_min thick_max thick_ave wgt_min wgt_max wgt_ave;
    set freeweigh;
  run;

  proc export data=OUTDIR.&prefixnm._freeweigh OUTFILE="&ocdpath\CSV &prefixnm._FreeWeigh.csv" DBMS=CSV REPLACE; run;

  %if &FWDEBUGON eq 1 %then %do;
    title "FreeWeigh.sas &fwsvr:&fwdb"; proc freq; run; proc contents; run; title;
  %end;

  %put NOTE: FreeWeigh.sas SYSCC: &SYSCC (%sysfunc(getoption(SYSIN)) ended: %sysfunc(putn(%sysfunc(datetime()),DATETIME.)) / minutes elapsed: %sysevalf((%sysfunc(time())-&fwstart)/60));
  %put _all_;
%mend FreeWeigh;

/* DEBUG */
/* DEBUG */
/* DEBUG */
/***options sgen mprint mlogic;***/
/***%let sysparm=C:\cygwin\home\bheckel\projects\datapost\tmp\;***/
/***%freeweigh(valtrex_caplets,valtrex,ADO_FW);***/
/* for UTC */
/***%freeweigh(freeweigh,freeweigh,ADO_FW);***/
/* DEBUG */
/* DEBUG */
/* DEBUG */
