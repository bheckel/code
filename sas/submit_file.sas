%macro submit_file(fn=, dir=);
  /* /sasdata/Macros/submit_file.sas
   *
   * Send a file to a directory.  The directory is usually dropbox. 
   *
   * Sample call:
   * %submit_file(fn=&path.&sp_name./&jobtype./&daten_exec./Output/imm_add_&daten_exec._&clid._1.csv, dir=/mnt/nfs/dropboxes/tmm/alert);
   *
   * 21-Sep-16 (bheckel)   Initial-intended for Immunization submissions
   */
  data _null_;
    %if %sysfunc(fileexist("&fn")) and %sysfunc(fileexist("&dir")) %then %do;

      /* Dropbox requires open permissions */
      rc1=system("chmod 777 &fn");
      rc2=system("cp -p &fn &dir");

      if (rc1 ne 0) or (rc2 ne 0) then
        do;
          sysuserid=symget('SYSUSERID');
          fn="&fn";
          dir="&dir";
          put 'ERROR: dropbox transfer failure: ' rc1= rc2= fn= dir= sysuserid=;
        end;

      %put NOTE: &fn was sent to &dir by &SYSUSERID;

    %end;
    %else %do;
      %put ERROR: transfer failure - check for existence of &fn and &dir;
    %end;
  run;
%mend;
