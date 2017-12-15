/*********************************************************************/
/*  MACRO SSCFLAT VERSION 1.09                                       */
/*  CREATES A COMMA DELIMITED FILE FROM ANY SAS DATA SET.            */
/*  IT CAN BE THEN DOWNLOADED AND IMPORTED INTO A SPREADSHEET.       */
/*                                                                   */
/*  SAMPLE WINDOWS CALL:                                             */
/*     %SSCFLAT(MSASDS=MAIL.TEMPMAIL,MPREFIX=C:\TEMP\)               */
/*  SAMPLE MVS CALL:                                                 */
/*     %SSCFLAT(MSASDS=WORK.XYZ,MFLATOUT=MYUSER.FILENAME.DAT)        */
/*                                                                   */
/*    STEVEN FIRST                                                   */
/* (C) SYSTEMS SEMINAR CONSULTANTS 2000     608 278-9964             */
/*                                                                   */
/* PERMISSION GIVEN TO SSC SAS STUDENTS TO USE IN PERSONAL SAS JOBS. */
/* FOR PERMISSION TO DISTRIBUTE TO OTHERS, OR FOR COMPANY WIDE USE,  */
/* CONTACT SSC AT 608 278-9964.                                      */
/*                                                                   */
/* VERSION 1.01 MODIFIED 06/20/1997 BY DAVID BEAM.  IF CHAR VALUES   */
/*    ARE BLANK, PUTS OUT NO SPACE "" INSTEAD OF " " AS BEFORE.      */
/* VERSION 1.02 MODIFIED 07/08/1998 BY STEVE FIRST. MACRO FAILING IF */
/*    INPUT FILE HAD 0 OBS.  CHANGED DATA STEP TO USE _N_, NOT EOF.  */
/*    ALSO MADE MTOTOBS MAC VAR GLOBAL SO USER COULD TEST.           */
/* VERSION 1.03 MODIFIED 12/16/1998 BY DAVID BEAM - ADD OPTION TO USE*/
/*    VARIABLE LABLES INSTEAD OF VARIABLE NAMES AS 1ST LINE OF OUTPUT*/
/*    ADDED USER PARM: MLABEL=YES TO USE THEM, MLABEL=NO IS DEFAULT. */
/* VERSION 1.04 MODIFIED 01/20/1999 BY STEVE FIRST. TO INCLUDE OPER  */
/*    SYSTEM ALXOSF (DEC UNIX).                                      */
/* VERSION 1.05 MODIFIED 04/30/1999 BY STEVE FIRST. SHORTEN ALL LINES*/
/*   TO NOT GO BEYOND COLUMN 71                                      */
/* VERSION 1.06 MODIFIED 05/13/1999 BY DAVID BEAM. FIX OVERRIDE OF   */
/*   NUMERIC FORMATS COMMA,DOLLAR AND PERCENT TO USE BEST32.         */
/*   (OTHERWISE THE FORMATTED RESULT HAS COMMAS IMBEDDED)            */
/*                                                                   */
/* VERSION 1.07 MODIFIED 05/08/1999 BY STEVE FIRST.                  */
/*   INCREASE VAR NAME LENGTH TO 32, LABEL LEN TO 256, ADD SUPPORT   */
/*   FOR SUN 4 OPERATING SYSTEM.                                     */
/*   ADDED MTRIMCHA OPTION TO TRIM CHARACTER VALUES TRAILING BLANKS  */
/*   MTRIMCHA ONLY AFFECTS CHAR VARIABLES WITH $ OR $CHAR FORMATS    */
/*   AS VARS WITHOUT FORMATS ALWAYS DISCARD BLANKS, AND USER WRITTEN */
/*   FORMAT ALWAYS CONTAIN LONGEST VALUE .                           */
/*   DEFAULT IS NO, SO THAT EARLIER USERS WILL GET FIXED COLUMNS IF  */
/*   A CHAR FORMAT IS PRESENT.                                       */
/*                                                                   */
/* VERSION 1.08 MODIFIED 07/28/2000 BY DAVID BEAM.                   */
/*   FOR SAS VERSION 8 - ALLOW DATA SET NAMES OVER 8 CHARACTERS LONG.*/
/*   USE NEW MACRO VARIABLE MMEMSHRT AS 1ST 8 CHARACTERS OF THE      */
/*   MMEMNAME MACRO VARIABLE.  USED FOR MVS FOR DEFAULT OUTPUT       */
/*   FILE NAME, SINCE A QUALIFIER IN THE DSN CANNOT BE MORE THAN 8   */
/*   CHARACTERS LONG.                                                */
/*   NOTE:                                                           */
/*   THIS REVISION DOES NOT ALLOW FOR DATA SET NAMES SUCH AS:        */
/*     MSASDS='USERXYZ.SASDATA.PERMLIB(MEMBERNAME)'                  */
/*   SO USERS SHOULD USE OLDER STYLE SAS DATA SET NAMES, SUCH AS:    */
/*     LIBNAME  MYSASLIB  'USERXYZ.SASDATA.PERMLIB';                 */
/*     DATA MYSASLIB.MEMBERNAME;                                     */
/*     THEN CALL THE MACRO WITH MSASDS=MYSASLIB.MEMBERNAME           */
/*   MPREFIX=&SYSPREF.. CHANGED TO MPREFIX= AS DEFAULT, USERS        */
/*     MUST EITHER USE THE MPREFIX OR THE MFLATOUT OPTION.           */
/*                                                                   */
/* VERSION 1.09 MODIFIED 09/19/2000 BY DAVID BEAM.                   */
/*   IF A NUMERIC VARIABLE PASSED WITH A FORMAT THAT RETURNS A       */
/*     CHARACTER STRING, THE MACRO WAS NOT PUTTING QUOTES AROUND     */
/*     THE VALUE.   EXAMPLE: NUMERIC VARIABLE 'CODE' HAS A USER      */
/*     DEFINED FORMAT THAT RETURNS "BEAM, DAVID".  THE MACRO WAS     */
/*     WRITING OUT:  BEAM,DAVID  AND SHOULD WRITE OUT "BEAM,DAVID"   */
/*   ALSO CHANGED TO CHECK FOR IMBEDDED DOUBLE QUOTES IN CHARACTER   */
/*     VALUES AND FORMATTED NUMERIC VALUES, THESE ARE REMOVED.       */
/*     MAXIMUM LENGTH OF OUTPUT FOR FORMATTED CHARACTER VALUES       */
/*     LIMITED TO 1000 BYTES.                                        */
/*********************************************************************/
/* THIS MACRO CAN BE INSTALLED IN THE SAS SYSTEM AUTOCALL MACRO LIB. */
/* IF IT IS NOT INSTALLED AS AN AUTOCALL MACRO, THE USER MUST INCLUDE*/
/*   MACRO CODE WITH THE FOLLOWING STATEMENT BEFORE USING THE MACRO. */
/*   %INCLUDE STATEMENT NEEDS TO BE RUN ONCE PER PROGRAM OR SESSION. */
/*   (CHANGE FOLLOWING TO CORRECT LOCATION ON YOUR COMPUTER!!)       */
/*                                                                   */
/* EXAMPLE FOR PC/SAS:                                               */
/*    %INCLUDE 'T:\SSC\COURSES\UPLOAD\FILES\SSCFLAT.SAS';            */
/*                                                                   */
/* EXAMPLE FOR MVS:                                                  */
/*    %INCLUDE 'AAA.BBBB.CCCC(SSCFLAT)';                             */
/*********************************************************************/
/* TO USE THIS MACRO, CREATE A SAS DATA SET WITH ONLY THE VARIABLES &*/
/*  OBSERVATIONS YOU NEED.  THIS MACRO WILL CREATE A FLAT FILE WITH  */
/*  THE DATA IN COMMA DELIMITED FORMAT.  THE DEFAULT WILL INCLUDE THE*/
/*  VARIABLE NAMES ON THE FIRST ROW OF THE NEW FLAT FILE.            */
/*                                                                   */
/*                                                                   */
/* CAN BE USED IN BATCH WITH NO ADDED JCL, OR DISPLAY MANAGER AS IS. */
/*                                                                   */
/* EXAMPLE 1 - TEMP SAS DATA SET CALLED CUSTOMER, USER ID OF USERXYZ */
/*       CREATES A FLAT FILE: "USERXYZ.CUSTOMER.DAT"                 */
/*                                                                   */
/*             %SSCFLAT(MSASDS=CUSTOMER,MPREFIX=USERXYZ.);           */
/*                                                                   */
/* EXAMPLE 2 - PERM SAS DATA SET SASUSER.PERSON, USER ID USERXYZ     */
/*       CREATES A FLAT FILE: "USERXYZ.PERSON.DAT"                   */
/*                                                                   */
/*             %SSCFLAT(MSASDS=SASUSER.PERSON,MPREFIX=USERXYZ.);     */
/*                                                                   */
/* ADDITIONAL OPTIONAL PARAMETERS THAT CAN BE USED:                  */
/*       MFLATOUT=FLAT FILE NAME TO CREATE                           */
/*       MHEADER=NO TO TURN OFF THE FIRST LINE OF VARIABLE NAMES     */
/*       MLABEL=YES TO USE LABELS INSTEAD OF VAR NAMES ON 1ST LINE   */
/*                                                                   */
/* EXAMPLE 3 - A TEMPORARY SAS DATA SET CALLED CUSTOMER, AND THE     */
/*             USER ID OF USERXYZ, CHANGING THE OUTPUT FILE NAME AND */
/*             TURNING OFF THE COLUMN NAMES:                         */
/*       CREATES A FLAT FILE: "ABCDE.WHATEVER.FLAT"                  */
/*                                                                   */
/*             %SSCFLAT(MSASDS=CUSTOMER,MFLATOUT=ABCDE.WHATEVER.FLAT,*/
/*                      MHEADER=NO);                                 */
/*********************************************************************/
/* EXAMPLE OF HOW A FLAT OUTPUT FILE MAY LOOK (THE SELLDATE VAR HAS A*/
/*  FORMAT SELLDATE MMDDYY10. ASSIGNED, & SALES = MISSING FOR "LAKE")*/
/*                                                                   */
/*  "NAME","CITY","STATE","SALES","SELLDATE"                         */
/*  "JONES, TOM","LAS VEGAS","NV",3456.85,02/18/1998                 */
/*  "LAKE, VERONICA","LOS ANGELES","CA",.,02/13/1998                 */
/*  "DAILEY, RICHARD","CHICAGO","IL",245.1,02/06/1998                */
/*********************************************************************/


