options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_sort_alternative.sas
  *
  *  Summary: Faster alternative to proc sort for large datasets.
  *
  *  Adapted: Mon 04 Jan 2010 11:24:17 (Bob Heckel -- http://support.sas.com/kb/37/581.html)
  * Modified: Fri 16 Oct 2015 14:00:10 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

/* Create a data set with duplicate observations */
data t;
  input x y z;
  cards;
1 1 1
1 1 1
1 2 1
1 2 2
2 2 2
2 2 2
2 2 2
2 2 1
  ;
run;
proc print data=t; run;

proc sort out=psrt NOdupkey; by x y z; run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H; run;title;

proc summary data=t NWAY;
  class x y z;
  output out=psum(/*drop=_TYPE_ _FREQ_*/);
run;

 /* _FREQ_ > 1 indicates dups were removed */
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H; run;title;
