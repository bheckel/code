%MACRO	LELimsIndRes;
*******************************************************************************;
*                     PROGRAM HEADER                                          *;
*-----------------------------------------------------------------------------*;
*  PROJECT NUMBER: ZEO-986025-1                                               *;
*  PROGRAM NAME: LELimsIndRes.SAS               SAS VERSION: 8.2              *;
*  DEVELOPED BY: Michael Hall                   DATE: 08/26/2002              *;
*  PROJECT REPRESENTATIVE: Carol Hiser                                        *;
*  PURPOSE: This program extracts the following fields out of the LIMS        *;
*			database for future insertion into the LINKS database:*;
*              	R.SampId, S.SpecName, V.Name, E.RowIx, E.ColumnIx,            *;
*               E.ElemStrVal, E.ElemNumVal, VC.ColName, R.ResLoopIx,          *;
*               R.ResRepeatIx, R.ResReplicateIx, R.ResId                      *;
*  SINGLE USE OR MULTIPLE USE? (SU OR MU) MU                                  *;
*  PROGRAM ASSUMPTIONS OR RESTRICTIONS: The LIMS database must be up and      *; 
*			accessable for this program to function correctly.    *;
*-----------------------------------------------------------------------------*;
*  OTHER SAS PROGRAMS, MACROS OR MACRO VARIABLES USED IN THIS PROGRAM:        *;
*           Macro Variables:                                                  *;
*               CondCode - Return Code of this program.                       *;
*               SqlXRc   - SAS Macro variable containing the Oracle return    *;
*                          code.                                              *;
*               SqlXMsg  - SAS Macro variable containing the Oracle return    *;
*                          message text.                                      *;
*               HSqlXRc  - Copy of SqlXRc to pass the SELECT return code      *;
*                          rather than the DISCONNECT return code.            *;
*               HSqlXMsg - Copy of SqlXMsg to pass the SELECT return code     *;
*                          rather than the DISCONNECT return code.            *;
*           Global variable passed by calling program:                        *;
*               LimsId   - LIMS Database Id.                                  *;
*               LimsPsw  - LIMS Database Password.                            *;
*               LimsPath - LIMS Database Server Id.                           *;
*               LimsFltr - Filter to apply to extraction routine to LIMS.     *;
*-----------------------------------------------------------------------------*;
*  DESCRIPTION OF OUTPUT: SAS dataset LELimsIndRes01a                         *;
*-----------------------------------------------------------------------------*;
*******************************************************************************;
*                     HISTORY OF CHANGE                                       *;
*-------------+---------+--------------+--------------------------------------*;
*     DATE    | VERSION | NAME         | Description                          *;
*-------------+---------+--------------+--------------------------------------*;
*  07/23/2002 |    1.0  | Michael Hall | Original                             *;
*-------------+---------+--------------+--------------------------------------*;
*  09/17/2002 |    2.0  | Michael Hall | Added R.ResLoopIx, R.ResRepeatIx,    *;
*             |         |              | R.ResReplicateIx, R.ResId as         *;
*             |         |              | outputs. Removed DeLoop process.     *;
*-------------+---------+--------------+--------------------------------------*;
*  01/13/2003 |    3.0  | James Becker | Added SEQUENCE$ to Query Criteria    *;
*             |         |              | per change in LIMS.                  *;
*-------------+---------+--------------+--------------------------------------*;
*  06/25/2003 |    4.0  | James Becker | Enhancements during MERPS/SAP phase  *;
*             |         |              | - Added READBUFF to speed up query   *;
*             |         |              | - Added &datefltr to date filter     *;
*-------------+---------+--------------+--------------------------------------*;
*  01/27/2005 |    5.0  | James Becker | Enhancements during MDPI phase       *;
*             |         |              | - Changed ProcStatus to be > 4       *;
*-----------------------------------------------------------------------------*;
*  02Aug2005  |    6.0  | Tammy Hodges | Changed SampStatus code to <> 20 and *;
*             |         |              | ProcStatus code to > 3.              *;
*-----------------------------------------------------------------------------*;
*  22MAR2006  |    7.0  | James Becker | VCC45936 - Added All Products        *;
*             |         |              | - Added External file which holds    *;
*             |         |              |   product list.                      *;
*-----------------------------------------------------------------------------*;
*  26JUL2006  |    8.0  | James Becker | VCC52093 -                           *;
*             |         |              | - Changed Length $400. for Txt File  *;
*-----------------------------------------------------------------------------*;
*  14NOV2006  |    9.0  | James Becker | VCC55175 -                           *;
*             |         |              | - Changed Query to pull from a list  *;
*             |         |              |   of Samples that info has changed   *;
*             |         |              |   recently on.                       *;
*******************************************************************************;
*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SETUP                                                   *;
*   REQUIREMENT:      N/A                                                     *;
*   INPUT:            &CtlDir.QueryProductList.txt                            *;
*   PROCESSING:       Establish Global Product list variable.                 *;
*   OUTPUT:           Macro Variable PRODUCT_LIST                             *;
*******************************************************************************;
	%GLOBAL HSQLXRC HSQLXMSG Product_List;
	/*************************************************/
	/*** V8 - Changed Length $400. for Txt File    ***/
	/*************************************************/
	DATA _NULL_;
	INFILE "&CtlDir.QueryProductList.txt"
	LENGTH=flen TRUNCOVER END=eofflg DLM='=' LRECL=400;
	LENGTH 	list		$400;
	INPUT @1 list $400.;
	Put List;
	IF list = "" THEN DO;
			CALL SYMPUT('JobStep','LeLimsIndres (Missing Product File)');
			CALL SYMPUT('CondCode',12);
		END;
	ELSE DO;
		CALL SYMPUT('Product_List',list);
	END;
	RUN;