%MACRO SSCFLAT(MSASDS=,                   /* INPUT SAS DS (REQUIRED  */
         MPREFIX=,                        /* OUT PREF, OR DIR OUT    */
         MFLATOUT=&MPREFIX&MMEMNAME..DAT, /* FLATFILE OUT            */
         MHEADER=YES,                     /* FIELD NAMES IN FIRST REC*/
         MLABEL=NO,                       /* USE LABELS ON FIRST LINE*/
         MLIST=YES,                       /* PRINT FLAT FILE IN LOG? */
         MTRIMNUM=YES,                    /* TRIM NUM TRAIL BLANKS?  */
         MTRIMCHA=NO,                     /* TRIM CHAR TRAIL BLANKS? */
         MTRACE=NO,                       /* DEBUGGING OPTION        */
         MMISSING=".",                    /* MISSING VALUE CHARACTER */
         MLRECL=6160,                     /* LARGEST RECORD LENGTH   */
         MVSOPT=UNIT=3390,                /* MVS UNIT OPTIONS        */
         MSPACE=1,                        /* MVS SPACE IN CYLS       */
         );

%PUT ***** SSCFLAT VERSION 1.09;
%PUT ***** COPYRIGHT (C) 2000 SYSTEMS SEMINAR CONSULTANTS;
%PUT ***** 608 278-9964;

