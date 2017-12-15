options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: u:/gsk/count_all_datasets.sas
  *
  *  Summary: Quick count and timestamps grouped by date
  *
  *  Created: Tue 08 Jan 2013 15:28:04 (Bob Heckel)
  * Modified: Tue 04 Aug 2015 09:51:08 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err ls=max ps=max;

 /* Simple: */
proc datasets memtype=data lib=l noprint;
   CONTENTS data=_ALL_ OUT=mylib_contents(KEEP=MEMNAME NOBS CRDATE) NOPRINT;
run;
proc print data=_LAST_(obs=max) width=minimum heading=H; run;
endsas;


 /* More detailed: */

 /***********************************/
%let MYLIB=DEMO;
/***%let MYLIB=tst;***/
/***%let MYLIB=prd;***/

%let SAVEPATH=u:/tmp;
 /***********************************/

libname demo (
  'x:/DatapostDEMO/data/gsk/zebulon/mdi'
  'x:/DatapostDEMO/data/gsk/zebulon/mdi/advairhfa'
  'x:/DatapostDEMO/data/gsk/zebulon/mdi/albuterol'
  'x:/DatapostDEMO/data/gsk/zebulon/mdpi'
  'x:/DatapostDEMO/data/gsk/zebulon/mdpi/advairdiskus'
  'x:/DatapostDEMO/data/gsk/zebulon/mdpi/sereventdiskus'
  'x:/DatapostDEMO/data/gsk/metadata/reference/gist'
  'x:/DatapostDEMO/data/gsk/sss/mdpi/seretidediskus'
  )
  access=readonly
;

libname tst (
  'y:/Datapost/data/gsk/zebulon/mdi/advairhfa'
  'y:/Datapost/data/gsk/zebulon/mdi/albuterol'
  'y:/Datapost/data/gsk/zebulon/mdpi/advairdiskus'
  'y:/Datapost/data/gsk/zebulon/mdpi/sereventdiskus'
  'y:/Datapost/data/gsk/zebulon/soliddose/avandamet'
  'y:/Datapost/data/gsk/zebulon/soliddose/avandaryl'
  'y:/Datapost/data/gsk/zebulon/soliddose/bupropion'
  'y:/Datapost/data/gsk/zebulon/soliddose/lamictal'
  'y:/Datapost/data/gsk/zebulon/soliddose/lotronex'
  'y:/Datapost/data/gsk/zebulon/soliddose/lovaza'
  'y:/Datapost/data/gsk/zebulon/soliddose/methylcellulose'
  'y:/Datapost/data/gsk/zebulon/soliddose/ratiolamotrigine'
  'y:/Datapost/data/gsk/zebulon/soliddose/retigabine'
  'y:/Datapost/data/gsk/zebulon/soliddose/retrovir'
  'y:/Datapost/data/gsk/zebulon/soliddose/rosiglitazone'
  'y:/Datapost/data/gsk/zebulon/soliddose/trizivir'
  'y:/Datapost/data/gsk/zebulon/soliddose/valtrex'
  'y:/Datapost/data/gsk/zebulon/soliddose/wellbutrin'
  'y:/Datapost/data/gsk/zebulon/soliddose/zantac'
  'y:/Datapost/data/gsk/zebulon/soliddose/zofran'
  'y:/Datapost/data/gsk/zebulon/soliddose/zovirax'
  'y:/Datapost/data/gsk/zebulon/soliddose/zyban'
  'y:/Datapost/data/gsk/zebulon/soliddose'
  'y:/Datapost/data/gsk/zebulon/mdi'
  'y:/Datapost/data/gsk/metadata/reference/merps'
  )
  access=readonly
;

