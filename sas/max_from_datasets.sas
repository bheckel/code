options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: max_from_datasets.sas
  *
  *  Summary: Using several datasets, find the highest number from each.
  *
  *  This might be easier with proc sql.
  *
  *  Created: Thu 04 Mar 2004 14:02:53 (Bob Heckel)
  *	Modified: Mon 23 Oct 2006 14:52:52 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* Create a dataset with year and total count for that year */
data foo1;
  input count name $;
  datalines;
5 abc
6 def
1 ghi
  ;
run;
data foo2;
  input count name $;
  datalines;
10 abc2
11 def2
6 ghi2
  ;
run;
data foo3;
  input count name $;
  datalines;
12 abc3
13 def3
1 ghi3
  ;
run;

%let nds=3;

 /* Find the maximum count from each of the 3 ds. */
%macro MaxFromEach;
  %local i;
  %do i=1 %to &nds;
    proc means data=foo&i NOPRINT;
      var count;
      output out=bar&i;
    run;
    data tmp&i;
      set bar&i;
      /* proc means generates automatic variable _STAT_ */
      if _STAT_ eq 'MAX';
      yr = %eval(&i+2000);
    run;
  %end;
%mend MaxFromEach;
%MaxFromEach

title '2001';
proc print data=bar1(obs=max); run;

data tmpall;
  set tmp1 tmp2 tmp3;
run;
proc print;
  var yr count;
run;
