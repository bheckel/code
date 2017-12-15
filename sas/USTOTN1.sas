//BQH0UST  JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=120,CLASS=A,REGION=0M
//***BQH0UST  JOB (BF00,BX21),BQH0,MSGCLASS=K,TIME=20,CLASS=J,REGION=0M
//STEP1    EXEC SAS913,TIME=100,OPTIONS='MEMSIZE=0,ALTPRINT=OLST,
//                                                 ALTLOG=OLOG'
//OLST     DD DISP=SHR,DSN=BQH0.INC.SASLST
//OLOG     DD DISP=SHR,DSN=BQH0.INC.SASLOG
//WORK     DD SPACE=(CYL,(1000,1000),,,ROUND)
//SYSIN    DD *

 /**********************************************************************
  * PROGRAM NAME: DWJ2.UTIL.LIBRARY(USTOTN1)
  *
  *  DESCRIPTION: Create a dataset containing percentages for all
  *               states.  When a TSA is run by a user, this dataset
  *               will be merged with current MVDS data to provide the
  *               US Total percent column.
  *
  *               This is based on TSAAAAA but has been modified to
  *               handle the processing of all states over 1 year
  *               instead of TSAAAAA's processing of 1 state over 6
  *               years plus the exclusion of certain vars for certain
  *               events.
  *
  *               Must be re-run each time the Structure file changes.
  *
  *               Nat 03 rev takes about 110 mins to run.
  *
  *     CALLS TO: nothing but relies on MVDS datasets
  *    CALLED BY: nothing, runs only by hand at data year end
  *
  *  INPUT MVARS: none
  *
  *   PROGRAMMER: bqh0
  * DATE WRITTEN: 2005-01-14
  *
  *   UPDATE LOG:
  * 2005-05-31 (bqh0) Re-run all using new exclusion lists from NCHS.
  * 2005-06-20 (bqh0) Re-run in preparation for release of new TSA
  *                   system.
  *********************************************************************/

%global Y REVTYPE FLAG EVT REPTYR;
 /**************** Edit (potentially more edits below) ******************/
%let Y=2003;  /* closed year from which to create US tot pct dataset */
 /************************ Edit *****************************************/
%let REVTYPE=%upcase(old);  /* OLD only */
%let EVT=%upcase(nat);  /* NAT only */
%let FLAG=; /* blank for nonrev - for the format lib extension only */

OPTIONS MLOGIC MPRINT SYMBOLGEN NOOVP FMTSEARCH=(WORK FMTLIB)
        NOSORTDEVWARN CENTER MISSING=0 ERRORABEND NOCAPS
        ;
TITLE1; FOOTNOTE1;
%GLOBAL SPLITOLD YEAR EVT STATE TMPF UPD ODS FIX J USER FILEOUT BADREC
        ;

%let START=%sysfunc(time());

 /* This is forced instead of using the year variable so that we ignore
  * potential bad year data from the states.
  */
%let REPTYR=&Y;  

***LIBNAME USTOT 'DWJ2.USTOT.SASLIB' DISP=OLD WAIT=30;
 /* debug */
LIBNAME USTOT 'BQH0.SASLIB' DISP=OLD WAIT=30;

 /* Format lib - Structure files are always 2003 */
LIBNAME FMTLIB "DWJ2.&EVT.2003&FLAG..FMTLIB" DISP=SHR WAIT=250;

LIBNAME MVDS&Y "DWJ2.&EVT.&Y..MVDS.LIBRARY.NEW" DISP=SHR WAIT=1;


 /* This block can be eliminated when all states have revised */
%GLOBAL CSVRISKVARS RISKV;
%LET CSVRISKVARS="";  /* quotes required b/c used in proc sql */
%LET RISKV=;
%MACRO GETRISKVARS;  /* if necessary *//*{{{*/
  %IF %SYSFUNC(INDEXW(NAT FET, &EVT)) AND &REVTYPE EQ OLD %THEN
    %DO;
      PROC FORMAT LIBRARY=FMTLIB CNTLOUT=TSARISKS;
        SELECT $TSARISKS;
      RUN;
      /* Get risk factor variable names for non-rev runs. */
      PROC SQL NOPRINT;
        /* Must be quoted for proc sql below */
        SELECT START INTO :RISKV SEPARATED BY ' '
        FROM TSARISKS
        ;
      QUIT;
      PROC SQL NOPRINT;
        /* Must be comma separated and quoted for proc sql below */
        SELECT QUOTE(TRIM(START)) INTO :CSVRISKVARS SEPARATED BY ', '
        FROM TSARISKS
        ;
      QUIT;
    %END;
%MEND GETRISKVARS;
%GETRISKVARS/*}}}*/


 /******** Start gathering variables and formats ********/
%GLOBAL VARS FMTS RANGEVARS RANGEVARS2;

 /*--- Build temporary datasets from Structure formats ---*/

PROC FORMAT LIBRARY=FMTLIB CNTLOUT=LISTA;
  SELECT $LISTA;
RUN;

PROC FORMAT LIBRARY=FMTLIB CNTLOUT=DROPZ;
  SELECT $DROPZ;  /* as in 'drop zero' */
RUN;

PROC FORMAT LIBRARY=FMTLIB CNTLOUT=NUMVALID;
  SELECT $NUMVALID;  /* as in 'these vars have numbers as valid values' */
RUN;


 /*--- Extract variable names ---*/

 /* Get all variable names to display on report from MVDS.  The
  * Structure format names will be used as the dataset names we create
  * via CNTLOUT.  For nat/fet nonrev, this includes Risk Factors we
  * don't want so we eliminate them in the WHERE clause.
  */
PROC SQL NOPRINT;
  SELECT START INTO :VARS SEPARATED BY ' '
  FROM LISTA
  WHERE START NOT IN ( &CSVRISKVARS )
  ORDER BY LABEL
  ;
QUIT;

 /* It is ok for the varname and its fmt to be concatenated w/o a space */
