options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: datasetexist.sas
  *
  *  Summary: Check for existence of a SAS dataset.
  *
  *  Created: Tue 29 Jun 2004 13:31:37 (Bob Heckel)
  * Modified: Wed 13 Aug 2014 08:21:39 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOreplace;


data _null_;
  /*                  keyword  */
  rc=exist('work.new','data');
  if rc=1 then put 'data set exists';
  else put 'data set does not exist';
run;



%let myds = SASHELP.shoes;

%macro Dex;
  %if %sysfunc(exist(&myds)) %then
    %do;
      %put !!! The dataset &myds does exist.;
    %end;
  %else
    %put !!! The dataset &myds does NOT exist.;
%mend;
/***%Dex;***/


 /* Best */
%macro DNex;
  %if not &sysfunc(exist(&myds)) %then %do;
    data &myds;
      length foo $8 bar $80;
      stop;
    run;
  %end;
%mend;
/***%DNex;***/



/***libname l 'c:/cygwin/home/rsh86800';***/
/***data wtf; set SASHELP.shoes; stop; run;***/
/***%let myds = wtf;***/
%macro DexSQL(ds);
  %local colcnt;

  proc sql NOPRINT;
    select count(*) into :colcnt
    from dictionary.columns 
    where memname eq upcase("&ds");
    ;
  quit;
  %if &colcnt eq 0 %then %do;
    data _NULL_; 
      put "ERROR: WORK.&ds does not exist";
      abort abend 002; 
    run;
  %end;
%mend;
/***%DexSQL(&myds);***/
