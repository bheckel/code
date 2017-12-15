%macro Interpret_sysinfo;
  %let keep=&sysinfo;

  data compare_report(keep=sysinfo binary line);
    length line $ 80;
    sysinfo=&keep;
    binary=put(&keep,binary16.);
    put sysinfo= binary=;
    rev=reverse(binary);
   * could modify to say what things are the same - e.g. dataset labels same;
   * the following definitions were copied from the SAS Help;
    if substr(rev,1,1)='1' then do;  line="DSLABEL      1  0001X  Data set labels differ "; output; end;
    if substr(rev,2,1)='1' then do;  line="DSTYPE       2  0002X  Data set types differ "; output; end;
    if substr(rev,3,1)='1' then do;  line="INFORMAT     4  0004X  Variable has different informat "; output; end;
    if substr(rev,4,1)='1' then do;  line="FORMAT       8  0008X  Variable has different format "; output; end;
    if substr(rev,5,1)='1' then do;  line="LENGTH      16  0010X  Variable has different length "; output; end;
    if substr(rev,6,1)='1' then do;  line="LABEL       32  0020X  Variable has different label "; output; end;
    if substr(rev,7,1)='1' then do;  line="BASEOBS     64  0040X  Base data set has observation not in comparison "; output; end;
    if substr(rev,8,1)='1' then do;  line="COMPOBS    128  0080X  Comparison data set has observation not in base "; output; end;
    if substr(rev,9,1)='1' then do;  line="BASEBY     256  0100X  Base data set has BY group not in comparison "; output; end;
    if substr(rev,10,1)='1' then do; line="COMPBY     512  0200X  Comparison data set has BY group not in base "; output; end;
    if substr(rev,11,1)='1' then do; line="BASEVAR   1024  0400X  Base data set has variable not in comparison "; output; end;
    if substr(rev,12,1)='1' then do; line="COMPVAR   2048  0800X  Comparison data set has variable not in base "; output; end;
    if substr(rev,13,1)='1' then do; line="VALUE     4096  1000X  A value comparison was unequal "; output; end;
    if substr(rev,14,1)='1' then do; line="TYPE      8192  2000X  Conflicting variable types "; output; end;
    if substr(rev,15,1)='1' then do; line="BYVAR    16384  4000X  BY variables do not match "; output; end;
    if substr(rev,16,1)='1' then do; line="ERROR    32768  8000X  Fatal error: comparison not done "; output; end;
    if sysinfo=0 then do; line="Datasets are precisely identical"; output; end;
  run;

  proc print data=compare_report noobs;
    by sysinfo binary;
    id sysinfo binary;
    var line;
  run;
%mend Interpret_sysinfo;
 

 /* Create dummy datasets */
data one(label='one');
  length a $ 1
         b 4
         c $ 3;
  label a='1ST VARIABLE';
  a='A'; b=2; c='C'; output;
  output; * another record;
run;
proc print data=_LAST_(obs=max); run;
 
data two(label='one');
  length a $ 2 /* different length for variable */
         b $ 4  /* different variable type */
         c $ 3; /* same */
  label a='1st variable'; /* case different in label */
  a='A'; b='2'; c='C'; output; /* only 1 record written */
run;
proc print data=_LAST_(obs=max); run;
 
 /* Run proc compare, which will set the value of &sysinfo.  Toggle NOPRINT if
  * there are diffs.
  */
proc compare base=one compare=two /*NOPRINT*/; run;
 
%Interpret_sysinfo;
