options sasautos=(SASAUTOS '/Drugs/Macros' '.') mprint mprintnest validvarname=any;
/********************************************************************************
*  SAVED AS:                SEG_priority_enrollment_task.sas
*                                                                         
*  CODED ON:                20-Oct-17 (bheckel)
*                                                                         
*  DESCRIPTION:             Generate tasks based on most recent .CSV texfile in
*                           T:\TMMEligibility\WinnDixie\ExternalFile\PE
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
*   20-Oct-17 (bheckel)     Initial version
*   08-Nov-17 (bheckel)     New input file format
********************************************************************************/
/* 40 03 * * 5 $SAS_COMMAND -sysin /sasdata/Cron/Weekly/SEGPriorityEnrollment/SEG_priority_enrollment_task.sas -log /sasdata/Cron/Weekly/SEGPriorityEnrollment/SEG_priority_enrollment_task.log -print /sasdata/Cron/Weekly/SEGPriorityEnrollment/SEG_priority_enrollment_task.lst */
%let ATEB_STACK=%sysget(ATEB_STACK); %put &=ATEB_STACK;
%let ATEB_TIER=%sysget(ATEB_TIER); %put &=ATEB_TIER;
%dbpassword;
%put NOTE: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;
%put NOTE: %sysfunc(getoption(SYSIN)) started: %sysfunc(putn(%sysfunc(datetime()),DATETIME.));
%put NOTE: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;

%global date_exec job_type clid path sp_name job_type;
%let date_exec=&SYSDATE;
%let datec_exec=%sysfunc(today(),yymmddd10.);
%let daten_exec=%sysfunc(today(),yymmddn8.);
%let expiredate=%sysfunc(putn(%sysevalf("&SYSDATE"d+90),yymmddn8.));
%let job_type=PriorityTasks;
%let clid=17;

%macro seg_priority_enrollment_task;
  %options_generic;

  /* For alert processor naming convention */
  libname db8 ODBC dsn='db8' schema='client' user=&user. password=&password.;
  proc sql NOprint;
    select distinct shortname into :sname TRIMMED
    from db8.client
    where clientid = &clid
    ;
  quit;

  %odbc_start(lib=work, ds=tmm_enrolled_optout_unenrolled, db=db8) 
    select atebpatientid
    from pmap.patientparticipation a join pmap.pmapcampaign as b on a.pmapcampaignid=b.pmapcampaignid
    where a.patientstatusid in (3,4,5) and b.pmapfeatureid=1 and a.clientid=&clid
    ;
  %odbc_end;

  /* Avoid 2 or more Priority Enrollment tasks for a patient */
  %odbc_start(lib=work, ds=tasks_other_tmmpri, db=db8);
    select ap.atebpatientid
    from pmap.interventionalert as ia
         join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
         join client.store as st on ap.storeid=st.storeid
         join client.chain as ch on ch.chainid=st.chainid 
         join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
    where alertstatusid=1 and ia.actioncodeid in( select distinct actioncodeid
                                                  from pmap.actioncode 
                                                  where code ilike 'TMM_ENROLL_PRI%')
          and ch.clientid=&clid and ia.reasonforalert != 'Manatee County Priority Enrollment'
  %odbc_end;

  data tmm_enrolled_optout_un_otherpri;
    set tmm_enrolled_optout_unenrolled tasks_other_tmmpri;
  run;


  /* We should have only 0 or 1 file in directory */
  filename FINDPIPE PIPE "find &path./&cl_foldername./ExternalFile/PE/ -type f -maxdepth 1";
  data _null_;
    infile FINDPIPE PAD;
    input fn $200.;
    if _N_ eq 1 then call symput('FNM', fn);
  run;

  %let FNMQ=%sysfunc(prxchange(s/ /\\ /, -1, &FNM));
  %put &=FNMQ;

  /* If there is a new file, process it */
  %if %sysfunc(fileexist("&path./&cl_foldername./ExternalFile/PE/*.csv")) %then %do; 
    %put NOTE: CSV file exists in &path./&cl_foldername./ExternalFile/PE/;

    data segfile_read(drop=dummy:);
      infile "&FNMQ" DLM=',' DSD MISSOVER FIRSTOBS=2;

      format dob DATE.;

      input clientstoreid :$20.
            dummy1 :$20.
            dummy2 :$20.
            lastname :$40.
            firstname :$40.
            dummy3 :$20.
            dob :MMDDYY.
            ;

      clientstoreidq = quote(strip(clientstoreid), "'");
      dobq = quote(put(dob, yymmddd10.), "'");
    run;
    proc contents; run;
  %end;
  %else %if %sysfunc(fileexist("&path./&cl_foldername./ExternalFile/PE/*.xlsx")) %then %do; 
    %put NOTE: XLSX file exists in &path./&cl_foldername./ExternalFile/PE/;

    proc import datafile="&FNM" dbms=xlsx out=segfile_read; 

    data segfile_read;
      set segfile_read;
      rename 'Ptnt Dob'n = dob
             'Ptnt Ls Nm'n = lastname
             'Ptnt Fst Nm'n = firstname
      ;

      clientstoreid = strip(put('Loc Id'n, F8.));

      clientstoreidq = quote(strip('Loc Id'n), "'");
      dobq = quote(put('Ptnt Dob'n, yymmddd10.), "'");
    run;
    proc contents; run;
  %end;
  %else %do;
    %put NOTE: &path./&cl_foldername./ExternalFile/PE/ has no CSV or XLSX files;
    %goto NONEWDATA;
  %end;


  /* SEG's file may contain stores that don't exist */
  %odbc_start(lib=work, ds=stores, db=db8) 
    select trim(leading '0' from st.clientstoreid) as clientstoreid
    from client.store as st join client.chain as ch on st.chainid=ch.chainid
    where ch.clientid=&clid and openflag=true;
  %odbc_end;
