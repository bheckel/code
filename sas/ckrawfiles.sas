//BQH0FRAK JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=20,CLASS=J,REGION=0M
//STEP1    EXEC SAS90,TIME=100,OPTIONS='MEMSIZE=0,ALTPRINT=OLST,
//                                                ALTLOG=OLOG'
//OLST     DD DISP=SHR,DSN=BQH0.INC.SASLST WAIT=10
//OLOG     DD DISP=SHR,DSN=BQH0.INC.SASLOG WAIT=10
//WORK     DD SPACE=(CYL,(100,100),,,ROUND)
//SYSIN    DD *

options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: ckrawfiles.sas
  *
  *  Summary: Iterate merge (text) files after creating a giant
  *           work.tmp that holds all lines from all merge files.
  *
  *           Use loopallfiles.sas if you don't know exactly which BF19...
  *           files to loop and want to use logic to parse Register.
  *
  *           See ckallstatefiles.sas for pedantic version.
  *
  *           ___CHECK RAW MERGEFILES___
  *
  *  Created: Wed 25 Feb 2004 09:56:04 (Bob Heckel)
  * Modified: Thu 05 Aug 2004 11:35:02 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOthreads NOcenter;


data tmp;
  infile cards MISSOVER;
  input fn $ 1-50;
  cards;
BF19.AKX0416.MORMER
  ;
run;

data tmp;
  set tmp;
  length currinfile $50  fnm $50;

  infile TMPIN FILEVAR=fn FILENAME=currinfile TRUNCOVER END=done; 

  do while ( not done );
    input @47 myvar $CHAR1.;
    output;
  end;
  fnm=fn;
run;

%macro optional;
data tmp;
  set tmp;
  if fnm in ('BF19.TXX03106.NATMER') then
    delete;
run;
%mend optional;
***%optional;

proc freq data=tmp;
  tables myvar / NOCUM;
run;



  /* vim: set tw=72 ft=sas ff=unix foldmethod=marker: */ 
