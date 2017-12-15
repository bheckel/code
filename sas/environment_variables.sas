options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: environment_variables.sas
  *
  *  Summary: Work with operating system's environment variables.
  *
  *  Adapted: Thu 13 May 2010 13:07:56 (Bob Heckel--SUGI 090-2010)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* Windows' SET command */
filename envcmd PIPE 'set' lrecl=1024;

data xpset;
  infile envcmd dlm='=' MISSOVER;
  ***length name $32 value $80;
  ***input name $ value $;
  input name :$32. value :$80.;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


 /* Implicit reference in pathnames */
filename TMP '!TEMP/t.dat';
data _null_;
  file TMP;
  put 'ok';
  put 'done';
run;

data _null_;
  infile TMP;
  input;
  put _infile_;
run;


data _null_;
 rc=fdelete('TMP');

 if rc eq 0 then
   put 'tempfile deleted';
run;