/* title "&SYSDSN";proc print data=stores width=minimum heading=H;run;title; */

  /* proc sql ; select distinct clientstoreid from stores ;quit; */

  proc sql NOprint;
    select distinct clientstoreidq into :STORES separated by ','
    from segfile_read
    where clientstoreid in ( select clientstoreid from stores )
    ;

    select distinct dobq into :DOBS separated by ','
    from segfile_read
    where clientstoreid in ( select clientstoreid from stores )
    ;
  quit;
%put &=STORES;

  %odbc_start(lib=work, ds=patdemog, db=db8);
    select a.atebpatientid, a.dateofbirth, a.knowledgeofdeath, b.lastname, b.firstname, trim(leading '0' from d.clientstoreid) as clientstoreid, c.pharmacypatientid
    from patient.patientdemographic a join patient.patientname b on a.atebpatientid=b.atebpatientid
     join patient.atebpatient c on a.atebpatientid=c.atebpatientid
     join client.store as d on c.storeid=d.storeid
     join client.chain as e on d.chainid=e.chainid
     where a.clientid=&clid and clientstoreid in ( &STORES ) and a.dateofbirth in ( &DOBS ) and a.knowledgeofdeath is null
  %odbc_end;
  
  /* We don't have pharmacypatientid in the texfile */
  proc sql;
    create table segfile as
    select distinct a.*, b.pharmacypatientid, b.atebpatientid
    from segfile_read a left join patdemog b on a.lastname=b.lastname and a.firstname=b.firstname and a.dob=b.dateofbirth 
    where b.pharmacypatientid is not null and a.clientstoreid in ( select clientstoreid from stores )
    ;
  quit;

  %rm_merged_patients(atebpatientid=Y, ds=segfile);

  proc sql;
    create table finaladd as 
      select
          '' as interventionalertid,
          "&clid" as clientid, 
          clientstoreid, 
          '' as storeid_unused,
          pharmacypatientid,
          '' as atebpatientid,
          'TMM_ENROLL_PRI' as actioncode, 
          'Manatee County Priority Enrollment' as reasonforalert, 
          '' as rxnum, 
          '' as patientrxid, 
          55 as priority,
          "%sysfunc(compress(&datec_exec.,'-'))" as earliestdate, 
          'A' as transactioncode, 
          '' as pmapcampaignid, 
          '' as patientstatus, 
          '' as immfamily,
          '' as immcvx,
          '' as immmvx,
          '' as ndc,
          "&expiredate" as expirationdate,
          '' as sponsor,
          '' as storenpi,
          '' as campaigninput,
          '' as labeldata
      from segfile
      where atebpatientid not in ( select distinct atebpatientid from tmm_enrolled_optout_un_otherpri )
      ;
  quit;

  proc export outfile="&path./&sp_name./&cl_foldername./&job_type./&daten_exec./Output/&sname._SEGPRIADD&SYSJOBID._&daten_exec..csv" data=finaladd dbms=dlm replace;
    delimiter='|';
    putnames=no;
  run;

  /* %submit_file(fn=&path./&sp_name./&cl_foldername./&job_type./&daten_exec./Output/&sname._SEGPRIADD&SYSJOBID._&daten_exec..csv, dir=/mnt/nfs/alertproc); */

  data _null_;
    rc=system("mv &FNMQ &path./&cl_foldername./ExternalFile/PE/processed/SEG_input_&SYSDATE._&SYSJOBID");
    put rc=;
  run;