%IF &MTRACE=YES %THEN
 %DO;
   OPTIONS MLOGIC SYMBOLGEN MPRINT;
 %END;

%LET MSASDS=%UPCASE(&MSASDS);
%LET MHEADER=%UPCASE(&MHEADER);
%LET MLABEL=%UPCASE(&MLABEL);
%LET MLIST=%UPCASE(&MLIST);
%LET MTRIMNUM=%UPCASE(&MTRIMNUM);
%LET MTRIMCHA=%UPCASE(&MTRIMCHA);  * 5/20/2000;
%LET MTRACE=%UPCASE(&MTRACE);

%LET FOUNDOT=%INDEX(&MSASDS,.);
%IF &FOUNDOT=0 %THEN
 %DO;
    %LET MLIB=WORK;
    %LET MMEMNAME=%SUBSTR(&MSASDS,1,%LENGTH(&MSASDS)); 
  %END;
%ELSE
 %DO;
    %LET MLIB=%SUBSTR(&MSASDS,1,%EVAL(&FOUNDOT-1));
    %LET MMEMNAME=%SUBSTR(&MSASDS,%EVAL(&FOUNDOT+1));
 %END;

* CHANGED 07/28/2000 BY D.BEAM - CREATE SHORTER MEMBER NAME FOR USE;
*   IN MVS DEFAULT FLAT FILE NAME;
%IF %LENGTH(&MMEMNAME) GT 8 %THEN                         
   %LET MMEMSHRT=%SUBSTR(&MMEMNAME,1,8);    
