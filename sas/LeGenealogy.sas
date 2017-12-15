%MACRO	LEGenealogy;
*******************************************************************************;
*                     PROGRAM HEADER                                          *;
*-----------------------------------------------------------------------------*;
*  PROJECT NUMBER: ZEO-986025-1                                               *;
*  PROGRAM NAME: LEGenealogy.SAS                 SAS VERSION: 8.2             *;
*  DEVELOPED BY: James Becker                    DATE: 03/08/2005             *;
*  PROJECT REPRESENTATIVE: Carol Hiser                                        *;
*  PURPOSE: This program creates the genealogy matrix to be used in           *;
*	       multiple area within LINKS to match up corresponding data :    *;
*              Batch Number, Material Number, Description, Manufacture Date,  *;
*              and Expiration Date for Assembled Batch, Fill Batch,           *;
*              Blend Batch, Lactose Batch, Fluticasone Batch and              *;
*              Salmeterol Batch for both US and UK.                           *;
*                                                                             *;
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
*               OraId   - LINKS Database Id.                                  *;
*               OraPsw  - LINKS Database Password.                            *;
*               OraPath - LINKS Database Server Id.                           *;
*-----------------------------------------------------------------------------*;
*  DESCRIPTION OF OUTPUT: SAS dataset LEGenealogy                             *;
*-----------------------------------------------------------------------------*;
*******************************************************************************;
*                     HISTORY OF CHANGE                                       *;
*-------------+---------+--------------+--------------------------------------*;
*     DATE    | VERSION | NAME         | Description                          *;
*-------------+---------+--------------+--------------------------------------*;
*  03/08/2005 |    1.0  | James Becker | Original                             *;
*-------------+---------+--------------+--------------------------------------*;
*  05/19/2005 |    2.0  | James Becker | VCC37634 - Added "Z" Batches for     *;
*             |         |              |    Fluticasone and Salmeterol.       *;
*-------------+---------+--------------+--------------------------------------*;
*  12APR2006  |    3.0  | James Becker | VCC45936 - Modified code for LAC,    *;
*             |         |              |    SAL & FLU with batch # containing *;
*             |         |              |    "00000" changed to "00".          *;
*             |         |              |  - Added additional Proc Sort to     *;
*             |         |              |    eliminate duplicate records.      *;
*-------------+---------+--------------+--------------------------------------*;
*  05JUN2006  |    4.0  | James Becker | VCC45936 - Changed NOSYMBOLGEN to    *;
*             |         |              |    SYMBOLGEN.                        *;
*-------------+---------+--------------+--------------------------------------*;
*  05JAN2007  |    5.0  | James Becker | VCC53434 - Added Packaging and       *;
*             |         |              |    Manufacturing Batch information.  *;
*-------------+---------+--------------+--------------------------------------*;
*  05MAR2007  |    6.0  | James Becker | VCC57698 - Assy/Fill Batches the     *;
*             |         |              |    same for Diskus.                  *;
*-------------+---------+--------------+--------------------------------------*;
*  05APR2007  |    7.0  | James Becker | VCC57958 - Added Info for Relenza    *;
*-------------+---------+--------------+--------------------------------------*;
*******************************************************************************;
*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SETUP                                                   *;
*   REQUIREMENT:      N/A                                                     *;
*   INPUT:            None.                                                   *;
*   PROCESSING:       Establish Global variables.                             *;
*   OUTPUT:           None.                                                   *;
*******************************************************************************;
	%GLOBAL HSQLXRC HSQLXMSG;
*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: Extraction                                              *;
*   REQUIREMENT:      N/A                                                     *;
*   INPUT:            None.                                                   *;
*   PROCESSING:       Select unique values of the following fields from the   *;
*                     specified LINK table.                                   *;
*                       Result.SampId, Result.SampName, Result.ResEntUserid,  *;
*                       Result.ResEntTs, Result.ResStrVal, Result.ResNumVal,  *;
*                       Spec.SpecName, Spec.DispName, Var.Name, Var.DispName, *;
*                       ProcLoopStat.ProcStatus, SampleStat.SampStatus        *;
*   FILTERS:          N/A                                                     *;
*   OUTPUT:           SAS dataset LEGenealogy.                                *;
*******************************************************************************;

OPTIONS NUMBER NODATE MLOGIC MPRINT SYMBOLGEN SOURCE SOURCE2 MAUTOSOURCE COMPRESS=YES PRINTMSGLIST;

%MACRO READIN;

