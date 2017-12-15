options nosource;
 /*---------------------------------------------------------------------------
  *     Name: count_num_obs.sas
  *
  *  Summary: Count number of observations in a given dataset 
  *
  *  Created: Fri 28 Feb 2003 15:44:58 (Bob Heckel)
  * Modified: Mon 29 Jul 2013 12:50:09 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source fullstimer NOreplace;

proc surveyselect data=SASHELP.shoes out=tmp samprate=1 reps=50000; run;

%macro PrintCountObs(dsn);
  %local dsid numobs rc;

  /* Doesn't work for views. */
  %let dsid=%sysfunc(open(&dsn));
  %let numobs=%sysfunc(attrn(&dsid, nobs));
  %let rc=%sysfunc(close(&dsid));

  %if &rc ne 0 %then
    %put ERROR: &rc in PrintCountObs macro;
  %else 
    %put !!!a Number of observations: &numobs;
%mend PrintCountObs;
%PrintCountObs(work.tmp)


 /* compare */

data _null_;
  /* If we don't care about closing, it's simple, otherwise need to get a ds id
   * number in a separate statement.
   */
  numobs=attrn(open('work.tmp'), 'nobs');
  put "!!!" numobs=;
run;
data _null_;
  dsid=open('work.tmp');
  numobs=attrn(dsid, 'nobs');
  rc=close(dsid);
  put "!!!" numobs=;
run;


 /* compare */
data _null_;
  /*                   adjust number according to dataset size */
  call symput('MYOBS', put(numobs, 4.));
  stop;
  set tmp nobs=numobs;
run;


 /* compare */
proc sql;
  select count(*) into :SQLMYOBS
  from tmp
  ;
quit;
%put !!!b Number of observations: &MYOBS;
%put !!!c Number of observations: &SQLMYOBS;


 /* compare fastest BEST (as long as not using views or MODIFY) */
data _null_;
  if 0 then set tmp nobs=numobs;  /* 0 condition returns false so the SET statement does not execute */
  call symput('MYOBS2', numobs);
  stop;  /* avoid continous loop Log error */
run;
%put !!!MYOBS2 &MYOBS2;

 /* same but worse, throws a warning */
data _null_;
  call symput('MYOBS3', numobs);
  stop;
  set tmp nobs=numobs;
run;
%put !!!MYOBS3 &MYOBS3;

