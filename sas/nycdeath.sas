//BQH0NYC   JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=5,CLASS=V,REGION=0M
//ANNUAL    EXEC SAS,TIME=100,OPTIONS='MSGCASE,MEMSIZE=0'
//WORK      DD SPACE=(CYL,(100,100),,,ROUND)
//SYSIN     DD *
 /*---------------------------------------------------------------------
  *     Name: nycdeath.sas
  *
  *  Summary: Request from Francine Winter
  *
  *  Created: Thu 27 Jun 2002 17:33:24 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options linesize=72 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=5 number serror merror
        noreplace datastmtchk=allkeywords;

title; footnote;

data work.indata;
  * Toggle;
  infile 'BF19.YCX0017.MORMER';
  ***infile 'BF19.YCX0118.MORMER';

  input @49 deathmo $char2.  @51 dod $char2.  @64 age $char3.  
        @74 birthstate $char2.  @76 typlaced $char1.  
        @94 hispanic $char1.  @95 race $char1.  @96 educ $char2.  
        @117 workinjury $char1.
        ;
  if deathmo = '09';
run;

data work.september;
  set work.indata;

  label deathmo    = 'Month of Death';
  label dod        = 'Day of Death';
  label age        = 'Age of Death';
  label birthstate = 'State of Birth';
  label typlaced   = 'Type/place of Death';
  label hispanic   = 'Hispanic';
  label race       = 'Race';
  label educ       = 'Education';
  label workinjury = 'Injury at Work?';

run;


proc freq data=work.september;
  table dod dod*educ / NOCUM NOPERCENT NOROW NOCOL;
run;

proc freq data=work.september;
  table dod dod*workinjury / NOCUM NOPERCENT NOROW NOCOL;
run;

proc freq data=work.september;
  table dod dod*race / NOCUM NOPERCENT NOROW NOCOL;
run;

proc freq data=work.september;
  table dod dod*hispanic / NOCUM NOPERCENT NOROW NOCOL;
run;

proc freq data=work.september;
  table dod dod*typlaced / NOCUM NOPERCENT NOROW NOCOL;
run;

proc freq data=work.september;
  table dod dod*birthstate / NOCUM NOPERCENT NOROW NOCOL;
run;

proc freq data=work.september;
  table dod dod*age / NOCUM NOPERCENT NOROW NOCOL;
run;
