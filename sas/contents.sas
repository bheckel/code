//BQH0CONT JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=1,CLASS=F,REGION=0M
//STEP1    EXEC SAS,TIME=100,OPTIONS='MEMSIZE=0'
//WORK     DD SPACE=(CYL,(100,100),,,ROUND)
//SYSIN    DD *

options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: contents.sas
  *
  *  Summary: Obtain SAS data library information, first for whole lib, then 
  *           at a dataset level.
  *
  *  Created: Wed 19 Mar 2003 09:26:43 (Bob Heckel)
  * Modified: perpetually
  *---------------------------------------------------------------------------
  */
options source ls=max NOcenter NOreplace;

***libname L 'DWJ2.NAT2003.MVDS.LIBRARY.NEW' DISP=SHR WAIT=1; /* closed yrs! */
***libname L '/u/dwj2/mvds/NAT/2003';  /* open yrs only!! */
***libname L '/u/dwj2/register/NAT/2004';  /* all yrs */
***libname L 'DWJ2.USTOT.SASLIB' DISP=SHR WAIT=1;
***libname L 'DWJ2.TEMPLATE.LIB';
 /* Non-reviser TSA formats catalog 'FORMATS' resides here... */
***libname L 'DWJ2.NAT1989.FORMAT.LIB';
 /* ...and here: */
***libname L 'DWJ2.NAT1989.FORMAT.ODSLIB';
***libname L '/u/bqh0/saslib';
***libname L 'DWJ2.NAT03.FORMAT.LIBRARY' DISP=SHR WAIT=20;
***libname L 'c:/temp';
***libname L 'I:/cabinets/tsb/SASFILES/';
***libname L 'BQH0.SASLIB';  /* keep at bottom */
***libname L 'X:\BPMS\VA\Data\Providers\SAS';


 /* See cntlout.format.sas or ckformat.sas instead of this */
***libname L 'DWJ2.MOR2003R.FMTLIB' DISP=SHR WAIT=20; /* always 2003! */
 
***proc contents data=L._ALL_; run;
***proc contents data=L.register; run;
***proc contents data=L.history; run;
***proc contents data=L.gaold; run;  /* MVDS member */
***proc contents data=L.WANEW; run;  /* MVDS member */
***proc contents data=L.data; run;  /* oldstyle US Total, bhb6 rev counter */
***proc contents data=SASHELP._ALL_; run;  /* no libname required above */
***proc contents data=L.UST2003OLDFET;  /* us tot newstyle */
***proc contents data=L.prescriber_validation;
proc contents data=SASHELP.shoes;

%put !!!SYSCC: (&SYSCC);


  /* vim: set tw=72 ft=sas foldmethod=marker: */ 
