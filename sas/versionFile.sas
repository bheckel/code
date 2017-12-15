
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: Utility macro
 *  INPUT:            File name and location to save a volatile, versioned,
 *                    backup file
 *  PROCESSING:       Create a backup copy of a file
 *  OUTPUT:           Backed up file written to filesystem
 *******************************************************************************
 */
%macro versionFile(fn, copytodir);
  /* Note: The timestamp number is the hour at which the file was backed-up,
   * not the file's actual run hour.
   */
  data _null_;
    %local fq shortname hourstamp copyto;

    %let fq = %sysfunc(reverse(&fn));
    %let shortname = %sysfunc(reverse(%scan(&fq, 1, '\')));

    /* E.g. 01 - 24 if we run 0_MAIN hourly */
    %let hourstamp = %scan(&SYSTIME, 1, ':');

    %let copyto = %sysfunc(compress(&copytodir.&shortname..&hourstamp));

    rc = system("copy &fn &copyto");

    if rc eq 0 then
      put "NOTE: backed up &fn " rc=;
    else
      put "ERROR: failed to backup &fn " rc=;
  run;
%mend;
