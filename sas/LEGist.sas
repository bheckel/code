%MACRO	LEGist;
**********************************************************************************;
*                     PROGRAM HEADER                                             *;
*--------------------------------------------------------------------------------*;
*  PROJECT NUMBER: ZEO-986025-1                                                  *;
*  PROGRAM NAME: LEGist.SAS		                SAS VERSION: 8.2         *;
*  DEVELOPED BY: Michael Hall                   DATE: 08/26/2002                 *;
*  PROJECT REPRESENTATIVE: Carol Hiser                                           *;
*  PURPOSE: This program extracts the following fields out of the GIST           *;
*			database for future insertion into the LINKS database:   *;
*			Study Description, Study Group, Study Number, Lot Number *;
*  SINGLE USE OR MULTIPLE USE? (SU OR MU) MU                                     *;
*  PROGRAM ASSUMPTIONS OR RESTRICTIONS: The GIST database must be up and         *; 
*			accessable for this program to function correctly.       *;
*--------------------------------------------------------------------------------*;
*  OTHER SAS PROGRAMS, MACROS OR MACRO VARIABLES USED IN THIS PROGRAM:           *;
*           Macro Variables:                                                     *;
*               CondCode - Return Code of this program.                          *;
*               SqlXRc   - SAS Macro variable containing the Oracle return       *;
*                          code.                                                 *;
*               SqlXMsg  - SAS Macro variable containing the Oracle return       *;
*                          message text.                                         *;
*               HSqlXRc  - Copy of SqlXRc to pass the SELECT return code         *;
*                          rather than the DISCONNECT return code.               *;
*               HSqlXMsg - Copy of SqlXMsg to pass the SELECT return code        *;
*                          rather than the DISCONNECT return code.               *;
*           Global variable passed by calling program:                           *;
*               GistId   - GIST Database Id.                                     *;
*               GistPsw  - GIST Database Password.                               *;
*               GistPath - GIST Database Server Id.                              *;
*               GistFltr - Filter to apply to extraction routine to GIST.        *;
*--------------------------------------------------------------------------------*;
*  DESCRIPTION OF OUTPUT: SAS dataset LEGist01A                                  *;
*--------------------------------------------------------------------------------*;
**********************************************************************************;
*                     HISTORY OF CHANGE                                          *;
*-------------+---------+--------------+-----------------------------------------*;
*     DATE    | VERSION | NAME         | Description                             *;
*-------------+---------+--------------+-----------------------------------------*;
*  08/26/2002 |    1.0  | Michael Hall | Original                                *;
*-------------+---------+--------------+-----------------------------------------*;
*  09/26/2002 |    2.0  | Michael Hall | Modified the LINKS Lot_Nbr field        *;
*             |         |              | to read the GIST field s.lot_no,        *;
*             |         |              | rather than the field s.bch_no.         *;
*-------------+---------+--------------+-----------------------------------------*;
*  03/18/2003 |    3.0  | James Becker | VCC24521 -                              *;
*             |         |              | -  Modified WHERE statement in PROC SQL *;
*             |         |              | to add stat "D". [D=Discontinued Batch] *;
*-------------+---------+--------------+-----------------------------------------*;
*  07/17/2003 |    4.0  | James Becker | Amendment for SAP/MERPS project         *;
*             |         |              |    VCC25658:                            *;
*             |         |              | -  Changed Lot_Nbr variable to refer to *;
*             |         |              |    new Batch_Nbr.                       *;
*             |         |              | -  Added Reference_Nbr, contains        *;
*             |         |              |    Matl_Nbr if not in description field.*;
*-------------+---------+--------------+-----------------------------------------*;
* 05-MAY-2006 |    5.0  | James Becker | VCC45936 -                              *;
*             |         |              | -  Added SQL to pull Time Point and     *;
*             |         |              |    Calculate MAX Time point.            *;
*-------------+---------+--------------+-----------------------------------------*;
* 01-JUN-2006 |    6.0  | James Becker | VCC45936 -                              *;
*             |         |              | -  Added SQL to pull Time Point and     *;
*             |         |              |    from archive Study_sched table.      *;
**********************************************************************************;
**********************************************************************************;
*                       MODULE HEADER                                            *;
*--------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SETUP                                                      *;
*   REQUIREMENT:      N/A                                                        *;
*   INPUT:            None.                                                      *;
*   PROCESSING:       Establish Global variables.                                *;
*   OUTPUT:           None.                                                      *;
**********************************************************************************;
	%GLOBAL HSQLXRC HSQLXMSG;
