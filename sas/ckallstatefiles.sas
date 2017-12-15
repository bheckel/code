//BQH0LOOP JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=20,CLASS=J,REGION=0M
//STEP1    EXEC SAS90,TIME=100,OPTIONS='MEMSIZE=0,ALTPRINT=OLST,
//                                                ALTLOG=OLOG'                              
//OLST     DD DISP=SHR,DSN=BQH0.INC.SASLIST
//OLOG     DD DISP=SHR,DSN=BQH0.INC.SASLOG
//WORK     DD SPACE=(CYL,(1000,1000),,,ROUND)
//SYSIN    DD *

options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: ckallstatefiles.sas (s/b symlinked as loopallfiles.sas)
  *
  *  Summary: Summarize a variable for all states using their mergefiles.
  *           Usually used to confirm the results of MVDS.
  *
  *           See iterate_textfiles.sas if you know exactly what BF19... files
  *           you want, this code uses the Register.
  *
  *           See EDUCBYYR.sas for a good application of this.
  *
  *  Created: Thu 18 Nov 2004 09:46:56 (Bob Heckel)
  * Modified: Mon 09 May 2005 10:54:38 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOthreads NOcenter mlogic mprint sgen NOs99nomig;


 /* Part I, gather latest BF19 filenames from Register. */
%macro ForEachYr(startyr, span);
  %local j;

  %let j=&startyr;

  %do %while ( &j lt %eval(&startyr+&span)  );
    /* ADJUST */
    libname L "/u/dwj2/register/NAT/200&j" DISP=SHR WAIT=10;

     /* Part I, build the dataset of filenames: */
    data tmp&j (keep=mergefile rename=(mergefile=fn));
      set L.register;
      /* Protect against states w/o any mergefiles submitted. */
      if mergefile ne '';
      /* DEBUG toggle to do specific files */
      ***if mergefile =: 'BF19.MA';
      /* ADJUST */
      if substr(reverse(trim(revising_status)),1,1) ne 'O';
    run;

    libname L clear;

    proc append base=allfnames data=tmp&j; run;

    %let j=%eval(&j+1);
  %end;
%mend ForEachYr;
 /* E.g. 3 for 2003, 1 for single year loop: %ForEachYr(3, 1); */
 /* ADJUST */
%ForEachYr(3, 1);


 /* Part II, use the filenames dataset to read each filename's data into
  * a single dataset: 
  */
data alldata;
  set allfnames;
  length currinfile $50 f $40  yr $2  st $2;

  infile TMPIN FILEVAR=fn FILENAME=currinfile TRUNCOVER END=e; 

  do while ( not e );
    /* ADJUST */
    input @9 myvar $CHAR2.;
    ***input @47 alias $CHAR1.  @40 racem $CHAR1.;
    ***input @13 void $CHAR1.  @47 alias $CHAR1.  @231 myvar $CHAR1.;
    ***st=substr(scan(currinfile,2,'.'),1,2);
    ***yr=substr(scan(currinfile,2,'.'),4,2);
    output;
  end;
run;

 /* ADJUST */
data alldata;
  set alldata;
  ***if alias eq '1' or void eq '1' then delete;
run;

proc freq;
  /* ADJUST */
  table myvar / missing;
run;