PROC SQL NOPRINT;
  SELECT CATS(START,LABEL) INTO :FMTS SEPARATED BY ' '
  FROM LISTA
  WHERE START NOT IN ( &CSVRISKVARS )
  ;
QUIT;

 /* Get special wide range variable names like MOTHYR, MENSYR, etc. into
  * a comma separated list.  Nat/fet only.
  */
PROC SQL NOPRINT;
  SELECT START INTO :RANGEVARS SEPARATED BY ' '
  FROM DROPZ
  ;
QUIT;

 /* Gather numeric variable names to be handled specially in the formats
  * to avoid trouble with character sorting in proc format.
  * E.g. DWGT FAGER FDOB_DY IDOB_DY MAGER MDOB_DY NPCES NPREV PLBD
  */
PROC SQL NOPRINT;
  SELECT START INTO :RANGEVARS2 SEPARATED BY ' '
  FROM NUMVALID
  ;
QUIT;
 /******** End gathering variables and formats ********/


%MACRO SET;
  %MACRO SNAT;/*{{{*/
    %IF &REVTYPE EQ NEW %THEN
      %DO;
        /* We're building e.g. UST2003NEWNAT */
        MVDS&Y..PA&REVTYPE(where=(void ne '1' and revtype eq 'NEW'))
        MVDS&Y..WA&REVTYPE(where=(void ne '1' and revtype eq 'NEW'))
      %END;
    %ELSE %IF &REVTYPE EQ OLD %THEN
      %DO;
        /* We're building e.g. UST2003OLDNAT */  
        MVDS&Y..AK&REVTYPE
        MVDS&Y..AL&REVTYPE
        MVDS&Y..AR&REVTYPE
        /* NCHS exclusion */
        /*** MVDS&Y..AS&REVTYPE ***/
        MVDS&Y..AZ&REVTYPE
        MVDS&Y..CA&REVTYPE
        MVDS&Y..CO&REVTYPE
        MVDS&Y..CT&REVTYPE
        MVDS&Y..DC&REVTYPE
        MVDS&Y..DE&REVTYPE
        MVDS&Y..FL&REVTYPE
        MVDS&Y..GA&REVTYPE
        MVDS&Y..GU&REVTYPE
        MVDS&Y..HI&REVTYPE
        MVDS&Y..IA&REVTYPE
        MVDS&Y..ID&REVTYPE
        MVDS&Y..IL&REVTYPE
        MVDS&Y..IN&REVTYPE
        MVDS&Y..KS&REVTYPE
        MVDS&Y..KY&REVTYPE
        MVDS&Y..LA&REVTYPE
        MVDS&Y..MA&REVTYPE
        MVDS&Y..MD&REVTYPE
        MVDS&Y..ME&REVTYPE
        MVDS&Y..MI&REVTYPE
        MVDS&Y..MN&REVTYPE
        MVDS&Y..MO&REVTYPE
        /* NCHS exclusion */
        /*** MVDS&Y..MP&REVTYPE ***/
        MVDS&Y..MS&REVTYPE
        MVDS&Y..MT&REVTYPE
        MVDS&Y..NC&REVTYPE
        MVDS&Y..ND&REVTYPE
        MVDS&Y..NE&REVTYPE
        MVDS&Y..NH&REVTYPE
        MVDS&Y..NJ&REVTYPE
        MVDS&Y..NM&REVTYPE
        MVDS&Y..NV&REVTYPE
        MVDS&Y..NY&REVTYPE
        MVDS&Y..OH&REVTYPE
        MVDS&Y..OK&REVTYPE
        MVDS&Y..OR&REVTYPE
        /*** MVDS&Y..PA&REVTYPE ***/
        MVDS&Y..PR&REVTYPE
        MVDS&Y..RI&REVTYPE
        MVDS&Y..SC&REVTYPE
        MVDS&Y..SD&REVTYPE
        MVDS&Y..TN&REVTYPE
        MVDS&Y..TX&REVTYPE
        MVDS&Y..UT&REVTYPE
        MVDS&Y..VA&REVTYPE
        MVDS&Y..VI&REVTYPE
        MVDS&Y..VT&REVTYPE
        /*** MVDS&Y..WA&REVTYPE ***/
        MVDS&Y..WI&REVTYPE
        MVDS&Y..WV&REVTYPE
        MVDS&Y..WY&REVTYPE
        MVDS&Y..YC&REVTYPE
      %END;
  %MEND SNAT;/*}}}*/

  %MACRO SFET;/*{{{*/
    %IF &REVTYPE EQ NEW %THEN
      %DO;
        /* We're building e.g. UST2003NEWFET */
        MVDS&Y..MI&REVTYPE(where=(revtype eq 'NEW'))
        MVDS&Y..WA&REVTYPE(where=(revtype eq 'NEW'))
      %END;
    %ELSE %IF &REVTYPE EQ OLD %THEN
      %DO;
        /* We're building e.g. UST2003OLDFET */  
        MVDS&Y..AK&REVTYPE
        MVDS&Y..AL&REVTYPE
        MVDS&Y..AR&REVTYPE
        /* NCHS exclusion */
        /*** MVDS&Y..AS&REVTYPE ***/
        MVDS&Y..AZ&REVTYPE
        MVDS&Y..CA&REVTYPE
        MVDS&Y..CO&REVTYPE
        MVDS&Y..CT&REVTYPE
        MVDS&Y..DC&REVTYPE
        MVDS&Y..DE&REVTYPE
        MVDS&Y..FL&REVTYPE
        MVDS&Y..GA&REVTYPE
        MVDS&Y..GU&REVTYPE
        MVDS&Y..HI&REVTYPE
        MVDS&Y..IA&REVTYPE
        MVDS&Y..ID&REVTYPE
        MVDS&Y..IL&REVTYPE
        MVDS&Y..IN&REVTYPE
        MVDS&Y..KS&REVTYPE
        MVDS&Y..KY&REVTYPE
        MVDS&Y..LA&REVTYPE
        MVDS&Y..MA&REVTYPE
        MVDS&Y..MD&REVTYPE
        MVDS&Y..ME&REVTYPE
        MVDS&Y..MI&REVTYPE
        MVDS&Y..MN&REVTYPE
        MVDS&Y..MO&REVTYPE
        /* NCHS exclusion */
        /*** MVDS&Y..MP&REVTYPE ***/
        MVDS&Y..MS&REVTYPE
        MVDS&Y..MT&REVTYPE
        MVDS&Y..NC&REVTYPE
        MVDS&Y..ND&REVTYPE
        MVDS&Y..NE&REVTYPE
        MVDS&Y..NH&REVTYPE
        MVDS&Y..NJ&REVTYPE
        MVDS&Y..NM&REVTYPE
        MVDS&Y..NV&REVTYPE
        MVDS&Y..NY&REVTYPE
        MVDS&Y..OH&REVTYPE
        MVDS&Y..OK&REVTYPE
        MVDS&Y..OR&REVTYPE
        MVDS&Y..PA&REVTYPE
        MVDS&Y..PR&REVTYPE
        MVDS&Y..RI&REVTYPE
        MVDS&Y..SC&REVTYPE
        MVDS&Y..SD&REVTYPE
        MVDS&Y..TN&REVTYPE
        MVDS&Y..TX&REVTYPE
        MVDS&Y..UT&REVTYPE
        MVDS&Y..VA&REVTYPE
        MVDS&Y..VI&REVTYPE
        MVDS&Y..VT&REVTYPE
        /*** MVDS&Y..WA&REVTYPE ***/
        MVDS&Y..WI&REVTYPE
        MVDS&Y..WV&REVTYPE
        MVDS&Y..WY&REVTYPE
        MVDS&Y..YC&REVTYPE
      %END;
  %MEND SFET;/*}}}*/

  %MACRO SMOR;/*{{{*/
    %IF &REVTYPE EQ NEW %THEN
      %DO;
        /* We're building e.g. UST2003NEWMOR */
        MVDS&Y..CA&REVTYPE(where=(alias ne '1' and
                                  void ne '1' and
                                  revtype eq 'NEW'))
        MVDS&Y..ID&REVTYPE(where=(alias ne '1' and
                                  void ne '1' and
                                  revtype eq 'NEW'))
        MVDS&Y..MT&REVTYPE(where=(alias ne '1' and
                                  void ne '1' and
                                  revtype eq 'NEW'))
        MVDS&Y..NY&REVTYPE(where=(alias ne '1' and
                                  void ne '1' and
                                  revtype eq 'NEW'))
        MVDS&Y..YC&REVTYPE(where=(alias ne '1' and
                                  void ne '1' and
                                  revtype eq 'NEW'))
      %END;
    %ELSE %IF &REVTYPE EQ OLD %THEN
      %DO;
        /* We're building e.g. UST2002OLDMOR */ 
        MVDS&Y..AK&REVTYPE(where=(alias ne '1'))
        MVDS&Y..AL&REVTYPE(where=(alias ne '1'))
        MVDS&Y..AR&REVTYPE(where=(alias ne '1'))
        /* NCHS exclusion */
        /*** MVDS&Y..AS&REVTYPE(where=(alias ne '1')) ***/
        MVDS&Y..AZ&REVTYPE(where=(alias ne '1'))
        /*** MVDS&Y..CA&REVTYPE(where=(alias ne '1')) ***/
        MVDS&Y..CO&REVTYPE(where=(alias ne '1'))
        MVDS&Y..CT&REVTYPE(where=(alias ne '1'))
        MVDS&Y..DC&REVTYPE(where=(alias ne '1'))
        MVDS&Y..DE&REVTYPE(where=(alias ne '1'))
        MVDS&Y..FL&REVTYPE(where=(alias ne '1'))
        MVDS&Y..GA&REVTYPE(where=(alias ne '1'))
        MVDS&Y..GU&REVTYPE(where=(alias ne '1'))
        MVDS&Y..HI&REVTYPE(where=(alias ne '1'))
        MVDS&Y..IA&REVTYPE(where=(alias ne '1'))
        /*** MVDS&Y..ID&REVTYPE(where=(alias ne '1')) ***/
        MVDS&Y..IL&REVTYPE(where=(alias ne '1'))
        MVDS&Y..IN&REVTYPE(where=(alias ne '1'))
        MVDS&Y..KS&REVTYPE(where=(alias ne '1'))
        MVDS&Y..KY&REVTYPE(where=(alias ne '1'))
        MVDS&Y..LA&REVTYPE(where=(alias ne '1'))
        MVDS&Y..MA&REVTYPE(where=(alias ne '1'))
        MVDS&Y..MD&REVTYPE(where=(alias ne '1'))
        MVDS&Y..ME&REVTYPE(where=(alias ne '1'))
        MVDS&Y..MI&REVTYPE(where=(alias ne '1'))
        MVDS&Y..MN&REVTYPE(where=(alias ne '1'))
        MVDS&Y..MO&REVTYPE(where=(alias ne '1'))
        /* NCHS exclusion */
        /*** MVDS&Y..MP&REVTYPE(where=(alias ne '1')) ***/
        MVDS&Y..MS&REVTYPE(where=(alias ne '1'))
        /*** MVDS&Y..MT&REVTYPE(where=(alias ne '1')) ***/
        MVDS&Y..NC&REVTYPE(where=(alias ne '1'))
        MVDS&Y..ND&REVTYPE(where=(alias ne '1'))
        MVDS&Y..NE&REVTYPE(where=(alias ne '1'))
        MVDS&Y..NH&REVTYPE(where=(alias ne '1'))
        MVDS&Y..NJ&REVTYPE(where=(alias ne '1'))
        MVDS&Y..NM&REVTYPE(where=(alias ne '1'))
        MVDS&Y..NV&REVTYPE(where=(alias ne '1'))
        /*** MVDS&Y..NY&REVTYPE(where=(alias ne '1')) ***/
        MVDS&Y..OH&REVTYPE(where=(alias ne '1'))
        MVDS&Y..OK&REVTYPE(where=(alias ne '1'))
        MVDS&Y..OR&REVTYPE(where=(alias ne '1'))
        MVDS&Y..PA&REVTYPE(where=(alias ne '1'))
        MVDS&Y..PR&REVTYPE(where=(alias ne '1'))
        MVDS&Y..RI&REVTYPE(where=(alias ne '1'))
        MVDS&Y..SC&REVTYPE(where=(alias ne '1'))
        MVDS&Y..SD&REVTYPE(where=(alias ne '1'))
        MVDS&Y..TN&REVTYPE(where=(alias ne '1'))
        MVDS&Y..TX&REVTYPE(where=(alias ne '1'))
        MVDS&Y..UT&REVTYPE(where=(alias ne '1'))
        MVDS&Y..VA&REVTYPE(where=(alias ne '1'))
        MVDS&Y..VI&REVTYPE(where=(alias ne '1'))
        MVDS&Y..VT&REVTYPE(where=(alias ne '1'))
        MVDS&Y..WA&REVTYPE(where=(alias ne '1'))
        MVDS&Y..WI&REVTYPE(where=(alias ne '1'))
        MVDS&Y..WV&REVTYPE(where=(alias ne '1'))
        MVDS&Y..WY&REVTYPE(where=(alias ne '1'))
        /*** MVDS&Y..YC&REVTYPE(where=(alias ne '1')) ***/
      %END;
  %MEND SMOR;/*}}}*/

  %IF &EVT EQ NAT AND &REVTYPE EQ OLD %THEN/*{{{*/
    %DO;
      SET %SNAT;
    %END;
  %ELSE %IF &EVT EQ NAT AND &REVTYPE EQ NEW %THEN
    %DO;
      SET %SNAT;
    %END;

  %ELSE %IF &EVT EQ MOR AND &REVTYPE EQ NEW %THEN
    %DO;
      SET %SMOR;
    %END;
  %ELSE %IF &EVT EQ MOR AND &REVTYPE EQ OLD %THEN
    %DO;
      SET %SMOR;
    %END;

  %ELSE %IF &EVT EQ FET AND &REVTYPE EQ OLD %THEN
    %DO;
      SET %SFET;
    %END;
  %ELSE %IF &EVT EQ FET AND &REVTYPE EQ NEW %THEN
    %DO;
      SET %SFET;
    %END;/*}}}*/
