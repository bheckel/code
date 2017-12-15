ods output CrossTabFreqs=freqs;
ods trace on;
proc freq data=sashelp.class;
  tables age*height*weight;
run;
ods output close;

endsas;

ods listing close;
 /*        __________ univariate exposes this object */
ods output ExtremeObs=myminmaxds;

proc univariate data=sashelp.class; var height weight; run;

ods output show;  /* prints Log info */
ods output close;
ods listing;

/***proc print data=_LAST_(obs=max) width=minimum; run;***/

 /* compare */
/***proc univariate data=sashelp.class; var height weight; run;***/


 /* Multiple procedures, single dataset: */

ods listing close;
ods output ExtremeObs(PERSIST=PROC)=myminmaxds;

proc univariate data=sashelp.class; var height weight; run;
proc univariate data=sashelp.shoes; var inventory sales; run;

ods output close;
ods listing;

proc print data=_LAST_(obs=max) width=minimum; run;