%ELSE                                                    
   %LET MMEMSHRT=&MMEMNAME;                   


OPTIONS MISSING=&MMISSING;

 * SJF 5/8/2000;
%IF %STR(&SYSSCP)=OS %THEN
  %DO;
    * CHANGED 07/28/2000 BY D.BEAM - CREATE SHORTER MEMBER NAME FOR USE;
    *   IN MVS DEFAULT FLAT FILE NAME - IF USER DOES NOT PASS MFLATOUT=;
    *   THEN ASSIGN DSN HERE;
    %IF &MFLATOUT=&MPREFIX&MMEMNAME..DAT %THEN
      %LET MFLATOUT=&MPREFIX&MMEMSHRT..DAT;

    FILENAME FLATOUT  "&MFLATOUT" DISP=(MOD,DELETE,DELETE);
    FILENAME FLATOUT  "&MFLATOUT" DISP=(NEW,CATLG,DELETE)
             LRECL=&MLRECL SPACE=(CYL,(&MSPACE,&MSPACE),RLSE)
             RECFM=VB &MVSOPT ;
 
  %END;

 * SJF 5/8/2000;
%IF %STR(&SYSSCP)=WIN
 OR %STR(&SYSSCP)=ALXOSF
 OR %STR(&SYSSCP)=%STR(SUN 4)
%THEN
  %DO;
    FILENAME FLATOUT  "&MFLATOUT" ;
  %END;

%IF %SUBSTR(&SYSVER,1,1) LE 6 %THEN    /* VER 6 OR EARLIER ? */
   %DO;
      %LET MMAXVLEN=8;                 /* LONGEST VAR        */
      %LET MMAXLLEN=40;                /* LONGEST LABEL      */
   %END;
%ELSE                                  /* 7 OR LATER         */
   %DO;
      %LET MMAXVLEN=32;                /* LONGEST VAR        */
      %LET MMAXLLEN=256;               /* LONGEST LABEL      */
   %END;


%GLOBAL MNOMACV MTOTOBS;
PROC SQL;
  CREATE TABLE WORK.VCOLUMN AS
    SELECT NAME, TYPE, FORMAT, LENGTH, LABEL
    FROM DICTIONARY.COLUMNS
    WHERE LIBNAME=UPCASE("&MLIB")
          & MEMNAME=UPCASE("&MMEMNAME");

%IF &MTRACE=YES %THEN
 %DO;
    PROC PRINT DATA=WORK.VCOLUMN;
      TITLE 'WORK.VCOLUMN';
    RUN;
 %END;

