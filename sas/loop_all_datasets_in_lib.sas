options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: loop_all_datasets_in_lib.sas
  *
  *  Summary: Do something to each dataset in a library
  *
  *           See also allchecker.sas
  *
  *  Created: Thu 14 Apr 2008 14:22:32 (Bob Heckel)
  * Modified: Tue 04 Aug 2015 11:55:46 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

%macro qc;
  proc sql NOPRINT;
    select memname into :ds separated by ' '
    from dictionary.members
    where libname like 'PQA';
  quit;
  %put _USER_;

  %local i f;
  %let i=1;
  %let f=%scan(&ds, &i, ' ');

  %do %while ( &f ne  );
    %let i=%eval(&i+1);

    proc freq data=PQA.&f; run;

    %let f=%scan(&ds, &i, ' ');
  %end;
%mend;



 /* Simple list of all datasets in WORK */
proc sql NOPRINT;
  select memname into :DSETS separated by ' '
  from dictionary.members
  where libname like 'WORK';
quit;


 /* or */

proc sql NOPRINT;
  select memname into :DSETS separated by ' L.'
  from dictionary.members
  /* Upcase! */
  where libname like 'L' and memname like 'IND%';
quit;
%put &DSETS;


 /* Display one of the 2 above sqls: */

data t;
  /* The first ds won't have the 'L' libname prepended so do it here */
  set L.&DSETS;
  if upcase(elemstrval) eq 'CONFORMS';
run;
proc print data=_LAST_(obs=1000); var specname varname colname; run;

 /* to use proc sql instead of the datastep, use WORK.t after removing the IF */




endsas;
OBSOLETE version
libname MVDS "DWJ2.MED2000.MVDS.LIBRARY.NEW" DISP=SHR;

%global DSETS;

proc sql NOPRINT;
  select memname into :DSETS separated by ' '
  from dictionary.members
  /* DEBUG */
  /***   where libname like 'MVDS' and memname like 'A%NEW' ***/
  /* Note: everything in dictionary is probably uppercased by SAS */
  where libname like 'MVDS' and memname like '%NEW';
quit;


 /* Build the set statement: */
%macro ForEach(s);
  %global SETSTMT;
  %local i d;

  %let i=1;
  %let d=%scan(&s, &i, ' '); 

  %do %while ( &d ne  );
    %let i=%eval(&i+1);
    %let SETSTMT=&SETSTMT MVDS.&d (keep=acme_uc) ;
    %let d=%scan(&s, &i, ' '); 
  %end;
%mend ForEach;
%ForEach(&DSETS)


data allds;
  set &SETSTMT;
  if acme_uc eq: 'F03';
run;


proc sql;
  select count(acme_uc) as cnt
  from allds
  ;
quit;
