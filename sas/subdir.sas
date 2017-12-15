options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: subdir.sas
  *
  *  Summary: This macro will scan all the sub-directories from a root and
  *           then run a macro passing each directory in as a parameter. This
  *           is aimed at running macros like autodoc which run on a directory
  *           at a time.
  *
  * Adapted: Mon Jul  2 16:47:47 2007 (Bob Heckel -- Phil Mason email)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

%macro Subdir(topdir, runthis=);
  /* Work out what all the sub-directories are, including the top directory
   * specified 
   */
  filename dir PIPE "dir ""&topdir"" /s";

  data subdirs;
    retain dir;
    length dir $ 100;
    infile dir length=length;

    input;

    if length>14 then
      if substr(_infile_,2)=:'Directory of' then
        do;
          dir=substr(_infile_,14);
          output;
        end;
  run;

   %if %superq(runthis)> %then
     %do;
       data _null_;
         set subdirs;
         call execute(&runthis);
       run;
     %end;
%mend Subdir;

%Subdir(C:\temp\ps, runthis=%nrstr('%put Dir='||trim(dir)||';'));
