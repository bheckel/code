//BQH0ABCD JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=1,CLASS=F,REGION=0M
//STEP1    EXEC SAS,TIME=100,OPTIONS='MEMSIZE=0'
//WORK     DD SPACE=(CYL,(100,100),,,ROUND)
//SYSIN    DD *
options nosource;
 /*---------------------------------------------------------------------
  *     Name: proc_source.sas (s/b symliked as ls.mvs.sas)
  *
  *  Summary: Demo of the OS/390-specific proc that lists files in a
  *           directory.
  *
  *  Created: Wed 05 Mar 2003 10:02:22 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options source;

proc source indd='bqh0.pgm.trash' NODATA NOSUMMARY;
  /* Show files in the PDS that start with TEST */
  select TEST: ;
run;

