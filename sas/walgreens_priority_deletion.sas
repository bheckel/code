/********************************************************************************
*  SAVED AS:                /Drugs/Cron/Hourly/Walgreens_Deletions/walgreens_priority_deletion.sas
*                                                                         
*  CODED ON:                09-Feb-16 (bheckel)
*                                                                         
*  DESCRIPTION:             Save current cepatientstaging table to WORK.
*
*                           Query patientparticipation tables and set soft-delete flag if any 
*                           of these conditions are true:
*
*                           1- If over 25/week or 100/mo enrollments in one store,
*                              soft-delete all patients for that clientstoreid
*                           2- Previously enrolled, unenrolled or opted-out atebpatientid
*                           3- Patient's phone number is null
*                           4- Patient previously contacted 3 or more times
*                           5- Patient received a call with voicemail left
*
*                           Compare with WORK cepatientstaging dataset:
*
*                           1-If atebpatientid is in softdelete dataset and not in cepatientstaging
*                             dataset, append to cepatientstaging dataset
*                           2-If atebpatientid is in both as soft-deleted, do nothing
*                           3-If atebpatientid in softdelete dataset but cepatientstaging has it
*                             as not soft-deleted then update flag to softdelete
*
*                           Perform a truncation of cepatientstaging.
*
*                           Insert this final dataset (with same # obs as the truncation) into 
*                           cepatientstaging table
*
*  PARAMETERS:              NONE
*
*  MACROS CALLED:           %dbpassword, %build_long_in_list, %options_wag_deletions
*                                                                         
*  INPUT GLOBAL VARIABLES:  NONE
*                                                                         
*  OUTPUT GLOBAL VARIABLES: NONE  
*                                                                         
*  LAST REVISED:                                                          
*       18-Feb-16 (bheckel) Initial version
*       25-Feb-16 (bheckel) Add criteria 5
*       18-Mar-16 (bheckel) Add ccereasonforcallid eq 1 criteria
*                           Add %options_wag_deletions
*       21-Mar-16 (bheckel) Improve log notifications
*       29-Apr-16 (bheckel) Modify logic - change to 3+ previous contacts
*                           Maintain original data in cepatientstaging table
*                           by updating
********************************************************************************/
 /* 02 06,20 * * * $SAS_COMMAND -sysin /sasdata/Cron/Hourly/Walgreens_Deletions/walgreens_priority_deletion.sas -log /sasdata/Cron/Hourly/Walgreens_Deletions/walgreens_priority_deletion.log -print /sasdata/Cron/Hourly/Walgreens_Deletions/walgreens_priority_deletion.lst */
%macro walgreens_priority_deletion;
  options sasautos=(SASAUTOS '/Drugs/Macros' '.') ls=159 ps=max mprint validvarname=any mprintnest nosgen;

  %let DEBUG=1;  /* 0==delete/update db */

  %let clid=2000000;
  %let maxweeklypats=25;
  %let maxmonthlypats=100;
  %let date_max=&SYSDATE;
  %let job_type=Studies;
  %let thispgm=%sysfunc(getoption(SYSIN));

  %options_wag_deletions;

  libname jasper ODBC dsn='db6' schema='cce' user=&user. password=&jasperpassword.;

  data DATA.ccecallrequest;
    set jasper.ccecallrequest;
    /* TMMENROLLMENT calls, not TMMCONFIRMATION calls */
    if clientid eq &clid and softdeletedate eq . and ccereasonforcallid eq 1;
  run;


  proc sql;
    connect to odbc as myconn (user=&user password=&password dsn='db103' readbuff=7000);

    create table DATA.tmm345 as select * from connection to myconn (

      select pp.clientid, st.storeid, st.clientstoreid, pp.atebpatientid, pp.statusmodifieddate, pp.patientstatusid
      from pmap.patientparticipation as pp
         join patient.atebpatient ap on pp.atebpatientid=ap.atebpatientid
         join client.store as st on st.storeid=ap.storeid
         join pmap.pmapcampaign as pc on pc.pmapcampaignid=pp.pmapcampaignid
      where pp.clientid=&clid and pc.pmapfeatureid=1 and pp.patientstatusid in(3,4,5)
         and pp.statusmodifieddate >= date('now')-interval '1 month'
         ;

       );

    disconnect from myconn;
  quit;