libname prd (
  'z:/Datapost/data/gsk/zebulon/mdi/advairhfa'
  'z:/Datapost/data/gsk/zebulon/mdi/albuterol'
  'z:/Datapost/data/gsk/zebulon/mdpi/advairdiskus'
  'z:/Datapost/data/gsk/zebulon/mdpi/sereventdiskus'
  'z:/Datapost/data/gsk/zebulon/soliddose/avandamet'
  'z:/Datapost/data/gsk/zebulon/soliddose/avandaryl'
  'z:/Datapost/data/gsk/zebulon/soliddose/bupropion'
  'z:/Datapost/data/gsk/zebulon/soliddose/lamictal'
  'z:/Datapost/data/gsk/zebulon/soliddose/lotronex'
  'z:/Datapost/data/gsk/zebulon/soliddose/lovaza'
  'z:/Datapost/data/gsk/zebulon/soliddose/methylcellulose'
  'z:/Datapost/data/gsk/zebulon/soliddose/ratiolamotrigine'
  'z:/Datapost/data/gsk/zebulon/soliddose/retigabine'
  'z:/Datapost/data/gsk/zebulon/soliddose/retrovir'
  'z:/Datapost/data/gsk/zebulon/soliddose/rosiglitazone'
  'z:/Datapost/data/gsk/zebulon/soliddose/trizivir'
  'z:/Datapost/data/gsk/zebulon/soliddose/valtrex'
  'z:/Datapost/data/gsk/zebulon/soliddose/wellbutrin'
  'z:/Datapost/data/gsk/zebulon/soliddose/zantac'
  'z:/Datapost/data/gsk/zebulon/soliddose/zofran'
  'z:/Datapost/data/gsk/zebulon/soliddose/zovirax'
  'z:/Datapost/data/gsk/zebulon/soliddose/zyban'
  'z:/Datapost/data/gsk/zebulon/soliddose'
  'z:/Datapost/data/gsk/zebulon/mdi'
  'z:/Datapost/data/gsk/metadata/reference/merps'
  )
  access=readonly
;

proc datasets memtype=data lib=&MYLIB;
/***  CONTENTS data=_ALL_ OUT=mylib_contents(KEEP=MEMNAME NOBS CRDATE) NOPRINT;***/
  CONTENTS data=_ALL_ OUT=mylib_contents;  /* better for debugging but hides the counts at bottom of Results */
run;

/* The CONTENTS statement outputs a row for each column in each data set,
 * therefore the SORT procedure is required
 */
proc sort data=mylib_contents NODUPKEY; by MEMNAME; run;
data mylib_contents(drop=CRDATE);
  set mylib_contents(keep= LIBNAME MEMNAME NOBS CRDATE);
  CRDATE2=datepart(CRDATE);
run;

proc sort data=mylib_contents; by CRDATE2; run;
proc printto PRINT="&SAVEPATH/count_all_datasets.&MYLIB..&SYSDATE..log" NEW; run;
proc print data=_LAST_(obs=max) width=minimum;
  format CRDATE2 DATE9. NOBS COMMA9.;
  where MEMNAME ne: 'TR_';
  by CRDATE2;
run;
proc printto; run;



/* Older version */
 /*** libname MVDS "DWJ2.MED2004.MVDS.LIBRARY.NEW" DISP=SHR; ***/
libname T "&HOME/tmp/testing/tst";

%global DSETS TOT;
%let TOT=0;
%let DSETS=;

proc sql NOPRINT;
  select memname into :DSETS separated by ' '
  from dictionary.members
 /***   where libname like 'T' and memname like 'ind%'; ***/
  where libname like 'T';
quit;

 
 /* Called for each dataset found in library */
%macro PrintCountObs(dsn);
  %local numobs;

  %let numobs=%sysfunc(attrn(%sysfunc(open(T.&dsn)), NLOBSF));

  %if not &numobs %then
    %do;
      %put ERROR: &dsn has &numobs obs;
    %end;
  %else 
    %do;
      %put !!! Number of observations in &dsn: %sysfunc(putn(&numobs,COMMA10.));
      %let TOT=%eval(&TOT+&numobs);
    %end;
%mend PrintCountObs;


%macro ForEach(s);
  %local i f;

  %let i=1;
  %let f=%scan(&s, &i, ' '); 

  %do %while ( &f ne  );
    %let i=%eval(&i+1);
    %PrintCountObs(&f)
    %let f=%scan(&s, &i, ' '); 
  %end;
%mend ForEach;
%ForEach(&DSETS)

%put !!! grand tot recs: %sysfunc(putn(&TOT,COMMA10.));
