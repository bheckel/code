%MACRO	LELimsSumRes;
*******************************************************************************;
*                     PROGRAM HEADER                                          *;
*-----------------------------------------------------------------------------*;
*  PROJECT NUMBER: ZEO-986025-1                                               *;
*  PROGRAM NAME: LELimsSumRes.SAS               SAS VERSION: 8.2              *;
*  DEVELOPED BY: Michael Hall                    DATE: 08/26/2002             *;
*  PROJECT REPRESENTATIVE: Carol Hiser                                        *;
*  PURPOSE: This program extracts the following fields out of the LIMS        *;
*			database for future insertion into the LINKS database:*;
*              Sample Id, Sample Name, Result Entry Userid, Result Entry      *;
*              Time Stamp, Result String Value, Result Numeric Value, Lims    *;
*              Specification Name, Lims Specification Display Name, Lims      *;
*              Variable Name, Lims Variable Display Name, Procedure Status,   *;
*              Sample Status.                                                 *;
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
*  DESCRIPTION OF OUTPUT: SAS dataset LELimsSumRes01a                         *;
*-----------------------------------------------------------------------------*;
*******************************************************************************;
*                     HISTORY OF CHANGE                                       *;
*-------------+---------+--------------+--------------------------------------*;
*     DATE    | VERSION | NAME         | Description                          *;
*-------------+---------+--------------+--------------------------------------*;
*  07/23/2002 |    1.0  | Michael Hall | Original                             *;
*-------------+---------+--------------+--------------------------------------*;
*  01/13/2003 |    2.0  | James Becker | Added SEQUENCE$ to Query Criteria    *;
*             |         |              | per change in LIMS.                  *;
*-------------+---------+--------------+--------------------------------------*;
*  06/25/2003 |    3.0  | James Becker | Amendment for SAP/MERPS project      *;
*             |         |              |   VCC25658:                          *;
*             |         |              | - Added SampTag2 to input from       *;
*             |         |              |   Results Table for new field:       *;
*             |         |              |   Matl_Nbr.                          *;
*             |         |              | - Added READBUFF to speed up query   *;
*             |         |              | - Added &datefltr to date filter     *;
*-------------+---------+--------------+--------------------------------------*;
*  01/27/2003 |    5.0  | James Becker | Enhancements during MDPI phase       *;
*             |         |              | - Changed ProcStatus to be > 4       *;
*-----------------------------------------------------------------------------*;
*  02aug2005  |    6.0  | Tammy Hodges | Changed sampstatus to <> 20 and      *;
*             |         |              | procstatus > 3                       *;
*-----------------------------------------------------------------------------*;
*  22MAR2006  |    7.0  | James Becker | VCC45936 - Added All Products        *;
*             |         |              | - Added External file which holds    *;
*             |         |              |   product list.                      *;
*-----------------------------------------------------------------------------*;
*  26JUL2006  |    8.0  | James Becker | VCC52093 -                           *;
*             |         |              | - Changed Length $400. for Txt File  *;
*-----------------------------------------------------------------------------*;
*  14NOV2006  |    9.0  | James Becker | VCC52093 -                           *;
*             |         |              | - Changed Query to pull from a list  *;
*             |         |              |   of Samples that info has changed   *;
*             |         |              |   recently on.                       *;
*             |         |              | - Added SS.EntryTs to proc sql code  *;
*-----------------------------------------------------------------------------*;
*  03APR2007  |   10.0  | James Becker | VCC57958 -                           *;
*             |         |              | - Added "Res_" Variables to          *;
*             |         |              |   Query Pull for use of INHALERUSE$  *;
*             |         |              |   in %TrnLimsI.                      *;
*******************************************************************************;
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
	%GLOBAL HSQLXRC HSQLXMSG;
	/*************************************************/
	/*** V8 - Changed Length $400. for Txt File    ***/
	/*************************************************/
	DATA _NULL_;
	INFILE "&CtlDir.QueryProductList.txt"
	LENGTH=flen TRUNCOVER END=eofflg DLM='=' LRECL=400;
	LENGTH 	list		$4500;
	INPUT @1 list $4500.;
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
*                       Result.SampId, Result.SampName, Result.ResEntUserid,  *;
*                       Result.ResEntTs, Result.ResStrVal, Result.ResNumVal,  *;
*                       Spec.SpecName, Spec.DispName, Var.Name, Var.DispName, *;
*                       ProcLoopStat.ProcStatus, SampleStat.SampStatus        *;
*      FILTERS:       Filter the records with the following filters:          *;
*                     Only Advair records -                                   *;
*                           V.Name = 'PRODCODEDESC$' AND                      *;
*                           UPPER(R.ResStrVal) LIKE 'ADVAIR%'                 *;
*                     Current Cycle -                                         *;
*                           SS.CurrAuditFlag = 1 AND SS.CurrCycleFlag = 1     *;
*                     Results exist -                                         *;
*                           SS.SampStatus <> 20     20=cancelled sample       *;
*                     Procedure Complete -                                    *;
*                           PLS.ProcStatus > 3                                *;
*                                       4-Entered / 16-Complete / 17-Approved *;
*                     Records associated with results -                       *;
*                           V.TYPE =  'T' AND R.ResReplicateIx <> 0           *;
*                               (NOTE: Get Measure Table data)                *;
*                           V.TYPE <> 'T' AND R.ResReplicateIx =  0           *;
*                               (NOTE: Get Calc Table Data)                   *;
*                     Non-Cancelled Loop data only                            *;
*                           R.ResSpecialResultType <> 'C'                     *;
*                     Optional filter -                                       *;
*                           &LimsFltr                                         *;
*   OUTPUT:           SAS dataset LELimsSumRes01A.                            *;
*******************************************************************************;
/*****************************************************************************************/
/*** V3 - Added SampTag2 to input for Matl_Nbr                                         ***/
/***      Added READBUFF to speed up query                                             ***/
/***      Added &datefltr for date criteria                                            ***/
/*** V9 - Changed Query to pull from a list of Samples that info has changed recently. ***/
/*** V10- Added ResLoopIx, ResRepeatIx, ResReplicateIX & ResId for use in %TrnLimsI.   ***/
/*****************************************************************************************/

