options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_surveyselect.sas
  *
  *  Summary: Demo of randomly selecting obs from a dataset.
  *
  *  Created: Wed 11 Feb 2004 13:23:07 (Bob Heckel)
  * Modified: Fri 18 Dec 2015 11:15:46 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

proc surveyselect
   data= sashelp.cars
   seed=31475            /* repeatable */
   method=srs            /* simple random sample */
/***   sampsize=12***/
   samprate=0.05
   out=work.CarSample12; 
run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;



endsas;
%macro select_all_from_subset;
  proc surveyselect data=sashelp.shoes(keep=region) out=t n=3; run;
  proc sql; select quote(strip(region)) into :list separated by ',' from t; quit;
  data t2; set sashelp.shoes(where=(region in (&list))); run;
  title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H; run;title;
  %put _USER_;
%mend;
%select_all_from_subset;

endsas;
data HospitalFrame;
   input Hospital$ Type$ SizeMeasure @@;
   if (SizeMeasure < 20) then Size='Small ';
      else if (SizeMeasure < 50) then Size='Medium';
      else Size='Large ';   
   datalines;
034 Rural  0.870   107 Rural  1.316
079 Rural  2.127   223 Rural  3.960
236 Rural  5.279   165 Rural  5.893
086 Rural  0.501   141 Rural 11.528
042 Urban  3.104   124 Urban  4.033
006 Urban  4.249   261 Urban  4.376
195 Urban  5.024   190 Urban 10.373 
038 Urban 17.125   083 Urban 40.382
259 Urban 44.942   129 Urban 46.702
133 Urban 46.992   218 Urban 48.231
026 Urban 61.460   058 Urban 65.931
119 Urban 66.352
;
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H; run;title;

proc surveyselect data=HospitalFrame method=pps_brewer
                  seed=48702 out=SampleHospitals;
   size SizeMeasure;
   strata Type Size notsorted;
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H; run;title;
endsas;



proc surveyselect data=sashelp.shoes out=t n=5;
  strata region;
run;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H; run;title;
endsas;



data tmp;
  input mydept $  mydate MMDDYY8.;
  call symput('RANDSAMPSZ', int(sqrt(_n_+1)));
  cards;
ADM10 06/01/96
ADM11 06/22/97
ADM13 06/22/97
ADM18 05/02/97
ADM19 06/12/97
ADM14 06/17/97
ADM12 06/08/97
ADM13 06/08/97
ADM14 06/08/97
ADM15 06/08/97
ADM16 06/08/97
ADM107 06/08/97
ADM108 06/01/97
ADM109verylong 06/08/97
ADM110 06/08/97
ADM111 06/08/97
ADM112 06/09/97
ADM113 06/08/97
ADM114 06/08/97
ADM115 06/08/97
ADM116 06/18/97
ADM117 06/08/97
  ;
run;

proc surveyselect data=tmp n=&RANDSAMPSZ; run;
proc print; run;

 /* More common - want to subset the orig dataset */
proc surveyselect data=tmp n=10 out=tmp2; run;
proc print; run;

%put _all_;