PROC SQL;										
	CONNECT TO ORACLE(USER=&OraId ORAPW=&OraPsw BUFFSIZE=25000 READBUFF=25000 PATH="&OraPath" DBINDEX=YES);
	CREATE TABLE DATA_SAMP AS SELECT * FROM CONNECTION TO ORACLE (
	SELECT	DISTINCT
		PMD.Batch_Nbr				AS Batch_Nbr,
		PMD.Matl_Nbr				AS Matl_Nbr,
		PMD.Stability_Study_Purpose_Txt  AS Stability_Study_Purpose_Txt,
		PMD.Stability_Study_Grp_Cd  AS Stability_Study_Grp_Cd,
		PMD.Stability_Study_Nbr_Cd  AS Stability_Study_Nbr_Cd,
		PMD.Prod_Nm					AS Prod_Nm,
		PMD.Prod_Grp				AS Prod_Grp
	FROM   	SAMP			  	pmd
	);
	CREATE TABLE DATA_RFT AS SELECT * FROM CONNECTION TO ORACLE (
	SELECT	DISTINCT
		RFT.Batch_Nbr				AS Batch_Nbr,
		RFT.Matl_Nbr				AS Matl_Nbr,
		RFT.Room_Line_Nbr			AS Room_Line_Nbr
	FROM   	RFT_BATCH_SUMMARY			RFT
	);
	CREATE TABLE DATA_LM AS SELECT * FROM CONNECTION TO ORACLE (
	SELECT	DISTINCT
		PMD.Batch_Nbr				AS Batch_Nbr,
		PMD.Matl_Nbr				AS Matl_Nbr,
		PMD.Matl_Desc				AS Item_Description,
		PMD.Matl_Mfg_Dt				AS Create_Date,
		PMD.Matl_Exp_Dt				AS Expire_Date,
		PMD.Matl_Typ				AS Matl_Typ
	FROM   	LINKS_MATERIAL			  	pmd
	);
	CREATE TABLE DATA_LMG AS SELECT * FROM CONNECTION TO ORACLE (
	SELECT	DISTINCT
		PMD.Prod_Batch_Nbr			AS Prod_Batch_Nbr,
		PMD.Prod_Matl_Nbr			AS Prod_Matl_Nbr,
		PMD.Comp_Batch_Nbr			AS Comp_Batch_Nbr,
		PMD.Comp_Matl_Nbr			AS Comp_Matl_Nbr
	FROM   	LINKS_MATERIAL_GENEALOGY  	pmd
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

*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: Data Processing                                         *;
*   REQUIREMENT:      N/A                                                     *;
*   INPUT:            Datasets DATA_LM & DATA_LMG                             *;
*   PROCESSING:       Creates the Genealogy Matrix.                           *;
*   OUTPUT:           Dataset GENETABLE.                                      *;
*******************************************************************************;

DATA DATA_LM;SET DATA_LM;
	LM_Batch=TRIM(LEFT(Batch_Nbr))||'-'||TRIM(LEFT(Matl_Nbr));
RUN;

DATA DATA_LMG;SET DATA_LMG;	CNT+1; RUN;

DATA T_LM T_LM2;SET DATA_LMG;
	Main_Batch = Prod_Batch_Nbr;
	Main_Matl  = Prod_Matl_Nbr;
	Batch_Nbr  = Prod_Batch_Nbr;
	Matl_Nbr   = Prod_Matl_Nbr;
	IF 	(Prod_Batch_Nbr =	Comp_Batch_Nbr)
	AND	(Prod_Matl_Nbr	=	Comp_Matl_Nbr) THEN OUTPUT T_LM;ELSE OUTPUT T_LM2;
RUN;

PROC SORT DATA=T_LM2 NODUPKEY;BY Comp_Batch_Nbr Comp_Matl_Nbr;RUN;
PROC SORT DATA=T_LM;BY Comp_Batch_Nbr Comp_Matl_Nbr;RUN;

DATA T_LM;
MERGE T_LM(IN=IN1)
	T_LM2(IN=IN2);
BY COMP_BATCH_NBR COMP_MATL_NBR;
IF IN1 AND NOT IN2;
RUN;

PROC SORT DATA=T_LM  OUT=T_LM NODUPKEY;BY Batch_Nbr Matl_Nbr ;RUN;
PROC SORT DATA=DATA_LMG OUT=T_LMG NODUPKEY;BY Prod_Batch_Nbr Prod_Matl_Nbr Comp_Batch_Nbr Comp_Matl_Nbr;RUN;

DATA TotalBackward;SET T_LM;
KEEP Batch_Nbr Matl_Nbr Main_Batch Main_Matl;
RUN;

%MEND READIN;

%MACRO BuildBackward(InTable,OutTable,type);
PROC SQL;										
	CREATE TABLE &OutTable AS SELECT * FROM (
	SELECT	DISTINCT 			
		PMD.*	,
		LR.Batch_Nbr,
		LR.Matl_Nbr,
		LR.Comp_Batch_Nbr,
		LR.Comp_Matl_Nbr
	FROM   	&InTable			 	pmd,
		T_LMG					lr
	WHERE   pmd.Comp_Batch_Nbr 	= lr.Comp_Batch_Nbr AND
		pmd.Comp_Matl_Nbr	= lr.Comp_Matl_Nbr
	);
	QUIT;
RUN;
PROC SORT DATA=&OUTTABLE NODUPKEY;BY Batch_NBR Comp_Batch_NBR;RUN;
DATA &OUTTABLE;LENGTH TYPE 5;SET &OUTTABLE;
	type=&TYPE;
RUN;
%MEND BuildBackward;

%MACRO BuildForward(InTable,OutTable,type);
PROC SQL;										
	CREATE TABLE &OutTable AS SELECT * FROM (
	SELECT	DISTINCT 			
		PMD.*	,
		LR.Prod_Batch_Nbr,
		LR.Prod_Matl_Nbr,
		LR.Comp_Batch_Nbr,
		LR.Comp_Matl_Nbr,
		LR.Cnt
	FROM   	&InTable			 	pmd,
		T_LMG					lr
	where   pmd.prod_Batch_Nbr 			= lr.Prod_Batch_Nbr AND
		pmd.prod_Matl_Nbr			= lr.Prod_Matl_Nbr
	) ORDER MAIN_BATCH, MAIN_MATL;
	QUIT;
RUN;
DATA &OUTTABLE;LENGTH TYPE 5;SET &OUTTABLE;
	BY MAIN_BATCH MAIN_MATL;
	type=&TYPE;
RUN;
%MEND BuildForward;

%MACRO RUNTHRU;
	*********************************************;
	* V4 - Changed NOSYMBOLGEN to SYMBOLGEN.    *;
	*********************************************;
	OPTIONS NUMBER NODATE MLOGIC MPRINT SYMBOLGEN SOURCE2 PAGENO=1 ERROR=2
			MERGENOBY=ERROR MAUTOSOURCE LINESIZE=120 NOCENTER PAGENO=1 NOXWAIT
			SPOOL COMPRESS=YES BLKSIZE=2560 MSGLEVEL=I; 

LIBNAME TSERVEP "&CtlDir";

%Readin;

DATA OUTALL;RUN;

DATA TEMP_LR1;SET TotalBackward;
Prod_Batch_Nbr = Batch_Nbr;
Prod_Matl_Nbr  = Matl_Nbr;
KEEP Prod_Batch_Nbr  Prod_Matl_Nbr
	 Batch_Nbr       Matl_Nbr
	 Main_Batch      Main_Matl;
RUN;

%BuildForward(TEMP_LR1,SELECT1,1);
data select2;set select1;Prod_Batch_nbr=Comp_Batch_Nbr;Prod_matl_nbr=Comp_Matl_Nbr;
drop Comp_Batch_nbr Comp_matl_nbr type;
run;

DATA selectOUTALL;SET OUTALL;RUN;

%DO LOOP=2 %TO 20 %BY 2;
	%LET OUTLOOP1=%EVAL(&LOOP+1);
	%LET OUTLOOP2=%EVAL(&LOOP+2);
	%BuildForward(SELECT&LOOP,SELECT&OUTLOOP1,&LOOP);

	DATA selectOUTALL;SET selectOUTALL select&OUTLOOP1;
		KEEP MAIN_BATCH MAIN_MATL PROD_BATCH_NBR PROD_MATL_NBR;
	RUN;

	data select&OUTLOOP2;set select&OUTLOOP1;
		IF Comp_Batch_Nbr='' AND Comp_Matl_Nbr='' THEN DELETE;
		PROD_Batch_nbr=Comp_Batch_Nbr;PROD_matl_nbr=Comp_Matl_Nbr;
		KEEP prod_BATCH_NBR PROD_MATL_NBR MAIN_BATCH MAIN_MATL;
	run;

	PROC SORT DATA=selectOUTALL NODUPKEY;BY PROD_BATCH_NBR PROD_MATL_NBR MAIN_BATCH MAIN_MATL;

    %IF &LOOP > 4 %THEN %DO;
		PROC SORT DATA=select&OUTLOOP2;BY PROD_BATCH_NBR PROD_MATL_NBR MAIN_BATCH MAIN_MATL;RUN;
		PROC SORT DATA=selectOUTALL;   BY PROD_BATCH_NBR PROD_MATL_NBR MAIN_BATCH MAIN_MATL;RUN;
		DATA select&OUTLOOP2;
		MERGE select&OUTLOOP2(IN=IN1)
			  selectOUTALL(IN=IN2);
		BY PROD_BATCH_NBR PROD_MATL_NBR MAIN_BATCH MAIN_MATL;
		IF IN1 AND NOT IN2;
		RUN;
	%END;

%END;

DATA TotalForward;
SET 
	%DO SETS=1 %TO 19 %BY 2;
		SELECT&SETS
	%END;
	;
	IF (Main_Batch = Comp_Batch_Nbr) AND (Main_Matl = Comp_Matl_Nbr)
   AND (Main_Batch = Batch_Nbr) AND (Main_Matl = Matl_Nbr)
   		THEN TYPE=0;
RUN;

PROC SORT DATA=TotalForward NODUPKEY;BY MATL_NBR BATCH_NBR COMP_MATL_NBR COMP_BATCH_NBR MAIN_MATL MAIN_BATCH;RUN;
DATA Total;SET TotalForward;RUN;

PROC SORT DATA=DATA_LM OUT=T_LMOUT NODUPKEY;BY Batch_Nbr Matl_Nbr;RUN;
PROC SQL;										
	CREATE TABLE OUT_TABLES AS SELECT * FROM (
	SELECT	DISTINCT 			
		LR.*	,
		PMD.Matl_Nbr,
		PMD.Item_Description,
		PMD.Create_Date,
		PMD.Expire_Date,
		PMD.Matl_Typ
	FROM   	TOTAL				lr left join
		T_LMOUT 			pmd
	ON      lr.Comp_Batch_Nbr 	= pmd.Batch_Nbr
	AND     lr.Comp_Matl_Nbr 	= pmd.Matl_Nbr
	);
	CREATE TABLE OUT_TABLES AS SELECT * FROM (
	SELECT	DISTINCT 			
		LR.*	,
		SAMP.Stability_Study_Purpose_Txt,
		SAMP.Stability_Study_Grp_Cd,
		SAMP.Stability_Study_Nbr_Cd,
		SAMP.Prod_Nm,
		SAMP.Prod_Grp
	FROM   	OUT_TABLES			lr left join
		DATA_SAMP 			SAMP
	ON      lr.Main_Batch 	= SAMP.Batch_Nbr
	AND     lr.Main_Matl 	= SAMP.Matl_Nbr
	);
	QUIT;
RUN;

PROC SORT DATA=OUT_TABLES;BY BATCH_NBR MATL_NBR Stability_Study_Purpose_Txt Stability_Study_Grp_Cd Stability_Study_Nbr_Cd;RUN;
PROC SORT DATA=DATA_SAMP;BY BATCH_NBR MATL_NBR Stability_Study_Purpose_Txt Stability_Study_Grp_Cd Stability_Study_Nbr_Cd;RUN;
DATA MERGE1;
	MERGE OUT_TABLES(IN=IN1)
		DATA_SAMP(IN=IN2);
	BY BATCH_NBR MATL_NBR Stability_Study_Purpose_Txt Stability_Study_Grp_Cd Stability_Study_Nbr_Cd;
	IF IN2 AND NOT IN1;
RUN;

PROC SQL;										
	CREATE TABLE MERGE1 AS SELECT * FROM (
	SELECT	DISTINCT 			
		LR.*	,
		PMD.Matl_Nbr,
		PMD.Item_Description,
		PMD.Create_Date,
		PMD.Expire_Date,
		PMD.Matl_Typ
	FROM   	MERGE1				lr left join
		T_LMOUT 			pmd
	ON      lr.Batch_Nbr 	= pmd.Batch_Nbr
	AND     lr.Matl_Nbr 	= pmd.Matl_Nbr
	);
	QUIT;
RUN;
DATA MERGE1;SET MERGE1;
		TYPE=0;
		MAIN_BATCH=BATCH_NBR;
		MAIN_MATL =MATL_NBR;
		Comp_Batch_NBR = BATCH_NBR;
		Comp_MATL_NBR = MATL_NBR;
		KEEP TYPE MAIN_BATCH MAIN_MATL Batch_NBR MATL_NBR Comp_Batch_NBR Comp_MATL_NBR Stability_Study_Purpose_Txt Stability_Study_Grp_Cd Stability_Study_Nbr_Cd;	
RUN;

DATA OUT_TABLES;SET OUT_TABLES MERGE1;RUN;
PROC SORT DATA=OUT_TABLES OUT=TABLEOUT NODUPKEY;BY type MAIN_BATCH MAIN_MATL Batch_NBR MATL_NBR Comp_Batch_NBR Comp_MATL_NBR Stability_Study_Purpose_Txt Stability_Study_Grp_Cd Stability_Study_Nbr_Cd;RUN;
DATA TABLEOUT;SET TABLEOUT;BY TYPE;
IF FIRST.TYPE THEN LEVEL+1;
run;

DATA TABLESOUT;SET TABLEOUT;LENGTH MAIN_NBR_CODE NBR_CODE COMP_NBR_CODE $40.  NBR_CODE_DESC COMP_NBR_CODE_DESC $100.;
	If Batch_Nbr NE '' THEN Nbr_Code=TRIM(LEFT(Batch_Nbr))||'-'||TRIM(LEFT(Matl_Nbr));
		ELSE Nbr_Code='';
	If Batch_Nbr NE '' THEN Nbr_Code_Desc=TRIM(LEFT(Batch_Nbr))||'-'||TRIM(LEFT(Matl_Nbr))||'~'||TRIM(LEFT(ITEM_DESCRIPTION));
		ELSE Nbr_Code_Desc='';
	If Comp_Batch_Nbr NE '' THEN Comp_Nbr_Code=TRIM(LEFT(Comp_Batch_Nbr))||'-'||TRIM(LEFT(Comp_Matl_Nbr));
		ELSE Comp_Nbr_Code='';
	If Comp_Batch_Nbr NE '' THEN Comp_Nbr_Code_Desc=TRIM(LEFT(Comp_Batch_Nbr))||'-'||TRIM(LEFT(Comp_Matl_Nbr))||'~'||TRIM(LEFT(ITEM_DESCRIPTION));
		ELSE Comp_Nbr_Code_Desc='';
 	IF INDEX(Nbr_Code,'Z') GT 0 THEN _PATTERN=2;
 	IF INDEX(Nbr_Code,'B0') GT 0 THEN _PATTERN=2;
	Main_Nbr_Code=TRIM(LEFT(Main_Batch))||'-'||TRIM(LEFT(Main_Matl));
RUN;

DATA TABLESOUT2;SET TABLESOUT;
	***********************************************************;
	* V2 - Added "Z" Batches for Fluticasone and Salmeterol   *;
	* V7 - Added Info for Relenza batches                     *;
	***********************************************************;

	IF INDEX(COMP_BATCH_NBR,'ZM') > 0 or
	   INDEX(COMP_BATCH_NBR,'ZP') > 0 or
	   (INDEX(COMP_BATCH_NBR,'BAA') > 0 AND INDEX(COMP_BATCH_NBR,'R') = 0 AND (INDEX(COMP_NBR_CODE_DESC,'LAC') > 0 OR INDEX(COMP_NBR_CODE_DESC,'FLU') > 0 OR INDEX(COMP_NBR_CODE_DESC,'FP') > 0 OR INDEX(COMP_NBR_CODE_DESC,'SAL') > 0)) or
	   (INDEX(COMP_BATCH_NBR,'B0')  > 0 AND INDEX(COMP_BATCH_NBR,'R') = 0 AND (INDEX(COMP_NBR_CODE_DESC,'LAC') > 0 OR INDEX(COMP_NBR_CODE_DESC,'FLU') > 0 OR INDEX(COMP_NBR_CODE_DESC,'FP') > 0 OR INDEX(COMP_NBR_CODE_DESC,'SAL') > 0)) or
	   (INDEX(COMP_BATCH_NBR,'00')  > 0 AND INDEX(COMP_BATCH_NBR,'R') = 0 AND (INDEX(COMP_NBR_CODE_DESC,'LAC') > 0 OR INDEX(COMP_NBR_CODE_DESC,'FLU') > 0 OR INDEX(COMP_NBR_CODE_DESC,'FP') > 0 OR INDEX(COMP_NBR_CODE_DESC,'SAL') > 0)) or
	   (INDEX(COMP_BATCH_NBR,'Z')   > 0 AND INDEX(COMP_BATCH_NBR,'R') = 0 AND (INDEX(COMP_NBR_CODE_DESC,'LAC') > 0 OR INDEX(COMP_NBR_CODE_DESC,'FLU') > 0 OR INDEX(COMP_NBR_CODE_DESC,'FP') > 0 OR INDEX(COMP_NBR_CODE_DESC,'SAL') > 0)) or
	   INDEX(COMP_BATCH_NBR,'BO')   > 0 OR
	   INDEX(COMP_BATCH_NBR,'400')   > 0 OR
	   INDEX(COMP_BATCH_NBR,'BAT')  > 0 OR
	   INDEX(COMP_BATCH_NBR,'TEST')  > 0;

	COUNT=1;
		IF Prod_Nm='' THEN DO;
			IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"COMBIVIR") THEN DO;
					Prod_Nm="Combivir Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"LANOXIN") THEN DO;
					Prod_Nm="Lanoxin Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"LOTRONEX") THEN DO;
					Prod_Nm="Lotronex Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"ZOVIRAX") AND INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"CAP") THEN DO;
					Prod_Nm="Zovirax Capsules";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"ZOVIRAX") AND INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"TAB") THEN DO;
					Prod_Nm="Zovirax Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"RETROVIR") AND 
					(INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"CAP") OR INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"CPSL")) THEN DO;
					Prod_Nm="Retrovir Capsules";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"RETROVIR") AND INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"TAB") THEN DO;
					Prod_Nm="Retrovir Tablets";Prod_Grp='Solid Dose';END;

			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"TRIZIVIRTABLETS") THEN DO;
					Prod_Nm="Trizivir Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"ZOFRAN") THEN DO;
					Prod_Nm="Zofran Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"ONDANSETRON") THEN DO;
					Prod_Nm="Ondansetron Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"IMITREX") AND INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"TAB") THEN DO;
					Prod_Nm="Imitrex Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"IMITREX") AND INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"FTD") THEN DO;
					Prod_Nm="Imitrex FDT Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"IMITREX") AND INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"FAST") THEN DO;
					Prod_Nm="Imitrex FDT Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"IMITREX") THEN DO;
					Prod_Nm="Imitrex Tablets";Prod_Grp='Solid Dose';END;
			/* Order matters */
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"LAMICTAL") AND INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"CD") THEN DO;
					Prod_Nm="Lamictal CD Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"LAMICTAL") AND INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"XR") THEN DO;
					Prod_Nm="Lamictal XR Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"LAMICTAL") THEN DO;
					Prod_Nm="Lamictal Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"ZIAGEN") THEN DO;
					Prod_Nm="Ziagen Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"EPIVIR") THEN DO;
					Prod_Nm="Epivir Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"VALTREX") THEN DO;
					Prod_Nm="Valtrex Caplets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"ZANTAC") THEN DO;
					Prod_Nm="Zantac Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"WELLBUTRIN") THEN DO;
					Prod_Nm="Wellbutrin SR Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"ZYBAN") THEN DO;
					Prod_Nm="Zyban SR Tablets";Prod_Grp='Solid Dose';END;
                        /* Special case where Bupro data is in Watson file */
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"(DEPRESSION)") THEN DO;
					Prod_Nm="Buproprion HCL SR Tablets";Prod_Grp='Solid Dose';END;
			/* Watson must precede Bupropion in this block */
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"WATSON") THEN DO;
					Prod_Nm="Watson HCL SR Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"BUPROPION") THEN DO;
					Prod_Nm="Buproprion HCL SR Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"VENTOLIN") THEN DO;
					Prod_Nm="Ventolin HFA";Prod_Grp='MDI';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"ALBUTEROL") THEN DO;
					Prod_Nm="Albuterol HFA";Prod_Grp='MDI';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"AVANDARYL") THEN DO;
					Prod_Nm="Avandaryl Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"ADVAIRHFA") OR INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"SAL/FP")
					OR INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"FP/SAL") THEN DO;
					Prod_Nm="Advair HFA";Prod_Grp='MDI';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"AGENERASE") THEN DO;
					Prod_Nm="Agenerase Capsules";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"AMERGE") THEN DO;
					Prod_Nm="Amerge Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"ADVAIR") THEN DO;
					Prod_Nm="Advair Diskus";Prod_Grp='MDPI';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"LACTOSE") THEN DO;
					Prod_Nm="Advair Diskus";Prod_Grp='MDPI';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"FLUTICASONE") OR INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"FP;") 
					OR INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"FP,") THEN DO;
					Prod_Nm="Advair Diskus";Prod_Grp='MDPI';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"SALMETEROL") OR INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"SALM;") 
					OR INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"SALM,") THEN DO;
					Prod_Nm="Advair Diskus";Prod_Grp='MDPI';END;
					/******/
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"TRIZIVIR") THEN DO;
					Prod_Nm="Trizivir Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"AVANDIA") THEN DO;
					Prod_Nm="Avandia Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"AVANDASTAT") THEN DO;
					Prod_Nm="Avandastat Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"AVANDAMET") THEN DO;
					Prod_Nm="Avandamet Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"LAMOTRIGINE") THEN DO;
					Prod_Nm="Lamotrigine Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"ROSIGLITAZONE") THEN DO;
					Prod_Nm="Rosiglitazone Tablets";Prod_Grp='Solid Dose';END;
			ELSE IF INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"RELENZA") OR INDEX(UPCASE(COMPRESS(COMP_NBR_CODE_DESC)),"ZANAMIVIR") THEN
					ProductNm="RELENZA ROTADISK";
			ELSE DO;
					Prod_Nm='N/A';Prod_Grp='N/A';END;
		END;
	IF Main_Nbr_Code=' - ' THEN DELETE;
	IF INDEX(COMP_BATCH_NBR,'T')>0 THEN DELETE;
