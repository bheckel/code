options nosource;
 /*----------------------------------------------------------------------------
  *     Name: proc_contents.sas     
  * 		
  *  Summary: Display full dataset details (descriptor) and optionally output
  *           as an xls
  *
  *           See build_dataset_of_varnames.sas for an alternative approach to 
  *           out=foo
  *
  *  Created: Mon Sep 28 11:02:57 1998 (Bob Heckel)                                     
  * Modified: Fri 11 Mar 2011 09:15:59 (Bob Heckel)
  *----------------------------------------------------------------------------
  */
options source nosource2;

proc contents data=SASHELP._all_; run;
/***proc contents data=SASHELP._all_ DIRECTORY; run;***/
/***proc contents data=SASHELP._all_ NODS; run;***/
/***proc contents data=SASHELP._all_ SHORT; run;***/
/* proc contents data=SASHELP.shoes; run; */

title '.............identical except this one orders by position...............';

proc datasets library=SASHELP;
proc datasets library=SASHELP;
/***  contents data=shoes;***/
  contents data=_all_ varnum;
  run;
quit;


endsas;
ods listing close;
proc contents data=sashelp._all_; 
   ods output members=m;
run;
ods listing;



libname BOBH 'c:/Temp/';

 /* To SAS Output Window AND create a ds. */
proc contents data=BOBH._ALL_ out=work.prcnts; run;

 /* Alternatively can avoid proc contents for simple questions about a
  * dataset.  We're assuming the ds exists.
  */
%let dsid=%sysfunc(open(BOBH.freaky));
%let numobs=%sysfunc(attrn(&dsid, nobs));
%let rc=%sysfunc(close(&dsid));
%put Number of observations: &numobs;

***proc contents data=SASUSER._ALL_; run;


 /* See all datasets in lib: TODO elim the WORK.SASMACR */
proc sql NOPRINT;
  select memname into :DSETS separated by ' '
  from dictionary.members
  where libname like 'WORK';
quit;
%put _all_;
%macro ForEach(s);
  %local i f;

  %let i=1;

  %do %until (%qscan(&s, &i)=  );
    %let f=%qscan(&s, &i); 
    /*...........................................................*/
    proc contents data=&f;run;
    /*...........................................................*/
    %let i=%eval(&i+1);
  %end;
%mend ForEach;
%ForEach(&DSETS)
