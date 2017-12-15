/*
 *------------------------------------------------------------------
 *   Program Name:  ehrbyrgnbytimecd.sas
 *
 *        Summary:  Per Terry & Ken C. criteria, find tot hours
 *                  where d-dt > 199822, by rgncode, by time_cd.
 *                  Requires jobcost, jobperf and costtime.
 *
 *      Generated:  Tue Sep 22 10:42:08 1998 (Bob Heckel)
 *------------------------------------------------------------------
 */
option linesize=80 pagesize=32767 nodate source source2 notes mprint
       symbolgen mlogic obs=max errors=3 nostimer nonumber;

title; footnote;

/* Need d_date prior to 9822.  Do DMS100 first. */
data work.tmp1;
  set dart.jobcost (keep=job_id prodline rgncode d_date);
  where d_date > 199821 and
        prodline = 'H';
run;

/*
 * Make sure only grabbing engineering hours.
 * Left join on jobperfd (Eng only I think).  Probably could have eliminated
 * this join by using emp_func in('EAE', 'PAE'...) but still need
 * emp+ctr+vnd calc...don't I??
 */
proc sql noprint;
  create table work.tmp2 as
    select a.job_id,
           a.prodline,
           a.rgncode,
           b.emphrse,
           b.ctrhrse,
           b.vendhrse
      from work.tmp1 as a,
           dart.jobperfd as b
        where a.job_id=b.job_id;
quit;

/* Not using; using costtime's hours */
/***data work.tmp3 (drop=emphrse ctrhrse vendhrse);
  set work.tmp2;
  eacthrs = emphrse + ctrhrse + vendhrse;
run;***/

/***data work.tmp3a;
  set work.tmp3;
   Create a list of all numeric variables 
  array nums _numeric_;
   Process list, replace blanks with zeros
  do over nums;
     if nums = . then
        nums = 0;
  end;
run;***/

/*
 * Proc after this one goes from jobs nos to costtime.  Don't want 
 * more than _one_ job on tmp2 when going left join to costtime.  Since 
 * not doing hrs calc, doesn't matter if lose some lines.
 */
proc sort data=work.tmp2 nodupkey;
  by job_id;
run;

/*
 * Where a job is on jobcost and perfd, find all timesheet entries on 
 * costtime.  Use costtime's hours, not jobcost/perfd.
 */
proc sql noprint;
  create table work.tmp4 as
    select a.job_id,
           a.prodline,
           a.rgncode,
           b.time_cd,
           b.hours
      from work.tmp2 as a
           left join
           dart.costtime as b
        on a.job_id=b.job_id;
quit;

/* Don't elim duplicates.  Valid to have same hrs on same job > 1 time */
/* Indicates that a job is set up on jobcost/perf but no hrs booked yet */
data work.tmp4a;
  set work.tmp4;
  where hours > 0;
run;

/*
 * SQL Rule -- Must use same varis in select as do in group & order, 
 * except summed vari.
 */
proc sql noprint;
  create table work.tmp5 as
    select rgncode, time_cd, sum(hours) as shours
      from work.tmp4a
        group by rgncode, time_cd
          order by rgncode, time_cd asc;
quit;

/* Outputs rgncode, time_cd and tot hours */
title 'DMS 100 Engineering Jobs with D-Date > 9821';
proc print data=work.tmp5 noobs label;
  label rgncode='Region' time_cd='Time Code' shours='Eng Hrs.';
  by rgncode;
  sum shours;
run;


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* DMS 10 Start */
data work.tmp1;
  set dart.jobcost (keep=job_id prodline rgncode d_date);
  where d_date > 199821 and
        prodline = 'T';
run;

/*
 * Make sure only grabbing engineering hours.
 * Left join on jobperfd (Eng only I think).  Probably could have eliminated
 * this join by using emp_func in('EAE', 'PAE'...) but still need
 * emp+ctr+vnd calc...don't I??
 */
proc sql noprint;
  create table work.tmp2 as
    select a.job_id,
           a.prodline,
           a.rgncode,
           b.emphrse,
           b.ctrhrse,
           b.vendhrse
      from work.tmp1 as a,
           dart.jobperfd as b
        where a.job_id=b.job_id;
quit;

/*
 * Proc after this one goes from jobs nos to costtime.  Don't want 
 * more than _one_ job on tmp2 when going left join to costtime.  Since 
 * not doing hrs calc, doesn't matter if lose some lines.
 */
proc sort data=work.tmp2 nodupkey;
  by job_id;
run;

/*
 * Where a job is on jobcost and perfd, find all timesheet entries on 
 * costtime.  Use costtime's hours, not jobcost/perfd.
 */
proc sql noprint;
  create table work.tmp4 as
    select a.job_id,
           a.prodline,
           a.rgncode,
           b.time_cd,
           b.hours
      from work.tmp2 as a
           left join
           dart.costtime as b
        on a.job_id=b.job_id;
quit;

/* Don't elim duplicates.  Valid to have same hrs on same job > 1 time */
/* Indicates that a job is set up on jobcost/perf but no hrs booked yet */
data work.tmp4a;
  set work.tmp4;
  where hours > 0;
run;

/*
 * SQL Rule -- Must use same varis in select as do in group & order, 
 * except summed vari.
 */
proc sql noprint;
  create table work.tmp5 as
    select rgncode, time_cd, sum(hours) as shours
      from work.tmp4a
        group by rgncode, time_cd
          order by rgncode, time_cd asc;
quit;

/* Outputs rgncode, time_cd and tot hours */
title 'DMS 10 Engineering Jobs with D-Date > 9821';
proc print data=work.tmp5 noobs label;
  label rgncode='Region' time_cd='Time Code' shours='Eng Hrs.';
  by rgncode;
  sum shours;
run;
