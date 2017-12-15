options nosource;
 /*---------------------------------------------------------------------
  *     Name: proc_sort.sas
  *
  *  Summary: Demo of NODUPKEY sort option (and an alternate approach
  *           using proc sql).
  *
  *           http://support.sas.com/documentation/cdl/en/proc/69850/HTML/default/viewer.htm#p02bhn81rn4u64n1b6l00ftdnxge.htm
  *
  *           See also proc_sort_alternative.sas
  *
  *  Created: Tue 22 Oct 2002 10:31:45 (Bob Heckel)
  * Modified: Fri 04 Oct 2013 14:57:24 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options source sortsize=max fullstimer ls=80;

title 'Raw with duplicate larry wall 345 records';
data work.sample;
  input fname $1-10  lname $15-25  @30 numb 3.;
  datalines;
larry         wall           346
larry         wall           345
larry         wall           678
richard       dawkins        345
richard       feynman        678
larry         wall           345
  ;
run;
proc print; run;
 

 /* Test if already sorted.  You'll get this nonfatal error if it's not:
  * ERROR: BY variables are not properly sorted on data set WORK.SAMPLE.
  */
data _NULL_;
  set sample;
  by lname;
run;
 /* But faster to check this way: */
proc contents; run;


title 'Descending (unlike SQL, must precede variable, and keywords DESC ';
title2 'also ASC does not exist).  We are implicitly "ASCENDING" lname';
proc sort;
  by DESCENDING numb lname;
run;
proc print; run;


title 'NODUPKEY -- want unique observations only';
proc sort data=work.sample out=work.sortednodups NODUPKEY;
  /* Obs is partially unique.  Eliminates 3 dups (1 richard and 2 larry). */
  ***by lname fname;
  /* Obs must be completely unique.  Eliminates 2 dups (2 larry). */
  by lname fname numb;
run;
proc print data=sortednodups; run;

 /* Good for debugging what you're removing */
proc sort data=sample NODUPKEY DUPOUT=justthedups;
  by lname fname numb;
run;
title "ds:justthedups";proc print data=justthedups(obs=max) width=minimum heading=H; run;title;


title "Compare with SQL DISTINCT";
proc sql NUMBER;
  create table work.sortednodups as
  select distinct lname, fname, numb
  from sample
  order by lname asc 
  ;
quit;
proc print data=sortednodups; run ;


title 'Capture the dups that are removed without DUPOUT=';
proc sort data=work.sample out=work.sorted;
  by lname fname numb;
run;
data work.tmp;
  set work.sorted;
  by lname fname numb;

  if first.lname and last.lname then
    delete;

  if first.fname and last.fname then
    delete;

  if first.numb and last.numb then
    delete;
run;
title2 'This is the original ds:';
proc print data=sample; run;
title2 'These are the dups:';
proc print data=tmp; run;



 /* If you don't require the data within BY groups to be kept in the same
  * order as it was before, use the NOEQUALS option. This will save you CPU
  * and elapsed time, particularly on very large data sets. This option causes
  * SAS not to worry about keeping observations with the same BY variable
  * values in the same order. Usually you don't need the order maintained, so
  * you can specify NOEQUALS. 
  */
options noreplace fullstimer;

title 'SASHELP.class is already sorted by name and a normal sort '
      'preserves that name order';
proc sort data=SASHELP.class out=classout; by sex; run;
proc print data=_LAST_(obs=max); run;

title 'SASHELP.class is already sorted by name and a NOEQUALS sort '
      'does not preserve that name order (hence saving time)';
proc sort data=SASHELP.class out=classout2 NOEQUALS; by sex; run;
proc print data=_LAST_(obs=max); run;



%macro m;
  %global DS;
  %do i=1 %to 1000;
    %let DS=&DS SASHELP.shoes;
  %end;
%mend;
%m
title 'Speed test - compare the last 2 (non-entire-job-summary) timers';
data big;
  set &DS;
run;

proc sort data=big out=bigout; by region; run;
proc sort data=big out=bigout2 NOEQUALS; by region; run;

proc sort data=big(where=('AFRICA'=upcase(Region) and Sales>5000)) NOEQUALS; 
  by inventory;
run;



 /* V9+ */
 /*
East 14th Street
East 2nd Street
 */
proc sort data=one out=two SORTSEQ=linguistic (numeric_collation=on);
  by street;
run;
