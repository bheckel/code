options NOsource;
%macro update_shortname_ds;
  /***************************************************************************************************
  *  SAVED AS:                update_shortname_ds.sas
  *                                                                         
  *  CODED ON:                05-Jan-15 by Bob Heckel
  *                                                                         
  *  DESCRIPTION:             Update standardized client short names data set and create folder
  *                           structure for new clients
  *
  *                           See S:\taeb\Analytics\Process Documents\Client Short Names Data Set.docx
  *                               S:\taeb\Analytics\Process Documents\Updating Client Short Names Data Set.docx
  *                                                                           
  *  PARAMETERS:              None
  *
  *  MACROS CALLED:           %dbpassword %odbc_start %odbc_end  
  *                                                                         
  *  INPUT GLOBAL VARIABLES:  NONE
  *                                                                         
  *  OUTPUT GLOBAL VARIABLES: NONE  
  *                                                                         
  *  LAST REVISED:            05-Jan-15 (bheckel) Initial version
  *                           07-Jan-16 (bheckel) AN-2540 update only NPI & CGID, check for new clients
  *                                               and append, add logic for 1=Big Chain (20+) 2=Small Chain (2-19) 3=Independent
  *                           29-Jan-16 (bheckel) Create directories for any new client(s) found
  *                           29-Feb-16 (bheckel) Uprade how CGID is determined
  *                           10-May-16 (bheckel) Change dsn from jasper to db6
  *                           14-Jul-16 (bheckel) AN-4509 add new vars to specify if mdfarchive is in use
  *                           18-Aug-16 (bheckel) Add email alert for duplicate short_client_name
  *                           14-Oct-16 (bheckel) Clarify error message and comments to handle dup shortnames
  *                           21-Oct-16 (bheckel) Add manual toggle for client name changes
  *                           28-Oct-16 (bheckel) Modify logic for forcing Walgreens into the dataset
  *                           11-Jan-17 (bheckel) Prevent control characters from interfering with folder
  *                                               creation
  ***************************************************************************************************/   
  /* 08-Jan-16 Running on sas-01 as bheckel */
  /* 00 02 * * * $SAS_COMMAND -sysin /sasdata/Cron/Daily/update_shortname_ds/update_shortname_ds.sas -log /sasdata/Cron/Daily/update_shortname_ds/update_shortname_ds.log -print /sasdata/Cron/Daily/update_shortname_ds/update_shortname_ds.lst */
  options mprint mautosource sasautos=('/Drugs/Macros', sasautos) ps=max ls=max nocenter sgen;
  %dbpassword;
  libname BUILD '/Drugs/FunctionalData';


  data clients_shortname_lookup(drop=storecnt);
    set BUILD.clients_shortname_lookup;
    /* If dup errors appear, edit a unique shortname below then toggle this to force the client back through the new client logic */
/***    if clientid eq 1028 then delete;***/
/***    if clientid eq 877 then delete;***/
/***    if clientid eq 1049 then delete;***/
/***    if clientid eq 1062 then delete;***/
/***    if clientid eq 1093 then delete;***/

    /* Walgreens is in a separate database so we'll force back in below */
    if clientid eq 2000000 then delete;

  /* To handle store name changes, e.g.:
   *
   * 66     MediShop1453    Medicine Shoppe 1453                            CLI_1528130317 / Medicine Shoppe 1453
   * 66     SidnHomePhar    Sidney Hometown Pharmacy                        CLI_1528130317 / Sidney Hometown Pharmacy
   *
   * this must occasionally be toggled and manuallly run
   */
