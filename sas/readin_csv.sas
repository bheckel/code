options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: readin_csv.sas
  *
  *  Summary: Read separated text data
  *
  *  Created: Fri 29 Jul 2016 13:11:15 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

/*
99999999|118|6|2016-01-14
99999997|118|7|2016-01-14
99999990|118|3|2016-01-14
*/
filename F "/Drugs/TMMEligibility/Publix/Imports/20160114/Output/PUPTMM_candidates_fdw_0.csv";

data f;
  infile F DLM='|' DSD MISSOVER FIRSTOBS=2;
  input atebpatientid  :$40.                             
        clientid       :$40.                          
        nrx            :8.
        senddate       :YYMMDD10.
        ;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;


 /* Same - use this if data is simple (numbers are numbers, not characters etc) */
proc import out=f datafile=F dbms=CSV REPLACE;
/***  delimiter='09'x;***/
/***  delimiter=',|;:';***/
  delimiter='|';
  getnames=no;
  datarow=1;
  guessingrows=max;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;

