//BQH0LOOP JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=5,CLASS=V,REGION=0M
//STEP1    EXEC SAS90,TIME=100,OPTIONS='MEMSIZE=0,ALTPRINT=OLST,
//                                                ALTLOG=OLOG'                              
//OLST     DD DISP=SHR,DSN=BQH0.INC.SASLIST
//OLOG     DD DISP=SHR,DSN=BQH0.INC.SASLOG
//WORK     DD SPACE=(CYL,(100,100),,,ROUND)
//SYSIN    DD *

options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: EDUCBYYR.sas
  *
  *  Summary: Summarize education "not classifiable" values for all states
  *           using their mergefiles.
  *
  *           Must run on mf to unmigrate via NOs99nomig successfully.
  *           
  *  Created: Thu 18 Nov 2004 09:46:56 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOthreads NOcenter mlogic mprint sgen NOs99nomig;


%macro ForEachYr(startyr, span);
  %local j;

  %let j=&startyr;
  %do %while ( &j lt %eval(&startyr+&span)  );

    libname THELIB "/u/dwj2/register/MOR/199&j" DISP=SHR;

     /* Part I, build the dataset of filenames: */
    data tmp&j (keep= mergefile rename= mergefile=fn);
      set THELIB.register;
      /* Must protect against states w/o any mergefiles submitted. */
      if mergefile ne '';
      /* DEBUG toggle */
      ***if mergefile =: "BF19.GA";
    run;

    libname THELIB clear;

    proc append base=allfnames data=tmp&j; run;

    %let j=%eval(&j+1);
  %end;
%mend ForEachYr;
%ForEachYr(8, 2);


 /* Part II, use the filenames dataset to read each filename's data into
  * a single dataset: 
  */
data alldata;
  set allfnames;
  /* S/b same width as fn created above. */
  length currinfile $50 f $40  yr $2  st $2;

 /* The INFILE statement closes the current file and opens a new one if
  * fn changes value when INFILE executes. FILEVAR must be same as var
  * on the ds that holds the filenames.
  */
  infile TMPIN FILEVAR=fn FILENAME=currinfile TRUNCOVER END=done; 

  /* TODO I don't think putting IF statements in here will work */
  do while ( not done );
    /* Read all input records from the currently opened input file, write
     * to work.alldata. 
     */
    input @47 alias $CHAR1.  @96 educ $CHAR2.;
    /* Make sure we can tell where the record came from. */
    f=fn;
    st=substr(scan(currinfile,2,'.'),1,2);
    yr=substr(scan(currinfile,2,'.'),4,2);
    output;
  end;
run;

data subset;
  set alldata;
  if educ eq '99' and alias ne '1';
run;

proc sql;
  create table tmp as
  select count(educ) as ce, st, yr
  from subset
  group by st, yr
  ;
quit;

proc transpose data=tmp prefix=Yr out=tmp2 (drop=_NAME_);
  by st;
  id yr;
  var ce;
run;

proc print data=_LAST_; 
  format Yr: COMMA8.;
run;
