options noxwait;

%let fname=SAP.xls;
%let ServerName=rtpsawn321;
data _null_;
  /* Windows can't handle colons in filename */
  %let timestamp=%scan(&SYSTIME, 1, ':')_%scan(&SYSTIME, 2, ':');
  rc=system("copy \\&ServerName\d\SQL_Loader\SAP_load\&fname
                  \\&ServerName\d\SQL_Loader\SAP_load\SAP.&SYSDATE..&timestamp..xls");
  put rc=;
run;



 /* or */

%macro BackupFile(f);
  data _null_;
    /* Windows can't handle colons in filename */
    %let timestamp=%scan(&SYSTIME, 1, ':')_%scan(&SYSTIME, 2, ':');

    rc = system("copy &f &f..&SYSDATE..&timestamp..log");

    if not rc then
      put "NOTE: copied &f for debugging. " rc=;
    else
      put "ERROR: failed to copy &f.. " rc=;
  run;
%mend;

 

  /* or better */
%macro backupFile(fn, copytodir);
  /* We'll have a set of up to 24 volatile files for debugging */
  data _null_;
    %local fq shortname hourstamp copyto;

    %let fq = %sysfunc(reverse(&fn));
    %let shortname = %sysfunc(reverse(%scan(&fq, 1, '\')));

    /* 01 - 24 */
    %let hourstamp = %scan(&SYSTIME, 1, ':');

    %let copyto = %sysfunc(compress(&copytodir.&shortname..&hourstamp));

    rc = system("copy &fn &copyto");

    if rc eq 0 then
      put "NOTE: backed up &fn " rc=;
    else
      put "ERROR: failed to backup &fn " rc=;
  run;
%mend;