/***    delete;***/
  run;

  /**************** Process Any New Clients *******************/
  %odbc_start(work, amcclients, amc);
    select id, name, short_name from amc.clients where name <> '';
  %odbc_end;


  %let newidlist=;
  proc sql NOprint;
    select id into :newidlist separated by ','
    from amcclients a left join clients_shortname_lookup b on a.id=b.clientid
    where b.clientid is null
    ;
  quit;

  %put _user_;

  %if &newidlist ne  %then %do;
    %put DEBUG: New client(s) exist;
    filename MAILTHIS email ('bob.heckel@taeb.com') subject="[cron] New client(s) found during &SYSHOSTNAME /Drugs/Cron/Daily/update_shortname_ds.sas execution";
    data _null_; file MAILTHIS; put; run;

    data clients_shortname_lookup_old;  set clients_shortname_lookup; run;

    data clients;
      length short_client_name $12 long_client_name $64;
      set amcclients(rename=(id=clientid));

      if clientid in ( &newidlist );

      put 'DEBUG: ' name=;

      split1 = scan(compress(name, "'&-.#()"), 1, ' ');
      split2 = scan(compress(name, "'&-.#()"), 2, ' ');
      split3 = scan(compress(name, "'&-.#()"), 3, ' ');
      split4 = scan(compress(name, "'&-.#()"), 4, ' ');
      split5 = scan(compress(name, "'&-.#()"), 5, ' ');
      split6 = scan(compress(name, "'&-.#()"), 6, ' ');
      split7 = scan(compress(name, "'&-.#()"), 7, ' ');
      split8 = scan(compress(name, "'&-.#()"), 8, ' ');
      
      /* 1 - Standardize e.g. "CLI_1720180147 / The Medicine Center" to "The Medicine Center" */
      splitx = scan(name, 2, '/');

      if split2 eq '/' then do;
        independent = 'Y';
        short_client_name = substr(compress(split3), 1, 12);
        if split4 ne '' then do;
          short_client_name = substr(compress(split3), 1, 8) || substr(compress(split4), 1, 4);
        end;
        if split5 ne '' then do;
          short_client_name = substr(compress(split3), 1, 4) || substr(compress(split4), 1, 4) || substr(compress(split5), 1, 4);
        end;
        if split6 ne '' then do;
          short_client_name = substr(compress(split3), 1, 4) || substr(compress(split4), 1, 4) || substr(compress(split5), 1, 2) || substr(compress(split6), 1, 2);
        end;
        if split7 ne '' then do;
          short_client_name = substr(compress(split3), 1, 4) || substr(compress(split4), 1, 4) || substr(compress(split5), 1, 2) || substr(compress(split6), 1, 1) || substr(compress(split7), 1, 1);
        end;
        if split8 ne '' then do;
          short_client_name = substr(compress(split3), 1, 4) || substr(compress(split4), 1, 4) || substr(compress(split5), 1, 1) || substr(compress(split6), 1, 1) || substr(compress(split7), 1, 1) || substr(compress(split8), 1, 1);
        end;
        long_client_name = left(trim(splitx));
      end;
      else do;
        independent = 'N';
        if split1 ne '' then do;
          short_client_name = substr(compress(split1), 1, 8) || substr(compress(split2), 1, 4);
        end;
        if split2 ne '' then do;
          short_client_name = substr(compress(split1), 1, 4) || substr(compress(split2), 1, 4) || substr(compress(split3), 1, 4);
        end;
        if split3 ne '' then do;
          short_client_name = substr(compress(split1), 1, 4) || substr(compress(split2), 1, 4) || substr(compress(split3), 1, 2) || substr(compress(split4), 1, 2);
        end;
        if split4 ne '' then do;
          short_client_name = substr(compress(split1), 1, 4) || substr(compress(split2), 1, 4) || substr(compress(split3), 1, 2) || substr(compress(split4), 1, 1) || substr(compress(split5), 1, 1);
        end;
        if split5 ne '' then do;
          short_client_name = substr(compress(split1), 1, 4) || substr(compress(split2), 1, 4) || substr(compress(split3), 1, 1) || substr(compress(split4), 1, 1) || substr(compress(split5), 1, 1) || substr(compress(split6), 1, 1);
        end;
        long_client_name = left(trim(name));
      end;
    run;


    /* 2 - If AMC's short_name <= 12 then use it instead, we'll deal with dups later in this code */
    data clients;
      set clients;

      if length(short_name) <= 12 then do;
        short_client_name = short_name;
      end;
    run;


    /* 3 - Fix any collisions manually */
    /* E.g.
     * 683  CLI_1407969710 / Clark's Rx-Cedarville  CLI_1407969710
     * 1049 CLI_1497208128 / Clark's Rx-Centerville CLI_1497208128
     */

    data clients_shortname_lookup_new;
      set clients;

      /* Manual name creation (12 char max) is required to maintain uniqueness for these clients: */
      if name eq 'CLI_1487720140 / Amicare Pharmacy/Moline' then short_client_name = 'AmicaPharmMo';
      if name eq 'CLI_1114934239 / Amicare Pharmacy/Bettendorf' then short_client_name = 'AmicaPharmBe';
      if name eq 'CLI_1134284565 / Amicare Pharmacy/Waterloo' then short_client_name = 'AmicaPharmWa';
      if name eq 'CLI_1306928197 / Azalea Health/Keystone' then short_client_name = 'AzaleHealKey';
      if name eq 'CLI_1316020472 / Azalea Health/Palatka' then short_client_name = 'AzaleHealPal';
      if name eq 'CLI_1497838551 / Azalea Health/Interlachen' then short_client_name = 'AzaleHealInt';
      if name eq 'CLI_1528204419 / Azalea Health/Hawthorne' then short_client_name = 'AzaleHealHaw';
      if name eq 'CLI_1033345673 / Bayside EMS' then short_client_name = 'BaysideEMS1';
      if name eq 'CLI_1942315981 / Bayside EMS' then short_client_name = 'BaysideEMS2';
      if name eq 'CLI_1942204581 / Center Pharmacy' then short_client_name = 'CenterPhar1';
      if name eq 'CLI_1407942667 / Center Pharmacy' then short_client_name = 'CenterPhar2';
      if name eq 'CLI_1972514529 / Center Pharmacy' then short_client_name = 'CenterPhar3';
      if name eq 'CLI_1053314021 / Georges Family Pharmacy' then short_client_name = 'GeorFamiPhr1';
      if name eq 'CLI_1184875122 / Georges Family Pharmacy' then short_client_name = 'GeorFamiPhr2';
      if name eq 'CLI_1689653040 / Glenview Professional Pharmacy' then short_client_name = 'GlenProfPhr1';
      if name eq 'CLI_1841279932 / Glenview Professional Pharmacy' then short_client_name = 'GlenProfPhr2';
      if name eq 'CLI_1225359664 / Medical Center Pharmacy' then short_client_name = 'MediCentPha1';
      if name eq 'CLI_1770587644 / Medical Center Pharmacy' then short_client_name = 'MediCentPha2';
      if name eq 'CLI_1588096010 / Medicine Shoppe 0564' then short_client_name = 'MediShp15461';
      if name eq 'CLI_1427160423 / Medicine Shoppe 0564' then short_client_name = 'MediShp15462';
      if name eq 'CLI_1659320547 / Medicine Shoppe 0741' then short_client_name = 'MediShp07411';
      if name eq 'CLI_1134470016 / Medicine Shoppe 0741' then short_client_name = 'MediShp07412';
      if name eq 'CLI_1336281716 / Medicine Shoppe 1483' then short_client_name = 'MediShp14831';
      if name eq 'CLI_1154621308 / Medicine Shoppe 1483' then short_client_name = 'MediShp14832';
      if name eq 'CLI_1124160569 / Medicine Shoppe 1546' then short_client_name = 'MediShp05641';
      if name eq 'CLI_1528368776 / Medicine Shoppe 1546' then short_client_name = 'MediShp05642';
      if name eq 'CLI_1932398468 / Mills Family Pharmacy' then short_client_name = 'MillFamiPhr1';
      if name eq 'CLI_1801836473 / Millers Family Pharmacy' then short_client_name = 'MillFamiPhr2';
      if name eq 'CLI_1568413128 / Osborn Drugs' then short_client_name = 'OsbornDrg1';
      if name eq 'CLI_1073560298 / Osborn Drug2' then short_client_name = 'OsbornDrg2';
      if name eq 'CLI_1649474453 / Pill Box Pharmacy' then short_client_name = 'PillBoxPhr1';
      if name eq 'CLI_1245225010 / Pill Box Pharmacy' then short_client_name = 'PillBoxPhr2';
      if name eq 'CLI_1164517124 / Prescription Shop' then short_client_name = 'PrescripShp1';
      if name eq 'CLI_1477688463 / Prescription Shop/AR' then short_client_name = 'PrescripShp2';
      if name eq 'CLI_1093071698 / Rx Care Pharmacy' then short_client_name = 'RxCarePharm1';
      if name eq 'CLI_1649404526 / Rx Care Pharmacy' then short_client_name = 'RxCarePharm2';
      if name eq 'CLI_1336413160 / Rx Care Pharmacy' then short_client_name = 'RxCarePharm3';
      if name eq 'CLI_1336468511 / Rx Care Pharmacy' then short_client_name = 'RxCarePharm4';
      if name eq 'CLI_1881951184 / Rx Care Pharmacy' then short_client_name = 'RxCarePharm5';
      if name eq 'CLI_1942584057 / Rx Care Pharmacy' then short_client_name = 'RxCarePharm6';
      if name eq 'CLI_1790747483 / Rx Care Pharmacy' then short_client_name = 'RxCarePharm7';
      if name eq 'CLI_14079943749 / Sheefa Pharmacy' then short_client_name = 'SheefaPharm1';
      if name eq 'CLI_1316968381 / Sheefa Pharmacy' then short_client_name = 'SheefaPharm2';
      if name eq 'CLI_1407994379 / Sheefa Pharmacy' then short_client_name = 'SheefaPharm3';
      if name eq 'CLI_1376676783 / Village Pharmacy' then short_client_name = 'VillagePhar1';
      if name eq 'CLI_1831135292 / Village Pharmacy' then short_client_name = 'VillagePhar2';
      if name eq 'CLI_1184631749 / Village Pharmacy/Marblehead' then short_client_name = 'VillagePhar3';
      if name eq 'CLI_1396800710 / Walker Drug Store' then short_client_name = 'WalkDrugStr1';
      if name eq 'CLI_1760638829 / Walkers Drug Store' then short_client_name = 'WalkDrugStr2';
      /* 18-Aug-16 */
      if name eq 'CLI_1679644694 / Davis Drug (Utah)' then short_client_name = 'DavisDrugUta';
      if name eq 'CLI_1972508695 / Tyson Drugs' then short_client_name = 'TysonDrug2';
      /* Extra work required because there are 2 clients named identically and their short_name is also the same ('FT'). That causes
       * the code below to use the 'FT' short_name because it's <= 12.  Unfortunately this creates dups if not handled here.
       */
      if name eq 'FAMILY THRIFT CENTER PHARMACY' and clientid eq 906 then do; short_client_name = 'FamilyThr906'; short_name = 'FamilyThr906'; end;
      if name eq 'FAMILY THRIFT CENTER PHARMACY' and clientid eq 903 then do; short_client_name = 'FamilyThr903'; short_name = 'FamilyThr903'; end;
      if name eq "CLI_1497208128 / Clark's Rx-Centerville" then short_client_name = 'ClarksRxCen';
    run;

    /* Check for the rare case of duplicate short names in the new clients.  We check against existing short names later. */
    proc sort data=clients_shortname_lookup_new; by short_client_name; run;
    data clients_shortname_lookup_new;
      set clients_shortname_lookup_new;
      by short_client_name;
      if first.short_client_name and last.short_client_name then do;
        /* Not a new client dup */
        call symput('DUPS', 0);
        output;
      end;
      else do;
        /* Skip dups, we probably need to manually edit exception code above and re-run */
        put 'ERROR: dups exist, deleting this record: ' (_all_)(=);
        call symput('DUPS', 1);
        delete;
      end;
    run;
    %if &DUPS eq 1 %then %do;
      filename MAILTHIS email ('bob.heckel@taeb.com') subject='[cron] Duplicates found during /Drugs/Cron/Daily/update_shortname_ds.sas execution';
      data _null_; file MAILTHIS; put; run;
    %end;

    data clients_shortname_lookup_new;
      set clients_shortname_lookup_new;
      put 'DEBUG: before ' short_client_name=;
      /* Remove non-standard characters (e.g. ApotPhar)@SnS before creating folders */
      short_client_name=prxchange('s/[^A-z1-9-_]//', -1, short_client_name);
      put 'DEBUG: after ' short_client_name=;
    run;
    
    %let newclients=;
    proc sql NOprint;
      select short_client_name into :newclients separated by ' '
      from clients_shortname_lookup_new
      ;
    quit;

    %let i=1;
    %let c=%qscan(&newclients, &i, %str( ));
    %do %while (&c ne %str( ));
      %put DEBUG: Creating new directories for &c ...;
      %let rc1=%sysfunc(dcreate(&c, /Drugs/TMMEligibility));
      %let rc2=%sysfunc(dcreate(AnalyticPanels, /Drugs/TMMEligibility/&c));
      %let rc3=%sysfunc(dcreate(HPTasks, /Drugs/TMMEligibility/&c));
      %let rc4=%sysfunc(dcreate(Imports, /Drugs/TMMEligibility/&c));
      %let rc5=%sysfunc(dcreate(Projections, /Drugs/TMMEligibility/&c));
      %let rc6=%sysfunc(dcreate(Studies, /Drugs/TMMEligibility/&c));
      %put &=rc1 &=rc2 &=rc3 &=rc4 &=rc5 &=rc6;
      %let i=%eval(&i+1);
      %let c=%qscan(&newclients, &i, %str( ));
    %end;

    data clients_shortname_lookup(drop= split:);
      set clients_shortname_lookup_old clients_shortname_lookup_new;
    run;

    %put NOTE: New client(s) processed;
  %end;  /* new client(s) processed */
  %else %do;
    %put NOTE: No new clients exist;
  %end;
  /******************************************************/


  /* Walgreens is in a separate database so force it */
  data clients_shortname_lookup;
    set clients_shortname_lookup end=e;
    if e then do;
      output;
      clientid = 2000000;
      clienttype = 1;
      independent = 'N';
      long_client_name = 'Walgreens';
      mdfarchive = 0;
      name = 'Walgreens';
      short_client_name = 'Walgreens';
      short_name = 'Walgreens';
      shortname = 'Walgreens';
      storecnt = 99999;
      output;
    end;
    else do;
      output;
    end;
  run;


  /**************** Update CGID & NPI (independents only) *******************/
  /* CGID */
  %odbc_start(work, cgrps, db6);
    select clientid, campaigngroupid as cgid from analytics.vtmmclient;
  %odbc_end;

  proc sort data=cgrps NOdupkey; by clientid; run;

  proc sql NOprint;
    create table current as
    select a.clientid, a.short_client_name, a.long_client_name, a.name, a.short_name, a.independent, a.clienttype, b.cgid
    from clients_shortname_lookup a left join cgrps b on a.clientid=b.clientid
    ;
  quit;


  /* NPI */
  proc sql NOprint;
    select distinct clientid into :clids separated by ',' from current
    ;
  quit;

  %odbc_start(work, ccsd, db6);
    select clientid, npi
    from test.client_chain_store_dimension
    where clientid in(&clids)
    ;
  %odbc_end;

  proc sort data=ccsd; by clientid npi; run;
  data ccsd;
    set ccsd;
    by clientid npi;

    if first.clientid and last.clientid;
  run;

  proc sql NOprint;
    create table clients_shortname_lookup as
    select a.*, b.npi
    from current a LEFT JOIN ccsd b  ON a.clientid=b.clientid
    ;
  quit;
  /*********************************************************************/


  /**************** Apply Size Logic *******************/
  %odbc_start(work, stores, amc);
    select clients_fkid, count(storeid) as storecnt from amc.stores where status='OPEN' group by clients_fkid;
  %odbc_end;

  proc sql NOprint;
    create table withcounts as
    select a.*, b.storecnt
    from clients_shortname_lookup a left join stores b  on a.clientid=b.clients_fkid
    ;
  run;

  data clients_shortname_lookup;
    set withcounts;

    clienttype = 0;

    if independent eq 'Y' then clienttype = 3;

    if independent ne 'Y' then do;
      if storecnt ge 1 and storecnt le 19 then clienttype = 2;
      if storecnt ge 20 then clienttype = 1;
    end;
  run;

  /* Walgreens database is not available via this code so add it manually */
  data clients_shortname_lookup;
    set clients_shortname_lookup;
    if short_client_name eq 'Walgreens' then do;
      clienttype = 1;
      clientid=2000000;
      storecnt = 99999;
    end;
  run;
  /*****************************************************/


  /************** Client uses mdfarchive ***************/
  data clients_shortname_lookup;
    format mdfarchive_startdt DATE9.;
    set clients_shortname_lookup;
    if short_client_name eq 'Delhaize' then mdfarchive = 1;
    else mdfarchive = 0;

    if short_client_name eq 'Delhaize' then mdfarchive_startdt = '01JUN2016'd;
  run;
  /*****************************************************/


  /********* Warn about any dups (new and old clients) ***************/
  %let DUPCLIDS=;
  proc sql;
    select clientid into :DUPCLIDS separated by ','
    from clients_shortname_lookup
    group by short_client_name
    having count(clientid)>1
    ;
  quit;

  %if &DUPCLIDS ne  %then %do;
    %put ERROR: Duplicate clid &DUPCLIDS in BUILD.clients_shortname_lookup;
    filename MAILTHIS email ('bob.heckel@taeb.com') subject='[cron] Duplicates found during /Drugs/Cron/Daily/update_shortname_ds.sas execution';
    data _null_; file MAILTHIS; put "&DUPCLIDS"; run;
  %end;
  /********************************************************************/

  proc sort data=clients_shortname_lookup; by clientid; run;

  data BUILD.clients_shortname_lookup;
    set clients_shortname_lookup;
    label name='AMC.stores name'
          cgid='Campaign Group ID (where available)'
          npi='NPI (where available)'
          short_name='AMC.stores short_name'
          short_client_name='Analytics-generated short name'
          long_client_name='AMC.stores name with CLI prefix removed'
          independent='Y=independent, N=chain'
          clientid='Client ID number'
          clienttype='1=Large Chain, 2=Small Chain(2-19 stores), 3=Independent'
          storecnt='Count of OPEN stores'
          independent='(Y)es / (N)o'
          mdfarchive='0=No, 1=Yes'
          mdfarchive_startdt='Date of first MDF load to mdfarchive'
          ;
  run;
  proc contents;run;
  title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;run;
  data _null_; if 0 then set BUILD.clients_shortname_lookup nobs=count; call symput('OBSCNT', strip(count)); stop; run;

  %if &SYSRC eq 0 %then %do;
    %put NOTE: Update successful &OBSCNT observations in BUILD.clients_shortname_lookup;
  %end;
  %else %do;
    %put ERROR: Update was not successful &OBSCNT observations in BUILD.clients_shortname_lookup;
    filename MAILTHIS email ('bob.heckel@taeb.com') subject='[cron] Error during /Drugs/Cron/Daily/update_shortname_ds.sas execution';
    data _null_; file MAILTHIS; put; run;
  %end;
%mend;
%update_shortname_ds;