%NONEWDATA:
  /* Remove task for a patient who has enrolled/unenrolled/opted-out or has received a Priority Enrollment task from another program since we added it */

  %odbc_start(lib=work, ds=existing_segtasks, db=db8);
    select ap.atebpatientid, st.clientstoreid, ap.pharmacypatientid
    from pmap.interventionalert as ia
         join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
         join client.store as st on ap.storeid=st.storeid
         join client.chain as ch on ch.chainid=st.chainid 
         join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
    where alertstatusid=1 and ia.actioncodeid in( select distinct actioncodeid
                                                  from pmap.actioncode 
                                                  where code ilike 'TMM_ENROLL_PRI%')
          and ch.clientid=&clid and ia.reasonforalert = 'Manatee County Priority Enrollment'
  %odbc_end;
 
  proc sql;
    create table existing_to_delete as
    select distinct *
    from existing_segtasks
    where atebpatientid in ( select atebpatientid from tmm_enrolled_optout_un_otherpri )
    ;
  quit;

  proc sql;
    create table finaldelete as 
      select
          '' as interventionalertid,
          "&clid" as clientid, 
          clientstoreid, 
          '' as storeid_unused,
          pharmacypatientid,
          '' as atebpatientid,
          'TMM_ENROLL_PRI' as actioncode, 
          'Manatee County Priority Enrollment' as reasonforalert, 
          '' as rxnum, 
          '' as patientrxid, 
          55 as priority,
          "%sysfunc(compress(&datec_exec.,'-'))" as earliestdate, 
          'D' as transactioncode, 
          '' as pmapcampaignid, 
          '' as patientstatus, 
          '' as immfamily,
          '' as immcvx,
          '' as immmvx,
          '' as ndc,
          "&expiredate" as expirationdate,
          '' as sponsor,
          '' as storenpi,
          '' as campaigninput,
          '' as labeldata
      from existing_to_delete
      ;
  quit;

  /* Avoid SAS errors if nothing to delete today */
  %nobs(ds=finaldelete);

  %if &nobs gt 0 %then %do;
    proc export outfile="&path./&sp_name./&cl_foldername./&job_type./&daten_exec./Output/&sname._SEGPRIDEL&SYSJOBID._&daten_exec..csv" data=finaldelete dbms=dlm replace;
      delimiter='|';
      putnames=no;
    run;

    /* %submit_file(fn=&path./&sp_name./&cl_foldername./&job_type./&daten_exec./Output/&sname._SEGPRIDEL&SYSJOBID._&daten_exec..csv, dir=/mnt/nfs/alertproc); */
  %end;

  %put _user_;
%mend;
%seg_priority_enrollment_task;
