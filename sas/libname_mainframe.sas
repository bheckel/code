//BQH0FREQ JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=1,CLASS=F,REGION=0M
//STEP1    EXEC SAS,TIME=100,OPTIONS='MEMSIZE=0'
//WORK     DD SPACE=(CYL,(100,100),,,ROUND)
//SYSIN    DD *

 /* 1. =+=+=+=+=+=+=+=+ libname =+=+=+=+=+=+=+ */
***libname L 'DWJ2.EIGHTLIB';  /* deprecated */
***libname L 'DWJ2.INTRNLIB';
***libname L 'DWJ2.MOR2004.LIBRARY' DISP=SHR;
***libname L 'DWJ2.MOR2004.LIBRARY.TEMP' DISP=SHR;
***libname L 'DWJ2.MOR2004.QUARTER.LIBRARY' DISP=SHR;
***libname L 'DWJ2.RESIDE.MOR2004.LIBRARY' DISP=SHR;
***libname L 'DWJ2.MORT2003.FREQ.US';  /* US total */
***libname L 'DWJ2.CAUS2003.LIBRARY';
***libname L 'DWJ2.CAUS2002.US';
***libname L 'DWJ2.CAUS2001.UC113.US';
***libname L 'DWJ2.NAT2003.LIBRARY' DISP=SHR;
***libname L 'DWJ2.NAT2002.US' DISP=SHR;
***libname L 'DWJ2.FET2000.LIBRARY' DISP=SHR;
***libname L 'DWJ2.FET2002.US' DISP=SHR;
***libname L 'DWJ2.MOR2003.LIBRARY' DISP=SHR;  /* old freq lib */
***libname L '/u/dwj2/register/NAT/2004';
***libname L '/u/dwj2/register/MOR/2003';
***libname L '/u/dwj2/register/FET/2005';
***libname L '/u/dwj2/register/MED/2005';
***libname L '/u/dwj2/mvds/NAT/2004';  /* open yrs ONLY */
***libname L '/u/dwj2/mvds/MOR/2004';  /* open yrs ONLY */
***libname L '/u/dwj2/mvds/FET/2004';  /* open yrs ONLY */
***libname L 'DWJ2.NAT2003.MVDS.LIBRARY.NEW' DISP=SHR; /* closed yrs ONLY */
***libname L 'DWJ2.MOR2003.MVDS.LIBRARY.NEW' DISP=SHR; /* closed yrs ONLY */
***libname L 'DWJ2.FET2003.MVDS.LIBRARY.NEW' DISP=SHR; /* closed yrs ONLY */
***libname L 'DWJ2.MED2003.MVDS.LIBRARY.NEW' DISP=SHR; /* closed yrs ONLY */
***libname L 'BQH0.SASLIB' DISP=SHR;
***libname L 'I:\Cabinets\tsb\SASFILES';
libname L 'DWJ2.USTOT.SASLIB' DISP=SHR;  /* 2005+> style us tot */
***libname L '/u/bqh0/saslib';  /* nothing that can't be deleted */
***libname L 'DWJ2.UTIL.SASLIB' DISP=SHR; /* closest distance ds */
***libname L 'DWJ2.MOR2005.LAST.REVISER.FILE' DISP=SHR;/* rev num increm */
***libname L 'BF19.FILETRAK.DAEA' DISP=OLD;
 /* =+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+ */


 /* 2. =~=~=~=~=~=~=~=~ freq =~=~=~=~=~=~=~=~=~ */
options NOcenter NOreplace;

 /* Better to use print.sas for UStot queries */
proc freq data=L.UST2002OLDFET;
***proc freq data=L.mortnc;
***proc freq data=L.NHNEW;
  table mothhisp / NOCUM NOROW NOCOL NOPERCENT;
run;
