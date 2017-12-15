%macro tmm_import_run;
  /********************************************************************************
  *  SAVED AS:                /Drugs/Cron/Daily/TMMTargetedList/tmm_import_run.sas
  *                                                                         
  *  CODED ON:                22-Mar-17 by Bob Heckel
  *                                                                         
  *  DESCRIPTION:             Run TMM targeted list import
  *
  *  PARAMETERS:              NONE
  *
  *  MACROS CALLED:           %sendtodropbox
  *  
  *  INPUT GLOBAL VARIABLES:  &myclid &DRYRUN
  *                                                                         
  *  OUTPUT GLOBAL VARIABLES: NONE  
  *                                                                         
  *  LAST REVISED:                                                          
  *   22-Mar-17 (bheckel)  Initial version
  ********************************************************************************/
  options ls=max;
  %put DEBUG: >>> starting &SYSMACRONAME for &=myclid &=DRYRUN;

  data _null_;
    set FDATA.tmm_targeted_list_refresh;

    if clid eq &myclid then do;
      call symput('on_hold', strip(on_hold));
      call symput('is_independent', strip(is_independent));
      call symput('el_file', strip(el_file));
      call symput('cl_shortname', strip(short_name));
      call symput('long_client_name', strip(long_client_name));
   end;
 run;

  %if &on_hold ne 1 %then %do; 
    %put DEBUG: &SYSMACRONAME is importing &=myclid &=el_file &=on_hold;

    %let mail=Y;
    %let el_submit=Y;
    %let cl_foldername=%scan(%bquote(&el_file), 3, '/');
    %let daten_max=%scan(%bquote(&el_file), 5, '/');
    %let monn_max=%substr(&daten_max, 1, 6);

    /************* Submit eligibility file e.g. CLI_1639275183_TMM_candidates_fdw.csv *************/
    %local droppath;
    %if &SYSCC le 4 %then %do;
      %if &DRYRUN eq Y %then %do;
        %let droppath=/mnt/nfs/home/bheckel/mnt/nfs/home/janitor/dataproc/tmm/pending;
      %end;
      %else %do;
        %let droppath=/mnt/nfs/home/janitor/dataproc/tmm/pending;
      %end;

      %if %sysfunc(fileexist("&el_file")) %then %do;
        %put DEBUG: &SYSMACRONAME is submitting &=el_file &=droppath &=daten_max &=monn_max &=cl_foldername &=cl_shortname;
        %sendtodropbox(sendfile=&el_file, droploc=&droppath);
        %if &DROPBOXERROR ne 0 %then %do;
          %put ERROR: failed to send to dropbox, status is &DROPBOXERROR;
        %end;
      %end;
      %else %do;
        %put ERROR: file missing: &el_file;
        %goto FDWMISSING;
      %end;
    %end;
    %else %do;
      %put ERROR: &SYSMACRONAME is skipping eligibility file submission because &=SYSCC;
    %end;

    /************* Email *************/
    %if &SYSCC le 4 and &mail eq Y %then %do;
      %let censusfilename=%str(/Drugs/TMMEligibility/&cl_foldername./Imports/&daten_max./Output/TMM-&cl_shortname.(clientid=&myclid.)-Census-&daten_max..xlsx);
      %let rfdfilename=%str(/Drugs/TMMEligibility/&cl_foldername./Imports/&daten_max./Output/TMM-&cl_shortname.(clientid=&myclid.)-RFD-&daten_max..xlsx);

      %if &DRYRUN eq Y %then %do;
        %let mailto=%str('bob.heckel@taeb.com');
        %let cc=%str('bob.heckel@taeb.com');
      %end;
      %else %do;
        %let mailto=%str('jonathan.hopewell@taeb.com' 'mark.gregory@taeb.com' 'robb.ayshford@taeb.com' 'Team-Partner-relationship-Managers@taeb.com' 'Team-Partner-Coaching-and-consulting@taeb.com');
        %let cc=%str('bob.heckel@taeb.com');
      %end;

      %if %sysfunc(fileexist("&censusfilename")) and %sysfunc(fileexist("&rfdfilename")) %then %do;
        %put DEBUG: &SYSMACRONAME is sending &=myclid &=mail &=is_independent import email to &=mailto &=cc &=DRYRUN;
        filename IMPMAIL email (&mailto)                       
             from='analytics@taeb.com'
             cc=(&cc)
             subject="TMM Refresh - &long_client_name (clientid-&myclid)"                         
             content_type="text/html"
             ;                                                                             
                                                                                           
        data _null_;                                                                           
          file IMPMAIL;
          put '<div style="font-family:Calibri">';
          put "Hi, a new &long_client_name refresh has been completed. The RFD & Census spreadsheets are available here:";
          put '<br><br>';
          put "R:\TMMEligImports\&monn_max\&cl_foldername\&daten_max\TMM-&cl_shortname.(clientid=&myclid.)-Census-&daten_max..xlsx";
          put "R:\TMMEligImports\&monn_max\&cl_foldername\&daten_max\TMM-&cl_shortname.(clientid=&myclid.)-RFD-&daten_max..xlsx";
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
        %put ERROR: &SYSMACRONAME is unable to email because file(s) missing see:;
        %put /Drugs/TMMEligibility/&cl_foldername./Imports/&daten_max./Output;
        %put &=censusfilename;
        %put &=rfdfilename;
      %end;
    %end;
    %else %do;
      %put DEBUG: &SYSMACRONAME is skipping email for &=myclid &=mail;
    %end;

    %if &SYSCC le 4 %then %do;
      data FDATA.tmm_targeted_list_refresh;
        set FDATA.tmm_targeted_list_refresh;

        if clid eq &myclid then do;
          lastimport_date = &DATEOFRUNSTART;
          /* el_file is a queued import, remove after submitted to PMAP */
          el_file = '';
       end;
      run;
      %put DEBUG: &SYSMACRONAME has updated FDATA.tmm_targeted_list_refresh after finishing the import for &=myclid;
    %end;
  %end;
  %else %do;
    %put DEBUG: &SYSMACRONAME is NOT importing &=myclid because this client is on hold &=on_hold;
  %end;

  %put tmm_import_run.sas; %put _user_;
%FDWMISSING:
%mend;
%tmm_import_run;
