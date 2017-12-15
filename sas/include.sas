//BQH0INC  JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=20,CLASS=J,REGION=0M,
//***BQH0INC  JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=120,CLASS=A,REGION=0M,
//***BQH0INC  JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=20,CLASS=J,REGION=0M,
//***BQH0INC  JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=5,CLASS=V,REGION=0M,
//***BQH0INC  JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=2,CLASS=D,REGION=0M,
//         NOTIFY=BQH0
/*ROUTE    PRINT R341
//PRINT    OUTPUT FORMDEF=A10111,PAGEDEF=V06683,CHARS=GT15,COPIES=1
//STEP1    EXEC SAS90,TIME=100,OPTIONS='MSGCASE,MEMSIZE=0,ALTPRINT=OLST,
//                                      ALTLOG=OLOG'
//WORK     DD SPACE=(CYL,(100,100),,,ROUND)
//*                  A == AUTOPRINT ON, 0 == AUTOPRINT OFF
//SASLIST  DD SYSOUT=0,OUTPUT=*.PRINT,RECFM=FBA,LRECL=165,BLKSIZE=0
//OLST     DD DISP=SHR,DSN=BQH0.INC.SASLST
//OLOG     DD DISP=SHR,DSN=BQH0.INC.SASLOG
//***OLST     DD PATH='/u/bqh0/saslog'
//***OLOG     DD PATH='/u/bqh0/saslst'
//IN       DD DISP=SHR,DSN=BF19.LAX0319.FETMER
//SYSIN    DD *

 /*$$$$$$$$$$$$$$$$$$$$$ begin include.sas $$$$$$$$$$$$$$$$$$$$$$$$$$$*/

 /* Use this pgm if JCL is required, mvars are required to be passed, or files
  * are %included.  Use Connect otherwise (of course there are always
  * exceptions).
  */

options source source2 NOs99nomig NOcenter mlogic mprint sgen replace;

 /* Use ~/bin/bftp -y to d/l MVS SAS Log, -z to d/l MVS SAS List. */
%let startinc=%sysfunc(time());
%put !!!Running include.sas on &SYSSCP;


 /******** Defaults -- may be overwritten below ***************/
%global TMPF ODS FIX;
%let TMPF='SASAF';  /* pair with ODS=OFF or ODS=  to avoid emailing everyone */
 /* Confusing 3 way switch, ODS= ; is not the same as ODS=OFF; */
***%let ODS=OFF;  /* ODS=ON sends email to Feds */
%let ODS= ;  /* still get FTP/ODS action if ODS=  ! */
%let FIX=NO;  /* write to Fed public_html */
 /******** Defaults -- may be overwritten below ***************/


 /* Old style non-mvds freq TSA.  Also need //IN ... above */
 /*****************
%let ODS=; %let LY=02; %let ST=NY;
%include 'BQH0.PGM.LIB(TSF03OA1)';      
 *****************/


 /* Uses //IN card above to run the series.  TSA goes to hold queue, not PDF
  * if ODS=OFF then email Fed 
  * if ODS=ON then email me
  * if ODS= ??no email?
  * TODO should UPD=NO to get TSAs produced?
  *
  * If not running this as an FCAST 1.[123] update substitute, may just want
  * to use FIX as PRINTER in FCAST to write to Fed's public_html - it changes
  * the &USER to the Fed but still mails me.
  *
  * SASAF causes the DWJ2 version to not update the mvds
  */
 /*****************
%let TMPF='SASAF'; %let ODS=;
***%include 'DWJ2.VSCP.PGMLIB(JSNAAAA)';
***%include 'BQH0.PGM.LIB(JSNAAAA)';
%include 'BQH0.PGM.LIB(JSFAAAA)';
***%include 'DWJ2.VSCP.PGMLIB(JSMAAAA1)';
 *****************/
 /* or if only need lib updates (e.g. data year closeout), don't think it
  * emails feds
  */
 /*****************/