%MEND SET;


 /* For items that are characters but display numeric ranges, make
  * sure garbage characters don't silently sort into valid "numeric"
  * ranges.
  */
%MACRO CK4NONNUMERIC;
  %LOCAL I V;
  %LET I=1;
  %LET V=%QSCAN(&RANGEVARS2, &I, ' ');
  %DO %WHILE ( &V NE  );
    %LET I=%EVAL(&I+1);
    IF NOTDIGIT(&V) THEN
      &V = '*';  /* found garbage, assign arbitrary invalid value */
    %LET V=%QSCAN(&RANGEVARS2, &I, ' ');
  %END;
 %MEND CK4NONNUMERIC;


 /*********** Begin using MVDS datasets ***********/
 /*                                               */
 /* Gather MVDS dataset data, RISKV will be empty and ignored if we're
  * not running a NAT/FET OLD.
  */
DATA STATEDS (KEEP=&VARS &RISKV REPTYR COUNT state);
  %SET

  /* debug */
  ***if uniform(0) le .0001;

  REPTYR=&Y;

  %CK4NONNUMERIC;

  COUNT = 1;  /* for proc means */
RUN;

LIBNAME MVDS&Y CLEAR;
 /*                                                 */
 /*********** Finished with MVDS datasets ***********/


 /* Avoid having spaces deleted instead of counted as ***INVALID*** in
  * the next proc means for vars that cannot properly accept blanks.
  * Those should have been converted to our convention of using 'b'.
  */
