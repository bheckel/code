%macro tmm_build_run;
  /********************************************************************************
  *  SAVED AS:                /Drugs/Cron/Daily/TMMTargetedList/tmm_build_run.sas
  *                                                                         
  *  CODED ON:                29-Mar-17 by Bob Heckel
  *                                                                         
  *  DESCRIPTION:             Run TMM targeted list build            
  *
  *  PARAMETERS:              NONE
  *
  *  MACROS CALLED:           %dbpassword, %options_tmm, %importst_TMM, %filter_tmm
  *                           %addtional_qc_tmm
  *                                                                         
  *  INPUT GLOBAL VARIABLES:  &myclid &DRYRUN
  *                                                                         
  *  OUTPUT GLOBAL VARIABLES: NONE  
  *                                                                         
  *  LAST REVISED:                                                          
  *   29-Mar-17 (bheckel)  Initial version
  ********************************************************************************/
  options ls=max;
  %put DEBUG: >>> starting &SYSMACRONAME for &=myclid &=DRYRUN;

  data _null_;
    set FDATA.tmm_targeted_list_refresh;

    if clid eq &myclid then do;
      call symput('lastbuild_date', strip(lastbuild_date));
      call symput('is_independent', strip(is_independent));
      call symput('months', strip(months));
      call symput('mindrugs', strip(mindrugs));
      call symput('cap', strip(cap));
      call symput('numcap', strip(numcap));
      call symput('import_delay_days', strip(import_delay_days));
      call symput('long_client_name', strip(long_client_name));
   end;
 run;

  /******* Copied from v19 TMM_Build.egp *******/
  %global months maxdate mon max mindate min location reportlocation filename storeid nobs
    totalpatients censusmaxdate censusmindate clid clientfolder NPI CGID store_name 
    short_client_name;
  %global date_max clid path date_min months mindrugs taebpatientid job_type cap numcap nrx filename
    date_mincensus date_maxcensus seq medseq cl_npi medlist rm_enrolled;

  %let date_max=%sysfunc(intnx(day, "&SYSDATE9"D, -1, b), DATE9.);
  %let clid=&myclid;
  %let months=&months;
  %let mindrugs=&mindrugs;
  %let minage=18;
  %let taebpatientid=Y;
  %let job_type=Imports;
  %let cap=&cap;
  %let numcap=&numcap;
  %let nrx=;
  %dbpassword;
  %options_tmm;
  %importst_TMM;
  %filter_tmm;
  %report_tmm;
  %census_tmm(var_patientid=pharmacypatientid);
  %censusreport_tmm;
  %additionalqc_tmm;
  /* ODS destinations are unpredictable at this point */
  /***********************************************/
  options ls=max;

  %if &SYSCC le 4 %then %do;
    /************* Export Census & RFD reports to R: *************/
    %put DEBUG: &SYSMACRONAME has finished the build for &=myclid;

    %local rpath rdirectory;
    %let rpath=/sasreports/TMMEligImports;
    %let rdirectory=%sysfunc(dcreate(&monn_max.,&rpath));
    %let rdirectory=%sysfunc(dcreate(&cl_foldername,&rpath/&monn_max));
    %let rdirectory=%sysfunc(dcreate(&daten_max,&rpath/&monn_max/&cl_foldername));
    %let censusfilename=%str(/Drugs/TMMEligibility/&cl_foldername./Imports/&daten_max./Output/TMM-&cl_shortname.\(clientid=&myclid.\)-Census-&daten_max..xlsx);
    %let rfdfilename=%str(/Drugs/TMMEligibility/&cl_foldername./Imports/&daten_max./Output/TMM-&cl_shortname.\(clientid=&myclid.\)-RFD-&daten_max..xlsx);

    %put DEBUG: &SYSMACRONAME is sending &censusfilename and ;
    %put DEBUG: &rfdfilename to R drive &=myclid;
    
    data _null_;
      rc1=system("cp -p &censusfilename &rpath/&monn_max/&cl_foldername/&daten_max/");
      rc2=system("cp -p &rfdfilename &rpath/&monn_max/&cl_foldername/&daten_max/");

      if (rc1 ne 0) or (rc2 ne 0) then do;
        sysuserid=symget('SYSUSERID');
        put "ERROR: &SYSMACRONAME &sysuserid cp to R: failed: " rc1= rc2=;
      end;
      else do;
        put "DEBUG: &SYSMACRONAME &sysuserid cp to R: was successful " rc1= rc2=;
      end;
    run;

    /***************** Email **************/
    %if &is_independent eq 0 %then %do;
      %put DEBUG: &SYSMACRONAME emailing tmm_build_run countdown for chain &=myclid because &=is_independent;

      %if &DRYRUN eq Y %then %do;
        %let mailto=%str('bob.heckel@taeb.com');
        %let cc=%str('bob.heckel@taeb.com');
      %end;
      %else %do;
        %let mailto=%str('jonathan.hopewell@taeb.com' 'mark.gregory@taeb.com' 'robb.ayshford@taeb.com' 'Team-Partner-relationship-Managers@taeb.com' 'Team-Partner-Coaching-and-consulting@taeb.com');
        %let cc=%str('bob.heckel@taeb.com');
      %end;

      filename BLDMAIL email (&mailto)                       
           from='analytics@taeb.com'
           cc=(&cc)
           subject="TMM Refresh - &long_client_name (clientid-&myclid) - RFD/Census"                         
           content_type="text/html"
           ;                                                                             
                                                                                         
      data _null_;                                                                           
        file BLDMAIL;
        put '<div style="font-family:Calibri">';
        put "Hi, a new &long_client_name refresh has been built. The RFD & Census spreadsheets are ready for your review:";
        put '<br><br>';
        put "R:\TMMEligImports\&monn_max\&cl_foldername\&daten_max\TMM-&cl_shortname.(clientid=&myclid.)-Census-&daten_max..xlsx";
        put "R:\TMMEligImports\&monn_max\&cl_foldername\&daten_max\TMM-&cl_shortname.(clientid=&myclid.)-RFD-&daten_max..xlsx";
        put '<br><br>';
        put "In &import_delay_days days the targeted list will be submitted to PMAP unless a hold request is issued.";
        put '<br><br>';
        put "Please reply to this email if you have any comments or questions.  Thanks!";
        put '</div><br><br>';
        put '<div style="font-family:Calibri; font-style:italic; font-size:60%">';
        put 'If you have received the message in error, please advise the sender by reply email and please delete the message.  This message contains information which may be confidential or otherwise '
            'protected.  Unless you are the addressee (or authorized to receive for the addressee), you may not use, copy, or disclose to anyone the message or any information contained in the message.';
        put '</div>';
        put;
      run;                                                                                   
    %end;
    %else %do;
      %put DEBUG: &SYSMACRONAME not emailing tmm_build_run countdown because &=is_independent;
    %end;
    /**************************************/

    /* Prepare for next build */
    data FDATA.tmm_targeted_list_refresh;
      set FDATA.tmm_targeted_list_refresh;

      /* Note lastbuild_date is one day later than date_max */
      if clid eq &myclid then do;
        lastbuild_date = &DATEOFRUNSTART;
        el_file = "/Drugs/TMMEligibility/&cl_foldername/Imports/&daten_max/Output/&filename..csv";
        projected_build_date = &DATEOFRUNSTART + refresh_cycle_days;
     end;
    run;
    %put DEBUG: &SYSMACRONAME has updated FDATA.tmm_targeted_list_refresh after finishing build for &=myclid;
  %end;  /* syscc was 4 or less */
  %else %do;
    %put DEBUG: &=myclid build failed &=SYSCC;
  %end;


  %put tmm_build_run.sas; %put _user_;
%mend;
%tmm_build_run;