**********************************************************************************;
*                       MODULE HEADER                                            *;
*--------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: Extract                                                    *;
*   REQUIREMENT:      N/A                                                        *;
*   INPUT:            GistId, GistPsw, GistPath, GistFltr                        *;
*   PROCESSING:       Select unique values of the following fields from the      *;
*                     GIST table gist2_c.study where the stat field in either    *;
*                     A or E (approved or edited): Study Description             *;
*                     Beginning, Study Description Ending, Study Group, Study    *;
*                     Number, Packaging Lot Number. Apply an additional          *;
*                     filter using the macro variable GISTFLTR.                  *;
*   OUTPUT:           SAS dataset legist01a with the following variables:        *;
*                     StudyDescriptionBegin, StudyDescriptionEnd,                *;
*                     Stability_Study_Grp_Cd, Stability_Study_Nbr_Cd,            *;
*                     Lot_Nbr. Also, Macro variables HSqlXRc and HSqlXMsg        *;
**********************************************************************************;

	/*************************************************/
	/*** V3 - Added stat 'D' to WHERE clause       ***/
	/*** V4 - Changed Lot_Nbr to Batch_Nbr         ***/
	/*************************************************/
PROC SQL;										
	CONNECT TO ORACLE(USER=&gistid ORAPW=&gistpsw BUFFSIZE=5000 PATH="&gistpath" dbindex=yes);
	CREATE TABLE legist01b AS SELECT * FROM CONNECTION TO ORACLE (
	SELECT	DISTINCT
			SUBSTR(s.descrip,1,200)	 AS StudyDescriptionBegin	,
			SUBSTR(s.descrip,41,200) AS StudyDescriptionEnd		,
			s.study_grp		 AS Stability_Study_Grp_Cd	,
			s.study_no		 AS Stability_Study_Nbr_Cd	,
			SUBSTR(s.lot_no,1,10)	 AS Batch_Nbr			,	
			s.Rglt_Ref		 AS Reference_Nbr		
	FROM	gist2_c.study		s
	WHERE	s.stat IN ('A', 'E', 'D')
	  &gistfltr
	);
	%PUT &SQLXRC;
	%PUT &SQLXMSG;
	%LET HSQLXRC = &SQLXRC;
	%LET HSQLXMSG = &SQLXMSG;
	DISCONNECT FROM ORACLE;
	QUIT;
RUN;

	/********************************************************************************************/
	/*** V5 - Added SQL to pull Time Point and Calculate MAX Time point                       ***/
	/*** V6 - Added SQL to pull Time Point and Calculate MAX Time point from archive table    ***/
	/********************************************************************************************/
PROC SQL;
CONNECT TO ORACLE(USER=&gistid ORAPW=&gistpsw BUFFSIZE=25000 READBUFF=25000 PATH="&gistpath" dbindex=yes);
CREATE TABLE TPGist01a AS SELECT * FROM CONNECTION TO ORACLE (
SELECT DISTINCT
	ss.STUDY_NO			   AS "Stability Study Nbr Cd",
	ss.Tm_Pt,
       TO_CHAR(DECODE(SUBSTR(ss.tm_pt, 1, 2), 'IN', 0,
         'MN', TO_NUMBER(SUBSTR(ss.tm_pt, 3, 2)),
         'WK', (TO_NUMBER(SUBSTR(ss.tm_pt, 3, 2)) * 7 / 30.44),
         'DY', (TO_NUMBER(SUBSTR(ss.tm_pt, 3, 2)) / 30.44),
         'HR', (TO_NUMBER(SUBSTR(ss.tm_pt, 3, 2)) / (24 * 30.44)),
              -1), 099.9999999990)                 AS "TEMP Samp Time Point"
  FROM gist2_c.study_sched ss
   );