*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: Extraction                                              *;
*   REQUIREMENT:      N/A                                                     *;
*   INPUT:            None.                                                   *;
*   PROCESSING:       Select unique values of the following fields from the   *;
*                     specified LIMS table.                                   *;
*                        Result.SampId, Spec.SpecName, Var.Name,              *;
*                        Element.RowIx, Element.ColumnIx, Element.ElemStrVal, *;
*                        Element.ElemNumVal, VarCol.ColName,                  *;
*                        Result.ResLoopIx, Result.ResRepeatIx,                *;
*                        R.ResReplicateIx, R.ResEntTS                         *;
*      FILTERS:       Filter the records with the following filters:          *;
*                     Only Advair records -                                   *;
*                           V.Name = 'PRODCODEDESC$' AND                      *;
*                           UPPER(R.ResStrVal) LIKE '%ADVAIR%'                *;
*                     Current Cycle -                                         *;
*                           SS.CurrAuditFlag = 1 AND SS.CurrCycleFlag = 1     *;
*                     Results exist -                                         *;
*                           SS.SampStatus <> 20    20=cancelled sample        *;
*                     Procedure Complete -                                    *;
*                           PLS.ProcStatus > 3                                *;
*                                      4-Entered / 16-Complete / 17-Approved  *;
*                     Records associated with results -                       *;
*                           V.TYPE =  'T' AND R.ResReplicateIx <> 0           *;
*                               (NOTE: Get Measure Table data)                *;
*                           V.TYPE <> 'T' AND R.ResReplicateIx =  0           *;
*                               (NOTE: Get Calc Table Data)                   *;
*                     Non-Cancelled Loop data only                            *;
*                           R.ResSpecialResultType <> 'C'                     *;
*                     Optional filter -                                       *;
*                           &LimsFltr                                         *;
*   OUTPUT:           SAS dataset LELimsIndRes01A with the following          *;
*                     variables:                                              *;
*                       Samp_Id, SampName, SpecName, VarName, RowIx, ColumnIx,*;
*                       ElemStrVal, ElemNumVal, ColName, ResLoopIx,           *;
*                       ResRepeatIx, ResReplicateIx, ResId.                   *;
*******************************************************************************;
PROC SQL;
	CONNECT TO ORACLE(USER=&limsid ORAPW=&limspsw BUFFSIZE=25000 READBUFF=25000 PATH="&limspath" dbindex=yes DIRECT_SQL=NOWHERE);
	CREATE TABLE lelimsindres01a AS SELECT * FROM CONNECTION TO ORACLE (
		SELECT DISTINCT
				R.SampId	 			AS Samp_Id,
				R.SampName				,
				R.ResLoopIx				AS Res_Loop       /* Modified V2*/,
				R.ResRepeatIx				AS Res_Repeat     /* Modified V2*/,
				R.ResReplicateIx			AS Res_Replicate  /* Modified V2*/,
				R.ResId					AS Res_Id         /* Added    V2*/,
				SUBSTR(R.SampTag2,1,18)                 AS Matl_Nbr,
				S.SpecName				,
				V.Name					AS VarName,
				E.RowIx					,
				E.ColumnIx				,
				E.ElemStrVal				,		
				E.ElemNumVal				,
				VC.ColName				,
				PLS.ProcStatus				AS ProcStat,
				SS.SampStatus				AS Samp_Status
		FROM		Element					E,
				Result					R,
				ProcLoopStat				PLS,
				SampleStat				SS,
				Var					V,
				VarCol					VC,
				Spec					S
		WHERE 	(
			&Sample_List1
			%DO Loop=2 %TO &NumLoops;
				OR &&Sample_List&Loop
			%END; 
			)
		  AND	R.SpecRevId = V.SpecRevId
		  AND	R.VarId = V.VarId
		  AND	R.ResId = E.ResId
		  AND	VC.ColNum = E.ColumnIx
		  AND	R.SpecRevId = VC.SpecRevId
		  AND	R.VarId = VC.TableVarId
		  AND	R.SampId = PLS.SampId
		  AND	R.ProcLoopId = PLS.ProcLoopId
		  AND	R.SampId = SS.SampId
		  AND	R.SpecRevId = S.SpecRevId
		  AND	SS.CurrAuditFlag = 1
		  AND	SS.CurrCycleFlag = 1
		  AND	SS.SampStatus <> 20			/* Modified V6 */
		  AND	PLS.ProcStatus > 3                      /* Modified V6 */
		  AND	((V.TYPE =  'T' AND R.ResReplicateIx <> 0) OR
			 (V.TYPE <> 'T' AND R.ResReplicateIx =  0))
		  AND	R.ResSpecialResultType <> 'C'
		  &limsfltr
		);
	%PUT &SQLXRC;
	%PUT &SQLXMSG;
	%LET HSQLXRC = &SQLXRC;
	%LET HSQLXMSG = &SQLXMSG;
	DISCONNECT FROM ORACLE;
	QUIT;