%global UPD TMPF;
%let UPD=YES; %let TMPF=;
%macro x;
  %include 'DWJ2.UTIL.LIBRARY(GETREG)';
  %if &REVTYPE eq OLD %then
    %do;
 /***       %include 'DWJ2.VSCP.PGMLIB(DLM03OA1)'; ***/
 /***       %include 'DWJ2.VSCP.PGMLIB(DLM03OA2)'; ***/
    %end;
  %include 'DWJ2.VSCP.PGMLIB(DLAAAA2)';
  options NOcaps;
  /* Optional */
 /***   %include 'DWJ2.VSCP.PGMLIB(JSMAAAA1)'; ***/
%mend x;
 /*****************/
%x

 /* Run jobstream report series w/o JS* and lib updates */
 /* TODO probably can replace the %let's with GETREG */
 /*****************
%let YEAR=2003; %let YR=03; %let CSTATUS=N; %let EVT=FET; %let ST=MI;
%let STATNAME=MICHIGAN; %let NSPAN=1; %let FSPAN=1; %let RSPAN=1;
%let IN2003=BF19.MI01.MI03005A.FETCRE.R729P007; 
%let FNAME=&IN2003; %let FN=&IN2003; 
%INCLUDE "DWJ2.VSCP.PGMLIB(TSFAAZA1)";
%INCLUDE "DWJ2.VSCP.PGMLIB(GEAAAFA)";
%INCLUDE "DWJ2.VSCP.PGMLIB(MRFAAZA)";
%INCLUDE "DWJ2.VSCP.PGMLIB(TSFAAZA2)";
 *****************/

 /* Haven't yet tried this one standalone */
 /* Register update only */
 /*****************
%include 'DWJ2.VSCP.PGMLIB(DLAAAA1)'; 
 *****************/
 /* MVDS update only.  Needs //IN... 
  * CSTATUS can be O N F R B and it is set inside GETREG via REVISING_STATUS
  * Alternate version using GETREG is above.
  */
 /*****************
options replace center;
%let YEAR=2004; %let YR=%substr(&YEAR,3,2); %let CSTATUS=N; %let EVT=FET; 
%let STATNAME=MICHIGAN; %let NSPAN=1; %let FSPAN=0; %let RSPAN=0;
%let LY=02; %let REVTYPE=NEW; %let ST=MI; %let STATE=&ST; 
%let FNAME=BF19.MIX0402.FETMERZ;
%include 'BQH0.PGM.LIB(DLAAAA2)';
 *****************/


 /* Multirace/hispanic */
 /*****************
%let YEAR=2004; %let IN2004=BF19.MNX0422.MORMER; %let RSPAN=1; 
%let STATNAME=mystate; %let FNAME=myfname;
%include 'BQH0.PGM.LIB(MHMAAOA)';
 *****************/
 /* If not calling MRNAAOA, MHNAAOA, etc. directly: */
 /* NON-REV */
***%RUNMULTI(NATALITY, 277, 224, 9, ANNUAL, RACE OF MOTHER);
***%RUNMULTI(MORTALITY, 166, 135, 49, ANNUAL, DECEDENT);
***%RUNMULTI(MORTALITY, 271, 1, 237, ANNUAL, DECEDENT);
***%RUNHISP(NATALITY, 899, 224, 9, ANNUAL, MOTHER OF HISP ORIG);
 /* REV */
***%RUNHISP(NATALITY, 95, 1, 31, ANNUAL, MOTHER OF HISP ORIG);


 /* Closest neighbor */
 /*****************
%let ODS=OFF;  * always use OFF when debugging TSAAAZAC to avoid dwj2 mail;
%let YEAR=2003; %let YR=03; %let EVT=FET; %let STATE=WA;  * from FCAST normally;
%include 'BQH0.PGM.LIB(TSAAAZAC)';
 *****************/


 /*****************
%let YEAR=2003; %let NSPAN=1; %let EVT=MED; %let IN2003=BF19.CAX0368.MEDMER;
%include 'BQH0.PGM.LIB(TSTAAAA3)';
 *****************/


 /*****************
%let IN2003=BF19.WA03NAT.RCPTDATE; %let NSPAN=1; %let YEAR=2003;
%let FNAME=BF19.WA03NAT.RCPTDATE;
%include 'DWJ2.VSCP.PGMLIB(TSNAAZA1)';
%include 'DWJ2.VSCP.PGMLIB(TSNAAZA2)';
 *****************/


