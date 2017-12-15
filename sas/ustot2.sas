//BQH0UST2 JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=20,CLASS=J,REGION=0M
//***BQH0USTO JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=120,CLASS=A,REGION=0M
//***BQH0USTO JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=20,CLASS=J,REGION=0M
//***BQH0USTO JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=5,CLASS=V,REGION=0M
//STEP1    EXEC SAS90,TIME=100,OPTIONS='MEMSIZE=0,ALTPRINT=OLST,
//                                                ALTLOG=OLOG'
//OLST     DD DISP=SHR,DSN=BQH0.INC.SASLIST
//OLOG     DD DISP=SHR,DSN=BQH0.INC.SASLOG
//WORK     DD SPACE=(CYL,(1000,1000),,,ROUND)
//SYSIN    DD *

 /**********************************************************************
  * PROGRAM NAME: DWJ2.UTIL.LIBRARY(USTOT2)
  *
  *  DESCRIPTION: Build one NAT US total dataset out of the 5 or so
  *               separately built datasets.
  *
  *     CALLS TO: nothing
  *    CALLED BY: nothing, runs only by hand once per year
  *
  *  INPUT MVARS: none
  *
  *   PROGRAMMER: bqh0
  * DATE WRITTEN: 2005-01-20
  *
  *   UPDATE LOG:
  *********************************************************************/
options NOcenter missing=0 ls=179 mlogic mprint sgen NOovp NOthreads 
        errorabend
        ;

%let START=%sysfunc(time());

%let Y=2003;    /* closed year from which to create us tot pct dataset */
%let REVTYPE=OLD;
%let EVT=NAT;

libname MVDS&Y "DWJ2.&EVT.&Y..MVDS.LIBRARY.NEW" DISP=SHR WAIT=30;
libname U 'DWJ2.USTOT.SASLIB' DISP=OLD WAIT=30;

 /* Only using this for us total count (sex is arbitrary).  For 2003 PA
  * and WA should be removed 
  */
data allst;
  set MVDS&Y..AK&REVTYPE (keep=sex)
      MVDS&Y..AL&REVTYPE (keep=sex)
      MVDS&Y..AR&REVTYPE (keep=sex)
      MVDS&Y..AS&REVTYPE (keep=sex)
      MVDS&Y..AZ&REVTYPE (keep=sex)
      MVDS&Y..CA&REVTYPE (keep=sex)
      MVDS&Y..CO&REVTYPE (keep=sex)
      MVDS&Y..CT&REVTYPE (keep=sex)
      MVDS&Y..DC&REVTYPE (keep=sex)
      MVDS&Y..DE&REVTYPE (keep=sex)
      MVDS&Y..FL&REVTYPE (keep=sex)
      MVDS&Y..GA&REVTYPE (keep=sex)
      MVDS&Y..GU&REVTYPE (keep=sex)
      MVDS&Y..HI&REVTYPE (keep=sex)
      MVDS&Y..IA&REVTYPE (keep=sex)
      MVDS&Y..ID&REVTYPE (keep=sex)
      MVDS&Y..IL&REVTYPE (keep=sex)
      MVDS&Y..IN&REVTYPE (keep=sex)
      MVDS&Y..KS&REVTYPE (keep=sex)
      MVDS&Y..KY&REVTYPE (keep=sex)
      MVDS&Y..LA&REVTYPE (keep=sex)
      MVDS&Y..MA&REVTYPE (keep=sex)
      MVDS&Y..MD&REVTYPE (keep=sex)
      MVDS&Y..ME&REVTYPE (keep=sex)
      MVDS&Y..MI&REVTYPE (keep=sex)
      MVDS&Y..MN&REVTYPE (keep=sex)
      MVDS&Y..MO&REVTYPE (keep=sex)
      MVDS&Y..MP&REVTYPE (keep=sex)
      MVDS&Y..MS&REVTYPE (keep=sex)
      MVDS&Y..MT&REVTYPE (keep=sex)
      MVDS&Y..NC&REVTYPE (keep=sex)
      MVDS&Y..ND&REVTYPE (keep=sex)
      MVDS&Y..NE&REVTYPE (keep=sex)
      MVDS&Y..NH&REVTYPE (keep=sex)
      MVDS&Y..NJ&REVTYPE (keep=sex)
      MVDS&Y..NM&REVTYPE (keep=sex)
      MVDS&Y..NV&REVTYPE (keep=sex)
      MVDS&Y..NY&REVTYPE (keep=sex)
      MVDS&Y..OH&REVTYPE (keep=sex)
      MVDS&Y..OK&REVTYPE (keep=sex)
      MVDS&Y..OR&REVTYPE (keep=sex)
 /***       MVDS&Y..PA&REVTYPE (keep=sex) ***/
      MVDS&Y..PR&REVTYPE (keep=sex)
      MVDS&Y..RI&REVTYPE (keep=sex)
      MVDS&Y..SC&REVTYPE (keep=sex)
      MVDS&Y..SD&REVTYPE (keep=sex)
      MVDS&Y..TN&REVTYPE (keep=sex)
      MVDS&Y..TX&REVTYPE (keep=sex)
      MVDS&Y..UT&REVTYPE (keep=sex)
      MVDS&Y..VA&REVTYPE (keep=sex)
      MVDS&Y..VI&REVTYPE (keep=sex)
      MVDS&Y..VT&REVTYPE (keep=sex)
 /***       MVDS&Y..WA&REVTYPE (keep=sex) ***/
      MVDS&Y..WI&REVTYPE (keep=sex)
      MVDS&Y..WV&REVTYPE (keep=sex)
      MVDS&Y..WY&REVTYPE (keep=sex)
      MVDS&Y..YC&REVTYPE (keep=sex)
      ;
