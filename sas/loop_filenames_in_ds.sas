//BQH0EFGH JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=1,CLASS=F,REGION=0M
//STEP1    EXEC SAS90,TIME=100,OPTIONS='MEMSIZE=0,ALTPRINT=OLST,
//                                                ALTLOG=OLOG'
//OLST     DD DISP=SHR,DSN=BQH0.INC.SASLIST WAIT=10
//OLOG     DD DISP=SHR,DSN=BQH0.INC.SASLOG WAIT=10
//WORK     DD SPACE=(CYL,(100,100),,,ROUND)
//SYSIN    DD *

options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: loop_filenames_in_ds.sas (s/b symlinked as iterate_textfiles.sas)
  *
  *  Summary: Iterate the latest merge (text) files after creating a giant
  *           work.tmp that holds all lines from all merge files.
  *
  *           Use loopallfiles.sas if you don't know exactly which BF19...
  *           files to loop and want to use logic to parse Register.
  *
  *           See also loopallmvds.sas to compare results with this output.
  *
  *  Created: Wed 25 Feb 2004 09:56:04 (Bob Heckel)
  * Modified: Thu 05 Aug 2004 11:35:02 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOthreads NOcenter;


 /* Part I, build the dataset of filenames: */
data tmp;
  infile cards MISSOVER;
  input fn $ 1-50;
  cards;
BF19.NYX0363.MORMERZ
  ;
run;


 /* Part II, use the dataset to read each filename's data into tmp dataset: */
data tmp;
  set tmp;
  /* S/b same width as fn created above. */
  length currinfile $50;

 /* The INFILE statement closes the current file and opens a new one if
  * fn changes value when INFILE executes. FILEVAR must be same as var on the
  * ds that holds the filenames.
  */
  infile TMPIN FILEVAR=fn FILENAME=currinfile TRUNCOVER END=done; 

  /* Apparently can't do any logic in this while loop like fileexist() or
   * it'll hang.
   */
  do while ( not done );
    /* Read all input records from the currently opened input file, write to
     * work.tmp. 
     */
    ***input @251 hisp $CHAR20.;
    input @247 hisp $CHAR4.;
    /* Make sure we can tell where the record came from. */
    f=fn;
    output;
    ***if yr in('2000','2001','2002') then output;
  end;
  put '!!!finished reading ' currinfile=; 
run;

proc freq data=tmp;
  tables hisp / nocum;
run;

%macro bobh2;
 /* Write a Unix webpage using the results.  Could have used ODS. */
data _NULL_;
  set tmp END=e;

  /* http://mainframe.cdc.gov/sasweb/nchs/bob/t.html */
  file '/u/bqh0/public_html/bob/t.html';

  if _N_ eq 1 then
    put @1 '<B>2004 current MEDMER mergefiles -- Certifier<BR><BR></B>
            <TABLE><CODE>'
            ;

  put @1 '<TR><TD>'f'<TD>' certifier '<BR>';

  if e then
    put @1 '</CODE></TABLE>';
run;
%mend;
