/********************************************************************************
*  SAVED AS:                excel_to_db.sas
*                                                                         
*  CODED ON:                18-Sep-15 by Bob Heckel
*                                                                         
*  DESCRIPTION:             
*                                                                           
*  PARAMETERS:              
*
*  MACROS CALLED:           %dbpassword 
*                                                                         
*  INPUT GLOBAL VARIABLES:  NONE
*                                                                         
*  OUTPUT GLOBAL VARIABLES: NONE  
*                                                                         
*  LAST REVISED:                                                          
*   15-Sep-15   Initial version
********************************************************************************/
%macro excel_to_db;
  options mautosource sasautos=('/Drugs/Macros', sasautos) mprint sgen NOquotelenmax ps=max ls=max NOsgen yearcutoff=1905;
  libname MOYA '.';

  %let DEBUG=1;

  data to_insert;
    set MOYA.ph_to_ateb;
    format dateofbirth DATE9.;

    hpprogramid=12;
    filerecdate='01SEP2015'd;

    rename
/***      CLM_SVC_BEG_DT      = claimdate***/
      CARDHOLDER_ID       = cardholderid
      MBR_LAST_NAME       = lastname
      MBR_FIRST_NAME      = firstname
      MEMBER_GENDER       = patientgender
/***      MBR_BIRTHDATE       = dateofbirthCHAR***/
      MBR_ADDR_LINE_1     = address1
      MBR_ADDR_LINE_2     = address2
      MBR_CITY            = city
      MBR_STATE_CD        = stateprov
      MBR_POSTAL_CD       = postalcode
      PHARMACY_CHAIN      = pharmacychain
      PHARMACY            = pharmacyname
      PHAMACY_ADDR_LINE_1 = pharmacyaddress1
      PHAMACY_ADDR_LINE_2 = pharmacyaddress2
      PHARMACY_CITY       = pharmacycity 
      PHARMACY_STATE      = pharmacystateprov
      PHARMACY_POSTAL_CD  = pharmacypostalcode
      NDC                 = ndc
/***      RX_PRESCRIPTION_ID  = rxnumNUM***/
      RX_DAYS_SUPPLY      = dayssupply 
      DRUG_CLASS_CD       = drugclasscode 
      DRUG_NAME           = medicationname
      GPI                 = gpi
/***      DIAB_PDC_RATE       = pdc_diabCHAR ***/
/***      RAS_PDC_RATE        = pdc_rasCHAR ***/
/***      CHOL_PDC_RATE       = pdc_cholCHAR ***/
      ;

    /* Char to date */
    claimdate = input(CLM_SVC_BEG_DT, DATE9.);
    dateofbirth = input(MBR_BIRTHDATE, DATE9.);
    /* Num to char */
    rxnum = put(RX_PRESCRIPTION_ID, F8. -L);
    /* Char to num */
    pdc_diab = input(DIAB_PDC_RATE, ? BEST. -L);
    pdc_ras = input(RAS_PDC_RATE, ? BEST. -L);
    pdc_chol = input(CHOL_PDC_RATE, ? BEST. -L);
  run;

  data to_insert;
    retain
      hpprogramid
      filerecdate
      claimdate
      cardholderid
      lastname
      firstname
      patientgender
      dateofbirth
      address1
      address2
      city
      stateprov
      postalcode
      pharmacychain
      pharmacyname
      pharmacyaddress1
      pharmacyaddress2
      pharmacycity
      pharmacystateprov
      pharmacypostalcode
      ndc
      rxnum
      dayssupply
      drugclasscode
      medicationname
      gpi
      pdc_diab
      pdc_ras
      pdc_chol
      ;
    set to_insert;
    keep
      hpprogramid
      filerecdate
      claimdate
      cardholderid
      lastname
      firstname
      patientgender
      dateofbirth
      address1
      address2
      city
      stateprov
      postalcode
      pharmacychain
      pharmacyname
      pharmacyaddress1
      pharmacyaddress2
      pharmacycity
      pharmacystateprov
      pharmacypostalcode
      ndc
      rxnum
      dayssupply
      drugclasscode
      medicationname
      gpi
      pdc_diab
      pdc_ras
      pdc_chol
      ;
  run;
  proc contents;run;
title "ds:SYSDSN";proc print data=MOYA.ph_to_ateb(obs=5) width=minimum heading=H; run;title;
title "ds:&SYSDSN";proc print data=_LAST_(obs=5) width=minimum heading=H; run;title;
/***title 'moya';proc freq data=moya.ph_to_ateb;table MBR_CITY RX_PRESCRIPTION_ID;run;***/
/***title 'ins';proc freq data=to_insert;table city rxnum;run;***/


  %if &DEBUG ne 1 %then %do;
    %dbpassword;
    /* Make sure table is empty */
    %odbc_start(WORK, hpp_stageBEFORE, jasper);
      select *
      from analytics.healthplanclaimsfile
      ;
    %odbc_end;

    data _null_;
      dsid = open('work.hpp_stageBEFORE');
      numobs = attrn(dsid, 'NOBS');
      rc = close(dsid);
      put 'numobs is ' numobs=;
      if numobs ne 0 then do;
        put 'ERROR: table is not empty so aborting';
        abort abend 008;
      end;
    run;

    %put Loading STAGING table...;
    libname jasper ODBC dsn='jasper' schema='analytics' user=&user password=&jasperpassword insertbuff=7000;
    proc sql;
      insert into jasper.healthplanclaimsfile
      select *
      from to_insert
    quit;
  %end;

%mend excel_to_db;
%excel_to_db;
