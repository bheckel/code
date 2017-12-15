options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: insert_into.sql.sas
  *
  *  Summary: Comparison of inserts under SAS vs. proc sql.
  *
  *  Created: Tue 08 Jun 2004 13:01:32 (Bob Heckel)
  * Modified: Thu 03 Dec 2015 15:55:59 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source fullstimer;


options sasautos=(SASAUTOS '/Drugs/Macros') ls=140 ps=max mprint mprintnest NOcenter validvarname=any; %dbpassword;

data t;
  infile cards dlm=',';
  input clid @@;
  cards;
17,22,55,56,123,137,142,186,187,188,189,190,192,193,201,209,314,329,424,434,445,449,589,605,606,615,623,636,648,650,651,654,656,657
662,663,668,683,684,686,689,690,691,699,702,704,754,755,756,757,758,760,761,762,764,768,769,797,805,825,829,833,834,841,847,857,879
880,882,884,895,902,909,924,931,935,939,941,950,952,953,958,963,964,965,968,969,970,1008,1010,1011,1012,1013,1015,1020,1021,1027,1033
1039,1041,1043,1048,1050,1056,1059,1060,1065,1068,1218,2,7
  ;
run;
/* title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title; */

proc sql NOprint;
  create table t2 as
  select case when independent='Y' then 't' else 'f' end as isindependent, clientid
  from FUNCDATA.clients_shortname_lookup
  ;
quit;
/* title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title; */

proc sql;
  create table t3 as
  select a.clid, b.isindependent
  from t a join t2 b on a.clid=b.clientid
  ;
quit;  
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;

proc contents data=t3; run;


libname jasper ODBC dsn='db6dev' schema='public' user=&user. password=&jasperpassword.;

proc sql;
  insert into jasper.dashboardclients ( clientid, isindependent )
  select * from t3;
quit;



%macro load_db_with_xls;
  libname MOYA '/Drugs/HealthPlans/Humana/Medicare/ExternalFiles/FromHumana/Archive/20151202';

  data to_insert;
    /* Database lengths */
    length Patient_Zip2 $10
           Target_Pharmacy_ID2 $15
           Target_Pharmacy_Zip $10
           Drug_NDC2 $11
           ;
/***    set MOYA.humana_xls(obs=1);***/
    set MOYA.humana_xls;
/***    cardholder_id='9999999';***/
    hpprogramid=5;
    filerecdate='02DEC15'd;
    /* Num to char */
    Patient_zip2 = put(Patient_zip, ? BEST. -L);
    Target_Pharmacy_ID2 = put(Target_Pharmacy_ID, ? BEST. -L);
    Drug_NDC2 = put(Drug_NDC, ? BEST. -L);
  run;
/***title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title; data;file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~';put;run;  ***/
/***proc contents data=to_insert;run;***/

    libname jasper ODBC dsn='jasper' schema='analytics' user=&user password=&jasperpassword insertbuff=7000;
    proc sql;
      insert into jasper.healthplanpatientsfile
            (hpprogramid,filerecdate,cardholderid, lastname,         firstname,         patientgender, dateofbirth,address1,               address2,               city,        stateprov,    postalcode,  pharmacyid,         pharmacyidqualifier,         pharmacyname,        pharmacyaddress,        pharmacycity,        pharmacystateprov,    pharmacypostalcode, notinplay,  notinprogram,       medicationname,drugclass, ndc,      checkval)
      select hpprogramid,filerecdate,Cardholder_ID,Patient_Last_Name,Patient_First_Name,Patient_Gender,Patient_DOB,Patient_address_field_1,Patient_address_field_2,Patient_city,Patient_State,Patient_zip2,Target_Pharmacy_ID2,Target_Pharmacy_ID_Qualifier,Target_Pharmacy_Name,Target_Pharmacy_Address,Target_Pharmacy_City,Target_Pharmacy_State,Target_Pharmacy_Zip,Not_in_Play,No_Longer_Enrolled, Drug_Name,     Drug_Class,Drug_NDC2,check
      from to_insert
      ;
    quit;
%mend load_db_with_xls;
%load_db_with_xls;



data tmp; set SASHELP.shoes; if Region in:('A', 'E'); run;

 /* Insert one single new record: */

 /* 'set' does not refer to dataset here! */
proc sql;
  insert into tmp
  set Stores = 1,
      Product = 'boot',
      Region = 'AFrica'
      ;