PROC SQL;
	CONNECT TO ORACLE(USER=&limsid ORAPW=&limspsw BUFFSIZE=25000 READBUFF=25000 PATH="&limspath" dbindex=yes DIRECT_SQL=NOWHERE);
	CREATE TABLE lelimssumres01a AS SELECT * FROM CONNECTION TO ORACLE (
		SELECT DISTINCT
				R.SampId				AS Samp_Id,
				R.SampName				,
				R.ResEntUserid				,
				R.ResEntTs				,
				R.ResStrVal				,
				R.ResNumVal				,
				R.ResLoopIx				AS Res_Loop,
				R.ResRepeatIx				AS Res_Repeat,
				R.ResReplicateIx			AS Res_Replicate,
				R.ResId					AS Res_Id,
				SUBSTR(R.SampTag2,1,18)                 AS Matl_Nbr,
				S.SpecName				,
				S.DispName				AS SpecDispName,
				V.Name					AS VarName,
				V.DispName				AS VarDispName,
				PLS.ProcStatus				AS ProcStat,
				SS.EntryTs   				,
				SS.SampStatus				AS Samp_Status
		FROM		ProcLoopStat				PLS,
				Result					R,
				SampleStat				SS,
 				Var					V,
				Spec					S
		WHERE 	(
			&Sample_List1
			%DO Loop=2 %TO &NumLoops;
				OR &&Sample_List&Loop
			%END; 
			)
		  AND	R.SpecRevId 	 = S.SpecRevId
		  AND	R.SpecRevId 	 = V.SpecRevId
		  AND	R.VarId  	 = V.VarId
		  AND	R.SampId 	 = SS.SampId
		  AND	R.SampId 	 = PLS.SampId
		  AND	SS.CurrAuditFlag = 1
		  AND	SS.CurrCycleFlag = 1
		  AND	SS.SampStatus 	 <> 20				/* Modified V6 */
		  AND	PLS.ProcStatus 	 > 3                            /* Modified V6 */
		  AND	((V.TYPE  = 'T' AND R.ResReplicateIx <> 0)  OR	
			 (V.TYPE <> 'T' AND R.ResReplicateIx =  0))
		  AND	R.ResSpecialResultType <> 'C'
		  &limsfltr
	);
	%PUT &SQLXRC;
	%PUT &SQLXMSG;
	%LET HSQLXRC  = &SQLXRC;
	%LET HSQLXMSG = &SQLXMSG;
	DISCONNECT FROM ORACLE;
	QUIT;
RUN;
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
	sqlxrc ="&HSqlXRc";
	sqlxmsg="&HSqlXMsg";

	IF sqlxrc = 0 THEN DO;
		IF sqlxmsg = ' ' THEN CALL SYMPUT('CondCode', 0);
				 ELSE CALL SYMPUT('CondCode', 4);
	END;
	ELSE CALL SYMPUT('CondCode', 12);
RUN;

%MEND;