RUN;
*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: DeLoop                                                  *;
*   REQUIREMENT:      N/A                                                     *;
*   INPUT:            LeLimsIndRes01A.                                        *;
*   PROCESSING:       Sort records into groups, sub-grouped by descending     *;
*                     ResLoopIx, ResRepeatIx, ResReplicateIx. Then, remove    *;
*                     duplicates of the original groupings.                   *;
*                         NOTE: This is intended to removed non-cancelled     *;
*                               loops that should have been cancelled,        *;
*                               presuming that the highest loop should be the *;
*                               correct loop. If this logic is not correct,   *;
*                               it is to the LIMS user(s) responsibility to   *; 
*                               correct the data by cancelling the incorrect  *;
*                               loop(s).                                      *;
*                     Last, sort the data into the following order:           *;
*                       Samp_Id, SpecName, VarName, RowIx, ColumnIx.          *;
*   OUTPUT:           None.                                                   *;
*******************************************************************************;
/* Removed in V2
PROC SORT DATA=lelimsindres01a;
	BY	Samp_Id SpecName VarName ColName RowIx ColumnIx 
		DESCENDING ResLoopIx DESCENDING ResRepeatIx DESCENDING ResReplicateIx;
RUN;

DATA	lelimsindres01a;
	SET	lelimsindres01a;
	BY	Samp_Id SpecName VarName ColName RowIx ColumnIx;
	IF	FIRST.ColumnIx;
	DROP ResLoopIx ResRepeatIx ResReplicateIx;
RUN;
*/

*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SetCC                                                   *;
*   REQUIREMENT:      N/A                                                     *;
*   INPUT:            Macro variables HSqlXRc and HSqlXMsg                    *;
*   PROCESSING:       Set Macro Return Code.                                  *;
*   OUTPUT:           CondCode.                                               *;
*******************************************************************************;
DATA _NULL_;
	sqlxrc="&HSqlXRc";
	sqlxmsg="&HSqlXMsg";

	IF sqlxrc = 0 THEN DO;
		IF sqlxmsg = ' ' THEN CALL SYMPUT('CondCode', 0);
		 ELSE CALL SYMPUT('CondCode', 4);
		END;
	ELSE CALL SYMPUT('CondCode', 12);
RUN;

%MEND;
