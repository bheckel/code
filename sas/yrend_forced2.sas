/*----------------------------------------------------------------------------
 * Program Name:  yrend_forced2.sas  DISCARD yrend_forced.sas!!
 *
 *      Summary:  Since ISS auto FTSDates jobs w/ status K+4, must determine
 *                which Open Jobs s/b reported as Final in the current year
 *                before they actually FTSDT (in early '99).
 *
 *    Generated:  Wed 11/04/98 10:14:48 (Bob Heckel)
 *     Modified:  Thu, 09 Dec 1999 08:46:07 (Bob Heckel)
 *----------------------------------------------------------------------------
 */
option linesize=80 pagesize=32767 nodate source nosource2 notes mprint
       nosymbolgen nomlogic obs=max errors=3 nostimer number;

title; footnote;

libname arch '/extdisc/ARCHIVE';
libname central '/DART/users/bh1/tmp';
libname master '/disc/data/master';

%include '~bh1/tabdelim.sas';

/* Kaley, et. al. want Actual, not Committed K-dt so must do left join with
 * costx.ssd01 to capture ACTKDATE.
 */
proc sql;
  create table work.costxact as
   select a.rgncode,
          a.distcode,
          a.class,
          a.job_id,
          a.job_loc,
          a.st,
          a.holdco,
          a.prodline,
          a.d_date,
          a.h_date,
          a.k_date,
          a.ftsdate,
          a.ord_stat,
          a.hrstrgi,
          a.iacthrs,
          a.dolrtrgi,
          a.i_cost,
          a.hrstrge,
          a.eacthrs,
          a.dolrtrge,
          a.e_cost,
          b.job_id as j_id,
          b.actkdate
   from central.costx a
     left join
       master.jobcost b
         on a.job_id = b.job_id;
quit;

data work.tmp;
  set work.costxact;  /* Want most current version of costx plus Act K. */
  /* First 3 rptg. periods of 1999. */
  where ord_stat ne 'CAN' and
        /* Not yet Finalled. */
        ftsdate < 199200 and
        /* Wk 199950 is last wk of 1999 so 199950 minus 4 is 199947. */
/***         (actkdate between 199947 and 199950); ***/
        /* DEBUG */
        (k_date between 199947 and 199952) and
        /* Not O in 1999. */
        prodline in ('H', 'T', 'A', 'Y', 'B');

  label hrstrgi = 'Inst Target Hrs.';
  label iacthrs = 'Inst Act. Hrs.';
  label dolrtrgi = 'Inst Target $';
  label i_cost = 'Inst Act. $';

  label hrstrge = 'Eng Target Hrs.';
  label eacthrs = 'Eng Act. Hrs.';
  label dolrtrge = 'Eng Target $';
  label e_cost = 'Eng Act. $';

  label distcode = "OM";
  label actkdate = "Actual K-Date";
  label k_date = "Commit. K-Date";
run;

/* Reorder variables for tabdelim.sas output. */
/***
proc sql;
  create table work.tmp2 as
    select rgncode, distcode, class, job_id, job_loc, st, holdco, 
           supervsr, prodline, d_date, h_date, actkdate, k_date, ftsdate, 
           hrstrgi, iacthrs, ihrslft, dolrtrgi, i_cost
      from work.tmp;
quit;
***/
/* Reorder variables for tabdelim.sas output. */
data work.tmp2;
  retain rgncode distcode class job_id job_loc st holdco 
         prodline d_date h_date actkdate k_date ftsdate 
         hrstrgi iacthrs dolrtrgi i_cost 
         hrstrge eacthrs dolrtrge e_cost;
  set work.tmp(keep=rgncode distcode class job_id job_loc st holdco
                    prodline d_date h_date actkdate k_date ftsdate 
                    hrstrgi iacthrs dolrtrgi i_cost 
                    hrstrge eacthrs dolrtrge e_cost);
run;         

proc sort data=work.tmp2;
  by rgncode distcode holdco;
run;

%tabdelim(work.tmp2, '~/output.xls');