CREATE TABLE TPGist01b AS SELECT * FROM CONNECTION TO ORACLE (
SELECT DISTINCT
	ss.STUDY_NO			   AS "Stability Study Nbr Cd",
	ss.Tm_Pt,
       TO_CHAR(DECODE(SUBSTR(ss.tm_pt, 1, 2), 'IN', 0,
         'MN', TO_NUMBER(SUBSTR(ss.tm_pt, 3, 2)),
         'WK', (TO_NUMBER(SUBSTR(ss.tm_pt, 3, 2)) * 7 / 30.44),
         'DY', (TO_NUMBER(SUBSTR(ss.tm_pt, 3, 2)) / 30.44),
         'HR', (TO_NUMBER(SUBSTR(ss.tm_pt, 3, 2)) / (24 * 30.44)),
              -1), 099.9999999990)                 AS "TEMP Samp Time Point"
  FROM gist2_c_arch.study_sched ss
   );
	%PUT &SQLXRC;
	%PUT &SQLXMSG;
	%LET HSQLXRC  = &SQLXRC;
	%LET HSQLXMSG = &SQLXMSG;
	DISCONNECT FROM ORACLE;
	QUIT;
RUN;

DATA TPGist01a;SET TPGist01a TPGist01b;RUN;
PROC SORT DATA=TPGist01a OUT=NEWGist01a;BY Stability_Study_Nbr_Cd DESCENDING TEMP_Samp_Time_Point;RUN;
DATA NEWGist01a;LENGTH Stability_Study_Max_TP $4.;SET NEWGist01a;
BY Stability_Study_Nbr_Cd DESCENDING TEMP_Samp_Time_Point;
	IF FIRST.Stability_Study_Nbr_Cd THEN DO;
		IF INDEX(Tm_Pt,'MN')>0
			THEN Stability_Study_Max_TP=COMPRESS(Tm_Pt,'MN');
			ELSE Stability_Study_Max_TP=Tm_Pt;
		IF Stability_Study_Max_TP='INT' THEN Samp_Time_Point='0';
		OUTPUT NEWGist01a;
	END;
RUN;

PROC SORT DATA=legist01b;BY Stability_Study_Nbr_Cd;RUN;
DATA legist01a;
LENGTH Batch_Nbr $10 StudyDescriptionBegin StudyDescriptionEnd $200;
FORMAT Batch_Nbr $10. StudyDescriptionBegin StudyDescriptionEnd $200.;
INFORMAT Batch_Nbr $10. StudyDescriptionBegin StudyDescriptionEnd $200.;
MERGE legist01b(IN=IN1)
      NEWGist01a(IN=IN2);
BY Stability_Study_Nbr_Cd;
IF IN1;
DROP Samp_Time_Point Tm_Pt TEMP_Samp_Time_Point;
RUN;
**********************************************************************************;
*                       MODULE HEADER                                            *;
*--------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: N/A                                                        *;
*   REQUIREMENT:      N/A                                                        *;
*   INPUT:            Macro variables HSqlXRc and HSqlXMsg                       *;
*   PROCESSING:       Set Macro Return Code.                                     *;
*   OUTPUT:           CondCode.                                                  *;
**********************************************************************************;
DATA _NULL_;
	sqlxrc="&HSqlXRc";
	sqlxmsg="&HSqlXMsg";

	IF sqlxrc = 0 THEN DO;
		IF sqlxmsg = ' ' THEN CALL SYMPUT('CondCode', 0);
		                 ELSE CALL SYMPUT('CondCode', 4);
	END;
	ELSE CALL SYMPUT('CondCode', 12);
RUN;
%MEND	LEGist;