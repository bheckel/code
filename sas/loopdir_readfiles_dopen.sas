options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: loopdir_readfiles_dopen.sas
  *
  *  Summary: Read all text files in a directory and turn them into datasets.
  *           An ls or dir for SAS.
  *
  *           dopen - opens the directory
  *           dnum - gets the number of items in the directory
  *           dread - reads in the name of an item
  *           dclose - closes the directory to avoid locks
  *
  *           See loopdir_listfiles_proc_fcmp.sas for recursive approach
  *
  *  Adapted: Wed 12 May 2010 09:24:43 (Bob Heckel--SUGI 009-2010)
  * Modified: Thu 22 Sep 2016 14:33:01 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* Macro approach */
%macro loopdir_read;
  %let rc=%sysfunc(filename(FILRF, "C:\temp\12May10_1273669655"));
  %put !!!&FILRF;  /* SAS internal number */
  %let did=%sysfunc(dopen(&FILRF));
  %let fcnt=%sysfunc(dnum(&did)); /* get # of files in directory */
  %let fname=;

  %if &fcnt gt 0 %then /* check for blank directory */
    %do i=1 %to &fcnt; /* start loop for files */
      %let fname=%sysfunc(dread(&did,&i)); /* get file name to process */
      filename NEXTF "C:\temp\12May10_1273669655\&fname"; /* assign file name */
      data files1;
        infile NEXTF;
        input b $CHAR3.;
        a=1;
      run;
      proc print; title "&fname file is now a dataset"; run;
    %end;
  %let rc=%sysfunc(dclose(&did));
%mend loopdir_read;
/***%loopdir_read;***/



 /* Datastep approach, just list files in directory: */
 /* May be easier to just a pipe with Windows DIR - see dir.sas */
%let path=C:\cygwin\home\rsh86800\tmp\1338472881_31May12;

data files2/*(drop= rc did i)*/;
  rc=filename('dlist', "&path");
  did=dopen("dlist");

  if did then do;
    do i=1 to dnum(did);
      name=dread(did,i);
      output;
    end;
    rc=dclose(did);
  end;
  else do;
    put "ERROR: could not open directory &path";
  end;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
