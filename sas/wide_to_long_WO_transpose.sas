options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: wide_to_long_WO_transpose.sas
  *
  *  Summary: Demo of transposing wide columns to long rows.
  *
  *  Adapted: Fri 24 Jun 2011 10:43:52 (Bob Heckel--SUGI 269-2011)
  * Modified: Fri 08 Apr 2016 14:18:29 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data wide;
  input id $ s1 s2 s3 s4;
  cards;
A01 33 44 55 99
A02 44 . 0  11
  ;
run;
title 'WIDE';
proc print data=_LAST_(obs=max) width=minimum; run;
/*
Obs    id     s1    s2    s3    s4

 1     A01    33    44    55    99
 2     A02    44     .     0    11
*/


data long;
  set wide;

  /* Existing column names */
/***  array s{4};***/
/***  array s{*} s:;***/
  array s s:;

  do i=1 to dim(s);
    snum = i;  /* unnecessary when we use vlabel() */
    sname = vlabel(s{i});
    value = s{i};
    if not missing(value) then output;
  end;
run;
title 'to LONG';
proc print data=_LAST_(obs=max) width=minimum; var id snum sname value;run;
/*
Obs    id      snum    sname    value

 1     A01       1        s1        33 
 2     A01       2        s2        44 
 3     A01       3        s3        55 
 4     A01       4        s4        99 
 5     A02       1        s1        44 
 6     A02       3        s3         0 
 7     A02       4        s4        11 
*/

proc print data=_LAST_(obs=max) width=minimum; run;
/*
Obs    id     s1    s2    s3    s4    i     snum    sname    value

 1     A01    33    44    55    99    1       1        s1        33 
 2     A01    33    44    55    99    2       2        s2        44 
 3     A01    33    44    55    99    3       3        s3        55 
 4     A01    33    44    55    99    4       4        s4        99 
 5     A02    44     .     0    11    1       1        s1        44 
 6     A02    44     .     0    11    3       3        s3         0 
 7     A02    44     .     0    11    4       4        s4        11 
*/


 /* Compare */
proc transpose data=wide out=long(where=(COL1 ne .));
  by id;
  var s1-s4;
run;  
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;
/*
Obs    id     _NAME_    COL1

 1     A01      s1       33 
 2     A01      s2       44 
 3     A01      s3       55 
 4     A01      s4       99 
 5     A02      s1       44 
 6     A02      s3        0 
 7     A02      s4       11 
*/
