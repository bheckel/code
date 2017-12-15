//BQH0RW   JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=1,CLASS=F,REGION=0M
//STEP1    EXEC SAS,TIME=100,OPTIONS='MEMSIZE=0'
//*        Must be run on MF
//WORK     DD SPACE=(CYL,(100,100),,,ROUND)
//IN       DD DISP=SHR,DSN=BQH0.BYTES407
//OUT      DD DISP=(NEW,CATLG,DELETE),UNIT=NCHS,
//            DSN=BQH0.NJX0417.MEDMER,
//            DCB=(LRECL=407,RECFM=FB),
//            SPACE=(CYL,(10,2),RLSE)
//SYSIN    DD *

 /* See also buildbf19file.sas */

 /* Don't forget to also adjust JCL. */
%let lrl=407;

 /* No pre-allocation required, just use DISP=NEW on the first run and
  * OLD on subsequent runs to overwrite.
  * Or use  filename OUT 'BQH0.NJX0417.MEDMER' LRECL=407 DISP=NEW  for Connect.
  */
data tmp;
  infile IN TRUNCOVER;
  input @1 block $CHAR&lrl..;
run;

 /* Make sure it looks ok first by creating a small OUT file. */
options NOcenter;
proc surveyselect n=10 out=tmp; run;

data _NULL_;
  set tmp;
  file OUT;
  /* $CHARnnn is mandatory to preserve leading whitespace.  Must be same
   * as LRECL in JCL.
   */
  put @1 block $CHAR&lrl..;
run;
