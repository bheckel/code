See also readme.sas.txt



                    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    To Insert 1 New Menu Item Into An
                          Existing Menu Structure
                         (using UC56 as an example)
                    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Edit SAS/AF template code ~/code/sas/sasaf.template.sas (ok to destroy, there
is a saved sample at bottom of this file) and 

:!bfp % 'BQH0.TMPTRAN1'

Select an existing menu to add an item to:

E
_  OTHMENU

ATTR

add to bottom
13          UC56       PROGRAM     *          *                _  

END

For first time only
===> EDIT UC56
(it'll be blank and scream at you, paste in the GUI text with the mvars)

ATTR
---------------
ÅBUILD: DISPLAY UC3D.PROGRAM (E)¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢Õ
… Command ===>                                                                 …
…                                                                              …
…  Use the scroll commands or function keys to review the fields.              …
…                                                                              …
…   Field name:  EY4       Frame: 1   Row: 5      Col: 41     Length: 4        …
…                                                                              …
…        Alias:  EY4         Choice group:  ________     Pad: _                …
…         Type:  CHAR             Protect:  YES   NO     INITIAL               …
…       Format:  ____________        Just:  LEFT  RIGHT  CENTER  NONE          …
…     Informat:  ____________                                                  …
…  Error color:  RED         attr:  REVERSE       Help:  ........  ........    …
…                                                                              …
…         List:  ________________________________________________________      …
…                ________________________________________________________      …
…      Initial:  2004                                                          …
…      Replace:  ________________________________________________________      …
…      Options:  CAPS  CURSOR  REQUIRED  AUTOSKIP  NOPROMPT  NON-DISPLAY       …
…                                                                              …
Ä¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢Ô

ÅBUILD: DISPLAY UC3D.PROGRAM (E)¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢Õ
… Command ===>                                                                 …
…                                                                              …
…  Use the scroll commands or function keys to review the fields.              …
…                                                                              …
…   Field name:  PRT       Frame: 1   Row: 8      Col: 28     Length: 4        …
…                                                                              …
…        Alias:  PRT         Choice group:  ________     Pad: _                …
…         Type:  CHAR             Protect:  YES   NO     INITIAL               …
…       Format:  ____________        Just:  LEFT  RIGHT  CENTER  NONE          …
…     Informat:  ____________                                                  …
…  Error color:  RED         attr:  REVERSE       Help:  ........  ........    …
…                                                                              …
…         List:  ________________________________________________________      …
…                ________________________________________________________      …
…      Initial:  MAIL                                                          …
…      Replace:  ________________________________________________________      …
…      Options:  CAPS  CURSOR  REQUIRED  AUTOSKIP  NOPROMPT  NON-DISPLAY       …
…                                                                              …
Ä¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢Ô

ÅBUILD: DISPLAY UC56.PROGRAM (E)¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢Õ
… Command ===>                                                                 …
…                                                                              …
…  Use the scroll commands or function keys to review the fields.              …
…                                                                              …
…   Field name:  STOP      Frame: 1   Row: 17     Col: 9      Length: 30       …
…                                                                              …
…        Alias:  STOP        Choice group:  ________     Pad: _                …
…         Type:  PUSHBTNC         Protect:  YES   NO     INITIAL               …
…       Format:  ____________        Just:  LEFT  RIGHT  CENTER  NONE          …
…     Informat:  ____________                                                  …
…  Error color:  RED         attr:  REVERSE       Help:  ........  ........    …
…                                                                              …
…         List:  ________________________________________________________      …
…                ________________________________________________________      …
…      Initial:  SUBMIT/RETURN TO READY PROMPT                                 …
…      Replace:  ________________________________________________________      …
…      Options:  CAPS  CURSOR  REQUIRED  AUTOSKIP  NOPROMPT  NON-DISPLAY       …
…                                                                              …
Ä¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢Ô

ÅBUILD: DISPLAY UC56.PROGRAM (E)¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢Õ
… Command ===>                                                                 …
…                                                                              …
…  Use the scroll commands or function keys to review the fields.              …
…                                                                              …
…   Field name:  GOBACK    Frame: 1   Row: 17     Col: 45     Length: 22       …
…                                                                              …
…        Alias:  GOBACK      Choice group:  ________     Pad: _                …
…         Type:  PUSHBTNC         Protect:  YES   NO     INITIAL               …
…       Format:  ____________        Just:  LEFT  RIGHT  CENTER  NONE          …
…     Informat:  ____________                                                  …
…  Error color:  RED         attr:  REVERSE       Help:  ........  ........    …
…                                                                              …
…         List:  ________________________________________________________      …
…                ________________________________________________________      …
…      Initial:  SUBMIT/RETURN TO MAIN                                         …
…      Replace:  ________________________________________________________      …
…      Options:  CAPS  CURSOR  REQUIRED  AUTOSKIP  NOPROMPT  NON-DISPLAY       …
…                                                                              …
Ä¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢Ô

---------------
END    <---autosaves
COMP

SOUR
INCLUDE 'BQH0.TMPTRAN1'
COMP

When ready to release, go back and add the 13 - UC 56 TSA text to OTHMENU
screen so users can find it.







                    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    To Insert 3 New Menu Items Into FCAST
                       (using multirace as an example)
                    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


Edit DWJ2.VSCPQC.LIB(FCAST), adding line 20 (8 char max libnames!)
...
000019 LIBNAME COMP     'DWJ2.COMP.SASLIB'    DISP=SHR; 
000020 LIBNAME MULTIRAC 'DWJ2.MULTIFC.SASLIB' DISP=SHR;
000021 DM 'LOG OFF;MANAGER OFF;';                       
...


-------------------

Create this (=2):

/* BHB6.AF.PROGS(MRFCBLD)                              */;                      
/* AF SCREENS FOR MULTIRACE REPORT                     */;                      
/* FC.REPORTN.PROGRAM WILL CREATE THE NATALITY REPORT  */;                      
/* FC.REPORTM.PROGRAM WILL CREATE THE MORTALITY REPORT */;                      
/* FC.REPORTF.PROGRAM WILL CREATE THE FET DEATH REPORT */;                      
                                                                                
LIBNAME MULTIRAC 'DWJ2.MULTIFC.SASLIB';                                           
                                                                                
PROC BUILD CATALOG=MULTIRACE.FC;                                                   
  ***COMPILE;                                                                       
RUN;                                                                            


-------------------

=6
sas609

include 'bhb6.af.progs(fcbld)'

sub

Menu where you want the new report:
e
_ TSAMENU

===> attr

add to bottom:
9  REPORTN  PROGRAM  MULTIRACE  FC  _
10 REPORTM  PROGRAM  MULTIRACE  FC  _
11 REPORTF  PROGRAM  MULTIRACE  FC  _

===> end (autosaves)


(may want to do this last so users can't use it yet)
add this to the existing 'TIME SERIES ANALYSIS REPORTS USING ANNUAL
PERCENTAGES' GUI:
 9 - NATALITY MULTI-RACE (REVISERS ONLY)
10 - MORTALITY MULTI-RACE (REVISERS ONLY)
11 - FETAL DEATH MULTI-RACE (REVISERS ONLY)

===> end
===> end (autosaves)


-------------------

include or paste this:

include 'BHB6.AF.PROGS(MRFCBLD)';

/* BHB6.AF.PROGS(MRFCBLD)                              */;                      
/* AF SCREENS FOR MULTIRACE REPORT                     */;                      
/* FC.REPORTN.PROGRAM WILL CREATE THE NATALITY REPORT  */;                      
/* FC.REPORTM.PROGRAM WILL CREATE THE MORTALITY REPORT */;                      
/* FC.REPORTF.PROGRAM WILL CREATE THE FET DEATH REPORT */;                      
                                                                                
LIBNAME MULTIRACE 'DWJ2.MULTIFC.SASLIB';                                           
                                                                                
PROC BUILD CATALOG=MULTIRACE.FC;                                                   
  ***COMPILE;                                                                       
RUN;                                                                            


then 
sub

Say Y and C if prompted to create BHB6.MULTFC.SASLIB catalog (DON'T say
delete!)


-------------------

You'll get a blank screen the first time thru.

edit REPORTN.PROGRAM
or
edit REPORTM.PROGRAM
or
edit REPORTF.PROGRAM


-------------------

Include or paste in this GUI from AF.MRGUI:
                                                                              
                          NATALITY DEMOGRAPHIC DATA                               
                                  MULTI-RACE
                         TIME SERIES ANALYSIS REPORT                              

                                                                              
                          CREATE THE REPORT                                   
                                                                              
                                                                              
      ENTER THE DATA SET NAME: &DSNAME_______________                         
                                                                              
      USERID: &USERID                                                         
                                                                              
      PRINTER: &PRT                                                           
                                                                              
                                                                              
                                                                              
   &STOP________________________        &GOBACK______________________         



-------------------

attr

ATTRibutes of the buttons, etc. have to be done by hand using scrshots as a
guide.  Scroll thru widgets via Shift-F8

For some reason must do sour AND compile when finished with the widgets or get
an FCAST error about not having code.  But don't need to save widgets after
COMP compiling the code.


-------------------

Edit BQH0.AF.TEST to make BQH0.AF.MRACEN, BQH0.AF.MRACEM and BQH0.AF.MRACEF
(to be INCLUDE'd later after SOURcing). 

===> sour

===> include 'BQHO.AF.MRACEN'

===> compile

===> msg      <---if errors









(see readme.sas.txt for full command list):
Shift-F7 Shift-F8 to move up/down
===> up 42
===> down 42   or just press enter 42 times


 /* FCAST navigation general */
=6
sas609

===> include 'bhb6.af.progs(fcbld)'
 /* Optional */
===> zoom
 /* Navigate with SHIFT+f8, SHIFT+f7 */

===> sub
 /* In the job of interest field: browse (s for select, i.e. edit) */
b
 /* Should see menu user will see. */

 /* To view code: */
===> source

 /* If changed source: */
===> compile

 /* To go back upward (?submits job anyway?): */
===> end

 /* To leave SAS, go to TSO command lines: */
===> bye

 /* To send text to another file (overwriting bqh0.junk): */
===> file 'bqh0.junk' r

 /* To insert read in text from another file */
===> include 'bqh0.junk'
===> include 'bqh0.pgm.lib(junk)'



~/code/sas/sasaf.template.sas:
Max code width is 72  :se tw=72

http://support.sas.com/91doc/getDoc/sclref.hlp/a000144382.htm

Error trapping after the submit button (e.g. blank state, bad year, etc.) is
pressed is impossible (has to be done in the included code).


View from FCAST user screen:
Å¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢Õ
… Command ===>                                                                 …
…                                                                              …
…               QUARTERLY TIME SERIES ANALYSIS REPORT                          …
…                         (DEBUG VERSION)                                      …
…   Split states will default to NEW, OLD must be run by hand on demand.       …
…                                                                              …
…                       EVENT TYPE: NAT                                        …
…                            STATE: __                                         …
…                             YEAR: 2004                                       …
…                                                                              …
…                                                                              …
…                                                                              …
…                                                                              …
…                  USER ID:  BQH0                                              …
…                  PRINTER:  MAIL                                              …
…                                                                              …
…                                                                              …
…                                                                              …
…                                                                              …
…        ­SUBMIT/RETURN TO READY PROMPT ½    ­SUBMIT/RETURN TO MAIN ½          …
…                                                                              …
…                                                                              …
Ä¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢Ô

View from SAS/AF:
ÅBUILD: DISPLAY QUARTER.PROGRAM (B)¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢Õ
… Command ===>                                                                 …
… NOTE: No editing allowed.                                                    …
…               QUARTERLY TIME SERIES ANALYSIS REPORT                          …
…                         (DEBUG VERSION)                                      …
…   Split states will default to NEW, OLD must be run by hand on demand.       …
…                                                                              …
…                       EVENT TYPE: &EV                                        …
…                            STATE: &S                                         …
…                             YEAR: &YR4                                       …
…                                                                              …
…                                                                              …
…                                                                              …
…                                                                              …
…                  USER ID:  &USERID                                           …
…                  PRINTER:  &PRT                                              …
…                                                                              …
…                                                                              …
…                                                                              …
…                                                                              …
…         &STOP_________________________      &GOBACK_______________           …
…                                                                              …
…                                                                              …
Ä¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢¢R¢¢¢¢¢¢¢¢¢Ô


INIT:
CONTROL LABEL;
USERID = SYMGET('SYSJOBID');
RETURN;


MAIN:
IF USERID EQ _BLANK_ THEN
  DO;
    _MSG_ = 'PLEASE ENTER THE USERID';
    CURSOR USERID;
    RETURN;
  END;

USR = USERID||'QTR';

CONTROL ASIS;


SUBMIT;
//*  PROGRAMMER: BQH0
//*
//*  PROGRAM:  FCBLD\QTR
//*
//*  DESCRIPTION: RUN QUARTERLY TSA UNDER MVS
//*
//*  UPDATE LOG:
//*
//&USR JOB (BF00,BX21),&USERID,MSGCLASS=K,TIME=20,CLASS=J,
//  REGION=0M
/*ROUTE    PRINT &PRT
//PRINT    OUTPUT FORMDEF=A10111,PAGEDEF=V06683,CHARS=GT15,
//         COPIES=1
//*** DJDE DUPLEX=YES,END;
//STEP1    EXEC SAS90,OPTIONS='MSGCASE,MEMSIZE=0,ALTLOG=OUTLOG',
//         WTR1=A
//SASLIST  DD  SYSOUT=A,OUTPUT=*.PRINT,
//             RECFM=FBA,LRECL=165,BLKSIZE=165
//WORK     DD SPACE=(CYL,(450,450),,,ROUND)
//OUTLOG   DD DISP=OLD,DSN=DWJ2.FCAST.&USERID.TSA.LOG
//SYSIN    DD *

%GLOBAL YEAR EVT TMPF FIX ODS PRINTDEST;
 /* &YR4 is an AF mvar, &YEAR is a SAS mvar used by included pgm. */
%LET EVT = &EV;
%LET STABBR = &S;
%LET YEAR = &YR4;
%LET TMPF = 'SASAF';    /* FOR PREMAIL */
%LET FIX = NO;          /* FOR PREMAIL */
%LET PRINTDEST = &PRT;  /* FOR PREMAIL */

%INCLUDE 'BQH0.PGM.LIB(TSAAAAQT)';


ENDSUBMIT;
RC=FILENAME('FILEREF','A','','PGM=INTRDR RECFM=FB LRECL=80
            SYSOUT=A');
RC=PREVIEW('FILE','FILEREF');
RC=PREVIEW('CLEAR');
RC=FILENAME('FILEREF','');
RC=RC;
RETURN;


STOP:
CALL EXECCMD('BYE;');
RETURN;


GOBACK:
CALL EXECCMD('END;');
RETURN;

TERM:
RETURN;