***%include 'BQH0.PGM.LIB(AVGLAGN)';

 /* Monthly Natality TSA old style, non-mvds.  Needs //IN above */
 /*****************
%let DATAYR=2004; %let STNM=02;
%include 'BQH0.PGM.LIB(NFCR1M)';
%include 'BQH0.PGM.LIB(NFCR2M)';
%include 'BQH0.PGM.LIB(NFCR3M)';
 *****************/
 /* Monthly Mortality TSA old style, non-mvds.  Needs //IN above */
 /*****************
%let DATAYR=2004; %let STNM=02;
%include 'BQH0.PGM.LIB(MFCRPM)';
 *****************/


 /* Missings report - relies on e.g. "BF20.OLS.VSCP.MD04MOR"
  * "BF20.OLS.VSCP.MD02MOR" "BF19.VSCP2000.TABLIB(STVOID04)"
  */
 /*****************
%let ODS=; %let FNAME=BF19.MDX0449.MORMER; %let ST=MD; %let YR=04; %let LY=02;
%include 'BQH0.PGM.LIB(MSMAAOA)';      
  *****************/


 /* FCAST #6.6 Unix transfer NOT USING - TOO COMPLICATED */
 /****************************
%let EVT=MOR;
%let YEAR=2005;
%let ST=KS;
%let BYR=2005;
%let STCODE=KS;
%let UNAME=ks05002a.dem.mer;
%let TMPF='';
%let ATT=DUMMY;
%include 'DWJ2.VSCP.PGMLIB(FCAAAZA)';
%include 'DWJ2.VSCP.PGMLIB(FCMAAZA)';
 ****************************/


%put !!! Generated mvars currently in scope:;
%put _USER_;
%put !!! Completed include.sas;
%put !!! (&SYSCC) Elapsed: %sysevalf((%sysfunc(time())-&startinc)/60);

//

 /*$$$$$$$$$$$$$$$$$$$$$$ end include.sas $$$$$$$$$$$$$$$$$$$$$$$$$$$$*/
 /*~~~~~~~ Hook up a report to the ODS/PDF/email golgi apparatus ~~~~~ */
 /* Won't easily work as a macro so move JCL slashes comment and '//'  */
 /* below this block to run it.  Put it back above when done.          */
 /* '$$$$' line as needed                                              */
 /*                                                                    */
 /*                                                                    */
%global USER FILEOUT TMPF ODS FIX;  /* for premail */
%let TMPF='SASAF'; %let USER=%lowcase(&SYSUID);
%let ODS=; %let FILEOUT=junk.pdf; %let LY=02; %let ST=GA;
 /* Not sure if //IN in JCL above is required. */
%let STATNAME=GEORGIA; %let FNAME=BF19.GAX0494.MORMER;
 /* TMPF='SASAF' should be set above before including this:            */
%include 'BQH0.PGM.LIB(PREMAIL)'; 
 /* MUST now call %PREODS & %POSTODS before and after code inclusion!  */
%PREODS(test email please ignore, junk.pdf);
%include 'BQH0.PGM.LIB(TSM04OA)';  /* also need //IN ... above */
%POSTODS;
%put !!! Generated mvars currently in scope:;
%put _USER_;
%put !!! Completed include.sas;
%put !!! (&SYSCC) Elapsed: %sysevalf((%sysfunc(time())-&startinc)/60);
 /*                                                                    */
 /*                                                                    */
 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
