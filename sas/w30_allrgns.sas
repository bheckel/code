/*----------------------------------------------------------------------------
 *  Program Name: w30_allrgns.sas
 *
 *       Summary: Based on containers_w30.sas
 *
 *                Containers' Final Jobs custfin output always shows zero for
 *                hours because all Container charges are ICID bills to other
 *                regions.  This problem inflates favorability in Thom's
 *                slideshow.  Thom will use this report to accurately provide 
 *                B/(W) based on the ICID W30 worked hours (from costtime, not
 *                jobcost/perf/d).
 *
 *                MAKE SURE JOBCOST, COSTTIME & JOBPERF ARE CURRENT.
 *                No other modis reqd prior to running (except yrend changes).
 *
 *       Created: Fri, 19 Nov 1999 09:19:18 (Bob Heckel)
 *      Modified: Tue, 01 Feb 2000 16:18:41 (Bob Heckel)
 *----------------------------------------------------------------------------
 */
options linesize=80 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=5 nostimer number serror merror
        noreplace;

title; footnote;

libname master '/disc/data/master';

/* Last fiscal week of prior year. */
%let YYYYWW = 199952;

%include '/DART/users/bh1/tabdelim.sas';


data work.jc_ours;
  set master.jobcost (keep=job_id d_date ord_stat prodline act_hrs
                           i_cost ftsdate holdco rgncode);
  where rgncode in ('C201', 'C202', 'C203', 'C204', 'C206', 'C209', 'C210',
                    'C211','C212', 'C214', 'C218', 'C219');
run;

/* Not all fields used below; anticipating future requests from Thom G. */
proc sql;
  create table work.ljoined as
    select a.job_id,
           a.d_date,
           a.ord_stat,
           a.prodline,
           a.act_hrs,
           a.i_cost,
           a.ftsdate,
           a.holdco,
           a.rgncode,
           b.emphrsi,
           b.ctrhrsi,
           b.vendhrsi,
           b.hrstrgi
    from work.jc_ours as a
         left join
         master.jobperf as b
    on a.job_id = b.job_id;
quit;
  
proc sql;
  create table work.ljoined2 as
    select a.*,
           b.time_cd,
           b.hours
    from work.ljoined as a,
         master.costtime as b
    where a.job_id = b.job_id;
quit;

 /* W30 only plus general criteria for both Open & Final Job runs. */
data work.ljoined3;
  set work.ljoined2;
  where time_cd = 'W30' and
        d_date ^= . and
        ord_stat ^= 'CAN' and
        job_id not like '$%';
  iacthrs = sum(emphrsi,ctrhrsi,vendhrsi);
run;

/* NOT IN 2000---Create production week macro var 1 week i.e. 7 days in the past. */
data _null_;
/***   call symput('FWEEK', input(put(today() - 7, ntyyww.), 6.)); ***/
  /* Imitate costx final criteria. */
  call symput('CLOSEWK', input(put(today(), ntyyww.), 6.));
run;

/* Final Jobs-specific criteria. */
data work.ljoined4(keep=job_id rgncode ftsdate time_cd hours);
  set work.ljoined3;
    where ftsdate ^= . and
          ftsdate > &YYYYWW and
          /* NOT IN 2000----&FWEEK is current wk minus 1; same as rptg wk plus 1. */ 
          ftsdate < &CLOSEWK and    
          prodline in ('H', 'T', 'A', 'Y', 'B', 'O');
run;

proc sort data=work.ljoined4;
  by rgncode;
run;

proc sql;
  create table work.ljoined5 as
    select distinct job_id label="COEO",
                    rgncode label="Region Code",
                    ftsdate label="FTS Date", 
                    time_cd label="Time Code", 
                    sum(hours) as shours label="Sum of Hrs"
    from work.ljoined4
      group by job_id
        order by rgncode asc;
quit;

%tabdelim(work.ljoined5, '/DART/users/bh1/output.xls');