run;

%macro CountObs;
  %global ALLCNT;
  %local dsid numobs rc;

  %let dsid=%sysfunc(open(allst));
  %let numobs=%sysfunc(attrn(&dsid, nobs));
  %let rc=%sysfunc(close(&dsid));

  %if &rc ne 0 %then
    %put ERROR: &rc in CountObs macro;
  %else 
    %let ALLCNT=&numobs;
%mend CountObs;
%CountObs


proc sql;
  create table tmpI as
  select coalesce(A.valseq, B.valseq) as valseq, 
         coalesce(A.varseq, B.varseq) as varseq,
         coalesce(A.varlab, B.varlab) as varlab,
         coalesce(A.vallab, B.vallab) as vallab,
         sum(A.yr&Y,B.yr&Y) as yr&Y
  from U.ust&Y.&REVTYPE.&EVT.1 as A full join U.ust&Y.&REVTYPE.&EVT.2 as B  
                                    on A.valseq=B.valseq and 
                                       A.varseq=B.varseq and
                                       A.varlab=B.varlab

  order by varseq, valseq, varlab
  ;
quit;

proc sql;
  create table tmpII as
  select coalesce(A.valseq, B.valseq) as valseq, 
         coalesce(A.varseq, B.varseq) as varseq,
         coalesce(A.varlab, B.varlab) as varlab,
         coalesce(A.vallab, B.vallab) as vallab,
         sum(A.yr&Y,B.yr&Y) as yr&Y
  from tmpI as A full join U.ust&Y.&REVTYPE.&EVT.3 as B  
                                    on A.valseq=B.valseq and 
                                       A.varseq=B.varseq and
                                       A.varlab=B.varlab

  order by varseq, valseq, varlab
  ;
quit;

proc sql;
  create table tmpIII as
  select coalesce(A.valseq, B.valseq) as valseq, 
         coalesce(A.varseq, B.varseq) as varseq,
         coalesce(A.varlab, B.varlab) as varlab,
         coalesce(A.vallab, B.vallab) as vallab,
         sum(A.yr&Y,B.yr&Y) as yr&Y
  from tmpII as A full join U.ust&Y.&REVTYPE.&EVT.4 as B  
                                    on A.valseq=B.valseq and 
                                       A.varseq=B.varseq and
                                       A.varlab=B.varlab

  order by varseq, valseq, varlab
  ;
quit;

proc sql;
  create table tmpIV as
  select coalesce(A.valseq, B.valseq) as valseq, 
         coalesce(A.varseq, B.varseq) as varseq,
         coalesce(A.varlab, B.varlab) as varlab,
         coalesce(A.vallab, B.vallab) as vallab,
         sum(A.yr&Y,B.yr&Y) as yr&Y
  from tmpIII as A full join U.ust&Y.&REVTYPE.&EVT.5 as B  
                                    on A.valseq=B.valseq and 
                                       A.varseq=B.varseq and
                                       A.varlab=B.varlab

  order by varseq, valseq, varlab
  ;
quit;

data U.ust&Y.&REVTYPE.&EVT (drop=yr&Y);
  set tmpIV;
  uspct&Y = (yr&Y / &ALLCNT) * 100;
run;

 /* TODO when all works, delete the intermediate numbered ds */


%put !!!Elapsed minutes: %sysevalf((%sysfunc(time())-&START)/60);



  /* vim: set tw=72 ft=sas ff=unix foldmethod=marker: */ 
