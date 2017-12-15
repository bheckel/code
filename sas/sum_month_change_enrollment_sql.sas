options sasautos=(SASAUTOS '/Drugs/Macros' '.') mprint mprintnest validvarname=any ps=max ls=max nocenter;
/********************************************************************************
*  SAVED AS:                patient_track_priority.sas
*                                                                         
*  CODED ON:                13-Nov-17 (bheckel)
*                                                                         
*  DESCRIPTION:             ETL enrollment status for health plans and therapies
*                                                                           
*  PARAMETERS:              NONE
*
*  MACROS CALLED:           %dbpassword 
*                                                                         
*  INPUT GLOBAL VARIABLES:  NONE
*                                                                         
*  OUTPUT GLOBAL VARIABLES: NONE  
*
*  LAST REVISED:                                                          
*   13-Nov-17 (bheckel)     Initial version
********************************************************************************/
%macro patient_track_priority;
  %let ATEB_STACK=%sysget(ATEB_STACK); %put &=ATEB_STACK;
  %let ATEB_TIER=%sysget(ATEB_TIER); %put &=ATEB_TIER;
  %dbpassword;

/*TODO stored proc*/
  /* insert into dashboardclients (clientid) values (1059);*/
/*TODO*/
  libname db6 ODBC dsn='db6dev' schema='public' user=&user. password=&password.;
  %global CLIDS;
  proc sql NOprint;
    select distinct clientid into :CLIDS separated by ','
    from db6.dashboardclients
    ;
  quit;
  %put &=CLIDS;
/* %let CLIDS=17; */

  /*TODO*/
  /* libname DATA '/sasdata/Cron/Daily/patient_track_hp_therapy'; */
  libname DATA '/sasdata/Personnel/bob/DashboardETLenroll';

  %odbc_start(lib=DATA, ds=oneyr, db=db8);
    select distinct ch.clientid, st.clientstoreid, ap.pharmacypatientid, ap.atebpatientid, ia.reasonforalert, pp.patientstatusid, pp.statusmodifieddate::date, pp.lastmodified::date
    from pmap.interventionalert as ia                                                               
         join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid                        
         join client.store as st on ap.storeid=st.storeid                                           
         join client.chain as ch on ch.chainid=st.chainid                                           
         join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid                              
         join pmap.patientparticipation as pp on pp.atebpatientid=ap.atebpatientid
    where ia.reasonforalert in (
                                    'Ahold SilverScript',
                                    'Ahold United Healthcare',
                                    'Brilinta Sponsored Program',
                                    'Cigna Healthspring',
                                    'Delhaize UHC Advantage',
                                    'Freds Diabetic Patients Priority Enrollments',
                                    'Freds Humana Priority Enrollment',
                                    'Freds SilverScript',
                                    'Giant Eagle Aetna or Coventry',
                                    'Giant Eagle Anthem',
                                    'Giant Eagle Cigna',
                                    'Giant Eagle Envision',
                                    'Giant Eagle Humana',
                                    'Giant Eagle Magellan',
                                    'Giant Eagle SilverScript',
                                    'Humana',
                                    'Meijer SilverScript',
                                    'Owens Cigna/Healthspring',
                                    'Owens Coventry',
                                    'Owens Humana',
                                    'Owens SilverScript',
                                    'Owens Wellcare',
                                    'Publix Caremark SilverScript',
                                    'Publix Express Scripts',
                                    'Publix Humana',
                                    'Publix Optum',
                                    'Publix Prime Therapeutics',
                                    'Publix Wellcare',
                                    'Shrivers Cigna/Healthspring',
                                    'Shrivers Humana',
                                    'Shrivers SilverScript',
                                    'Silverscript',
                                    'Time My Meds - Priority Patient Enrollment - UnitedHealthcare',
                                    'Weis SilverScript',
                                    'Statin Gap in Care'
                                    )
          and ch.clientid in ( &CLIDS )
          and pp.patientstatusid in(3, 4, 5)
          /* and coalesce(pp.statusmodifieddate::date, pp.lastmodified::date)>='2017-07-18' */
          and coalesce(pp.statusmodifieddate::date, pp.lastmodified::date) >= date('now')-interval '1 year'
    ;
  %odbc_end;


  proc sql;
    create table lastmonth as
    select distinct clientid, clientstoreid, pharmacypatientid, atebpatientid, reasonforalert, patientstatusid,
                    sum(case when patientstatusid = 3 then 1 else 0 end) as enrolled,
                    sum(case when patientstatusid = 4 then 1 else 0 end) as optout,
                    sum(case when patientstatusid = 5 then 1 else 0 end) as unenrolled
    from DATA.oneyr 
    /* where coalesce(statusmodifieddate, lastmodified)>='18SEP2017'd and coalesce(statusmodifieddate, lastmodified)<='28SEP2017'd */
    where coalesce(statusmodifieddate, lastmodified)>=today()-60 and
          coalesce(statusmodifieddate, lastmodified)<=today()-30
    group by clientid, clientstoreid, pharmacypatientid, atebpatientid, reasonforalert, patientstatusid
    order by 6, 1, 2, 3
    ;
  quit;
