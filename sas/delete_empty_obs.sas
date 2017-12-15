
data dataset_with_holes;
  infile cards MISSOVER;  /* without MISSOVER blank obs are skipped */
  input c :$12. x1 x2;
  cards;
aa 1 2
bb 3 4

cc 5 6
dd 7 8

ee 9 0
  ;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;

options missing='';
data dataset_without_holes;
  length debug $32;
  set dataset_with_holes;

  debug=cats(of _ALL_);
  if missing(cats(of _ALL_)) then delete;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;