quit;
title 'proc sql';
proc print data=_LAST_; where Region eq: 'A'; run;

data tmp;
  set tmp end=the_end;
  if the_end then
    do;
      Stores = 1;
      Product = 'boot';
      Region = 'AFrica';
    end;
run;
title 'traditional SAS';
proc print data=_LAST_; where Region eq: 'A'; run;


 /* Several fields: */
proc sql;
  insert into analytic.membership (lname,fname,memberno,gender,dob,plan,account,client_id,load_date)
  select                           lname,fname,memberno,gender,dob,plan,account,client_id,'31JUL2010'D
  from ops.members
  where status = 'Active'
  ;
quit;


 /* For Oracle: */
 /* TODO how to nrbquote the mvars in case the string has e.g. '%foo' in it? */

%macro LoadMatl(ODataset,OUser,OPsw,OServer);
  %let TotNum=;
  data _NULL_;
    format Mfg_Dt1 Exp_Dt1 MMDDYY8. New_Mfg_Dt $24. New_Exp_Dt $24.;
    set &Odataset/*(obs=20)*/;
    TotNum+1;
    call symput('TVarA'||compress(put(_N_,5.)),left(COMPRESS(Matl_Nbr)));
    call symput('TVarB'||compress(put(_N_,5.)),left(COMPRESS(Batch_Nbr)));
    call symput('TVarC'||compress(put(_N_,5.)),left(TRIM(Matl_Desc1)));
    
    Mfg_Dt1=MDY(SUBSTR(Matl_Mfg_Dt1,4,2),SUBSTR(Matl_Mfg_Dt1,1,2),SUBSTR(Matl_Mfg_Dt1,7,4));
          Mfg_Month1=UPCASE(PUT(Mfg_Dt1,monname3.));Mfg_Day1=PUT(DAY(Mfg_Dt1),Z2.);Mfg_Year1=YEAR(Mfg_Dt1);
    Exp_Dt1=MDY(SUBSTR(Matl_Exp_Dt1,4,2),SUBSTR(Matl_Exp_Dt1,1,2),SUBSTR(Matl_Exp_Dt1,7,4));
          Exp_Month1=UPCASE(PUT(Exp_Dt1,monname3.));Exp_Day1=PUT(DAY(Exp_Dt1),Z2.);Exp_Year1=YEAR(Exp_Dt1);
    
    if Matl_Mfg_Dt1 = '00.00.0000' then
      New_Mfg_Dt="'01-JAN-60:00:00:00'DT";
    else
      New_Mfg_Dt="'"||TRIM(LEFT(Mfg_Day1))||'-'||TRIM(LEFT(Mfg_Month1))||'-'||TRIM(LEFT(Mfg_Year1))||":00:00:00'DT";
    
    if Matl_Exp_Dt1 = '00.00.0000' then
      New_Exp_Dt="'01-JAN-60:00:00:00'DT";
    else
      New_Exp_Dt="'"||TRIM(LEFT(Exp_Day1))||'-'||TRIM(LEFT(Exp_Month1))||'-'||TRIM(LEFT(Exp_Year1))||":00:00:00'DT";
    
    CALL SYMPUT('TVarD'||COMPRESS(PUT(_N_,5.)),LEFT(COMPRESS(New_Mfg_Dt)));
    CALL SYMPUT('TVarE'||COMPRESS(PUT(_N_,5.)),LEFT(COMPRESS(New_Exp_Dt)));
    CALL SYMPUT('TVarF'||COMPRESS(PUT(_N_,5.)),LEFT(COMPRESS(Matl_Typ1)));
/***put _all_;	***/
    CALL SYMPUT('TotNum',TotNum);
  RUN;

  %IF %SUPERQ(TotNum)^= %THEN %DO;
  libname LOADORACLE oracle user=&OUser password=&OPsw path="&OServer";

  PROC SQL;
    %DO I=1 %TO &TotNum;
      INSERT INTO LOADORACLE.LINKS_MATERIAL
      (Matl_Nbr,    Batch_Nbr,   Matl_Desc,   Matl_Mfg_Dt, Matl_Exp_Dt, Matl_Typ)
      VALUES ("&&TVarA&i", "&&TVarB&i", "&&TVarC&i", &&TVarD&i, &&TVarE&i, "&&TVarF&i");
    %END;
  QUIT;
  %END;
%mend LoadMatl;