/* title "&SYSDSN";proc print data=_LAST_(obs=1000) width=minimum heading=H;run;title; */
title "&SYSDSN";proc print data=_LAST_(where=(clientid=17 and clientstoreid='1610')) width=minimum heading=H;run;title;

  proc sql;
    create table thismonth as
    select distinct clientid, clientstoreid, pharmacypatientid, atebpatientid, reasonforalert, patientstatusid,
                    sum(case when patientstatusid = 3 then 1 else 0 end) as enrolled,
                    sum(case when patientstatusid = 4 then 1 else 0 end) as optout,
                    sum(case when patientstatusid = 5 then 1 else 0 end) as unenrolled
    from DATA.oneyr
    /* where coalesce(statusmodifieddate, lastmodified)>='18OCT2017'd and coalesce(statusmodifieddate, lastmodified)<='28OCT2017'd */
    where coalesce(statusmodifieddate, lastmodified)>today()-30
    group by clientid, clientstoreid, pharmacypatientid, atebpatientid, reasonforalert, patientstatusid
    order by 6, 1, 2, 3
    ;
  quit;
/* title "&SYSDSN";proc print data=_LAST_(obs=1000) width=minimum heading=H;run;title; */
title "&SYSDSN";proc print data=_LAST_(where=(clientid=17 and clientstoreid='1610')) width=minimum heading=H;run;title;


  proc sql;
    create table lm as
    select clientid, clientstoreid, reasonforalert as priorityplan, sum(enrolled) as enrolled, sum(optout) as optout, sum(unenrolled) as unenrolled
    from lastmonth
    group by clientid, clientstoreid, reasonforalert
    ;
  quit;  
  /* title "&SYSDSN";proc print data=_LAST_(obs=20) width=minimum heading=H;run;title; */
title "&SYSDSN";proc print data=_LAST_(where=(clientid=17 and clientstoreid='1610')) width=minimum heading=H;run;title;

  proc sql;
    create table tm as
    select clientid, clientstoreid, reasonforalert as priorityplan, sum(enrolled) as enrolled, sum(optout) as optout, sum(unenrolled) as unenrolled
    from thismonth
    group by clientid, clientstoreid, reasonforalert
    ;
  quit;  
  /* title "&SYSDSN";proc print data=_LAST_(obs=20) width=minimum heading=H;run;title; */
/* title "&SYSDSN";proc print data=_LAST_(where=(clientid=2 and clientstoreid='0032')) width=minimum heading=H;run;title; */
title "&SYSDSN";proc print data=_LAST_(where=(clientid=17 and clientstoreid='1610')) width=minimum heading=H;run;title;

  proc sql;
    create table mochg as
    select a.clientid, a.clientstoreid, a.priorityplan, a.enrolled, a.optout, a.unenrolled, b.enrolled as tmenr, b.optout as tmopt, b.unenrolled as tmun
    from lm a left join tm b on a.clientid=b.clientid and a.clientstoreid=b.clientstoreid and a.priorityplan=b.priorityplan
    ;
  quit;  
