options sasautos=(SASAUTOS '/Drugs/Macros' '.') mprint mprintnest validvarname=any;
/********************************************************************************
*  SAVED AS:                SEG_priority_enrollment_task.sas
*                                                                         
*  CODED ON:                20-Oct-17 (bheckel)
*                                                                         
*  DESCRIPTION:             Generate tasks based on most recent texfile
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
********************************************************************************/
%let ATEB_STACK=%sysget(ATEB_STACK); %put &=ATEB_STACK;
%let ATEB_TIER=%sysget(ATEB_TIER); %put &=ATEB_TIER;
%dbpassword;
%put NOTE: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;
%let _start=%sysfunc(datetime());
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
  /* %odbc_start(lib=work, ds=tasks_other_tmmpri, db=db8); */
  /*   select ap.atebpatientid */
  /*   from pmap.interventionalert as ia */
  /*        join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid */
  /*        join client.store as st on ap.storeid=st.storeid */
  /*        join client.chain as ch on ch.chainid=st.chainid */ 
  /*        join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid */
  /*   where alertstatusid=1 and ia.actioncodeid in( select distinct actioncodeid */
  /*                                                 from pmap.actioncode */ 
  /*                                                 where code ilike 'TMM_ENROLL_PRI%') */
  /*         and ch.clientid=&clid and ia.reasonforalert != 'Manatee County Priority Enrollment' */
  /* %odbc_end; */

  %if %sysfunc(fileexist("&path./&cl_foldername./ExternalFile/PE/*.csv")) %then %do; 
    %put NOTE: CSV file exists in &path./&cl_foldername./ExternalFile/PE/;
    filename FINDPIPE PIPE "find &path./&cl_foldername./ExternalFile/PE/ -type f";

    data _null_;
      infile FINDPIPE PAD;
      input fn $200.;
      if _N_ eq 1 then call symput('FNM', fn);
    run;
  %end;
  %else %do;
    %put NOTE: &path./&cl_foldername./ExternalFile/PE/ has no CSV files;
    %goto NONEWDATA;
  %end;

  %let FNMQ=%sysfunc(prxchange(s/ /\\ /, -1, &fnm));
  %put &=FNMQ;

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

  /* SEG's file contains stores that don't exist */
  %odbc_start(lib=work, ds=stores, db=db8) 
    select trim(leading '0' from st.clientstoreid) as clientstoreid
    from client.store as st join client.chain as ch on st.chainid=ch.chainid
    where ch.clientid=&clid and openflag=true;
  %odbc_end;

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

  %odbc_start(lib=work, ds=pats, db=db8);
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
    from segfile_read a left join pats b on a.lastname=b.lastname and a.firstname=b.firstname and a.dob=b.dateofbirth 
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
      where atebpatientid not in ( select distinct atebpatientid from tmm_enrolled_optout_unenrolled )
      ;
  quit;

  proc export outfile="&path./&sp_name./&cl_foldername./&job_type./&daten_exec./Output/&sname._SEGPRIADD&SYSJOBID._&daten_exec..csv" data=finaladd dbms=dlm replace;
    delimiter='|';
    putnames=no;
  run;

  /*TODO*/
  %submit_file(fn=&path./&sp_name./&cl_foldername./&job_type./&daten_exec./Output/&sname._SEGPRIADD&SYSJOBID._&daten_exec..csv, dir=~/tmp/mnt/nfs/alertproc);

  data _null_;
    rc=system("mv &FNMQ &path./&cl_foldername./ExternalFile/PE/processed/SEG_input_&SYSDATE._&SYSJOBID..csv");
    put rc=;
  run;


%NONEWDATA:

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
          /*TODO*/
          /* and ch.clientid=&clid and ia.reasonforalert = 'Manatee County Priority Enrollment' */
          and ch.clientid=&clid and ia.reasonforalert = 'Time My Meds - Priority Patient Enrollment - UnitedHealthcare'
  %odbc_end;
 
  proc sql;
    create table existing_to_delete as
    select distinct *
    from existing_segtasks
    where atebpatientid in ( select atebpatientid from tmm_enrolled_optout_unenrolled )
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

  %nobs(ds=finaldelete);

  %if &nobs gt 0 %then %do;
    proc export outfile="&path./&sp_name./&cl_foldername./&job_type./&daten_exec./Output/&sname._SEGPRIDEL&SYSJOBID._&daten_exec..csv" data=finaldelete dbms=dlm replace;
      delimiter='|';
      putnames=no;
    run;

    /*TODO*/
    %submit_file(fn=&path./&sp_name./&cl_foldername./&job_type./&daten_exec./Output/&sname._SEGPRIDEL&SYSJOBID._&daten_exec..csv, dir=~/tmp/mnt/nfs/alertproc);
  %end;

  %put _user_;
%mend;
%seg_priority_enrollment_task;
