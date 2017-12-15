/*----------------------------------------------------------------------------
 * Program Name: job_timecd_class_hrs.sas
 *
 *      Summary: For each 1999 PacBell job, show timecd, class then sum the
 *               hours.  Sends output to the user's home directory.
 *               Requested by Kristi Jochimsen; based loosely on 
 *               timecd_count_hrs_p40.sas.
 *               !! Make sure JOBCOST & COSTTIME have been updated !!
 *
 *      Created: Fri Mar 05 1999 15:04:05 (Bob Heckel esn 352-8901)
 *     Modified: Mon Mar 08 1999 09:35:39 (Bob Heckel -- criteria changed to
 *                                         imitate Job Costing.)
 *----------------------------------------------------------------------------
 */
options linesize=80 pagesize=32767 nodate source source2 notes mprint
       symbolgen mlogic obs=max errors=3 nostimer nonumber;

title; footnote;

/* Pac Bell Region only, using Job Cost criteria, job-to-date. */
data work.tmp;
  set dart.jobcost (keep= job_id rgncode class d_date ord_stat prodline 
                          distcode);
  where rgncode = 'C206' and
        d_date ^= . and
        ord_stat ^= 'CAN' and
        job_id not like '$%' and
        prodline in ('H', 'T', 'A', 'Y', 'B') and
        distcode ^= 'OM68';
run;

/* For each job_id, get all related line items in costtime.ssd01 */
proc sql;
  create table work.tmp2 as
    select a.job_id,
           a.rgncode,
           a.class,
           b.hours,
           b.time_cd
      from work.tmp as a
        left join
          dart.costtime as b
            on a.job_id = b.job_id;
quit;

/* Uncomment if you'd like a downloadable file; otherwise this will print to
 * output window.
 */
/***proc printto file='~/job_timecd_class_hrs.xls' NEW; run;***/

/* Get sum of hours for each job/time_cd/class grouping. */
proc sql;
  create table work.tmp3 as
    select job_id, time_cd, class, sum(hours) as shours
      from work.tmp2
        group by job_id, time_cd, class;
quit;

proc print data=work.tmp3 noobs; run;
