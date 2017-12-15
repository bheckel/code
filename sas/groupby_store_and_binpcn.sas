options sasautos=(SASAUTOS '/Drugs/Macros' '.') ls=180 ps=max mprint mprintnest validvarname=any;

%macro m(maxdate, period);
  /* options obs=25000; */
  libname build '/Drugs/TMMEligibility/Wakefern/Studies/20170314/Data';

  /********* Initial criteria ************/
  proc sql;
    create table all as
    select distinct cats(storeid,pharmacypatientid) as UPID, storeid, age, ndc, filldate, catx('/',bin,pcn) as binpcn
    from build.rxfilldata
    where age >= 65
      and cats(bin,pcn)  in ('004336MEDDADV','610029CRK','017010CIHSCARE','01558103200000','003858MD','016499HMOPOSNJ','016499HMOPOSNJG','016499PPONJG','016499PDPNJ')
      and filldate >= &maxdate
  /* and storeid eq '0835' */
  /* and cats(storeid,pharmacypatientid) <> '08352228723' */
    ;
  quit;
  /* title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;where upid='08352228723';run;title; */

  proc sql;
    create table diab as
    select distinct cats(storeid,pharmacypatientid) as UPID, storeid, age, ndc, filldate, catx('/',bin,pcn) as binpcn
    from build.rxfilldata
    where age >= 65
      and ndc in(select ndc from funcdata.pqa_medlist where diabetes=1)
      and cats(bin,pcn)  in ('004336MEDDADV','610029CRK','017010CIHSCARE','01558103200000','003858MD','016499HMOPOSNJ','016499HMOPOSNJG','016499PPONJG','016499PDPNJ')
      and filldate >= &maxdate
  /* and storeid eq '0835' */
  /* and cats(storeid,pharmacypatientid) <> '08352228723' */
    ;
  quit;
  /* proc sql; select min(filldate) as min12 format=date9., max(filldate) as max12 format=date9. from diab; quit; */
  /* title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;where upid='08352228723';run;title; */

  proc sql;
    create table stat as
    select distinct cats(storeid,pharmacypatientid) as UPID, storeid, age, ndc, filldate, catx('/',bin,pcn) as binpcn
    from build.rxfilldata
    where age >= 65
      and ndc in(select ndc from funcdata.pqa_medlist where statin=1)
      and cats(bin,pcn)  in ('004336MEDDADV','610029CRK','017010CIHSCARE','01558103200000','003858MD','016499HMOPOSNJ','016499HMOPOSNJG','016499PPONJG','016499PDPNJ')
      and filldate >= &maxdate
  /* and storeid eq '0835' */
  /* and cats(storeid,pharmacypatientid) <> '08352228723' */
    ;
  quit;
  /* title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title; */ 
  /* title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;where upid='08352228723';run;title; */
  /***************************************/


  /************* Unique ************/
  /***1 ***/
  proc sql;
    create table all2 as
    select distinct UPID, storeid, binpcn
    from all
    ;
  quit;
  /*******/
/* title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title; */  
  /* title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;where storeid='0105';run;title; */

  /*** 2 ***/
  proc sql;
    create table diab2 as
    select distinct UPID, storeid, binpcn
    from diab
    ;
  quit;
  /*******/

  /*** 3 ***/
  proc sql;
    create table diabonly as
    select a.UPID, a.age, a.storeid, a.ndc as diabetes, b.ndc as statin, a.filldate format=date9. as fa, a.binpcn
    from diab a left join stat b on a.UPID=b.UPID
    where b.UPID is null
    ;
  quit;
  /* title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;where upid='08352228723';run;title; */
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;where storeid='0105';run;title;

  proc sql;
    create table diabonly2 as
    select distinct UPID, storeid, binpcn
    from diabonly
    ;
  quit;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;where storeid='0105';run;title;
  /* title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;where upid='08352228723';run;title; */
  /*******/
  /*********************************/


   /*************** 1) Just patients for these plans ******************/
  proc sql;
    create table cnt_all_&period as
    select storeid as 'Store ID'n, binpcn as 'BIN/PCN'n, count(*) as Count
    from all2
    group by storeid, binpcn
    order by storeid, binpcn
    ;
  quit;
  /* title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;where 'Store ID'n='0105';run;title; */
   /*******************************************************************/

   /*************** 2) Just patients for these plans with oral diabetic fill ******************/
  proc sql;
    create table cnt_diab_&period as
    select storeid as 'Store ID'n, binpcn as 'BIN/PCN'n, count(*) as Count
    from diab2
    group by storeid, binpcn
    order by storeid, binpcn
    ;
  quit;
  /* title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;where 'Store ID'n='0835';run;title; */
   /*******************************************************************************************/

   /*************** 3) Patients on these plans with oral diabetic fill without ******************/
  proc sql;
    create table cnt_diabonly2_&period as
    select storeid as 'Store ID'n, binpcn as 'BIN/PCN'n, count(*) as Count
    from diabonly2
    group by storeid, binpcn
    order by storeid, binpcn
    ;
  quit;
  /* title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;where 'Store ID'n='0835';run;title; */
/* title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title; */  
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;where 'Store ID'n='0105';run;title;
   /*********************************************************************************************/
%mend;
%m(%str('16SEP2016'd), 6mo);
%m(%str('16SEP2000'd), 12mo);


ods excel file="/Drugs/RFD/2017/03/AN-6986/Reports/AN-6986_patients_for_these_plans_binpcn.xlsx";
  ods excel options(sheet_name="6 mo lookback");
  proc print data=cnt_all_6mo NOobs; sum count; run;
  ods excel options(sheet_name="12 mo lookback");
  proc print data=cnt_all_12mo NOobs; sum count; run;
ods excel close;
ods excel file="/Drugs/RFD/2017/03/AN-6986/Reports/AN-6986_patients_for_these_plans_with_diab_binpcn.xlsx";
  ods excel options(sheet_name="6 mo lookback");
  proc print data=cnt_diab_6mo NOobs; sum count; run;
  ods excel options(sheet_name="12 mo lookback");
  proc print data=cnt_diab_12mo NOobs; sum count; run;
ods excel close;
ods excel file="/Drugs/RFD/2017/03/AN-6986/Reports/AN-6986_patients_for_these_with_diab_only_binpcn.xlsx";
  ods excel options(sheet_name="6 mo lookback");
  proc print data=cnt_diabonly2_6mo NOobs; sum count; run;
  ods excel options(sheet_name="12 mo lookback");
  proc print data=cnt_diabonly2_12mo NOobs; sum count; run;
ods excel close;
