options nosource;
 /*---------------------------------------------------------------------
  *     Name: proc_datasets.sas
  *
  *  Summary: Provides all the capabilities of the APPEND, CONTENTS, 
  *           DELETE and COPY procedures (but not necessarily better).
  *
  *           Demo of maintaining integrity constraints on a dataset.
  *
  *  Created: Tue 22 Oct 2002 12:19:45 (Bob Heckel)
  * Modified: Fri 02 Sep 2016 14:11:48 (Bob Heckel)
  *---------------------------------------------------------------------
  */

data t; set sashelp.shoes; run;
title "&SYSDSN";proc print data=t(obs=10) width=minimum heading=H;run;title;

proc datasets library=work;
  modify t;
    format sales comma.;
    rename region=regnew;
  run;

  change t=t2;

  /* v9.4 won't drop so use proc sql */
/***  modify t2;***/
/***    drop subsidiary;***/
/***  run;***/
quit;
proc sql;
  alter table t2
  drop subsidiary
  ;
quit;
title "t2";proc print data=t2(obs=10) width=minimum heading=H;run;title;



endsas;
proc datasets library=sgflib;
  modify snacks;
    format price dollar6.2 ;
    informat date mmddyy10.;
  run;

  append base=snacks data=newsnacks;
  change newsnacks = oldsnacks;

  copy out=archive; select oldsnacks / memtype =data; run;
quit;

proc datasets NOlist; delete Foo_DS Bar_DS; quit;

endsas;
data sample1;
  input fname $1-10  lname $15-25  @30 numb 3.;
  datalines;
mario         lemieux        123
ron           francis        123
jerry         garcia         123
  ;
run;

 /* Prevent blank fname. */
proc datasets library=work NOLIST;
  modify sample1;
  /* Integrity constraint.  TOGGLE to test */
  ***ic create foo=check(where=(fname ^= ''));
  /* Same */
  ***ic create foo=check(where=(fname NE ''));
quit;
***proc contents; run;


data sample2 (label='Sample 2');
  input fname $1-10  lname $15-25  @30 numb 3.;
  datalines;
another       guy            678
.             blanker        678
  ;
run;


proc append base=sample1 data=sample2; run;

proc datasets nolist nodetails force;
  append base=sample3 data=sample1;
quit;
 /* same */
/***proc append base=sample3 data=sample1; run;***/


 /* To see how sorting info appears in proc contents output. */
proc sort data=sample1; 
  by lname; 
run;
proc contents; run;


 /* Rename a dataset. */
proc datasets lib=work DETAILS;
  change sample1=renamed;
run;


proc datasets library=work;
  /* Colon is wildcard */
  delete sample: renamed;
  /* To delete all datasets from the library: TODO not working?? */
  ***kill;
  /* To delete all datasets from the library except sample1: */
  ***save sample1;
run;


endsas;
 /* Unsort */
proc sort data=SASHELP.shoes out=sortedshoes;
  by region;
run;

proc datasets;
  modify sortedshoes(sortedby=_NULL_);
quit;
proc contents; run;
