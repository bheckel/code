//BQH0MVDS JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=20,CLASS=J,REGION=0M
//STEP1    EXEC SAS90,TIME=100,OPTIONS='MEMSIZE=0,ALTPRINT=OLST,
//                                                ALTLOG=OLOG'
//OLST     DD DISP=SHR,DSN=BQH0.INC.SASLST WAIT=10
//OLOG     DD DISP=SHR,DSN=BQH0.INC.SASLOG WAIT=10
//WORK     DD SPACE=(CYL,(100,100),,,ROUND)
//SYSIN    DD *

options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: loopallmvds.singleyr.sas
  *
  *  Summary: Look for something in all states' MVDS datasets.
  *
  *           This is often useless since you have to get lucky enough to have
  *           all 57 datasets not in use by someone else.
  *
  *           ___CHECK MVDS___
  *
  *           total records s/b equal to Register counts
  *
  *  Created: Wed 17 Nov 2004 17:22:51 (Bob Heckel)
  * Modified: Tue 31 May 2005 13:38:27 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter NOreplace mlogic mprint sgen NOreplace;

***libname L 'DWJ2.MOR2002.MVDS.LIBRARY.NEW' DISP=SHR WAIT=5;
 /* ADJUST */
%let EVT=MOR;  /* can't run NAT via Connect */
%let YYYY=2003;
%let VAR=race;

libname L "/u/dwj2/mvds/&EVT/&YYYY";
libname R "/u/dwj2/register/&EVT/&YYYY";


 /* A.  Toggle automatic selection... */
data tmp;
  set R.register(keep=mergefile stabbrev revising_status revtype obs=max);
  if mergefile ne '';
  /* ADJUST */
  ***if substr(reverse(trim(revising_status)),1,1) in ('O','B');
  if substr(reverse(trim(revising_status)),1,1) ne 'N';
  /* ADJUST */
  if revtype eq 'OLD';
run;

proc sql;
  /* ADJUST */
  select distinct 'L.'||stabbrev||'OLD' into :SS separated by ' '
  from tmp
quit;

 /* B.  ...or toggle specific datasets */
%macro bobh;
%let REVTYPE=OLD;
%let SS=%str(
             L.AK&REVTYPE/*{{{*/
             L.AL&REVTYPE
             L.AR&REVTYPE
             L.AS&REVTYPE
             L.AZ&REVTYPE
             L.CA&REVTYPE
             L.CO&REVTYPE
             L.CT&REVTYPE
             L.DC&REVTYPE
             L.DE&REVTYPE
             L.FL&REVTYPE
             L.GA&REVTYPE
             L.GU&REVTYPE
             L.HI&REVTYPE
             L.IA&REVTYPE
             L.ID&REVTYPE
             L.IL&REVTYPE
             L.IN&REVTYPE
             L.KS&REVTYPE
             L.KY&REVTYPE
             L.LA&REVTYPE
             L.MA&REVTYPE
             L.MD&REVTYPE
             L.ME&REVTYPE
             L.MI&REVTYPE
             L.MN&REVTYPE
             L.MO&REVTYPE
             L.MP&REVTYPE
             L.MS&REVTYPE
             L.MT&REVTYPE
             L.NC&REVTYPE
             L.ND&REVTYPE
             L.NE&REVTYPE
             L.NH&REVTYPE
             L.NJ&REVTYPE
             L.NM&REVTYPE
             L.NV&REVTYPE
             L.NY&REVTYPE
             L.OH&REVTYPE
             L.OK&REVTYPE
             L.OR&REVTYPE
             L.PR&REVTYPE
             L.RI&REVTYPE
             L.SC&REVTYPE
             L.SD&REVTYPE
             L.TN&REVTYPE
             L.TX&REVTYPE
             L.UT&REVTYPE
             L.VA&REVTYPE
             L.VI&REVTYPE
             L.VT&REVTYPE
 /***              L.WA&REVTYPE ***/
             L.WI&REVTYPE
             L.WV&REVTYPE
             L.WY&REVTYPE
             L.YC&REVTYPE
      );/*}}}*/
%mend bobh;

data tmp;
  set &SS;
  ***where mrace ne 'X';
run;

proc freq data=tmp;
  table &VAR / NOCUM;
run;



  /* vim: foldmethod=marker: */ 
