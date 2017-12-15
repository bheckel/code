options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_transpose_alternative_unflip.sas
  *
  *  Summary: Reverse transpose using datastep instead of TRANSPOSE.
  *
  *           See also wide_to_long.sas
  *
  *  Adapted: Mon 04 Jan 2010 12:49:17 (Bob Heckel--SUGI 60-24)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data t;
  input name $ date1 $ date2 $ date3 $;
  cards;
Amy Date#A1 Date#A2 .
Bob Date#B1 . Date#B3
  ;
run;
title 'TRANSPOSE should work on this dataset...';
proc print data=_LAST_(obs=max) width=minimum; run;

proc transpose data=t;
  by name;
  var date1-date3;
run;
title '...but we do not want missings in COL1 to show like they do here...';
proc print data=_LAST_(obs=max) width=minimum; run;

title '...so it is time to use datastep instead of TRANSPOSE';
/***data t2(keep=name col1);***/
data t2;
  set t;
  array d{3} date1-date3;
  do i=1 to 3;
    if d{i} ne '' then do;
      col1 = d{i};
      output;
    end;
  end;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