%put !!!&SQLRC &SQLOBS;
/***title "&SYSDSN 3 only";proc print data=DATA.tmm345(obs=1000 where=(patientstatusid=3)) width=minimum heading=H NOobs;run;title;***/

  %if &SQLRC ne 0 %then %do;
    %put ERROR: Query of pmap.patientparticipation failed;
    filename MAILTHIS email ('bob.heckel@taeb.com') subject="Error during &thispgm execution";
    data _null_; file MAILTHIS; put; run;
    abort abend;
  %end;

/* DEBUG */
  /*
proc sql;
  title '3,4,5';
  select clientstoreid, count(*)
  from l.tmm345
  group by clientstoreid
  order by clientstoreid
  ;
  title 'enrolled this week';
  select clientstoreid, put(datepart(statusmodifieddate), DATE9.) as dtlastmodified, count(*) as thisweektot
  from l.tmm345
  where patientstatusid=3 and week(datepart(statusmodifieddate), 'W')=week("&SYSDATE"d, 'W')
  group by clientstoreid, 2
  order by clientstoreid
  ;
  title 'enrolled this month';
  select clientstoreid, put(datepart(statusmodifieddate), MONTH.) as dtlastmodified, count(*) as thismonthtot
  from l.tmm345
  where patientstatusid=3 and month(datepart(statusmodifieddate))=month("&SYSDATE"d)
  group by clientstoreid, 2
  order by clientstoreid
  ;
  title;
quit;
  */

  /* Prepare proc append for a potentially 0 observation run with an empty data set */
  proc sql;
    create table tosoftdelete as 
    select &clid. as clientid,
       clientstoreid format $20. length  20, 
       atebpatientid,
       today() as startdate format date9.,
       today()+8 as enddate format date9.,
       1000000 as ranking,
       &clid as pmapcampaignid,
       '                              ' as criteria,
       0 as softdeleteflag
    from DATA.ccecallrequest(obs=0)
    ;
  quit;


  /********** 1.  25 patients enrolled per week per store or 100 patients enrolled per month per store *********/
  data; file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 1. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~';put;run;
  data tmm3;
    set DATA.tmm345;
    if patientstatusid eq 3;  /* Enrolled */
    /* Mon thru Sun */
    weeknum=week(datepart(statusmodifieddate), 'W');
    monthnum=month(datepart(statusmodifieddate));
  run;

  proc sql;
    create table weekcnt as
    select clientstoreid, weeknum, count(atebpatientid) as wkcntaid
    from tmm3
    where week(datepart(statusmodifieddate), 'W')=week("&SYSDATE"d, 'W')
    group by clientid, clientstoreid, weeknum
    ;
  quit;
title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;run;title; data;

  proc sql;
    create table monthcnt as
    select clientstoreid, monthnum, count(atebpatientid) as mocntaid
    from tmm3
    where month("&SYSDATE"d)=monthnum
    group by clientid, clientstoreid, monthnum
    ;
  quit;