DATA _NULL_;
  IF NOBS=0 THEN
    DO;
      FILE LOG;
      PUT "*** MSASDS=&MSASDS DOESNT EXIST OR HAS 0 VARS**";
      PUT "*** MLIB=&MLIB MMEMNAME=&MMEMNAME **";
      CALL SYMPUT('MNOMACV',"0");
      STOP;
    END;
  SET WORK.VCOLUMN END=EOF NOBS=NOBS;

      * ADDED 5/20/2000 TO NULLIFY FMTS FOR CHAR FIELDS;
      * IF MTRIMCHA=YES. LATER WHEN PUT STATEMENT WRITES;
      * THE VAR WITHOUT FORMAT, NO TRAILING BLANKS ARE;
      * WRITTEN.  DONT WANT TO NULLIFY IF USER FORMAT;

      * CHANGED 09/15/2000 BY D.BEAM TO USE CORRECT SUBSTR FOR $CHAR FORMAT;

  IF UPCASE(TYPE)= 'CHAR'                 /* IS VAR CHAR ?            */
   & "&MTRIMCHA" = "YES" THEN             /* TRIM OPTION ON           */
     DO;                                  /* DO THIS                  */
       IF SUBSTR(FORMAT,1,1)='$'          /* IS IT A $ FORMAT?        */
       OR SUBSTR(FORMAT,1,5)='$CHAR' THEN /* OR A $CHAR FORMAT        */
       DO;
         IF SUBSTR(FORMAT,1,5)='$CHAR'    /* FOR CHAR, LOOK IN POS 6  */
            THEN LENPOS=6;
         ELSE IF SUBSTR(FORMAT,1,1)='$'   /* IS IT A $ FORMAT?        */
            THEN LENPOS=2;                /* MIGHT CHECK POS 2 FOR DIG*/
                                          /* IS DIGIT NUMERIC? IE. NOT*/
         IF '0' LE SUBSTR(FORMAT,LENPOS,1) /* A USER FORMAT?          */
         &  SUBSTR(FORMAT,LENPOS,1)  LE '9' THEN
           FORMAT=' ';                    /* BLANK OUT FORMAT THIS VAR*/
       END;                               /* END $, $CHAR BLOCK       */
     END;                                 /* END CHAR, TRIM BLOCK     */
  * CHANGED 05/13/1999 BY DAVID BEAM. FIX OVERRIDE OF;
  *   NUMERIC FORMATS COMMA,DOLLAR AND PERCENT TO USE BEST32.;

  IF SUBSTR(FORMAT,1,5) IN('COMMA','DOLLA','PERCE')
     THEN FORMAT='BEST32.';
  CALL SYMPUT('MVAR'!!LEFT(PUT(_N_,4.)),NAME);
  CALL SYMPUT('MTYP'!!LEFT(PUT(_N_,4.)),UPCASE(TYPE));
  IF FORMAT NE ' ' THEN
     CALL SYMPUT('MFMT'!!LEFT(PUT(_N_,4.)),FORMAT);
  ELSE
     CALL SYMPUT('MFMT'!!LEFT(PUT(_N_,4.))," ");
  IF "&MHEADER"="YES" THEN
    DO;
      FILE FLATOUT LRECL=&MLRECL;
      IF _N_ GT 1 THEN
        PUT "," @;

      * ADDED 12/16/1998 - LABELS CAN BE USED INSTEAD OF VAR NAME;
      *    (USE VAR NAME IF LABEL EMPTY);
      * 5/8/2000 INCREASE NAME LEN TO 32, LABEL LEN TO 256 ;

      IF "&MLABEL"="YES" AND (LABEL NE ' ') THEN
        DO;
          LEN=LENGTH(LABEL);
          PUT '"' LABEL VARYING&MMAXLLEN.. LEN '"' @;
        END;
      ELSE
        DO;
          LEN=LENGTH(NAME);
          PUT '"' NAME VARYING&MMAXVLEN..  LEN '"' @;
        END;
    END;
  OUTPUT;

  IF EOF THEN
    CALL SYMPUT('MNOMACV',LEFT(PUT(NOBS,3.)));
RUN;

%IF &MTRACE=YES %THEN
 %DO;
    PROC PRINT DATA=&MLIB..&MMEMNAME(OBS=50);
      TITLE "&MLIB..&MMEMNAME(OBS=50)";
    RUN;
 %END;

