
 /* To Log */
%macro ls(path);
  filename q PIPE "dir %bquote(&path)";
  data err;
    infile q TRUNCOVER;
    input ls $80.;
  run;
  data _null_;
    set err;
    file LOG;
    put ls;
  run;
%mend;


 /* To Lst */
%macro ls;
  filename q PIPE "dir %bquote(&FREEW)";
  data err;
    infile q TRUNCOVER;
    input ls $80.;
  run;
  proc print data=_LAST_(obs=max) width=minimum; run;
%mend;