RUN;

/**
data TABLESOUT2a;set TABLESOUT2;
	sub1=substr(COMP_NBR_CODE_DESC,INDEX(COMP_NBR_CODE_DESC,'~')+1);
run;
Proc freq data=TABLESOUT2;
tables prod_nm * COMP_NBR_CODE_DESC / list missing;
run;
Proc freq data=TABLESOUT2a;
tables prod_nm / list missing;
run;
Proc freq data=TABLESOUT2a;
where prod_nm = 'N/A';
tables COMP_NBR_CODE_DESC / list missing;
tables sub1 / list missing;
run;
**/
PROC SORT DATA=TABLESOUT2 nodupkey;BY Prod_Nm Prod_Grp Main_Nbr_Code TYPE Comp_Nbr_Code Stability_Study_Purpose_Txt Stability_Study_Grp_Cd Stability_Study_Nbr_Cd;RUN;
PROC SORT DATA=TABLESOUT2 nodupkey;BY Prod_Nm Prod_Grp Main_Nbr_Code Comp_Nbr_Code Stability_Study_Purpose_Txt Stability_Study_Grp_Cd Stability_Study_Nbr_Cd TYPE;RUN;
************************************************************************;
* V3 - Added additional Proc Sort below to eliminate duplicate records.*;
************************************************************************;
PROC SORT DATA=TABLESOUT2         ;BY Prod_Nm Prod_Grp Main_Nbr_Code Stability_Study_Purpose_Txt Stability_Study_Grp_Cd Stability_Study_Nbr_Cd Comp_Nbr_Code TYPE;RUN;
PROC SORT DATA=TABLESOUT2 nodupkey;BY Prod_Nm Prod_Grp Main_Nbr_Code Stability_Study_Purpose_Txt Stability_Study_Grp_Cd Stability_Study_Nbr_Cd Comp_Nbr_Code;RUN;
PROC SORT DATA=TABLESOUT2         ;BY Prod_Nm Prod_Grp Main_Nbr_Code Stability_Study_Purpose_Txt Stability_Study_Grp_Cd Stability_Study_Nbr_Cd TYPE DESCENDING CNT Comp_Nbr_Code;RUN;