title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;run;title; data;

  /* Gather clientstoreids where the threshold has been exceeded for the week (to soft-delete their patients) */
  %let csidweeklist=; %let csidweeklistq=;
  proc sql NOprint;
    select distinct clientstoreid into :csidweeklist separated by ','
    from weekcnt
    where (wkcntaid > &maxweeklypats) and (week("&SYSDATE"d, 'W') = weeknum)
    ;
  quit;

  /* Gather clientstoreids where the threshold has been exceeded for the month (to soft-delete their patients) */
  %let csidmonthlist=; %let csidmonthlistq=;
  proc sql NOprint;
    select distinct clientstoreid into :csidmonthlist separated by ','
    from monthcnt
    where (mocntaid > &maxmonthlypats) and (month("&SYSDATE"d) = monthnum)
    ;
  quit;


  /* Week soft-deletions are required */
  %if "&csidweeklist" ne "" %then %do;
    data _null_;
      call symput('csidweeklistq', catq('1AC', &csidweeklist));
    run;

    %put NOTE: 1a. &maxweeklypats patient week threshold exceeded, patients from clientstoreid &csidweeklistq will be softdeleted;

    proc sql;
      create table tosoftdelete1a as 
      select &clid. as clientid,
         clientstoreid format $20. length  20, 
         atebpatientid,
         today() as startdate format date9.,
         today()+8 as enddate format date9.,
         1000000 as ranking,
         &clid as pmapcampaignid,
         'week exceeded' as criteria,
         1 as softdeleteflag
      from DATA.ccecallrequest
      where clientstoreid in ( &csidweeklistq )
      ;
    quit;
    proc sort data=tosoftdelete1a NOdupkey; by atebpatientid; run;
    title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;
    proc append base=tosoftdelete data=tosoftdelete1a FORCE; run;
  %end;
  %else %do;
    %put NOTE: 1a. Count per week of &maxweeklypats not reached, no deletions;
  %end;


  /* Month soft-deletions are required */
  %if "&csidmonthlist" ne "" %then %do;
    data _null_;
      call symput('csidmonthlistq', catq('1AC', &csidmonthlist));
    run;

    %put NOTE: 1b. &maxmonthlypats patient month threshold exceeded, patients from clientstoreid &csidmonthlistq will be softdeleted;

    proc sql;
      create table tosoftdelete1b as 
      select &clid. as clientid,
         clientstoreid format $20. length  20, 
         atebpatientid,
         today() as startdate format date9.,
         today()+8 as enddate format date9.,
         1000000 as ranking,
         &clid as pmapcampaignid,
         'month exceeded' as criteria,
         1 as softdeleteflag
      from DATA.ccecallrequest
      where clientstoreid in ( &csidmonthlistq )
      ;
    quit;
    proc sort data=tosoftdelete1b NOdupkey; by atebpatientid; run;
    title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;
    proc append base=tosoftdelete data=tosoftdelete1b FORCE; run;
  %end;
  %else %do;
    %put NOTE: 1b. Count per month of &maxmonthlypats not reached, no deletions;
  %end;
  /********************************************************************************************************/


  /************* 2.  Patient Enrolled (3), Opted-Out (4) or Un-Enrolled (5) in the last month *************/
  data; file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 2. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~';put;run;

  %build_long_in_list(ds=DATA.tmm345, var=atebpatientid, type=num);

  %put NOTE: 2. tmm345 count &nitems;
  %if &nitems ne 0 %then %do;
    proc sql;
      create table tosoftdelete2 as 
      select &clid. as clientid,
         clientstoreid format $20. length  20, 
         atebpatientid,
         today() as startdate format date9.,
         today()+8 as enddate format date9.,
         1000000 as ranking,
         &clid as pmapcampaignid,
         'already 3,4,5' as criteria,
         1 as softdeleteflag
      from DATA.ccecallrequest
      where atebpatientid in ( %long_in_list )
      ;
    quit;

    proc sql;
      select count(*) into :cntsoft2
      from tosoftdelete2
      ;
    quit;
    %if &cntsoft2 ne 0 %then %do;
      %put NOTE: 2. Found Enrolled, Opt-Out, Un-Enrolled patients to be soft-deleted;

      proc sort data=tosoftdelete2 NOdupkey; by atebpatientid; run;
      title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;
      proc append base=tosoftdelete data=tosoftdelete2 FORCE; run;
    %end;
    %else %do;
      %put NOTE: 2. No patients 3,4,5 found to soft-delete;
    %end;
  %end;
  /********************************************************************************************************/


  /***************************** 3.  Phone number is null *************************************************/
  data; file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 3. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~';put;run;

  %build_long_in_list(ds=DATA.ccecallrequest, var=atebpatientid, type=num);

  proc sql;
    connect to odbc as myconn (user=&user password=&password dsn='db103' readbuff=7000);

    create table patientcontact as select * from connection to myconn (

      select distinct atebpatientid, phonenum
      from patient.patientcontact
      where clientid=&clid and atebpatientid in ( %long_in_list )
      ;

       );

    disconnect from myconn;
  quit;
