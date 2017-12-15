options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: minmaxmean.sas
  *
  *  Summary: Across obs and across vars
  *
  *  Created: Tue 12 Nov 2013 14:22:37 (Bob Heckel)
  * Modified: Wed 08 Apr 2015 15:41:13 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;


data secondbest;
  input x1-x5;
  S1 = smallest(1, of x1-x5);
  S2 = smallest(2, of x1-x5);
  L2 = largest(2, of x1-x5);
  datalines;
7 2 . 6 4
10 . 2 8 9
;
run;



data t;
  input id $ s1 s2 s3 s4 z;
  cards;
A01 33 44 55 99 20
A02 44 . 0  11 20
A03 55 5 1  22 20
  ;
run;


 /* Approach 1 - across column */
proc summary data=t;  /* do not use proc means here, too verbose */
  class id;
  output min(s1)=mymin max(s1)=mymax mean(s1)=mymean;
run;
title '1 - across column';
proc print data=_LAST_ width=minimum NOobs; run;
proc print data=_LAST_(obs=max where=(_TYPE_ in (0,3))) width=minimum NOobs; run;


title '2 - across column'; 
 /* Approach 2 - across column */
proc sql;
  select min(s1), max(s1), mean(s1)
  from t
  ;
quit;

 /* Approach 3 - across row */
data t2;
  set t;
  mymin=min(of s1-s4 z);
/***  mymax=max(of s1-s4 z);***/
  /* same */
  mymax=max(s1, s2, s3, s4, z);
  mymean=mean(of s1-s4 z);
run;
title '3 - across row'; 
proc print data=_LAST_(obs=max) width=minimum; run;


 /* Approach 4 - across row */
data t2;
  set t;
  array a{*} _numeric_;
  mymin=min(of a{*});
  mymax=max(of a{*});
  mymean=mean(of a{*});
run;
title '4 - across row'; 
proc print data=_LAST_(obs=max) width=minimum; var _numeric_; run;

endsas;
data t;
  set allmeths(rename=(recorded_text=nresult));
  result = input(nresult, ?? F8.);
run;
proc sort; by lims_id1; run;
proc summary data=t;
  class long_test_name short_test_name_level1;
  output min(result)=min max(result)=max mean(result)=mean;
run;
proc print data=_LAST_(obs=max where=(_TYPE_ in (0,3))) width=minimum NOobs; run;