proc summary data=TABLESOUT2;
by Prod_Nm Prod_Grp Main_Nbr_Code;
output out=sumout
sum(count)=total;
RUN;

PROC TRANSPOSE DATA=TABLESOUT2 OUT=OUT;
BY Prod_Nm Prod_Grp Main_Nbr_Code Stability_Study_Purpose_Txt Stability_Study_Grp_Cd Stability_Study_Nbr_Cd;
VAR Comp_Nbr_Code_Desc;
RUN;

OPTIONS NOSYMBOLGEN NOMLOGIC;
%MACRO FIXGENE;
data genebuild(KEEP=Prod_Nm Prod_Grp main_NBR_code ASSY_BATCH FILL_BATCH BLEND_BATCH LAC_BATCH SAL_BATCH FLU_BATCH PKG_BATCH MFG_BATCH
WARE_LAC_BATCH WARE_SAL_BATCH WARE_FLU_BATCH Stability_Study_Purpose_Txt STABILITY_STUDY_GRP_CD STABILITY_STUDY_NBR_CD);

FORMAT main_nbr_code assy_batch fill_batch blend_batch mfg_batch pkg_batch LAC_batch SAL_batch FLU_batch Ware_LAC_batch Ware_SAL_batch Ware_FLU_batch $40.;
set out;
	
	LAC_BATCH='';FLU_BATCH='';SAL_BATCH='';
	WARE_LAC_BATCH='';WARE_FLU_BATCH='';WARE_SAL_BATCH='';
	MFG_BATCH='';PKG_BATCH='';

	%DO I = 1 %TO 12;
		IF COL&i NE '' THEN COL&i.A=SUBSTR(COL&i,1,INDEX(COL&i,'~')-1);
	%END;

	IF Prod_Grp='MDPI' THEN DO;

	%DO I = 12 %TO 1 %BY -1;
		IF INDEX(UPCASE(COL&i),'LACT')>0 AND INDEX(UPCASE(COL&i.A),'BAA')>0     THEN LAC_BATCH=COL&i.A;
	%END;

	IF LAC_BATCH = '' THEN DO;
		%DO I = 12 %TO 1 %BY -1;
			IF INDEX(UPCASE(COL&i),'LACT')>0 AND INDEX(UPCASE(COL&i.A),'00')>0  THEN LAC_BATCH=COL&i.A;
		%END;
	END;

	%DO I = 12 %TO 1 %BY -1;
	    IF INDEX(UPCASE(COL&i),'SALM')>0 AND INDEX(UPCASE(COL&i.A),'BAA')>0     THEN SAL_BATCH=COL&i.A;
	%END;

	***********************************************************;
	* V2 - Added "Z" Batches for Fluticasone and Salmeterol   *;
	***********************************************************;
	IF SAL_BATCH = '' THEN DO;
		%DO I = 12 %TO 1 %BY -1;
		    IF INDEX(UPCASE(COL&i),'SALM')>0 AND INDEX(UPCASE(COL&i.A),'00')>0  THEN SAL_BATCH=COL&i.A;
		%END;
	END;
	IF SAL_BATCH = '' THEN DO;
		%DO I = 12 %TO 1 %BY -1;
		    IF INDEX(UPCASE(COL&i),'SALM')>0 AND INDEX(UPCASE(COL&i.A),'Z')>0   THEN SAL_BATCH=COL&i.A;
		%END;
	END;

	%DO I = 12 %TO 1 %BY -1;
	    IF INDEX(UPCASE(COL&i),'FLUT')>0 AND INDEX(UPCASE(COL&i.A),'BAA')>0     THEN FLU_BATCH=COL&i.A;
	%END;

	IF FLU_BATCH = '' THEN DO;
		%DO I = 12 %TO 1 %BY -1;
		    IF INDEX(UPCASE(COL&i),'FP')>0 AND INDEX(UPCASE(COL&i.A),'BAA')>0  THEN FLU_BATCH=COL&i.A;
		%END;
	END;
	IF FLU_BATCH = '' THEN DO;
		%DO I = 12 %TO 1 %BY -1;
		    IF INDEX(UPCASE(COL&i),'FLUT')>0 AND INDEX(UPCASE(COL&i.A),'Z')>0  THEN FLU_BATCH=COL&i.A;
		%END;
	END;
	IF FLU_BATCH = '' THEN DO;
		%DO I = 12 %TO 1 %BY -1;
		    IF INDEX(UPCASE(COL&i),'FP')>0 AND INDEX(UPCASE(COL&i.A),'Z')>0    THEN FLU_BATCH=COL&i.A;
		%END;
	END;
	IF FLU_BATCH = '' THEN DO;
		%DO I = 12 %TO 1 %BY -1;
		    IF INDEX(UPCASE(COL&i),'FLUT')>0 AND INDEX(UPCASE(COL&i.A),'00')>0 THEN FLU_BATCH=COL&i.A;
		%END;
	END;
	IF FLU_BATCH = '' THEN DO;
		%DO I = 12 %TO 1 %BY -1;
		    IF INDEX(UPCASE(COL&i),'FP')>0 AND INDEX(UPCASE(COL&i.A),'00')>0   THEN FLU_BATCH=COL&i.A;
		%END;
	END;

	%DO I = 12 %TO 1 %BY -1;
	    IF INDEX(UPCASE(COL&i),'LACT')>0 AND INDEX(UPCASE(COL&i.A),'B0')>0     THEN WARE_LAC_BATCH=COL&i.A;
	%END;

	%DO I = 12 %TO 1 %BY -1;
	    IF INDEX(UPCASE(COL&i),'SALM')>0 AND INDEX(UPCASE(COL&i.A),'B0')>0     THEN WARE_SAL_BATCH=COL&i.A;
	%END;

	%DO I = 12 %TO 1 %BY -1;
	    IF INDEX(UPCASE(COL&i),'FLUT')>0 AND INDEX(UPCASE(COL&i.A),'B0')>0     THEN WARE_FLU_BATCH=COL&i.A;
	%END;

	IF WARE_FLU_BATCH = '' THEN DO;
		%DO I = 12 %TO 1 %BY -1;
		    IF INDEX(UPCASE(COL&i),'FP')>0 AND INDEX(UPCASE(COL&i.A),'B0')>0   THEN WARE_FLU_BATCH=COL&i.A;
		%END;
	END;

	END;  /* End of MDPI Section */

	******************************************************************************************;
	* V3 - Modified code for LAC,SAL & FLU with batch # containing "00000" changed to "00".  *;
	* V6 - Modified code to fix Assy/Fill Batches being the same.  Added ELSE to 2nd IF.     *;
	******************************************************************************************;
	IF INDEX(COL1A,'ZP')>0 AND INDEX(COL2A,'ZP')>0 AND INDEX(COL3A,'ZM')>0 THEN DO;
		IF Prod_Grp='MDPI'       THEN DO;Assy_Batch=Col1A;	Fill_Batch=Col2A; 	Blend_Batch=Col3A;END;
	END;
	ELSE IF INDEX(COL1A,'ZP')>0 AND (INDEX(COL2A,'X')>0 AND INDEX(COL2A,'ZM')>0) AND INDEX(COL3A,'ZM')>0 THEN DO;
		IF Prod_Grp='MDPI'       THEN DO;Assy_Batch=Col1A;	Fill_Batch=Col2A; 	Blend_Batch=Col3A;END;
	END;
	ELSE IF INDEX(COL1A,'ZP')>0 AND INDEX(COL2A,'ZM')>0 THEN DO;
		IF Prod_Grp='MDPI'       THEN DO;Fill_Batch=Col1A; 	Blend_Batch=Col2A;END;
		IF Prod_Grp='Solid Dose' THEN DO;Pkg_Batch=Col1A;	Mfg_Batch=Col2A;  END;
		IF Prod_Grp='MDI'        THEN DO;Pkg_Batch=Col1A;	Mfg_Batch=Col2A;  END;
	END;
	ELSE IF INDEX(COL1A,'ZP') > 0 THEN DO;
		IF Prod_Grp='MDPI'       THEN DO;Fill_Batch=Col1A;END;
		IF Prod_Grp='Solid Dose' THEN DO;Pkg_Batch=Col1A; END;
		IF Prod_Grp='MDI'        THEN DO;Pkg_Batch=Col1A; END;
	END;
	ELSE IF INDEX(COL1A,'ZM') > 0 THEN DO;
		IF Prod_Grp='MDPI'       THEN DO;Blend_Batch=Col1A;END;
		IF Prod_Grp='Solid Dose' THEN DO;Mfg_Batch=Col1A;  END;
		IF Prod_Grp='MDI'        THEN DO;Mfg_Batch=Col1A;  END;
	END;
	/****
	ELSE IF INDEX(COL1A,'EF') > 0 AND INDEX(COL2A,'EF') > 0 AND INDEX(COL3A,'EF') > 0 THEN DO;
		Assy_Batch=Col1A;	Fill_Batch=Col2A; 	Blend_Batch=Col3A;
	END;
	ELSE IF INDEX(COL1A,'EF') > 0 AND INDEX(COL2A,'EF') > 0 AND INDEX(COL3A,'CO') > 0 THEN DO;
							Fill_Batch=Col1A; 	Blend_Batch=Col2A;
	END;
	ELSE IF INDEX(COL1A,'EF') > 0 AND INDEX(COL2A,'EF') > 0 AND COL3 EQ ' ' THEN DO;
							Fill_Batch=Col1A; 	Blend_Batch=Col2A;
	END;
	ELSE IF INDEX(COL1A,'EF') > 0 AND INDEX(COL2A,'CO') > 0 THEN DO;
												Blend_Batch=Col1A;
	END;
	ELSE IF INDEX(COL1A,'EF') > 0 AND COL2 EQ ' ' THEN DO;
												Blend_Batch=Col1A;
	END;
	****/