%put !!!&SQLRC &SQLOBS;

  %if &SQLRC ne 0 %then %do;
    %put ERROR: Query of patient.patientcontact failed;
    filename MAILTHIS email ('bob.heckel@taeb.com') subject="Error during &thispgm execution";
    data _null_; file MAILTHIS; put; run;
    abort abend;
  %end;

  proc sql;
    create table nullphones as 
    select distinct a.atebpatientid, b.phonenum
    from DATA.ccecallrequest a left join patientcontact b  on a.atebpatientid=b.atebpatientid
    where b.phonenum is null
    ;
  quit;

  %build_long_in_list(ds=nullphones, var=atebpatientid, type=num);

  %put NOTE: 3. nullphones count &nitems;
  %if &nitems ne 0 %then %do;
    %put NOTE: 3. Found NULL phonenum, soft-deleting atebpatientid;

    proc sql;
      create table tosoftdelete3 as 
      select &clid. as clientid,
         clientstoreid format $20. length  20, 
         atebpatientid,
         today() as startdate format date9.,
         today()+8 as enddate format date9.,
         1000000 as ranking,
         &clid as pmapcampaignid,
         'phone num null' as criteria,
         1 as softdeleteflag
      from DATA.ccecallrequest
      where atebpatientid in ( %long_in_list )
      ;
    quit;
    proc sort data=tosoftdelete3 NOdupkey; by atebpatientid; run;
    title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title; data;file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~';put;run;
    proc append base=tosoftdelete data=tosoftdelete3 FORCE; run;
  %end;
  %else %do;
    %put NOTE: 3. No patients with NULL phonenum to soft-delete;
  %end;
  /********************************************************************************************************/


  /***************************** 4.  Previously contacted 3+ times *************************************************/
  data; file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 4. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~';put;run;
  proc sql;
    connect to odbc as myconn (user=&user password=&jasperpassword dsn='db6' readbuff=7000);

    create table prevcontacts as select * from connection to myconn (

      select atebpatientid
      from cce.ccepatientcontact
      where ccecallresultid in (select distinct ccecallresultid from cce.ccecallresult where livecallflag=true)
      group by atebpatientid
      having count(*)>2
      ;

       );

    disconnect from myconn;
  quit;
%put !!!&SQLRC &SQLOBS;

  %if &SQLRC ne 0 %then %do;
    %put ERROR: Query of cce.ccepatientcontact failed;
    filename MAILTHIS email ('bob.heckel@ateb.com') subject="Error during &thispgm execution";
    data _null_; file MAILTHIS; put; run;
    abort abend;
  %end;

  %build_long_in_list(ds=prevcontacts, var=atebpatientid, type=num);

  %put NOTE: 4. prevcontacts count &nitems;
  %if &nitems ne 0 %then %do;
    proc sql;
      create table tosoftdelete4 as 
      select &clid. as clientid,
         clientstoreid format $20. length  20, 
         atebpatientid,
         today() as startdate format date9.,
         today()+8 as enddate format date9.,
         1000000 as ranking,
         &clid as pmapcampaignid,
         'contacted 3+' as criteria,
         1 as softdeleteflag
      from DATA.ccecallrequest
      where atebpatientid in ( %long_in_list )
      ;
    quit;

    proc sql;
      select count(*) into :cntsoft4
      from tosoftdelete4
      ;
    quit;
    %if &cntsoft4 ne 0 %then %do;
      %put NOTE: 4. Found previously contacted, soft-deleting atebpatientid;
      proc sort data=tosoftdelete4 NOdupkey; by atebpatientid; run;
      title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title; data;file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~';put;run;
      proc append base=tosoftdelete data=tosoftdelete4 FORCE; run;
    %end;
    %else %do;
      %put NOTE: 4. No previously contacted found;
    %end;
  %end;
  /********************************************************************************************************/


  /***************************** 5.  Previously voicemailed *************************************************/
  data; file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 5. ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~';put;run;

  /* 11 = "Agent dialed telephone number and was able to leave a message for the patient" */
  proc sql;
    connect to odbc as myconn (user=&user password=&jasperpassword dsn='db6' readbuff=7000);

    create table prevvoicemail as select * from connection to myconn (

      select atebpatientid, ccecallresultid
      from cce.ccepatientcontact
      where ccecallresultid = 11
      ;

       );

    disconnect from myconn;
  quit;
