options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: ranuni.sas
  *
  *  Summary: Random selection.
  *
  *           See also random_sample_w_replace.sas
  *
  *  Created: Tue 25 May 2010 13:14:12 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

options NOmprint NOmlogic NOsgen;

data t;
  do i=1 to 10;
    x=ranuni(1);  /* same random floating point 0-1 (noninclusive) each run */
    y=ranuni(0);  /* different random floating point 0-1 (noninclusive) each run */
    integer=ceil(ranuni(1)*10);  /* random num between 1 to 10 (inclusive) */
    output;
  end;
run;
proc print data=_LAST_(obs=max) width=minimum; run;



endsas;
 /* TODO not very random */
%macro m(maxn, iter);
  %do i=1 %to &iter;
    data _null_;
      randomnum = ceil(ranuni(0) * &maxn);
      put randomnum=;
      x = sleep(randomnum);
    run;
  %end;
%mend;
%m(10, 20);
