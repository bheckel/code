%macro bobh0308102003; /* {{{ */
//BQH0EFGH JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=1,CLASS=F,REGION=0M
//STEP1    EXEC SAS90,TIME=100,OPTIONS='MEMSIZE=0,ALTPRINT=OLST,
//                                                ALTLOG=OLOG'                              
//OLST     DD DISP=SHR,DSN=BQH0.INC.SASLIST
//OLOG     DD DISP=SHR,DSN=BQH0.INC.SASLOG
//WORK     DD SPACE=(CYL,(100,100),,,ROUND)
//SYSIN    DD *
%mend bobh0308102003; /* }}} */

options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: stresstest.sas
  *
  *  Summary: Torture SAS for speed comparisons across boxes.
  *           Don't run if diskspace is low.
  *
  *   WinXP work laptop 2010-08-03
  *
  *   real time           5:26.35
  *   user cpu time       22.12 seconds
  *   system cpu time     50.24 seconds
  *   Memory                            1371k
  *
  *  Created: Wed 26 Jan 2005 14:48:19 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter fullstimer;

data tmp;
  set SASHELP.shoes SASHELP.shoes SASHELP.shoes SASHELP.shoes;
  do i=1 to 100000;
    num=i;
    l=sqrt(log(num)*10000/5.321);
    output;
  end;
run;