run;
%MEND FIXGENE;
%FIXGENE;
OPTIONS SYMBOLGEN MLOGIC;

PROC SQL;										
	CREATE TABLE genealogy AS SELECT * FROM (
	SELECT	DISTINCT 			
		LR.*	,
		PMD.Item_Description	AS Assy_Desc,
		PMD.Create_Date			AS Assy_Mfg_Dt,
		PMD.Expire_Date			AS Assy_Exp_Dt
	FROM   	GeneBuild			lr left join
			DATA_LM 			pmd
	ON      lr.Assy_Batch 	= pmd.LM_Batch
	);
	CREATE TABLE genealogy AS SELECT * FROM (
	SELECT	DISTINCT 			
		LR.*	,
		PMD.Item_Description	AS Blend_Desc,
		PMD.Create_Date			AS Blend_Mfg_Dt,
		PMD.Expire_Date			AS Blend_Exp_Dt
	FROM   	Genealogy			lr left join
			DATA_LM 			pmd
	ON      lr.Blend_Batch 	= pmd.LM_Batch
	);
	CREATE TABLE genealogy AS SELECT * FROM (
	SELECT	DISTINCT 			
		LR.*	,
		PMD.Item_Description	AS Fill_Desc,
		PMD.Create_Date			AS Fill_Mfg_Dt,
		PMD.Expire_Date			AS Fill_Exp_Dt
	FROM   	Genealogy			lr left join
			DATA_LM 			pmd
	ON      lr.Fill_Batch 	= pmd.LM_Batch
	);
	CREATE TABLE genealogy AS SELECT * FROM (
	SELECT	DISTINCT 			
		LR.*	,
		PMD.Item_Description	AS LAC_Desc,
		PMD.Create_Date			AS LAC_Mfg_Dt,
		PMD.Expire_Date			AS LAC_Exp_Dt
	FROM   	Genealogy			lr left join
			DATA_LM 			pmd
	ON      lr.LAC_Batch 	= pmd.LM_Batch
	);
	CREATE TABLE genealogy AS SELECT * FROM (
	SELECT	DISTINCT 			
		LR.*	,
		PMD.Item_Description	AS FLU_Desc,
		PMD.Create_Date			AS FLU_Mfg_Dt,
		PMD.Expire_Date			AS FLU_Exp_Dt
	FROM   	Genealogy			lr left join
			DATA_LM 			pmd
	ON      lr.FLU_Batch 	= pmd.LM_Batch
	);
	CREATE TABLE genealogy AS SELECT * FROM (
	SELECT	DISTINCT 			
		LR.*	,
		PMD.Item_Description	AS SAL_Desc,
		PMD.Create_Date			AS SAL_Mfg_Dt,
		PMD.Expire_Date			AS SAL_Exp_Dt
	FROM   	Genealogy			lr left join
			DATA_LM 			pmd
	ON      lr.SAL_Batch 	= pmd.LM_Batch
	);
	CREATE TABLE genealogy AS SELECT * FROM (
	SELECT	DISTINCT 			
		LR.*	,
		PMD.Item_Description	AS Pkg_Desc,
		PMD.Create_Date			AS Pkg_Mfg_Dt,
		PMD.Expire_Date			AS Pkg_Exp_Dt
	FROM   	Genealogy			lr left join
			DATA_LM 			pmd
	ON      lr.Pkg_Batch 	= pmd.LM_Batch
	);
	CREATE TABLE genealogy AS SELECT * FROM (
	SELECT	DISTINCT 			
		LR.*	,
		PMD.Item_Description	AS Mfg_Desc,
		PMD.Create_Date			AS Mfg_Mfg_Dt,
		PMD.Expire_Date			AS Mfg_Exp_Dt
	FROM   	Genealogy			lr left join
			DATA_LM 			pmd
	ON      lr.Mfg_Batch 	= pmd.LM_Batch
	);
	CREATE TABLE genealogy AS SELECT * FROM (
	SELECT	DISTINCT 			
		LR.*	,
		PMD.Item_Description	AS Ware_LAC_Desc,
		PMD.Create_Date			AS Ware_LAC_Mfg_Dt,
		PMD.Expire_Date			AS Ware_LAC_Exp_Dt
	FROM   	Genealogy			lr left join
			DATA_LM 			pmd
	ON      lr.Ware_LAC_Batch 	= pmd.LM_Batch
	);
	CREATE TABLE genealogy AS SELECT * FROM (
	SELECT	DISTINCT 			
		LR.*	,
		PMD.Item_Description	AS Ware_FLU_Desc,
		PMD.Create_Date			AS Ware_FLU_Mfg_Dt,
		PMD.Expire_Date			AS Ware_FLU_Exp_Dt
	FROM   	Genealogy			lr left join
			DATA_LM 			pmd
	ON      lr.Ware_FLU_Batch 	= pmd.LM_Batch
	);
	CREATE TABLE GeneTable AS SELECT * FROM (
	SELECT	DISTINCT 			
		LR.*	,
		PMD.Item_Description	AS Ware_SAL_Desc,
		PMD.Create_Date			AS Ware_SAL_Mfg_Dt,
		PMD.Expire_Date			AS Ware_SAL_Exp_Dt
	FROM   	Genealogy			lr left join
			DATA_LM 			pmd
	ON      lr.Ware_SAL_Batch 	= pmd.LM_Batch
	);
	QUIT;
