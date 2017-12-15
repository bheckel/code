  /********************************************************************************
  *  SAVED AS:                tmm_run_check.sas 
  *                                                                         
  *  CODED ON:                22-Mar-17 by Bob Heckel
  *                                                                         
  *  DESCRIPTION:             Conditionally run TMM eligibility list build & import
  *
  *  PARAMETERS:              NONE
  *
  *  MACROS CALLED:           NONE
  *                                                                         
  *  INPUT GLOBAL VARIABLES:  NONE
  *                                                                         
  *  OUTPUT GLOBAL VARIABLES: NONE  
  *                                                                         
  *  LAST REVISED:                                                          
  *   28-Mar-17 (bheckel)  Initial version
  ********************************************************************************/
options sasautos=(SASAUTOS '/Drugs/Cron/Daily/TMMTargetedList' '/Drugs/Macros') ls=max ps=max mprint mprintnest validvarname=any;

 /* /sas/sashome/SASFoundation/9.4/sas -sysin /Drugs/Cron/Daily/TMMTargetedList/tmm_run_check.sas -log /Drugs/Cron/Daily/TMMTargetedList/tmm_run_check.log -altlog /Drugs/Cron/Daily/TMMTargetedList/tmm_run_check.`date +\%a`.log */


 /* Y = send el_file to dummy location and send email to developer instead of group */
%global DRYRUN; %let DRYRUN=N;
libname FDATA '/Drugs/FunctionalData';

 /* Avoid problems when a long run passes into a new day */
%global DATEOFRUNSTART; %let DATEOFRUNSTART=%sysfunc(today());

%macro tmm_build_check;
  %put DEBUG: starting &SYSMACRONAME &SYSDATE &SYSTIME;

  %local runlist; %let runlist=;
  proc sql;
    select distinct clid into :runlist separated by ' '
    from FDATA.tmm_targeted_list_refresh
    where (lastbuild_date+refresh_cycle_days eq &DATEOFRUNSTART) and (on_hold=0)
    ;
  quit;
  %put DEBUG: ~~~~~~~~~~~~ clients due for BUILD today &=runlist ~~~~~~~~~~~~;
  %if "&runlist" eq "" %then %goto NOBUILDSTODAY;

  data _null_;
    %local i myclid;
    %let i=1;
    %do %until(%qscan(&runlist, &i)=  );
      %let myclid=%qscan(&runlist, &i);
      %put DEBUG: queuing build &=myclid;
      call symput('myclid', strip(&myclid));
      rc=dosubl("%include '/Drugs/Cron/Daily/TMMTargetedList/tmm_build_run.sas';");
      %let i=%eval(&i+1);
    %end;
  run;

  proc datasets library=WORK kill NOlist; run; quit;
  ods listing; title '~~~~~~~~~~~~tmm_build_run done';proc print data=FDATA.tmm_targeted_list_refresh width=minimum heading=H;run;title; 
%NOBUILDSTODAY:
  %put DEBUG: ending &SYSMACRONAME;
%mend;
%tmm_build_check;


%macro tmm_import_check;
  %put DEBUG: starting &SYSMACRONAME &SYSDATE &SYSTIME &=DATEOFRUNSTART;

  /* Independents usually go on same day as build, chains 5 days after build */
  %local runlist; %let runlist=;
  proc sql;
    select distinct clid into :runlist separated by ' '
    from FDATA.tmm_targeted_list_refresh
    where (lastbuild_date+import_delay_days eq &DATEOFRUNSTART) and (el_file is not null) and (lastimport_date ne &DATEOFRUNSTART) and (on_hold=0)
    ;
  quit;

  %put DEBUG: ~~~~~~~~~~~~ clients due for IMPORT today &=runlist ~~~~~~~~~~~~;
  %if "&runlist" eq "" %then %goto NOIMPORTSTODAY;

  data _null_;
    %local i myclid;
    %let i=1;
    %do %until(%qscan(&runlist, &i)=  );
      %let myclid=%qscan(&runlist, &i);
      %put DEBUG: queuing import &=myclid;
      call symput('myclid', strip(&myclid));
      rc=dosubl("%include '/Drugs/Cron/Daily/TMMTargetedList/tmm_import_run.sas';");
      %let i=%eval(&i+1);
    %end;
  run;

  proc datasets library=WORK kill NOlist; run; quit;
  ods listing; title '~~~~~~~~~~~~tmm_import_run done';proc print data=FDATA.tmm_targeted_list_refresh width=minimum heading=H; run; title;  
%NOIMPORTSTODAY:
  %put DEBUG: ending &SYSMACRONAME;
%mend;
%tmm_import_check;


ods listing; title '~~~~~~~~~~~~daily done';proc print data=FDATA.tmm_targeted_list_refresh width=minimum heading=H; run; title;  

libname BKUP '/Drugs/Cron/Daily/TMMTargetedList';
data BKUP.tmm_targeted_list_refresh_bk(genmax=21);
  set FDATA.tmm_targeted_list_refresh;
run;

