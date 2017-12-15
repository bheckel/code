/*----------------------------------------------------------------------------
 *          Name: spsht_to_sas.sas (formerly collins.sas)
 *                                               
 *       Summary: Assumes you've been passed a column of job_ids.
 *                Provides DART fields based on list of job_id.
 *                !!Make sure jobcost stamp is current!!
 *                1-On PC -- Receive spdsht or text file and save as
 *                  c:\todel\INTEXT.TXT in Excel.
 *                  note _Uppercase_
 *                  Explicitly specify TEXT.
 *                  I can use any spdsht with col A containing job_id, the
 *                  other columns are ignored by this pgm.
 *                  But make sure job_id field width is a max of 6.  
 *                2-On PC -- Use output_uplo1.bat to upload INTEXT.TXT
 *                3-Run this SAS job
 *                4-Use output_dl1.bat to download output.xls
 *                  to c:\todel  Manually rename to whatever Lee/Dave
 *                  is calling the originally emailed file this mo.
 *
 *       Created: Wed Apr 14 1999 10:14:37 (Bob Heckel)
 *----------------------------------------------------------------------------
 */
options linesize=80 pagesize=32767 nodate source source2 notes mprint
       symbolgen mlogic obs=max errors=3 nostimer number;

title; footnote;

%include '~/tabdelim.sas';

libname master '/disc/data/master/';
libname homelib '~';

filename TXTFILE '~/INTEXT.TXT';

/* Use list from Dave. Manually make sure each job is max 6 chars wide */
/* TODO test for 6 char automatically with Vim */
data work.tmp;
  infile TXTFILE;
  input @1 job_id $6.;
run;

proc sort data=work.tmp;
  by job_id;
run;

/* Link an OM number with job.  Should only be one OM number per job. */
proc sql;
  create table homelib.job_plus as
    select a.job_id label='Job Number',
           b.rgncode label='Region Code',
           b.k_date label='K Date'   /* No trailing comma. */
      from work.tmp as a
        left join
          master.jobcost as b
      on a.job_id=b.job_id;
quit;

%tabdelim(homelib.job_plus, '~/output.xls');
