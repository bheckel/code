
/***filename q PIPE "ls -1 .";***/
filename q PIPE "dir /B .";

 /* In pwd ex130123.log ex130124.log ex130125.log ... exist, we want to parse each */
data fnames;
  infile q;
  input ls $80.;
/***  if index(ls, '.log');***/
  if index(ls, '08.log');
run;
/***proc print data=_LAST_(obs=max) width=minimum; run;***/

data alllogs;
  set fnames;
  infile TMP DLM=' ' DSD MISSOVER LRECL=32767 FILEVAR=ls FILENAME=currinfile end=done;
  do while ( not done );
    input a :$50. b :$50. c :$50.;
    output;
  end;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
