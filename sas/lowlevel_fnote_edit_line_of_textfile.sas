 /* Adapted from http://support.sas.com/documentation/cdl/en/lefunctionsref/67960/HTML/default/viewer.htm#p13v3rvxl2t6k1n15hb5388naenn.htm */

 /* Avoid first reading file into dataset */
%macro m;
  %let fref=MYFILE;
  %let rc=%sysfunc(filename(fref, ~/t.out));

  /* Update mode */
  %let fid=%sysfunc(fopen(&fref, U));

  %if &fid > 0 %then
    %do;
       %let rc=%sysfunc(fread(&fid));
       /* Read second record */
       %let rc=%sysfunc(fread(&fid));
       /* Read third record */
       %let rc=%sysfunc(fread(&fid));

       /* Note position of third record */
       %let note=%sysfunc(fnote(&fid));

       /* Read fourth record */
       %let rc=%sysfunc(fread(&fid));
          /* Read fifth record */
       %let rc=%sysfunc(fread(&fid));

       /* Point to third record */
       %let rc=%sysfunc(fpoint(&fid,&note));
       /* Read third record */
       %let rc=%sysfunc(fread(&fid));
       /* Copy new text to FDB.  New text must be <= existing line length or will silently fail even if record length is specified in fopen */
       %let rc=%sysfunc(fput(&fid, New text));
       /* Update third record  with data in FDB */
       %let rc=%sysfunc(fwrite(&fid));

       %let rc=%sysfunc(fclose(&fid));
    %end;
%mend;
%m;