/* title "&SYSDSN";proc print data=_LAST_(where=(clientid=2 and clientstoreid='0032')) width=minimum heading=H;run;title; */
title "&SYSDSN";proc print data=_LAST_(where=(clientid=17 and clientstoreid='1610')) width=minimum heading=H;run;title;

  data mochg;
    set mochg;
    array nums _numeric_;
    do over nums;
      if nums eq . then nums=0;
    end;
  run;

  proc sql;
    create table diffs as
    select clientid, %rml0(clientstoreid) as clientstoreid, priorityplan, tmenr-enrolled as enrollchangethismo,
                                                                          tmopt-optout as optoutchangethismo,
                                                                          tmun-unenrolled as unenrollchangethismo
    from mochg
    ;
  quit;  
title "&SYSDSN";proc print data=_LAST_(where=(clientid=17 and clientstoreid='1610')) width=minimum heading=H;run;title;


  proc sql;
    create table oneyr0 as
    select distinct clientid, clientstoreid, pharmacypatientid, atebpatientid, reasonforalert, patientstatusid,
                    sum(case when patientstatusid = 3 then 1 else 0 end) as enrolled,
                    sum(case when patientstatusid = 4 then 1 else 0 end) as optout,
                    sum(case when patientstatusid = 5 then 1 else 0 end) as unenrolled
    from DATA.oneyr
    where coalesce(statusmodifieddate, lastmodified)>='18JUL2017'd
    /* where coalesce(statusmodifieddate, lastmodified)>=select date('now') - interval '1 year' */
    group by clientid, clientstoreid, pharmacypatientid, atebpatientid, reasonforalert, patientstatusid
    ;
  quit;
title "&SYSDSN";proc print data=_LAST_(where=(clientid=17 and clientstoreid='1610')) width=minimum heading=H;run;title;

  proc sql;
    create table oneyr as
    select clientid, %rml0(clientstoreid) as clientstoreid, reasonforalert as priorityplan, sum(enrolled) as enrolled, sum(optout) as optout, sum(unenrolled) as unenrolled
    from oneyr0
    group by clientid, clientstoreid, reasonforalert
    ;
  quit;  
title "&SYSDSN";proc print data=_LAST_(where=(clientid=17 and clientstoreid='1610')) width=minimum heading=H;run;title;

  proc sql;
    create table final as
    select a.*, b.enrollchangethismo, b.optoutchangethismo, b.unenrollchangethismo
    from oneyr a left join diffs b on a.clientid=b.clientid and a.clientstoreid=b.clientstoreid and a.priorityplan=b.priorityplan
    ;
  quit;  
title "&SYSDSN";proc print data=_LAST_(where=(clientid=17 and clientstoreid='1610')) width=minimum heading=H;run;title;

  data final_insert;
    set final;
    format measurementdate date.;

    measurementdate=today();

    array nums _numeric_;
    do over nums;
      if nums eq . then nums=0;
    end;
  run;

  proc sort data=final_insert NOdupkey; by clientid clientstoreid priorityplan; run;
title "&SYSDSN";proc print data=_LAST_(where=(clientid=17 and clientstoreid='1610')) width=minimum heading=H;run;title;


/*TODO*/
  libname db6 ODBC dsn='db6dev' schema='public' user=&user. password=&jasperpassword.;
  proc sql;
    insert into db6.enrollchgdashboard (clientid, clientstoreid, priorityplan, enrolled, optout, unenrolled, enrollchangethismo, optoutchangethismo, unenrollchangethismo, measurementdate)
    select * from final_insert
    ;
  quit;
%mend;
%patient_track_priority;
