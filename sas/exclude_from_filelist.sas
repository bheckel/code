options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: exclude_from_filelist.sas
  *
  *  Summary: Module for DataPost to remove rogue unapproved samples
  *
  *  Created: Fri 15 Jan 2010 09:42:11 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

/* TODO this doesnt work - &sampidexclude is local to the macro */
%global sampidexclude;

%macro excluder(fn);
  filename EXCLUDER "&fn";

  data _null_;
    %if not %sysfunc(fexist(EXCLUDER)) %then %do;
      put "WARNING: no excluder file exists &fn";
      ***link EXIT;
    %end;

    infile EXCLUDER DLM='=' MISSOVER;
    input key :$40. val :$216.;
    if substr(key, 1, 1) not in('', ' ', ';');  /* skip comments and blank lines */
    call symput(key, compress(val));
/***EXIT:***/
  run;
%mend;
%excluder(./junk.txt);
%put _all_;  /* DEBUG */



endsas;
junk.txt:
; List of sample IDs to exclude from processing - must be separated by commas:
sampidexclude=123456,789012,345678