%IF &MNOMACV NE 0 %THEN
 %DO;
  DATA _NULL_;

   /* 7/8/1998 FIX 0 OBS PROBLEM SJF */
   IF _N_ =1 THEN                /* USE _N_ INSTEAD OF EOF         */
      CALL SYMPUT('MTOTOBS',LEFT(PUT(NOBS,8.)));

   SET &MLIB..&MMEMNAME NOBS=NOBS END=EOF;

   FILE FLATOUT MOD LRECL=&MLRECL;

     %DO I=1 %TO &MNOMACV;
       %IF &&MTYP&I=CHAR %THEN
         %DO;
           * ADDED 06/20/97 BY D.BEAM TO NOT PUT 1 SPACE OUT FOR;
           *   EMPTY FIELDS;
           IF TRIM(&&MVAR&I) = ' ' THEN
             DO;
               PUT '"",' @;
             END;
           ELSE
             DO;
               * CHANGED 09/18/2000 BY D.BEAM TO REMOVE DOUBLE QUOTES;
               *    IF PRESENT IN CHARACTER STRING VALUE;
               %IF &&MFMT&I=%STR() %THEN    /* NO FORMAT */
                 %DO;
                   &&MVAR&I = COMPRESS(&&MVAR&I,'"');
                   PUT
                     '"'
                     &&MVAR&I
                     +(-1)                  /* BACKUP UP 1 SPACE */
                    '",' @;
                 %END;
               %ELSE
                 %DO;                       /* USES FORMAT */
                   LENGTH _SSCHARVAR $ 1000;
                   _SSCHARVAR = LEFT(TRIM(PUT(&&MVAR&I,&&MFMT&I)));
                   * REMOVE DOUBLE QUOTE IF PRESENT;
                   _SSCHARVAR = COMPRESS(_SSCHARVAR,'"');
                   PUT
                     '"'
                     _SSCHARVAR
                     +(-1)                  /* BACKUP UP 1 SPACE */
                     '",' @;
                 %END;
             END;
         %END;

       %IF &&MTYP&I=NUM %THEN
         %DO;
           %IF &MTRIMNUM=NO %THEN
             %DO;
               PUT
                  &&MVAR&I &&MFMT&I
                  %IF &&MFMT&I=%STR() %THEN
                    %DO;
                      +(-1)
                    %END;
                  ',' @;
             %END;

           %IF &MTRIMNUM=YES %THEN
             %DO;
               LENGTH _SSCCVAR $ 40;
               %IF &&MFMT&I=%STR() %THEN
                 %DO;
                   * CHANGED 05/13/1999 BY DAVID BEAM. FIX OVERRIDE OF;
                   *   NUMERIC FORMATS COMMA,DOLLAR AND PERCENT TO USE BEST32.;
                   _SSCCVAR=LEFT(TRIM(PUT(&&MVAR&I,BEST32.)));
                 %END;
               %ELSE
                 %DO;
                   _SSCCVAR=LEFT(TRIM(PUT(&&MVAR&I,&&MFMT&I)));

                   * CHANGED 09/18/2000 BY D.BEAM TO CHECK FORMATTED NUMERIC;
                   *  RESULT FOR ANY COMMAS. IF SO, WRAP THE STRING IN QUOTES;
                   * ALSO TO REMOVE DOUBLE QUOTES IF PRESENT IN FORMATTED VALUE;
                   _SSCCVAR = COMPRESS(_SSCCVAR,'"');
                   IF INDEX(_SSCCVAR,",") GT 0 THEN
                     DO;
                       _SSCCVAR = '"' !! TRIM(_SSCCVAR) !! '"';
                     END;

                 %END;
               PUT _SSCCVAR +(-1) ',' @;
             %END;
         %END;
     %END;

     PUT +(-1) ' ' ;

  RUN;

  *******************************************************************;
  * READ DATA SET, COUNT RECS AND BYTES                             *;
  *******************************************************************;

   DATA _NULL_;
    INFILE FLATOUT  MISSOVER LENGTH=LENREC END=EOF LRECL=&MLRECL;
    RETAIN LONGEST 0;
    INPUT;
    %IF &MLIST=YES %THEN LIST %STR(;);
    BYTES+(LENREC+2);
    REC+1;
    LONGEST=MAX(LONGEST,LENREC);
    IF EOF;
     BYTECNT+1;                      /* ADD ONE FOR ASCII EOF  */
     TOTOBS=&MTOTOBS;
     IF "&MHEADER"="YES" THEN
         HEADOUT=1;
     ELSE
         HEADOUT=0;
     DATAOUT=REC-HEADOUT;
     FILE PRINT;TITLE;
     PUT '**********************************************************';
     PUT ' SSCFLAT CONVERSION MACRO OUTPUT  VERSION 1.08            ';
     PUT;
     PUT "  INPUT SAS DATASET =  &MLIB..&MMEMNAME ";
     PUT "  INPUT OBSERVATIONS = " TOTOBS COMMA9.;
     PUT;
     PUT " OUTPUT FLAT FILE   =  &MFLATOUT ";
     PUT "  RECORDS OUT                    ";
     PUT "   HEADER RECORDS   = " HEADOUT COMMA9.;
     PUT "   DATA   RECORDS   = " DATAOUT COMMA9.;
     PUT "  TOTAL  RECORDS    = " REC     COMMA9.;
     PUT;
     PUT " TOTAL BYTES        = " BYTES COMMA9.;
     PUT " LONGEST RECORD     = " LONGEST COMMA9.;
     IF DATAOUT NE TOTOBS THEN
        DO;
         PUT;
         PUT " NOTE: NO. OF OBS IN DOES NOT MATCH RECORDS OUT !!! ";
         PUT " DATA MAY BE LOST OR BROKEN INTO MULTIPLE RECORDS !!! ";
         PUT " MLRECL MAY NEED TO BE INCREASED  !!! ";
         PUT;
        END;
     PUT '**********************************************************';
   RUN;
 %END;

  FILENAME FLATOUT  CLEAR;

%MEND SSCFLAT;