%put !!!&SQLRC &SQLOBS;

  %if &SQLRC ne 0 %then %do;
    %put ERROR: Query of cce.ccepatientcontact failed;
    filename MAILTHIS email ('bob.heckel@taeb.com') subject="Error during &thispgm execution";
    data _null_; file MAILTHIS; put; run;
    abort abend;
  %end;

  proc sql;
    create table prevvoicemailfound as
    select distinct a.atebpatientid
    from patientcontact a left join prevvoicemail b  on a.atebpatientid=b.atebpatientid
    where b.atebpatientid is not null
    ;
  quit;

  %build_long_in_list(ds=prevvoicemailfound, var=atebpatientid, type=num);

  %put NOTE: 5. prevvoicemailfound count &nitems;
  %if &nitems ne 0 %then %do;
    proc sql;
      create table tosoftdelete5 as 
      select &clid. as clientid,
         clientstoreid format $20. length  20, 
         atebpatientid,
         today() as startdate format date9.,
         today()+8 as enddate format date9.,
         1000000 as ranking,
         &clid as pmapcampaignid,
         'previously voicemailed' as criteria,
         1 as softdeleteflag
      from DATA.ccecallrequest
      where atebpatientid in ( %long_in_list )
      ;
    quit;

    proc sql;
      select count(*) into :cntsoft5
      from tosoftdelete5
      ;
    quit;
    %if &cntsoft5 ne 0 %then %do;
      %put NOTE: 5. Found previously voice-mailed, soft-deleting atebpatientid;
      proc sort data=tosoftdelete5 NOdupkey; by atebpatientid; run;
      title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title; data;file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~';put;run;
      proc append base=tosoftdelete data=tosoftdelete5 FORCE; run;
    %end;
    %else %do;
      %put NOTE: 5. No previously voice-mailed;
    %end;
  %end;
  /********************************************************************************************************/


  /**************************** Update against existing table data ****************************************/
  data; file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ update ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~';put;run;
  /* Patient may be a softdelete candidate due to more than one criteria, only take 1 */
  proc sort data=tosoftdelete NOdupkey; by atebpatientid; run;

  proc sql;
    select count(*) into :cntsoftdel
    from tosoftdelete
    ;
  quit;

  %if &cntsoftdel eq 0 %then %do;
    %put WARNING: No soft-deletions required;
    %goto NODATA;
  %end;

  proc sql;
    create table DATA.prev_ccepatientstaging as
    select clientid, atebpatientid, startdate, enddate, ranking, pmapcampaignid, softdeleteflag from jasper.cepatientstaging;
  quit;

  /* On tosoft not cce */
/***  proc sql;***/
/***    create table compare1a as***/
/***    select a.****/
/***    from tosoftdelete a left join DATA.prev_ccepatientstaging b on a.atebpatientid=b.atebpatientid***/
/***    where b.atebpatientid is null***/
/***    ;***/
/***  quit;***/
  proc sql;
    create table on_cce_not_tosoftdel as
    select a.*
    from DATA.prev_ccepatientstaging a left join tosoftdelete b on a.atebpatientid=b.atebpatientid
    where b.atebpatientid is null
    ;
  quit;

  proc sql;
    select count(*) into :cntsoftdel
    from on_cce_not_tosoftdel
    ;
  quit;

  data final_to_insert;
    set tosoftdelete on_cce_not_tosoftdel;
  run;

/*DEBUG*/
proc sql;
/***select * from data.prev_ccepatientstaging a left join final b on a.atebpatientid=b.atebpatientid where a.atebpatientid is null;***/
/***select * from data.prev_ccepatientstaging a left join tosoftdelete b on a.atebpatientid=b.atebpatientid where a.atebpatientid is null;***/
  select count(*) from final_to_insert;
  select atebpatientid from final_to_insert group by atebpatientid having count(*)>1;
quit;
  /********************************************************************************************************/


  %if &DEBUG eq 0 %then %do;
    proc sql;
      delete from jasper.cepatientstaging;
    quit;

    proc sql;
      insert into jasper.cepatientstaging (clientid, atebpatientid, startdate, enddate, ranking, pmapcampaignid, softdeleteflag)
      select * from final_to_insert(drop= clientstoreid criteria);
    quit;
  %end;

  data DATA.final_to_insert; set final_to_insert; run;

  %NODATA:
%mend walgreens_priority_deletion;
%walgreens_priority_deletion;