RUN;

PROC SORT DATA=GENETABLE;BY blend_batch descending fill_batch descending assy_batch;run;
DATA GENETABLE1;SET GENETABLE;
	Assy_LAG=LAG(ASSY_BATCH);
	Fill_LAG=LAG(FILL_BATCH);
	Blnd_LAG=LAG(BLEND_BATCH);
RUN;
DATA GENETABLE1(KEEP=blend_batch fill_batch assy_batch);SET GENETABLE1;
	WHERE (Blnd_LAG=BLEND_BATCH AND Fill_LAG IS NOT NULL AND FILL_BATCH IS NULL) OR
	   (Blnd_LAG=BLEND_BATCH AND Fill_LAG=FILL_BATCH AND Assy_LAG IS NOT NULL AND Assy_Batch IS NULL) OR
	   (FILL_BATCH=FILL_LAG AND BLEND_BATCH=BLND_LAG AND FILL_BATCH IS NOT NULL AND BLEND_BATCH IS NOT NULL) OR
	   (BLEND_BATCH=BLND_LAG AND ASSY_BATCH IS NULL);
	DELETE;
RUN;
*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: Output                                                  *;
*   REQUIREMENT:      N/A                                                     *;
*   INPUT:            Dataset GENETABLE                                       *;
*   PROCESSING:       Writes dataset to Server.                               *;
*   OUTPUT:           SAS Dataset LeGenealogy.                                *;
*******************************************************************************;
PROC SORT DATA=GENETABLE OUT=DUPGENE         ;BY blend_batch descending fill_batch descending assy_batch LAC_BATCH FLU_BATCH SAL_BATCH;RUN;

%IF &CondCode = 0 %THEN %DO;
	DATA _NULL_;							*** Create DB-update-in-progress flag ***;
		FILE "&CtlDir.CkRptFlg.txt";
		PUT		@1 'x';
	RUN;
%END;

DATA tServeP.LeGenealogy01A;
MERGE DUPGENE(IN=IN1)
	GENETABLE1(IN=IN2);
BY blend_batch descending fill_batch descending assy_batch;
IF IN1 and NOT IN2;
run;

%IF &CondCode = 0 %THEN %DO; /* Clear DB-update-in-progress   */
	DATA _NULL_;
		delrc = SYSTEM("Del &CtlDir.CkRptFlg.txt");
		PUT '+++ SYSTEM CHECK: CkRptFlg.txt Delete' +2 delrc 6.;
		IF delrc ^= 0 THEN DO;
			PUT '+++ ERROR: CkRptFlg.txt Delete failed!' +2 delrc 6.;
			CALL SYMPUT('JobStep','CleanUp (Del CkRptFlg)');
			CALL SYMPUT('StepRC',delrc);
			CALL SYMPUT('CondCode',delrc);
		END;
	RUN;
%END;

%MEND RunThru;

%RunThru;
%MEND LEGenealogy;
