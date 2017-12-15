//BQH0RCPT JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=1,CLASS=F,REGION=0M
//STEP1    EXEC SAS,TIME=100,OPTIONS='MEMSIZE=0'
//WORK     DD SPACE=(CYL,(100,100),,,ROUND)
//SYSIN    DD *

 /* See also dhms() */

%include 'c:/cygwin/home/bqh0/code/sas/connect_setup.sas';
signon cdcjes2;
rsubmit;

filename IN 'BF19.ALX0101.NATMER';

data work.readin;
  infile IN;
  input @3 certno $char6.  @16 state $char2.  @241 mo $char1.
        @242 dom $char2.  @244 yr $char1.
        ;
  /* Use date pieces to create SAS date. */
  rcptdt = mdy(mo, dom, yr+2000); 
run;
proc print; run;

proc sql;
quit;

endrsubmit;
signoff cdcjes2;


/* 01-OCT-15 */
day = substr(clm_svc_beg_dt_IN, 1, 2);
mo = month(input(clm_svc_beg_dt_IN, DATE9.));
yr = substr(clm_svc_beg_dt_IN, 8, 2);
clm_svc_beg_dt = mdy(mo, day, yr+2000);
/* or use YEARCUTOFF */