DATA STATEDS;
  SET STATEDS;
  ARRAY C _CHARACTER_;
  DO OVER C;
    IF C = ' ' THEN
      C = '_';
  END;
RUN;


 /* This algorithm is very differ from TSAAAAA because we must delete
  * exclusion observations prior to creating the freqsN datasets.  It is
  * not possible to do that in a single PROC MEANS.
  */
SASFILE STATEDS OPEN;
%MACRO BUILDFREQS;/*{{{*/
  %LOCAL I VAR;
  %LET I=1;
  %DO %UNTIL (%QSCAN(&VARS,&I) EQ  );
    %LET VAR=%QSCAN(&VARS,&I);
    DATA TMP;
      SET STATEDS;
      /* NCHS exclusions. */
      /***** Revisers *****/
      IF "&REVTYPE" EQ 'NEW' THEN
        DO;
          IF "&EVT" EQ 'NAT' THEN
            DO;/*{{{*/
              IF "&VAR" EQ 'MAGE_BYPASS' AND STATE IN('PA') THEN DELETE;
              ELSE IF "&VAR" EQ 'LIMITS' AND STATE IN('PA') THEN DELETE;
              ELSE IF "&VAR" EQ 'FAGE_BYPASS' AND STATE IN('PA') THEN DELETE;
              ELSE IF "&VAR" EQ 'MARE' AND STATE IN('PA','WA') THEN DELETE;
              ELSE IF "&VAR" EQ 'ACKN' AND STATE IN('PA') THEN DELETE;
              ELSE IF "&VAR" EQ 'MEDUC_BYPASS' AND STATE IN('PA') THEN DELETE;
              ELSE IF "&VAR" EQ 'FEDUC_BYPASS' AND STATE IN('PA') THEN DELETE;
              ELSE IF "&VAR" EQ 'NPREV_BYPASS' AND STATE IN('PA') THEN DELETE;
              ELSE IF "&VAR" EQ 'HGT_BYPASS' AND STATE IN('PA') THEN DELETE;
              ELSE IF "&VAR" EQ 'PWGT_BYPASS' AND STATE IN('PA') THEN DELETE;
              ELSE IF "&VAR" EQ 'DWGT_BYPASS' AND STATE IN('PA') THEN DELETE;
              ELSE IF "&VAR" EQ 'NPCES_BYPASS' AND STATE IN('PA') THEN DELETE;
              ELSE IF "&VAR" EQ 'BW_BYPASS' AND STATE IN('PA') THEN DELETE;
              ELSE IF "&VAR" EQ 'OWGEST_BYPASS' AND STATE IN('PA') THEN DELETE;
              ELSE IF "&VAR" EQ 'PLUR_BYPASS' AND STATE IN('PA') THEN DELETE;
              ELSE IF "&VAR" EQ 'ECVS' AND STATE IN('WA') THEN DELETE;
              ELSE IF "&VAR" EQ 'ECVF' AND STATE IN('WA') THEN DELETE;
              ELSE IF "&VAR" EQ 'LIVEB' AND STATE IN('PA','WA') THEN DELETE;
              ELSE IF "&VAR" EQ 'MAGER' AND STATE IN('WA') THEN DELETE;
              ELSE IF "&VAR" EQ 'FAGER' AND STATE IN('WA') THEN DELETE;
            END;/*}}}*/
          ELSE IF "&EVT" EQ 'FET' THEN
            DO;/*{{{*/
              IF "&VAR" EQ 'MAGE_BYPASS' AND STATE IN('MI') THEN DELETE;
              ELSE IF "&VAR" EQ 'FAGE_BYPASS' AND STATE IN('MI') THEN DELETE;
              ELSE IF "&VAR" EQ 'MARE' AND STATE IN('MI','WA') THEN DELETE;
              ELSE IF "&VAR" EQ 'MEDUC_BYPASS' AND STATE IN('MI') THEN DELETE;
              ELSE IF "&VAR" EQ 'NPREV_BYPASS' AND STATE IN('MI') THEN DELETE;
              ELSE IF "&VAR" EQ 'HGT_BYPASS' AND STATE IN('MI') THEN DELETE;
              ELSE IF "&VAR" EQ 'PWGT_BYPASS' AND STATE IN('MI') THEN DELETE;
              ELSE IF "&VAR" EQ 'DWGT_BYPASS' AND STATE IN('MI') THEN DELETE;
              ELSE IF "&VAR" EQ 'CIGPN' AND STATE IN('MI') THEN DELETE;
              ELSE IF "&VAR" EQ 'CIGFN' AND STATE IN('MI') THEN DELETE;
              ELSE IF "&VAR" EQ 'CIGSN' AND STATE IN('MI') THEN DELETE;
              ELSE IF "&VAR" EQ 'CIGLN' AND STATE IN('MI') THEN DELETE;
              ELSE IF "&VAR" EQ 'NPCES_BYPASS' AND STATE IN('MI') THEN DELETE;
              ELSE IF "&VAR" EQ 'FW_BYPASS' AND STATE IN('MI') THEN DELETE;
              ELSE IF "&VAR" EQ 'OWGEST_BYPASS' AND STATE IN('MI') THEN DELETE;
              ELSE IF "&VAR" EQ 'FDTH' AND STATE IN('MI','WA') THEN DELETE;
              ELSE IF "&VAR" EQ 'PLUR_BYPASS' AND STATE IN('MI') THEN DELETE;
              ELSE IF "&VAR" EQ 'MAGER' AND STATE IN('WA') THEN DELETE;
              ELSE IF "&VAR" EQ 'FAGER' AND STATE IN('WA') THEN DELETE;
              /* FDOD_MO to be excluded for 2003 split year only */
              ELSE IF "&VAR" EQ 'FDOD_MO' AND STATE IN('MI') THEN DELETE;
            END;/*}}}*/
          ELSE IF "&EVT" EQ 'MOR' THEN
            DO;/*{{{*/
              IF "&VAR" EQ 'TOD' AND STATE IN('CA') THEN DELETE;
              ELSE IF "&VAR" EQ 'SEX_BYPASS' AND STATE IN('YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'AGE_BYPASS' AND STATE IN('YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'LIMITS' AND STATE IN('CA') THEN DELETE;
              ELSE IF "&VAR" EQ 'MARITAL_BYPASS' AND STATE IN('YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'DISP' AND STATE IN('CA') THEN DELETE;
              ELSE IF "&VAR" EQ 'DEDUC_BYPASS' AND STATE IN('YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'RACE_MVR' AND STATE IN('YC','NY') THEN DELETE;
            END;/*}}}*/
        END;
      /********************/

      /***** Non-Revisers *****/
      ELSE IF "&REVTYPE" EQ 'OLD' THEN
        DO;
          IF "&EVT" EQ 'NAT' THEN
            DO;/*{{{*/
              IF "&VAR" EQ 'MOTHHISP' AND STATE IN('PR') THEN DELETE;
              ELSE IF "&VAR" EQ 'FATHHISP' AND STATE IN('PR') THEN DELETE;
              ELSE IF "&VAR" EQ 'GEST_WKS' AND STATE IN('CA') THEN DELETE;
              ELSE IF "&VAR" EQ 'GEST_WKS2' AND STATE IN('CA') THEN DELETE;
              ELSE IF "&VAR" EQ 'GEST_WKS3' AND STATE IN('CA') THEN DELETE;
              ELSE IF "&VAR" EQ 'GEST_WKS4' AND STATE IN('CA') THEN DELETE;
              ELSE IF "&VAR" EQ 'APGAR5' AND STATE IN('CA','TX') THEN DELETE;
              ELSE IF "&VAR" EQ 'TOB_USE' AND STATE IN('CA') THEN DELETE;
              ELSE IF "&VAR" EQ 'TOB_DAY' AND STATE IN('CA','IN','NY','SD') 
                THEN DELETE;
              ELSE IF "&VAR" EQ 'ALC_USE' AND STATE IN('CA') THEN DELETE;
              ELSE IF "&VAR" EQ 'ALC_DAY' AND STATE IN('CA','SD') THEN DELETE;
              ELSE IF "&VAR" EQ 'WGT_GAIN' AND STATE IN('CA') THEN DELETE;
              ELSE IF "&VAR" EQ 'HERPES' AND STATE IN('TX') THEN DELETE;
              ELSE IF "&VAR" EQ 'RHSENSIT' AND STATE IN('KS') THEN DELETE;
              ELSE IF "&VAR" EQ 'UTERINE' AND STATE IN('TX') THEN DELETE;
              ELSE IF "&VAR" EQ 'ANESTHE' AND STATE IN('TX') THEN DELETE;
              ELSE IF "&VAR" EQ 'FETALDIS' AND STATE IN('TX') THEN DELETE;
              ELSE IF "&VAR" EQ 'INJURY' AND STATE IN('NE','TX') THEN DELETE;
              ELSE IF "&VAR" EQ 'ALCO_SYN' AND STATE IN('WI') THEN DELETE;
              ELSE IF "&VAR" EQ 'LT30MIN' AND STATE IN('YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'GT30MIN' AND STATE IN('YC') THEN DELETE;

              ELSE IF "&VAR" EQ 'NO_CONG' AND STATE IN('NM') THEN DELETE;
              ELSE IF "&VAR" EQ 'ANENCEP' AND STATE IN('NM') THEN DELETE;
              ELSE IF "&VAR" EQ 'MENING' AND STATE IN('NM') THEN DELETE;
              ELSE IF "&VAR" EQ 'HYDROC' AND STATE IN('NM') THEN DELETE;
              ELSE IF "&VAR" EQ 'MICROCEC' AND STATE IN('NM') THEN DELETE;
              ELSE IF "&VAR" EQ 'CENNERV' AND STATE IN('NM') THEN DELETE;
              ELSE IF "&VAR" EQ 'HEART' AND STATE IN('NM') THEN DELETE;
              ELSE IF "&VAR" EQ 'RESP' AND STATE IN('NM') THEN DELETE;
              ELSE IF "&VAR" EQ 'STENOSIS' AND STATE IN('NM') THEN DELETE;
              ELSE IF "&VAR" EQ 'ATRESIA' AND STATE IN('NM') THEN DELETE;
              ELSE IF "&VAR" EQ 'GASTROS' AND STATE IN('NM') THEN DELETE;
              ELSE IF "&VAR" EQ 'OTH_GAS' AND STATE IN('NM') THEN DELETE;
              ELSE IF "&VAR" EQ 'MALGENIT' AND STATE IN('NM') THEN DELETE;
              ELSE IF "&VAR" EQ 'AGENES' AND STATE IN('NM') THEN DELETE;
              ELSE IF "&VAR" EQ 'OTH_UROG' AND STATE IN('NM') THEN DELETE;
              ELSE IF "&VAR" EQ 'CLEFT' AND STATE IN('NM') THEN DELETE;
              ELSE IF "&VAR" EQ 'POLYDAC' AND STATE IN('NM') THEN DELETE;
              ELSE IF "&VAR" EQ 'CLUB' AND STATE IN('NM') THEN DELETE;
              ELSE IF "&VAR" EQ 'HERNIA' AND STATE IN('NM') THEN DELETE;
              ELSE IF "&VAR" EQ 'OTH_MUSC' AND STATE IN('NM') THEN DELETE;
              ELSE IF "&VAR" EQ 'DOWNS' AND STATE IN('NM') THEN DELETE;
              ELSE IF "&VAR" EQ 'OTHCHROM' AND STATE IN('NM') THEN DELETE;
              ELSE IF "&VAR" EQ 'OTH_CONG' AND STATE IN('NM') THEN DELETE;

              /***
              Change per dwj2 2005-06-15
              ELSE IF "&VAR" IN('MRACE','FRACE') AND STATE IN('CA','HI','UT') 
                THEN DELETE;
              ELSE IF "&VAR" IN('MRACE','FRACE') AND STATE EQ 'OH' AND
                &VAR EQ 'X' THEN DELETE;
              ***/
              ELSE IF "&VAR" IN('MRACE','FRACE') AND 
                STATE IN('CA','HI','UT','OH') THEN DELETE;
            END;/*}}}*/
          IF "&EVT" EQ 'FET' THEN
            DO;/*{{{*/
               /* MI MOTHMO to be excluded for 2003 split year only */
              IF "&VAR" EQ 'MOTHMO' AND STATE IN('VA','MI') THEN DELETE;
              ELSE IF "&VAR" EQ 'MOTHDAY' AND STATE IN('VA') THEN DELETE;
              ELSE IF "&VAR" EQ 'MOTHYR' AND STATE IN('VA') THEN DELETE;
               /* MI FATHMO to be excluded for 2003 split year only */
              ELSE IF "&VAR" EQ 'FATHMO' AND STATE IN('VA','MI') THEN DELETE;
              ELSE IF "&VAR" EQ 'FATHDAY' AND STATE IN('VA') THEN DELETE;
              ELSE IF "&VAR" EQ 'FATHYR' AND STATE IN('VA') THEN DELETE;
              ELSE IF "&VAR" EQ 'MARSTAT' AND 
                STATE IN('CA','MI','NV','NY','TX','YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'MOTHHISP' AND STATE IN('OK','PR') THEN DELETE;
              ELSE IF "&VAR" EQ 'FATHHISP' AND 
                STATE IN('OK','PR','VA') THEN DELETE;
              ELSE IF "&VAR" EQ 'MRACE' AND STATE IN('PR') THEN DELETE;
              ELSE IF "&VAR" EQ 'FRACE' AND STATE IN('PR','VA') THEN DELETE;
              ELSE IF "&VAR" EQ 'FATHEDUC' AND STATE IN('VA') THEN DELETE;
              ELSE IF "&VAR" EQ 'FATHAGE' AND STATE IN('VA') THEN DELETE;
              ELSE IF "&VAR" EQ 'GEST_WKS' AND STATE IN('CA','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'GEST_WKS2' AND STATE IN('CA','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'GEST_WKS3' AND STATE IN('CA','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'GEST_WKS4' AND STATE IN('CA','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'TOB_USE' AND 
                STATE IN('CA','HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'TOB_DAY' AND 
                STATE IN('CA','HI','OK','IN','NY','SD') THEN DELETE;
              ELSE IF "&VAR" EQ 'ALC_USE' AND 
                STATE IN('CA','HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'ALC_DAY' AND 
                STATE IN('CA','HI','OK','SD') THEN DELETE;
              ELSE IF "&VAR" EQ 'WGT_GAIN' AND 
                STATE IN('CA','HI','OK') THEN DELETE;
 
              ELSE IF "&VAR" EQ 'NO_RISK' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'ANEMIA' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'CARDIAC' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'LUNG' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'DIABETES' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'HERPES' AND 
                STATE IN('HI','OK','TX') THEN DELETE;
              ELSE IF "&VAR" EQ 'HYDRAM' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'HEMOGLOB' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'HYPERTEN' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'PREGASC' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'ECLAMPS' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'CERVIX' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'INFGRAM' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'INFPRET' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'RENAL' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'RHSENSIT' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'UTERINE' AND 
                STATE IN('HI','OK','TX') THEN DELETE;
              ELSE IF "&VAR" EQ 'OTH_RISK' AND STATE IN('HI','OK') THEN DELETE;

              ELSE IF "&VAR" EQ 'NO_OBST' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'AMNIO' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'ELEC_FET' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'IND_LAB' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'STIM_LAB' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'TOCO' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'ULTRA' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'OTH_OBS' AND STATE IN('HI','OK') THEN DELETE;

              ELSE IF "&VAR" EQ 'NO_COMPL' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'FEBRIL' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'MECONIUM' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'MEMBRANE' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'ABRUPTIO' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'PREVIA' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'BLEED' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'SEIZ' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'PREC_LAB' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'PROL_LAB' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'DYSFUNC' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'BREECH' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'CEPHAL' AND STATE IN('HI','OK','TX') THEN 
                DELETE;
              ELSE IF "&VAR" EQ 'CORD' AND 
                STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'ANESTHE' AND 
                STATE IN('HI','OK','TX') THEN DELETE;
              ELSE IF "&VAR" EQ 'FETALDIS' AND 
                STATE IN('HI','OK','TX') THEN DELETE;
              ELSE IF "&VAR" EQ 'OTH_COMP' AND STATE IN('HI','OK') THEN DELETE;

              ELSE IF "&VAR" EQ 'NO_DELIV' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'VAGINA' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'AFTERC' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'PRIMC' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'REPEATC' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'FORCEPS' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'VACUUM' AND STATE IN('HI','OK') THEN DELETE;
              ELSE IF "&VAR" EQ 'HYST' AND 
                STATE IN('HI','OK','AK','CA','CT','NY','OR','WY') THEN DELETE;

              ELSE IF "&VAR" EQ 'NO_CONG' AND 
                STATE IN('HI','NM','NY','OK','YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'ANENCEP' AND 
                STATE IN('HI','NM','NY','OK','YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'MENING' AND 
                STATE IN('HI','NM','NY','OK','YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'HYDROC' AND 
                STATE IN('HI','NM','NY','OK','YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'MICROCEC' AND 
                STATE IN('HI','NM','NY','OK','YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'CENNERV' AND 
                STATE IN('HI','NM','NY','OK','YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'HEART' AND 
                STATE IN('HI','NM','NY','OK','YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'RESP' AND 
                STATE IN('HI','NM','NY','OK','YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'STENOSIS' AND 
                STATE IN('HI','NM','NY','OK','YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'ATRESIA' AND 
                STATE IN('HI','NM','NY','OK','YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'GASTROS' AND 
                STATE IN('HI','NM','NY','OK','YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'OTH_GAS' AND 
                STATE IN('HI','NM','NY','OK','YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'MALGENIT' AND 
                STATE IN('HI','NM','NY','OK','YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'AGENES' AND 
                STATE IN('HI','NM','NY','OK','YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'OTH_UROG' AND 
                STATE IN('HI','NM','NY','OK','YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'CLEFT' AND 
                STATE IN('HI','NM','NY','OK','YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'POLYDAC' AND 
                STATE IN('HI','NM','NY','OK','YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'CLUB' AND 
                STATE IN('HI','NM','NY','OK','YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'HERNIA' AND 
                STATE IN('HI','NM','NY','OK','YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'OTH_MUSC' AND 
                STATE IN('HI','NM','NY','OK','YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'DOWNS' AND 
                STATE IN('HI','NM','NY','OK','YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'OTHCHROM' AND 
                STATE IN('HI','NM','NY','OK','YC') THEN DELETE;
              ELSE IF "&VAR" EQ 'OTH_CONG' AND 
                STATE IN('HI','NM','NY','OK','YC') THEN DELETE;
            END;/*}}}*/
          IF "&EVT" EQ 'MOR' THEN
            DO;/*{{{*/
              IF "&VAR" EQ 'HISPANIC' AND STATE IN('PR') THEN DELETE;
              ELSE IF "&VAR" EQ 'EDUC' AND STATE IN('GA','RI','SD') THEN 
                DELETE;
              ELSE IF "&VAR" EQ 'RACE' AND STATE IN('HI','ME','WI') THEN 
                DELETE;
            END;/*}}}*/
        END;
      /************************/

      /***** Error *****/
      ELSE
        PUT "ERROR: unknown EVT (&EVT)";
      /*****************/
    RUN;

    DATA TMP2;
      LENGTH VARNAME $25;
      VARNAME="&VAR";
      TOTC=ATTRN(OPEN('WORK.TMP'), 'NOBS');
      OUTPUT;
    RUN;
      
    PROC APPEND BASE=COUNTER DATA=TMP2 FORCE; RUN;

    PROC MEANS DATA=TMP NOPRINT MISSING COMPLETETYPES;
      BY REPTYR;
      CLASS &VAR / PRELOADFMT;
      VAR COUNT;
      WAYS 1;
      FORMAT &FMTS;
      OUTPUT OUT=FREQS&I (WHERE=(&VAR NE '') KEEP=&VAR REPTYR _FREQ_) SUM=;
    RUN;
    %LET VAR=%QSCAN(&VARS,&I);
    %LET I=%EVAL(&I+1);
  %END;
%MEND BUILDFREQS;/*}}}*/
options nomprint;
%BUILDFREQS
SASFILE STATEDS CLOSE;
options mprint;

%MACRO ANNLOOP;  /* {{{1 */
  /* Number of vars looped.  We're using it outside this macro to tell
   * how many vars we're working with.
   */
  %GLOBAL NV;
  %LOCAL VAR;
  %LET NV=1;
  %DO %UNTIL (%QSCAN(&VARS,&NV)=);
    %LET VAR = %QSCAN(&VARS,&NV);
    DATA FREQS&NV;
      SET FREQS&NV;
      /* E.g. 039 Oregon (38) */
      LONGLAB = VVALUE(&VAR);
    RUN;

    PROC SQL NOPRINT;
      CREATE TABLE TMPFREQS&NV AS
      SELECT REPTYR, LONGLAB, SUM(_FREQ_) AS SF
      FROM FREQS&NV
      GROUP BY REPTYR, LONGLAB
      ORDER BY LONGLAB
      ;
    QUIT;

    PROC TRANSPOSE DATA=TMPFREQS&NV PREFIX=YR OUT=FREQS&NV;
      BY LONGLAB;
      ID REPTYR;
      VAR SF;
    RUN;

    DATA FREQ&NV (KEEP=VARSEQ VARLAB VALSEQ VALLAB VARNAME YR0 YR&Y);
      /* VARNAME's length is arbitrary, should be enough to handle
       * 'OWGEST_BYPASS' etc.
       */
      LENGTH VARNAME $ 25  VARLAB $ 100  VALSEQ 8  RNG $ 1;
      RETAIN VALSEQ 0;
      SET FREQS&NV;

      VARNAME = "&VAR";
      VARSEQ = &NV;
      VARLAB = PUT(VARNAME, $VARLABF.);
      YR0 = &Y;

      %IF &RANGEVARS NE   %THEN
        %DO;
          /* 'Z' indicates a range variable that should be dropped from
           * the report if showing a zero, e.g. FATHYR
           */
          RNG = PUT(VARNAME,$DROPZ.);
        %END;
      %ELSE
        %DO;
          RNG='';
        %END;

      VALLAB = SUBSTR(LONGLAB,5);
      /* E.g. no mothers were born in 1914, we don't want to display the
       * 1914 line on the TSA.  But Not Class is an exception that
       * should always show, even if all zeros.
       */
      IF (RNG EQ 'Z') AND (YR0 EQ 0) AND (VALLAB NE: 'Not Class') THEN
        DELETE;

      VALSEQ = SUBSTR(LONGLAB,1,3);
    RUN;
    %LET NV=%EVAL(&NV+1);
  %END;
%EXIT:
%MEND ANNLOOP;
%ANNLOOP


%MACRO ALLFREQS;  /* {{{1 */
  %LOCAL NVAR K;

  %LET NVAR = %EVAL(&NV - 1);
  %DO K = 1 %TO &NVAR;
    FREQ&K
  %END;
%MEND ALLFREQS; /* }}} */

DATA FINAL (DROP=YR0);/*{{{*/
  SET %ALLFREQS;

  /* Display desired formatted values of infant death COMPINFD, COMPMO,
   * COMPDY, ETC.
   */
  IF VALLAB EQ '***DELETE' THEN
    DELETE;

  IF YR0 EQ 0 AND VALLAB EQ '***INVALID' THEN
    DELETE;

  /* The special GEST_WKS2-4 breakouts are single liners */
  IF (VARLAB EQ: 'Clinical Estimate of Gestation Weeks--') AND
     (VALLAB EQ '***INVALID') THEN
    DELETE;
RUN;/*}}}*/

 /* Gather denominators */
PROC SQL;
  CREATE TABLE FIN AS
  SELECT A.*, B.TOTC
  FROM FINAL AS A LEFT JOIN COUNTER AS B  ON A.VARNAME=B.VARNAME
  /* For the merging in TSAAAAA */
  ORDER BY A.VARLAB, A.VALLAB
  ;
QUIT;

libname NAT1LIB 'BQH0.SASLIB' DISP=OLD;
***DATA USTOT.UST&Y.&REVTYPE.&EVT (DROP=YR&Y varname totc);
DATA NAT1LIB.nfin (DROP=YR&Y varname totc);
  SET FIN;  /* varname, vallab, valseq, varlab, varseq */
  IF TOTC NE 0 THEN
    USPCT&Y = (YR&Y / TOTC) * 100;
  ELSE
    USPCT&Y = 0;
RUN;
 /* Quick verification */
 /*** proc print data=USTOT.ust&Y.&REVTYPE.&EVT(obs=max); run; ***/
proc print data=TMP.nfin(obs=max); run;

%put !!!SYSCC (&SYSCC) Elapsed minutes: %sysevalf((%sysfunc(time())-&START)/60);



  /* vim: set tw=72 ft=sas ff=unix foldmethod=marker: */
