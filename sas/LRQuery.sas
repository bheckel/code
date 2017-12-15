*********************************************************************************************;
*                     PROGRAM HEADER                                                        *;
*-------------------------------------------------------------------------------------------*;
*  PROJECT NUMBER: ZE0-986025-1                                                             *;
*  PROGRAM NAME: LRQuery.SAS                    SAS VERSION: 8.2                            *;
*  DEVELOPED BY: Carol Hiser                    DATE: 11/05/2002                            *;
*  PROJECT REPRESENTATIVE: Carol Hiser                                                      *;
*  PURPOSE: Generate a series of screens dynamically populated with data                    *;
*  from the LINKS data base to allow a LINKS user to define query parameters.               *;
*  SINGLE USE OR MULTIPLE USE? (SU OR MU) MU                                                *;
*  PROGRAM ASSUMPTIONS OR RESTRICTIONS: None                                                *;
*-------------------------------------------------------------------------------------------*;
*  OTHER SAS PROGRAMS, MACROS OR MACRO VARIABLES USED IN THIS                               *;
*  PROGRAM:   Macro variables: UID, UserRole, Rpttype                                       *;
*-------------------------------------------------------------------------------------------*;
*  DESCRIPTION OF OUTPUT: Several HTML screens output to web browser plus                   *;
*						  dataset LRQuery01a.                       *;
*********************************************************************************************;
*                     HISTORY OF CHANGE                                                     *;
*-------------+---------+--------------+----------------------------------------------------*;
*     DATE    | VERSION | NAME         | Description                                        *;
*-------------+---------+--------------+----------------------------------------------------*;
*  11/05/2002 |    1.0  | Carol Hiser  | Original                                           *;
*-------------+---------+--------------+----------------------------------------------------*;
*  02/03/2003 |    2.0  | James Becker |  - In %MACRO SCREENS, Changed the Query for        *;
*             |         |              |    the Test Method Screen to pull against          *;
*             |         |              |    Samp & Tst_Rslt_Summary instead of              *;
*             |         |              |    VW_Results Table.                               *;
*             |         |              |  - In %MACRO SCREENS, Added code for Product       *;
*             |         |              |    Release Screen options.                         *;
*             |         |              |  - In %MACRO QUERYSUM, Added code for              *;
*             |         |              |    Product Release Screen information.             *;
*-------------+---------+--------------+----------------------------------------------------*;
*  02/19/2003 |    3.0  | James Becker |  - In %MACRO SCREENS, Corrected error by           *;
*             |         |              |    removing TRIM function with both dates.         *;
*-------------+---------+--------------+----------------------------------------------------*;
*  02/26/2003 |    4.0  | James Becker |  - In %MACRO QUERYSUM, Modified Web Page           *;
*             |         |              |    message to state "a few" instead of "5"         *;
*             |         |              |    minutes.                                        *;
*-------------+---------+--------------+----------------------------------------------------*;
*  04/25/2003 |    5.0  | James Becker |  VCC25295 -                                        *;
*             |         |              |    - In %MACRO SCREENS, Added                      *;
*             |         |              |      Added STABILITY_STUDY_NBR_CD to               *;
*             |         |              |      create Study Number Selection screen and      *;
*             |         |              |      Lot Relationship section.                     *;
*-------------+---------+--------------+----------------------------------------------------*;
*  08/08/2003 |    6.0  | James Becker |  VCC25658 -                                        *;
*             |         |              |    - Replaced Lot_Nbr With Material_Nbr /          *;
*             |         |              |      Batch_Nbr in the following Macros:            *;
*             |         |              |      %MACRO SCREENS                                *;
*-------------+---------+--------------+----------------------------------------------------*;
*  02/10/2004 |    7.0  | James Becker |  VCC30154 - (Due to MERPS/SAP Change to Genealogy) *;
*             |         |              |    - %MACRO SCREENS                                *;
*             |         |              |      ADDED "AND (Prod_Matl_Nbr ^= Comp_Matl_Nbr)   *;
*             |         |              |      AND (Prod_Batch_Nbr ^= Comp_Batch_Nbr)"       *;
*-------------+---------+--------------+----------------------------------------------------*;
*  03/31/2004 |    8.0  | James Becker |  VCC31135 - Date Screen Modifications              *;
*             |         |              |    - %MACRO SCREENS                                *;
*             |         |              |      Modified Date Selection Screen                *;
*             |         |              |      Modified Item Description Macro Variable      *;
*-------------+---------+--------------+----------------------------------------------------*;
* 13-DEC-2005 |    9.0  | James Becker |  VCC43434 - Added GetResults section which submits *;
*             |         |              |      the query from LeMetadata SAS Datasets.       *;
*             |         |              |           - Added Strength Criteria option to      *;
*             |         |              |      Study Group screen.                           *;
*-------------------------------------------------------------------------------------------*;
* 24-May-2006 |  10.0   | Carol Hiser  |  VCC45936 - Added Product and Product Strength     *;
*             |         |              |             Screen to Stability and Product        *;
*             |         |              |             Strength Screen to Batch Trending.     *;
*             |         |              |           - Modified Study Group and Storage       *;
*             |         |              |             Condition screens to include study     *;
*             |         |              |             numbers in table, modified Test        *;
*             |         |              |             Method screen to include Product       *;
*             |         |              |             Names.                                 *;
*             |         |              |           - Modified Date Range screen             *;
*             |         |              |             to include text describing available   *;
*             |         |              |             data.                                  *;
*             |         |              |           - Modified Querysum screen to            *;
*             |         |              |             reflect actual data selected           *;
*             |         |              |             (instead of just user selections)      *;
*             |         |              |           - Modified code to read in individual    *;
*             |         |              |             product metadata datasets.             *;
*             |         |              |           - Removed datasets LRQueryRes_Specs      *;
*             |         |              |             and LRQueryRes_Relationship (data now  *;
*             |         |              |             included in metadata files)            *;
*-------------------------------------------------------------------------------------------*;
* 12Jun2006   |  11.0   | Carol Hiser  | VCC45936 - Revised code to reflect correct         *;
*             |         |              | parameters for Study Number Screen in Select All   *;        
*             |         |              | html form                                          *;
*             |         |              | Removed Advair flag so parameters dataset is       *;
*             |         |              | always created.                                    *;
*--------------------------------------------------------------------------------------------*;
* 23OCT2006   | 12.0    | Carol Hiser  | VCC55034 - Modified date sort and summary so min and *;
*             |         |              | max dates are chosen correctly on datescreen        *;
*********************************************************************************************;

		*** Execute GetParm ***;
		OPTIONS NOMPRINT MLOGIC NOSYMBOLGEN;
		%GetParm(SasServer, CtlDir, N);			%LET CtlDir     = &parm;
		%GetParm(SasServer, ServerName, N);		%LET ServerName = &parm;
		%GetParm(DbServer, ServerName, N);		%LET OraPath  = &parm;
		%GetParm(DbServer, SysOperId, N);		%LET OraId    = &parm;
		%GetParm(DbServer, SysOperPsw, Y);		%LET OraPsw   = &parm;
		%LET METHOD=GET;	
		libname OUTSRVE2 "&CtlDir.METADATA";

/*OPTIONS MPRINT MLOGIC SYMBOLGEN NOSOURCE2;*/
OPTIONS NUMBER NODATE MLOGIC MPRINT SYMBOLGEN SOURCE2 PAGENO=1 ERROR=2
	MERGENOBY=ERROR MAUTOSOURCE LINESIZE=120 NOCENTER PAGENO=1
	SPOOL COMPRESS=YES BLKSIZE=2560 MSGLEVEL=I MRECALL; 
%GLOBAL CONDCODE CTLDIR SAVE_USERROLE Save_UID     SAVE_RPTTYPE SAVE_LINKSHOME 
	STABILITY_STUDY_GRP_CD     STABILITY_STUDY_GRP_CD0     STABILITY_STUDY_GRP_CDQUERY     STABILITY_STUDY_GRP_CDQUERY2 
	STABILITY_STUDY_NBR_CD     STABILITY_STUDY_NBR_CD0     STABILITY_STUDY_NBR_CDQUERY     STABILITY_STUDY_NBR_CDQUERY2  
	STABILITY_SAMP_STOR_COND   STABILITY_SAMP_STOR_COND0   STABILITY_SAMP_STOR_CONDQUERY   STABILITY_SAMP_STOR_CONDQUERY2 
	LAB_TST_METH_SPEC_DESC     LAB_TST_METH_SPEC_DESC0     LAB_TST_METH_SPEC_DESCQUERY     LAB_TST_METH_SPEC_DESCQUERY2 
	STABILITY_SAMP_PRODUCT	   STABILITY_SAMP_PRODUCT0           STABILITY_SAMP_PRODUCTQUERY	       STABILITY_SAMP_PRODUCTQUERY2
	PROD_NM	   PROD_NM0       PRODnMQUERY	       PROD_NMQUERY2
	
	CREATE_START_DT		   CREATE_START_DT0	       CREATE_START_DTQUERY	       CREATE_START_DTQUERY2
	CREATE_END_DT		   CREATE_END_DT0	       CREATE_END_DTQUERY	       CREATE_END_DTQUERY2
	      
	STARTMONTH 		   STARTDAY 		       STARTYEAR				
	ENDMONTH 		   ENDDAY 		       ENDYEAR				
	MINYEAR			   MAXYEAR		       	       
	SAVE_CREATE_START_DT	   SAVE_CREATE_END_DT	       
	LIST_CREATE_START_DT	   LIST_CREATE_END_DT	       NODATA			       NODATAERR
	Save_Last_Update_Date	   Save_Last_Update_Time

	SAVE_STABILITY_STUDY_GRP_CD0 	 SAVE_STABILITY_STUDY_GRP_CDLST 
	SAVE_STABILITY_STUDY_NBR_CD0     SAVE_STABILITY_STUDY_NBR_CDLST 
	SAVE_STABILITY_SAMP_STOR_COND0   SAVE_STABILITY_SAMP_STOR_CONDLST 
	SAVE_LAB_TST_METH_SPEC_DESC0     SAVE_LAB_TST_METH_SPEC_DESCLST 
	SAVE_STABILITY_SAMP_PRODUCT0		 SAVE_STABILITY_SAMP_PRODUCTLST
	SAVE_PROD_NM0		 SAVE_PROD_NMLST
	SAVE_CREATE_START_DT0		 SAVE_CREATE_START_DTLST
	SAVE_CREATE_END_DT0		 SAVE_CREATE_END_DTLST
	SAVE_SUMQUERY0 			 SAVE_SUMQUERY_DTLST  SAVE_PRODUCTQUERY3  SAVE_ADVAIRCIFLAG
         HOME HELP Save_RptType Screenvar screenvar2 ScreenvarLast Screenvar STOP Save_NumItemLst Save_NumLst NumList
	OraId OraPsw OraPath METHOD Save_Home0 Home0 Home Save_Re_Home0 Re_Home0 Re_Home BUTTON BUTTON2 ;
*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SEE LINKS SDS                                           *;
*   REQUIREMENT:      SEE LINKS FRS                                           *;
*   INPUT:            Passed parameters: RptType, Uid, UserRole               *;
*   PROCESSING:       Copies values of passed				      *;
*                     parameters to Save_RptType, Save_Uid, Save_UserRole,    *;
*                     respectively. Sets value of MACRO variable ScreenVar as *;
*                     'STABILITY_STUDY_GRP_CD' and ScreenVarLast as 'HOME'.   *;
*		      Create variable SAVE_LINKSHOME based on value of 	      *;
*		      SAVE_USERROLE.					      *;
*   OUTPUT:           MACRO variables: Save_Uid, Save_UserRole, Save_RptType, *;
*                     ScreenVar, ScreenVarLast, Method, SAVE_LINKSHOME.       *;
*******************************************************************************;
%MACRO Init;
		%LET StartMonth=0;%LET StartDay=0;%LET StartYear=0;
		%LET EndMonth=0;  %LET EndDay=0;  %LET EndYear=0;
		%LET Save_RptType=&RptType;
		%LET SAVE_USERROLE=&USERROLE;
		%LET Save_UID=&Uid; 
		%IF &Save_RptType=ST %THEN %DO;
			%LET ScreenVar=PROD_NM;
			%LET ScreenVar2=PROD_NM;
			%LET ScreenVarLast=HOME;	
		%END;
		%IF &Save_RptType=RE %THEN %DO;
			%LET ScreenVar=PROD_NM;
			%LET ScreenVarLast=RE_HOME;	
		%END;
		%LET STARTMONTH=1;  %LET ENDMONTH=1;
		%LET STARTDAY=01;   %LET ENDDAY=01;
		%LET STARTYEAR=2002;%LET ENDYEAR=2002;

		%LET SAVE_LINKSHOME=USER_HOMEPAGE;
%MEND Init;
*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SEE LINKS SDS                                           *;
*   REQUIREMENT:      SEE LINKS FRS                                           *;
*   INPUT:            Saved Macro Variables:  Save_ScreenvarLast0,            *;
*                     ScreenvarLast1,...ScreenvarLast#.                       *;
*   PROCESSING:       Creates Macro Setup.  Obtains required parameters using *;
*		      the program GetParm.   Clears saved screen selections   *;
*                     of previous screen. The saved selections will be        *;
*                     regenerated.  This ensures correct parameters when the  *;
*                     user uses the back button.                              *;
*   OUTPUT:           Macro variables: CtlDir, ServerName, OraPath, OraID,    *;
*		      OraPSW, Saved Macro Variables set to Null:  	      *;
*                     Save_ScreenvarLast0,Save_ScreenvarLast1,...             *;
*******************************************************************************;
%MACRO Setup;
		%GLOBAL Save_STABILITY_SAMP_PRODUCT0 /*Save_Study_Group0 Save_Study0 Save_Storage0
			Save_Test0 Save_Item0 Save_Date0 */;
		%GLOBAL Query Query2 ScreenVarLast ;
	/*	%GLOBAL Save_STABILITY_SAMP_PRODUCTList Save_Study_GroupList Save_StudyList 
			Save_StorageList Save_TestList Save_ItemList Save_Date_List; */
		%LET METHOD=GET;	

		%LET ServerName = ;
		%LET CondCode   = 0;
		%LET Check1   = 0;
		%LET Check2   = 0;

		OPTIONS MPRINT MLOGIC SYMBOLGEN;
		
			DATA _NULL_;						*** Selection count of last screen variable ***;
				Count="&&Save_&ScreenVarLast.0"; 
				IF Count ^='' THEN CALL SYMPUT('Count', Count);
				              ELSE CALL SYMPUT('Count',0);
			RUN;

			%LOCAL i;
			%DO i = 1 %TO &Count; 					*** Clear saved screen parameters from prior screen ***;
				%GLOBAL Save_&ScreenVarLast.&i ;
				DATA _NULL_;
			 	   CALL SYMPUT("Save_&ScreenVarLast.&i", ' ');
				RUN;
			%END;

			DATA _NULL_;
				%GLOBAL Save_&ScreenVarLast.0 ;
				CALL SYMPUT("Save_&ScreenVarLast.0", ' ');
				CALL SYMPUT("SAVE_&SCREENVARLAST.LST",' ');
			RUN;

*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SEE LINKS SDS                                           *;
*   REQUIREMENT:      SEE LINKS FRS                                           *;
*   INPUT:            Macro variables: Screenvarlast0, ScreenvarLast,         *;
*                     ScreenvarLast1,...ScreenvarLast#.                       *;
*   PROCESSING:       If this is not the first screen, check to ensure that   *;
*                     at least one selection was made from the previous       *;
*                     screen. If not set the macro variable Stop to           *;
*                     'MESSAGE'.  Otherwise, save each selection to saved     *;
*                     macro variables. Also save the list as a comma          *;
*                     delimited list.       	                              *;
*   OUTPUT:           Save_ScreenvarLastLst, Save_ScreenvarLast0,             *;
*                     Save_ScreenvarLast1,Save_ScreenvarLast2,...             *;
*******************************************************************************;

			%IF %SUPERQ(&ScreenVarLast)=  AND %SUPERQ(SCREENVARLAST)^=HOME AND %SUPERQ(SCREENVARLAST)^=RE_HOME %THEN %LET STOP=MESSAGE;  	* Set flag for no selections made;
				
			
			%IF %SUPERQ(&SCREENVARLAST)^= ALL %THEN %DO;

			%IF %SUPERQ(&ScreenVarLast.0)= %THEN %DO; * Only one selection made;
				%GLOBAL &ScreenVarLast.0 &ScreenVarLast.1;
				DATA _NULL_; 
					CALL SYMPUT("&ScreenVarLast.0",1);
					CALL SYMPUT("&ScreenVarLast.1", SYMGET("&ScreenVarLast"));
				RUN;
			%END;
			%IF %SUPERQ(ScreenVarLast)=CREATE_START_DT %THEN %DO;  	* Set flag for no selections made;
				DATA _NULL_;  
					CALL SYMPUT("&ScreenVarLast.0",1);
					CALL SYMPUT("&ScreenVarLast.1", SYMGET("&ScreenVarLast"));
			 		CALL SYMPUT('Stop', ' ');
				RUN;
			%END;
			
			DATA _NULL_;   * Setup parameters from prior screen;
				CALL SYMPUT('Count2',SYMGET("&ScreenVarLast.0"));
				CALL SYMPUT("Save_&ScreenVarLast.0",SYMGET("&ScreenVarLast.0"));
				CALL SYMPUT("&ScreenVarLast.Sub1",'');
			RUN;

			%LOCAL i;
			DATA _NULL_;
				STOR_COND_FLAG='F';
				ADVAIRCIFLAG='F';
				%DO i = 1 %TO &Count2;
					IF SYMGET("&ScreenVarLast.&i") = "INT" THEN STOR_COND_FLAG='T';
					IF SYMGET("&ScreenVarLast.&i") = "HPLC Advair MDPl Cas. Impaction" THEN ADVAIRCIFLAG='T'; 
				%END;
				CALL SYMPUT('STOR_COND_FLAG',STOR_COND_FLAG);
				CALL SYMPUT('SAVE_ADVAIRCIFLAG', ADVAIRCIFLAG);
				*IF 	"&SCREENVARLAST" = "STABILITY_SAMP_STOR_COND" AND STOR_COND_FLAG='F' THEN 
					CALL SYMPUT("&ScreenVarLast.sub1", "^INT^ ,");
			RUN;

			%IF %SUPERQ(Stop)=  %THEN %DO;
			    %DO i = 1 %TO &Count2;  

				*Save prior screen parameters (individual and comma separated list);
				%GLOBAL Save_&ScreenVarLast.0 Save_&ScreenVarLast.&i ;
				DATA _NULL_;
					CALL SYMPUT("Save_&ScreenVarLast.&i",TRIM(SYMGET("&ScreenVarLast.&i")));
				RUN;

				DATA _NULL_;
					CALL SYMPUT("Save_&ScreenVarLast.lst", SYMGET("&ScreenVarLast.Sub1")||" ^"||left(TRIM(SYMGET("&ScreenVarLast.&i")))||"^ ");
				RUN;

				DATA _NULL_;
					i=&i;
					Count=&Count2;
					IF i < Count THEN CALL SYMPUT("&ScreenVarLast.sub1", TRIM(SYMGET("Save_&ScreenVarLast.lst"))||' ,');
				RUN; 
			     %END;
		        %END;
			%IF %SUPERQ(ScreenVarLast)=STABILITY_STUDY_NBR_CD %THEN %DO;
				DATA _NULL_;
					IF 	"&SCREENVARLAST" = "STABILITY_SAMP_STOR_COND" AND "&STOR_COND_FLAG"='F' THEN DO; 
						Count=&Count2+1;
						CALL SYMPUT("Save_&ScreenVarLast.0",Count);
                        	                PUT count;
					END;
				RUN;
			%END;
			%IF %SUPERQ(ScreenVarLast)=STABILITY_SAMP_STOR_COND %THEN %DO;
				DATA _NULL_;
					IF 	"&SCREENVARLAST" = "STABILITY_SAMP_STOR_COND" AND "&STOR_COND_FLAG"='F' THEN DO; 
						Count=&Count2 /*+1*/;
						CALL SYMPUT("Save_&ScreenVarLast.0",Count);
                        	                PUT count;
					END;
				RUN;
			%END;
			
		
**************************************************************************************;
*                       MODULE HEADER                                                *;
*------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SEE LINKS SDS                                           	     *;
*   REQUIREMENT:      SEE LINKS FRS                                                  *;
*   INPUT:            Macro variables:  Stop, ScreenvarLast, ScreenvarLastLst        *;
*		      Stability_Study_Nbr_CdQuery, Stability_Samp_Stor_CondQuery,    *;
*		      Stability_Study_Grp_CdQuery, Item_DescriptionQuery,            *;
*                     Create_Start_DtQuery, Create_End_DtQuery                       *;
*   PROCESSING:       Translate Query macros from '^' to single quotes.  Create	     *;
*		      query for current screen.					     *;
*   OUTPUT:           Macro variables:                                               *;
*                     Stability_Study_Grp_CdQuery,   Stability_Study_Grp_CdQuery2,   *;
*		      Stability_Study_Nbr_CdQuery,   Stability_Study_Nbr_CdQuery2,   *;
*                     Stability_Samp_Stor_CondQuery, Stability_Samp_Stor_CondQuery2, *;
*		      Item_DescriptionQuery,	     Item_DescriptionQuery2,  	     *;
*		      Create_Start_DtQuery,          Create_Start_DtQuery2,          *;
*		      Create_End_DtQuery,            Create_End_DtQuery2,            *;
**************************************************************************************;
	   
	%IF %SUPERQ(Save_RptType)=RE AND %SUPERQ(ScreenVarLast)=CREATE_START_DT AND %SUPERQ(ScreenVar)^=SUMQUERY %THEN %DO;
		DATA _NULL_; 
			STARTMONTH=&STARTMONTH;STARTDAY=&STARTDAY;STARTYEAR=&STARTYEAR;
			Start_Dt=DHMS(MDY(&STARTMONTH,&STARTDAY,&STARTYEAR),0,0,0);
			IF Start_Dt=. THEN CALL SYMPUT('NoDataErr','STARTERR');
			CALL SYMPUT('Save_Create_Start_Dt',Start_Dt);
			ENDMONTH=&ENDMONTH;ENDDAY=&ENDDAY;ENDYEAR=&ENDYEAR;
			End_Dt=DHMS(MDY(&ENDMONTH,&ENDDAY,&ENDYEAR),0,0,0);
			IF End_Dt=. THEN CALL SYMPUT('NoDataErr','ENDERR');
			CALL SYMPUT('Save_Create_End_Dt',End_Dt);
			IF Start_Dt=. AND End_Dt=. THEN CALL SYMPUT('NoDataErr','BOTHERR');
		RUN;
	%END;

		DATA _NULL_; LENGTH Query Query2 $2500;
		Stop="&Stop";
		ScreenVarLast="&ScreenVarLast";

		*** V2 - Added to create both date strings for query ***;
		%IF %SUPERQ(Stop)^= MESSAGE AND %SUPERQ(ScreenVarLast)=CREATE_START_DT %THEN %DO;
			Query= 'MATL_Mfg_Dt >= '||PUT(&Save_Create_Start_Dt,DATETIME19.)||"'DT"; 
			Query2=TRANWRD(TRIM(Query),'^',"'");
		        CALL SYMPUT("Create_Start_DtQuery",  TRIM(Query));
			CALL SYMPUT("Create_Start_DtQuery2", TRIM(Query2));
			Query= 'MATL_Mfg_Dt <= '||PUT(&Save_Create_End_Dt,DATETIME19.)||"'DT"; 
			Query2=TRANWRD(TRIM(Query),'^',"'");
		     	CALL SYMPUT("Create_End_DtQuery",  TRIM(Query));
			CALL SYMPUT("Create_End_DtQuery2", TRIM(Query2)); 

		  
		%END;
		%ELSE %IF %SUPERQ(Stop) ^= MESSAGE AND %SUPERQ(ScreenVarLast)^=HOME AND %SUPERQ(ScreenVarLast)^=RE_HOME %THEN %DO;
				Query = SYMGET('ScreenVarLast')||' in ('||TRIM(SYMGET("Save_&ScreenVarLast.lst"))||')'; 
				Query2=TRANWRD(TRIM(QUERY),'^',"'");
		
				%IF %SUPERQ(SCREENVARLAST)^=STABILITY_SAMP_PRODUCT %THEN %DO;
				CALL SYMPUT("&ScreenVarLast.Query",  TRIM(Query)||' AND ');
			    CALL SYMPUT("&ScreenVarLast.Query2", TRIM(Query2)||' AND ');
				%END;
				%ELSE %DO;
				CALL SYMPUT("&ScreenVarLast.Query",  TRIM(Query));
			    CALL SYMPUT("&ScreenVarLast.Query2", TRIM(Query2));
				%END;
		%END;
		%ELSE %DO;
			CALL SYMPUT("&ScreenVarLast.Query",' ');
			CALL SYMPUT("&ScreenVarLast.Query2",' ');
		%END;

	RUN;
%END;

DATA _NULL_;
		STABILITY_STUDY_GRP_CDQUERY=TRANWRD("&STABILITY_STUDY_GRP_CDQUERY",'$',"%");
		CALL SYMPUT('STABILITY_STUDY_GRP_CDQUERY2',  TRANWRD(STABILITY_STUDY_GRP_CDQUERY,'^',"'"));
		
		STABILITY_STUDY_NBR_CDQUERY=TRANWRD("&STABILITY_STUDY_NBR_CDQUERY",'$',"%");
		CALL SYMPUT('STABILITY_STUDY_NBR_CDQUERY2',  TRANWRD(STABILITY_STUDY_NBR_CDQUERY,'^',"'"));
		

		CALL SYMPUT('STABILITY_SAMP_STOR_CONDQUERY2',TRANWRD("&STABILITY_SAMP_STOR_CONDQUERY",'^',"'"));
		CALL SYMPUT('PROD_NMQUERY2'        ,TRANWRD("&PROD_NMQUERY",'^',"'"));		*** Added V2 ***;
		CALL SYMPUT('STABILITY_SAMP_PRODUCTQUERY2'        ,TRANWRD("&STABILITY_SAMP_PRODUCTQUERY",'^',"'"));		*** Added V2 ***;
		CALL SYMPUT('CREATE_START_DTQUERY2'         ,TRANWRD("&CREATE_START_DTQUERY",'^',"'"));			*** Added V2 ***;
		CALL SYMPUT('CREATE_END_DTQUERY2'           ,TRANWRD("&CREATE_END_DTQUERY",'^',"'"));			*** Added V2 ***;
		ScreenVarLast="&ScreenVarLast";
		ScreenVarLast=TRANWRD(ScreenVarLast,'$','%');
		CALL SYMPUT("&ScreenVarLast.2",  TRANWRD(ScreenVarLast,'^',"'"));
	RUN;

%GLOBAL STABILITY_SAMP_PRODUCTQUERY3;
		%IF %SUPERQ(SCREENVARLAST)=STABILITY_SAMP_PRODUCT %THEN %DO;
		DATA _NULL_;
			QUERY2="&STABILITY_SAMP_PRODUCTQUERY";
			IF QUERY2 ^= '' THEN 
			CALL SYMPUT('SAVE_PRODUCTQUERY3', TRANWRD(TRIM(qUERY2),'^',"'"));
			ELSE
			CALL SYMPUT('SAVE_PRODUCTQUERY3', TRANWRD(TRIM(TRANWRD("&PROD_NMQUERY", ' AND ', ' ')),'^',"'"));
			RUN;
		%END;  


%IF %SUPERQ(SCREENVAR)^=LAB_TST_METH_SPEC_DESC %THEN %DO; %LET BUTTON = Next;  %LET BUTTON2=Select All; %END;
%ELSE %DO; %LET BUTTON = Submit Query; %LET BUTTON2=Select All and Submit Query; %END;

%MEND Setup;
*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SEE LINKS SDS                                           *;
*   REQUIREMENT:      SEE LINKS FRS                                           *;
*   INPUT:            Macro variables: ScreenVar, OraID, OraPath, OraPSW.     *;
*   PROCESSING:       Setup required query parameters and specific HTML code  *;	
*		      for each screen.  Query the database to obtain screen   *;
*		      data and lot relationship data.		  	      *;
*   OUTPUT:           SAS Datasets: LRQuery01a, SAVE_LRQuery01a   	      *;
*******************************************************************************;
%MACRO Screens;

		%GLOBAL /* save_Screenvar */ Droplist1 Droplist2 Header1 Header2 Header3 WIDTH CHECKED ; 

		
		DATA _NULL_;
			ScreenVar="&ScreenVar";
			SaveRptType="&Save_RptType"; 
			CALL SYMPUT('TblJoin', ' ');	                   *** Added   V2 - FOR JOINING TABLES (BLANK EXCEPT FOR "LAB_TST_METH_SPEC_DESC" QUERY) ***;
			%IF %SUPERQ(ScreenVar)=STABILITY_STUDY_GRP_CD %THEN %DO;
				CALL SYMPUT('ByVar', 'Stability_Study_Grp_Cd Stability_Study_Nbr_Cd Stability_Study_Purpose_Txt '); 
				CALL SYMPUT('Header1', "<TR BGCOLOR=#C0C0C0><TD colspan=2><FONT FACE=arial SIZE=2><STRONG>Study Group</STRONG></FONT></TD><TD><FONT FACE=arial SIZE=2><STRONG>Product(s)</STRONG></FONT></TD>");
				CALL SYMPUT('Header2', "<TD><FONT FACE=arial SIZE=2><STRONG>Study(s)</STRONG></FONT></TD></TR>");
				CALL SYMPUT('Droplist1', '"<TD WIDTH=10% ALIGN=left><FONT FACE=arial SIZE=2><STRONG>"||TRIM(Stability_Study_Grp_Cd)||"</STRONG></FONT></TD><TD><FONT FACE=arial SIZE=2>"');
				CALL SYMPUT('Droplist2', "TRIM(LEFT(PRODLIST))||'</FONT></TD><TD ><FONT FACE=arial SIZE=2>'||TRIM(LEFT(StudyList))||'</FONT></TD></TR>'");
				CALL SYMPUT('Droplist3', '"<!>"');
				CALL SYMPUT('Droplist4', '"<!>"');
				CALL SYMPUT('WIDTH','WIDTH=90%');
				CALL SYMPUT('TblName', ' ');
				CALL SYMPUT('DefWhere', 'WHERE=(&SAVE_PRODUCTQUERY3) ');
   			%END; 
		   	%IF %SUPERQ(ScreenVar)=STABILITY_STUDY_NBR_CD %THEN %DO; 
				CALL SYMPUT('ByVar', 'Stability_Study_Grp_Cd Stability_Study_Nbr_Cd Stability_Study_Purpose_Txt ');
				CALL SYMPUT('Header1', "<TR BGCOLOR=#C0C0C0><TD colspan=2><FONT FACE=arial SIZE=2><STRONG>Study Number</STRONG></FONT></TD><TD><FONT FACE=arial SIZE=2><STRONG>Product Description</STRONG></FONT></TD>");
				CALL SYMPUT('Header2', "<TD><FONT FACE=arial SIZE=2><STRONG>Purpose</STRONG></FONT></TD></TR>");
				CALL SYMPUT('Droplist1', '"<TD WIDTH=10% ALIGN=left><FONT FACE=arial SIZE=2><STRONG>"||TRIM(Stability_Study_Nbr_Cd)||"</STRONG></FONT></TD>"');
				CALL SYMPUT('Droplist2', '"<TD><FONT FACE=arial SIZE=2>"||LEFT(TRIM(stability_samp_product))||"</FONT></TD><TD>"')	;		
				CALL SYMPUT('Droplist3', '"<FONT FACE=arial SIZE=2>"||LEFT(TRIM(Stability_Study_Purpose_Txt))||"</FONT></TD></TR>"');
				CALL SYMPUT('Droplist4', '"<!>"');
				CALL SYMPUT('WIDTH','WIDTH=85%');
				CALL SYMPUT('DefWhere', 'WHERE=(&STABILITY_STUDY_GRP_CDQUERY2 &SAVE_PRODUCTQUERY3)');
	   		%END;
			%IF %SUPERQ(ScreenVar)=STABILITY_SAMP_STOR_COND %THEN %DO;
				CALL SYMPUT('ByVar', 'Stability_Study_Grp_Cd Stability_Study_Nbr_Cd Stability_Samp_Stor_Cond');
				CALL SYMPUT('Header1', "<TR BGCOLOR=#C0C0C0><TD colspan=2><FONT FACE=arial SIZE=2><STRONG>Storage Condition</STRONG></FONT></TD>");
				CALL SYMPUT('Header2', "<TD><FONT FACE=arial SIZE=2><STRONG>Study</STRONG></FONT></TD></TR>");
				CALL SYMPUT('Droplist1', '"<TD WIDTH=10% ALIGN=left><FONT FACE=arial SIZE=2><STRONG>"||TRIM(Stability_Samp_Stor_Cond)||"</STRONG></FONT></TD>"');
				CALL SYMPUT('Droplist2', '"<TD WIDTH=10% ALIGN=left><FONT FACE=arial SIZE=2><STRONG>"||TRIM(StudyLIST)||"</STRONG></FONT></TD></TR>"')	;		
				CALL SYMPUT('Droplist3', '"<!>"');
				CALL SYMPUT('Droplist4', '"<!>"');
				CALL SYMPUT('WIDTH','WIDTH=45%');
				CALL SYMPUT('DefWhere', 'WHERE=(&STABILITY_STUDY_GRP_CDQUERY2 &STABILITY_STUDY_NBR_CDQUERY2 &SAVE_PRODUCTQUERY3)');
				
			%END;
			%IF %SUPERQ(ScreenVar)=LAB_TST_METH_SPEC_DESC AND %SUPERQ(Save_RptType)=ST %THEN %DO;
				CALL SYMPUT('ByVar', 'STABILITY_SAMP_PRODUCT Lab_Tst_Meth_Spec_Desc Stability_Study_Grp_Cd Stability_Study_Nbr_Cd Stability_Samp_Stor_Cond ');
				CALL SYMPUT('Header1', "<TR BGCOLOR=#C0C0C0><TD colspan=2><FONT FACE=arial SIZE=2><STRONG>Test Method</STRONG></FONT></TD>");
				CALL SYMPUT('Header2', "<TD><FONT FACE=arial SIZE=2><STRONG>Product</STRONG></FONT></TD></TR>");
				CALL SYMPUT('Droplist1', '"<TD WIDTH=10% ALIGN=left><FONT FACE=arial SIZE=2><STRONG>"||TRIM(Lab_Tst_Meth_Spec_Desc)||"</STRONG></FONT></TD>"');
				CALL SYMPUT('Droplist2', '"<TD WIDTH=10% ALIGN=left><FONT FACE=arial SIZE=2><STRONG>"||TRIM(PRODLIST)||"</STRONG></FONT></TD></TR>"')	;		
				CALL SYMPUT('Droplist3', '"<!>"');
				CALL SYMPUT('Droplist4', '"<!>"');  

				CALL SYMPUT('WIDTH','WIDTH=45%');
				CALL SYMPUT('DefWhere', 'WHERE=(&STABILITY_STUDY_GRP_CDQUERY2 &STABILITY_STUDY_NBR_CDQUERY2 &STABILITY_SAMP_STOR_CONDQUERY2 &SAVE_PRODUCTQUERY3)');
				%END;

			**************************************************;
			*** Added V2 - PRODUCT RELEASE OPTION SECTION  ***;
			**************************************************;
			%IF %SUPERQ(ScreenVar)=PROD_NM %THEN %DO;   /* Added V10 */
				CALL SYMPUT('ByVar', 'STABILITY_SAMP_PRODUCT');
				CALL SYMPUT('Header1', "<TR BGCOLOR=#C0C0C0><TD colspan=2><FONT FACE=arial SIZE=2><STRONG>Product</STRONG></FONT></TD></TR>");
				CALL SYMPUT('Droplist1', '"<TD WIDTH=20% ALIGN=left><FONT FACE=arial SIZE=2><STRONG>"||PROD_NM||"</STRONG></FONT></TD></TR>"');
				CALL SYMPUT('Droplist2', '"<!>"');
				CALL SYMPUT('Droplist3', '"<!>"');
				CALL SYMPUT('Droplist4', '"<!>"');
				CALL SYMPUT('WIDTH','WIDTH=45%');
				CALL SYMPUT('DefWhere', "WHERE= (PROD_NM ^= '' )");
			%END;

			%IF %SUPERQ(ScreenVar)=STABILITY_SAMP_PRODUCT %THEN %DO;  /*Added V10 */
				CALL SYMPUT('ByVar', 'STABILITY_SAMP_PRODUCT');
				CALL SYMPUT('Header1', "<TR BGCOLOR=#C0C0C0><TD colspan=2><FONT FACE=arial SIZE=2><STRONG>Product</STRONG></FONT></TD></TR>");
				CALL SYMPUT('Droplist1', '"<TD WIDTH=20% ALIGN=left><FONT FACE=arial SIZE=2><STRONG>"||STABILITY_SAMP_PRODUCT||"</STRONG></FONT></TD></TR>"');
				CALL SYMPUT('Droplist2', '"<!>"');
				CALL SYMPUT('Droplist3', '"<!>"');
				CALL SYMPUT('Droplist4', '"<!>"');
				CALL SYMPUT('WIDTH','WIDTH=45%');
				CALL SYMPUT('DefWhere', "WHERE=(&PROD_NMQUERY2 STABILITY_SAMP_PRODUCT ^= '' )");
			%END;

			%IF %SUPERQ(ScreenVar)=CREATE_START_DT %THEN %DO;
				CALL SYMPUT('ByVar', 'Matl_Mfg_Dt');
				CALL SYMPUT('Header4', "<TR BGCOLOR=#C0C0C0><TD colspan=2><FONT FACE=arial SIZE=2><STRONG>Start Date</STRONG></FONT></TD>");
				CALL SYMPUT('Header4', "<TR BGCOLOR=#C0C0C0><TD colspan=2><FONT FACE=arial SIZE=2><STRONG>End Date</STRONG></FONT></TD>");
				CALL SYMPUT('Droplist1', '"<TD WIDTH=20% ALIGN=left><FONT FACE=arial SIZE=2><STRONG>"||put(mdy(01,01,Create_START_DT),worddate20.)||"</STRONG></FONT></TD></TR>"');
				CALL SYMPUT('Droplist2', '"<TD WIDTH=20% ALIGN=left><FONT FACE=arial SIZE=2><STRONG>"||put(mdy(12,31,Create_END_DT),worddate20.)||"</STRONG></FONT></TD></TR>"');
				CALL SYMPUT('Droplist3', '"<!>"');
				CALL SYMPUT('Droplist4', '"<!>"');
				CALL SYMPUT('WIDTH','WIDTH=25%');
				CALL SYMPUT('DefWhere', "WHERE =(&SAVE_PRODUCTQUERY3) ");
				
			%END;
			%IF %SUPERQ(ScreenVar)=LAB_TST_METH_SPEC_DESC AND %SUPERQ(Save_RptType)=RE %THEN %DO; /* Modified V10 */
				CALL SYMPUT('ByVar', 'PROD_NM STABILITY_SAMP_PRODUCT Lab_Tst_Meth_Spec_Desc');
				CALL SYMPUT('Header1', "<TR BGCOLOR=#C0C0C0><TD colspan=2><FONT FACE=arial SIZE=2><STRONG>Test Method</STRONG></FONT></TD>");
				CALL SYMPUT('Header2', "<TD><FONT FACE=arial SIZE=2><STRONG>Product</STRONG></FONT></TD></TR>");
				CALL SYMPUT('Droplist1', '"<TD WIDTH=10% ALIGN=left><FONT FACE=arial SIZE=2><STRONG>"||TRIM(Lab_Tst_Meth_Spec_Desc)||"</STRONG></FONT></TD>"');
				CALL SYMPUT('Droplist2', '"<TD WIDTH=10% ALIGN=left><FONT FACE=arial SIZE=2><STRONG>"||TRIM(PRODLIST)||"</STRONG></FONT></TD></TR>"')	;		
				CALL SYMPUT('Droplist3', '"<!>"');
				CALL SYMPUT('Droplist4', '"<!>"');

				CALL SYMPUT('WIDTH','WIDTH=45%');
				CALL SYMPUT('DefWhere', 'WHERE= (&SAVE_PRODUCTQUERY3)');
				CALL SYMPUT('Create_Start_DtQuery',"Matl_Mfg_Dt >='"||PUT(&SAVE_CREATE_START_DT,DATETIME19.)||"'DT");
				CALL SYMPUT('Create_End_DtQuery'  ,"Matl_Mfg_Dt <='"||PUT(&SAVE_CREATE_END_DT,DATETIME19.)||"'DT");
			%END;

			
		RUN;

%IF %SUPERQ(SCREENVAR)^=PROD_NM %THEN %DO;  /* Added V10 Delete Save.LRQuery01a to ensure accurate dataset is created for each screen */
proc datasets LIBRARY=SAVE;
delete lrquery01a ;
run;
%END; 

%IF %SUPERQ(SCREENVAR)=CREATE_START_DT %THEN %DO;  /* Added V10 */

	   PROC SORT DATA=OUTSRVE2.LEMETADATA_REPRODUCTLIST /* NODUPKEY removed V12.0*/ OUT=SAVE.LRQUERY01A(&DEFWHERE);
	   BY PROD_NM STABILITY_SAMP_PRODUCT ;
	   RUN;

	   DATA save.LRQuery01a;SET save.lrquery01a;
				CREATE_START_DT=MIN_MFG_DT;
		RUN;  

		PROC SUMMARY DATA=save.LRQUERY01A;
			VAR MIN_MFG_DT MAX_MFG_DT;
			BY PROD_NM STABILITY_SAMP_PRODUCT ;  /* Added by line V12.0  */
			OUTPUT OUT=DATEOUT 
			MIN(MIN_MFG_DT)=MINDATE 
			MAX(MAX_MFG_DT)=MAXDATE;
		RUN;  

		PROC SUMMARY DATA=DATEOUT;  /* Added V12.0  */
			VAR MINDATE MAXDATE;
			OUTPUT OUT=DATEOUT2 
			MIN(MINDATE)=MINDATE 
			MAX(MAXDATE)=MAXDATE;
		RUN;  
		%END;

%ELSE %DO;  /*Added V10 */
		
		
		PROC SORT DATA=OUTSRVE2.LeMetaData_&SAVE_RPTTYPE.PRODUCTList  NODUPKEY  OUT=save.LRQUERY01A(&defwhere); BY &BYVAR; RUN;

		DATA _NULL_; SET SAVE.LRQUERY01A;
		PUT STABILITY_STUDY_GRP_CD STABILITY_STUDY_NBR_CD STABILITY_SAMP_STOR_COND LAB_TST_METH_SPEC_DESC;
		RUN;
		
		%END;
	
		%IF %SUPERQ(SCREENVAR)=STABILITY_SAMP_STOR_COND %THEN %DO;
			DATA save.lrquery01a;SET save.lrquery01a(WHERE=(STABILITY_SAMP_STOR_COND IS NOT NULL));RUN;
		%END;

		%IF %SUPERQ(SCREENVAR)=STABILITY_SAMP_PRODUCT %THEN %DO;
			PROC SORT DATA=save.lrquery01a OUT=ItemLst NODUPKEY; BY STABILITY_SAMP_PRODUCT; RUN;

			PROC SORT DATA=save.lrquery01a OUT=LRQuery01x NODUPKEY; BY STABILITY_SAMP_PRODUCT; RUN;
			DATA Save.ItemLst;SET LRQuery01x;
				CALL SYMPUT('Save_NumItemLst',put(_n_,4.));
			RUN;
			PROC SORT DATA=save.lrquery01a NODUPKEY; BY STABILITY_SAMP_PRODUCT; RUN;
			DATA NumLst;SET save.lrquery01a;
				CALL SYMPUT('Save_NumLst',put(_n_,4.));
			RUN;

		%END;
		*** V2 - Added to retrieve unique dates for start and end date ***;

		%IF %SUPERQ(SCREENVAR)=PROD_STR %THEN %DO;

		DATA save.lrquery01a; LENGTH STABILITY_SAMP_PRODUCT $50; RUN;

		%DO Loop = 1 %TO &Save_STABILITY_SAMP_PRODUCT0;
			PROC FREQ DATA='OUTSRVE2.LEMETADATA_'||COMPRESS(LEFT("&&SAVE_STABILITY_SAMP_PRODUCT&LOOP")) NOPRINT;
			TABLE STABILITY_SAMP_STABILITY_SAMP_PRODUCT/OUT=STR&LOOP;
			
			DATA save.lrquery01a; SET save.lrquery01a STR&LOOP; KEEP STABILITY_SAMP_STABILITY_SAMP_PRODUCT;
			RUN;

		%END; 
		%END;

		%IF %SUPERQ(SCREENVAR)=CREATE_START_DT %THEN %DO;
			
			DATA _NULL_;SET DATEOUT2;  /* Modified V12.0 */
				PUT _ALL_;
				MINDATE=DATEPART(MINDATE);
				MAXDATE=DATEPART(MAXDATE);
				MINYEAR=YEAR(MINDATE);
				CALL SYMPUT('MINYEAR',MINYEAR);
				STARTMONTH=MONTH(MINDATE);	CALL SYMPUT('STARTMONTH',STARTMONTH);
				STARTDAY=DAY(MINDATE);		CALL SYMPUT('STARTDAY',STARTDAY);
				STARTYEAR=YEAR(MINDATE);	CALL SYMPUT('STARTYEAR',STARTYEAR);
				MINDATE2=DHMS(MINDATE,0,0,0);
				CALL SYMPUT('SAVE_CREATE_START_DT',MINDATE2);
			        CALL SYMPUT('Create_Start_DtQuery',"Matl_Mfg_Dt >='"||PUT(MINDATE2,DATETIME19.)||"'DT");

				MAXYEAR=YEAR(MAXDATE);
				CALL SYMPUT('MAXYEAR',MAXYEAR);
				ENDMONTH=MONTH(MAXDATE);	CALL SYMPUT('ENDMONTH',ENDMONTH);
				ENDDAY=DAY(MAXDATE);		CALL SYMPUT('ENDDAY',ENDDAY);
				ENDYEAR=YEAR(MAXDATE);		CALL SYMPUT('ENDYEAR',ENDYEAR);
				MAXDATE2=DHMS(MAXDATE,23,59,59);
				CALL SYMPUT('SAVE_CREATE_END_DT',MAXDATE2);
				CALL SYMPUT('Create_End_DtQuery'  ,"Matl_Mfg_Dt <='"||PUT(MAXDATE2,DATETIME19.)||"'DT");
			RUN;
		%END;

		%IF %SUPERQ(SCREENVAR)=LAB_TST_METH_SPEC_DESC AND %SUPERQ(Save_RptType)=RE %THEN %DO;
			%LET NoData=0;

			%IF (%SUPERQ(Save_Create_Start_Dt) LT %SUPERQ(Save_Create_End_Dt))
			OR   %SUPERQ(NoDataErr)^=STARTERR OR %SUPERQ(NoDataErr)^=ENDERR OR %SUPERQ(NoDataErr)^=BOTHERR 
			%THEN %DO;
			DATA save.lrquery01a;SET save.lrquery01a NOBS=MaxObs;
					*IF &Create_Start_DtQuery AND &Create_End_DtQuery;
					CALL SYMPUT('NoData',MaxObs); 
				RUN; 
			%END;
		%END;

	%IF %SUPERQ(NoDataErr)=STARTERR OR %SUPERQ(NoDataErr)=ENDERR OR %SUPERQ(NoDataErr)=BOTHERR %THEN %DO; %NoData; %END;

	%ELSE %IF %SUPERQ(Save_Create_End_Dt) LT %SUPERQ(Save_Create_Start_Dt) %THEN %DO; %LET NoDataErr=ENDSTART; %NoData; %END;

	%ELSE %IF %SUPERQ(NoData)=0 %THEN %DO; %LET NoDataErr=NODATA; %NoData; %END;
	
		
*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SEE LINKS SDS                                           *;
*   REQUIREMENT:      SEE LINKS FRS                                           *;
*   INPUT:            SAS dataset: LRQuery01A                                 *;
*   PROCESSING:       Setup dataset for creating checkbox list.		      *;
*   OUTPUT:           Macro variable: NumList, SAS dataset:  DATALIST1        *;
*******************************************************************************;

		%IF %SUPERQ(ScreenVar)^=SUMQUERY %THEN %DO;

		%IF %SUPERQ(ScreenVar)=STABILITY_STUDY_GRP_CD %THEN %DO;
				PROC SORT DATA=save.lrquery01a NODUPKEY OUT=STABILITY_SAMP_PRODUCTS; 
					BY STABILITY_STUDY_GRP_CD stability_samp_product; RUN;

				DATA DataList0a; LENGTH ProdList $1000;
					SET STABILITY_SAMP_PRODUCTS; BY STABILITY_STUDY_GRP_CD;
					RETAIN ProdList ;
					
					PKG_LOT_DESC=stability_samp_product;
					IF FIRST.STABILITY_STUDY_GRP_CD THEN DO;
						ProdList = TRIM(PKG_LOT_DESC);
						END;
					ELSE DO;
						IF PKG_LOT_DESC ^= '' THEN ProdList = TRIM(ProdList)||', '||TRIM(LEFT(PKG_LOT_DESC));
						put stability_study_grp_cd pkg_lot_desc prodlist;
					    END;
						
					IF LAST.STABILITY_STUDY_GRP_CD THEN DO;
						IF SUBSTR(TRIM(LEFT(ProdList)),1,1)=',' THEN ProdList=SUBSTR(TRIM(LEFT(ProdList)),2);
						OUTPUT;
					END;				
				RUN;

				PROC SORT DATA=save.lrquery01a NODUPKEY OUT=STUDYDESC; 
					BY STABILITY_STUDY_GRP_CD STABILITY_STUDY_NBR_CD STABILITY_STUDY_PURPOSE_TXT; RUN;

				DATA DataList0b; LENGTH StudyList $1000;
					SET STUDYDESC; BY STABILITY_STUDY_GRP_CD;
					RETAIN StudyList;
					IF FIRST.STABILITY_STUDY_GRP_CD THEN StudyList = TRIM(STABILITY_STUDY_NBR_CD)||' ('||LEFT(TRIM(STABILITY_STUDY_PURPOSE_TXT))||')'; 
					ELSE StudyList = TRIM(STUDYLIST)||', '||TRIM(STABILITY_STUDY_NBR_CD)||' ('||TRIM(STABILITY_STUDY_PURPOSE_TXT)||')'; 

					IF LAST.STABILITY_STUDY_GRP_CD THEN OUTPUT;
				RUN;

				DATA DataList0c; MERGE DATALIST0A DATALIST0B; BY STABILITY_STUDY_GRP_CD; RUN;

				DATA DataList1; SET DataList0c NOBS=MaxObs;
					RETAIN ObsNum 0 ;
					ObsNum = ObsNum + 1;
					IF PRODLIST ='' THEN PRODLIST='Not Available';
					CALL SYMPUT('NumList', MaxObs);
				RUN;

			%END;

			%ELSE %IF %SUPERQ(SCREENVAR)=LAB_TST_METH_SPEC_DESC %THEN %DO;

				PROC SORT DATA=save.lrquery01a NODUPKEY OUT=TESTS_PRODUCTS; 
					BY  LAB_TST_METH_SPEC_DESC PROD_NM; RUN;

				DATA DataList0a; LENGTH ProdList $1000;
					SET TESTS_PRODUCTS; BY LAB_TST_METH_SPEC_DESC;
					RETAIN ProdList ;
					
					IF FIRST.LAB_TST_METH_SPEC_DESC THEN ProdList = TRIM(PROD_NM);
					ELSE IF PROD_NM ^= '' THEN ProdList = TRIM(ProdList)||', '||TRIM(LEFT(PROD_NM));
						
					IF LAST.LAB_TST_METH_SPEC_DESC THEN DO;
						IF SUBSTR(TRIM(LEFT(ProdList)),1,1)=',' THEN ProdList=SUBSTR(TRIM(LEFT(ProdList)),2);
						OUTPUT;
					END;				
				RUN;

				DATA DataList1; SET DataList0A NOBS=MaxObs;
					RETAIN ObsNum 0 ;
					ObsNum = ObsNum + 1;
					put lab_tst_meth_spec_desc prodlist;
					IF PRODLIST ='' THEN PRODLIST='Not Available';
					CALL SYMPUT('NumList', MaxObs);
				RUN;
				%END;

				%ELSE %IF %SUPERQ(SCREENVAR)=STABILITY_SAMP_STOR_COND %THEN %DO;

				PROC SORT DATA=save.lrquery01a NODUPKEY OUT=COND_STUDIES; 
					BY  STABILITY_SAMP_STOR_COND STABILITY_STUDY_NBR_CD; RUN;

				DATA DataList0a; LENGTH STUDYList $1000;
					SET COND_STUDIES; BY STABILITY_SAMP_STOR_COND;
					RETAIN STUDYList ;
					
					IF FIRST.STABILITY_SAMP_STOR_COND THEN STUDYList = TRIM(STABILITY_STUDY_NBR_CD);
					ELSE IF STABILITY_STUDY_NBR_CD ^= '' THEN STUDYList = TRIM(STUDYList)||', '||TRIM(LEFT(STABILITY_STUDY_NBR_CD));
						
					IF LAST.STABILITY_SAMP_STOR_COND THEN DO;
						IF SUBSTR(TRIM(LEFT(STUDYList)),1,1)=',' THEN STUDYList=SUBSTR(TRIM(LEFT(STUDYList)),2);
						OUTPUT;
					END;				
				RUN;

				DATA DataList1; SET DataList0A NOBS=MaxObs;
					RETAIN ObsNum 0 ;
					ObsNum = ObsNum + 1;
					CALL SYMPUT('NumList', MaxObs);
				RUN;
				%END;


			%ELSE %DO;

				 DATA save.lrquery01a;SET save.lrquery01a; IF INDEX(STABILITY_SAMP_STOR_COND,'INT')>0 THEN STABILITY_SAMP_STOR_COND='INT'; RUN; 
					
				 
				PROC SORT DATA=save.lrquery01a NODUPKEY OUT=DATALIST0; BY &SCREENVAR; RUN;  
				DATA DataList1;LENGTH Blend_Nbr_List $200; 
					SET DATALIST0 NOBS=MaxObs;
					RETAIN ObsNum 0;
					ObsNum = ObsNum + 1;
					IF Blend_Nbr ='' THEN Blend_Nbr_List='Not Available';
							 ELSE Blend_Nbr_List=Blend_Nbr;
					OUTPUT;
					CALL SYMPUT('NumList', MaxObs);
				RUN;

			%END;

			
		%END;

			

*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SEE LINKS SDS                                           *;
*   REQUIREMENT:      SEE LINKS FRS                                           *;
*   INPUT:            Macro variables Screenvar, _Server, _Port, _SessionId,  *;
*                     _Program, _Service, ScreenvarLast,		      *;
*		      Stability_Study_Grp_CDQuery,Stability_Study_Nbr_CdQuery,*;
*		      Stability_Samp_Stor_CondQuery, Item_DescriptionQuery,   *;
*                     Create_Start_DtQuery, Create_End_DtQuery.               *;
*   PROCESSING:       Sets up html code for background color, window title,   *;
*                     and passed parameters.  Setup macro variable Screenvar2 *;
*                     for screen title.                                       *;
*   OUTPUT:           HTML code to browser (File _webout), Macro variable     *;
*                     Screenvar2.                                             *;
*******************************************************************************;

		DATA _NULL_;
			LENGTH LINE $2000;
			FILE _WEBOUT;
			ScreenVar="&ScreenVar";
			SaveRptType="&Save_RptType"; 
			
			PUT   '<BODY BGCOLOR="#808080">';
			IF SaveRptType='ST' THEN PUT   '<TITLE>LINKS Stability Module</TITLE>'; 
			IF SaveRptType='RE' THEN PUT   '<TITLE>LINKS Batch Trending Module</TITLE>'; 
			LINE = '<FORM METHOD='||"&METHOD"||' ACTION="'||"&_url"||'">'; PUT LINE;
			PUT   '<INPUT TYPE="hidden" NAME="_service"      	VALUE="default">';
			LINE = '<INPUT TYPE="hidden" NAME="_program"      	VALUE="'||"LINKS.LRQuery.sas"||'">'; 	PUT LINE;
			LINE = '<INPUT TYPE="hidden" NAME="_server" 		VALUE="'||SYMGET('_server')||'">';	PUT LINE;
			LINE = '<INPUT TYPE="hidden" NAME="_port" 		VALUE="'||SYMGET('_port')||'">';       	PUT LINE;
			LINE = '<INPUT TYPE="hidden" NAME="_sessionid"    	VALUE="'||SYMGET('_sessionid')||'">';  	PUT LINE;
			LINE = '<INPUT TYPE="hidden" NAME="ScreenvarLast" 	VALUE="'||SYMGET('Screenvar')||'">';   	PUT LINE;
			LINE = '<INPUT TYPE="hidden" NAME="NoData" 		VALUE="'||SYMGET('NoData')||'">';   	PUT LINE;
	  		*LINE=   '<INPUT TYPE=hidden   NAME=_debug       VALUE="0">';				*PUT LINE;
			IF SAVERPTTYPE='ST' THEN DO;
			LINE = '<INPUT TYPE="hidden" NAME="STABILITY_STUDY_GRP_CDQuery"   
				VALUE="'||SYMGET('STABILITY_STUDY_GRP_CDQuery')||'">';	     			PUT LINE;
	  		LINE = '<INPUT TYPE="hidden" NAME="STABILITY_STUDY_NBR_CDQuery"   
				VALUE="'||SYMGET('STABILITY_STUDY_NBR_CDQuery')||'">';	     			PUT LINE;
	  		LINE = '<INPUT TYPE="hidden" NAME="STABILITY_SAMP_STOR_CONDQuery" 
				VALUE="'||SYMGET('STABILITY_SAMP_STOR_CONDQuery')||'">';     			PUT LINE;
	  		
			LINE = '<INPUT TYPE="hidden" NAME="PROD_NMQuery" VALUE="'||TRIM(SYMGET('PROD_NMQuery'))||'">'; PUT LINE;
	  		LINE = '<INPUT TYPE="hidden" NAME="STABILITY_SAMP_PRODUCTQuery" VALUE="'||TRIM(SYMGET('STABILITY_SAMP_PRODUCTQuery'))||'">'; PUT LINE;
			END;
	  		
			IF Screenvar='HOME' THEN DO;
				LINE = '<INPUT TYPE="hidden" NAME="Screenvar" VALUE="PROD_NM">';	PUT LINE; 
				CALL SYMPUT('Screenvar2', 'products:');
			END;

			IF Screenvar='PROD_NM' AND SAVERPTTYPE='ST' THEN DO;
				LINE = '<INPUT TYPE="hidden" NAME="Screenvar" VALUE="STABILITY_SAMP_PRODUCT">';	PUT LINE; 
				CALL SYMPUT('Screenvar2', 'products:');
			END;

			IF Screenvar='STABILITY_SAMP_PRODUCT' AND SAVERPTTYPE='ST' THEN DO;
				LINE = '<INPUT TYPE="hidden" NAME="Screenvar" VALUE="STABILITY_STUDY_GRP_CD">';	PUT LINE; 
				CALL SYMPUT('Screenvar2', 'product strengths:');
			END;

			IF Screenvar='STABILITY_STUDY_GRP_CD' THEN DO;
				LINE = '<INPUT TYPE=hidden NAME=Screenvar VALUE=STABILITY_STUDY_NBR_CD>';  	PUT LINE;  
			END; 
			IF Screenvar='STABILITY_STUDY_NBR_CD' THEN DO;
				LINE = '<INPUT TYPE="hidden" NAME="Screenvar" VALUE="STABILITY_SAMP_STOR_COND">'; PUT LINE; 
				CALL SYMPUT('Screenvar2', 'study numbers:');
			END;
			IF Screenvar='STABILITY_SAMP_STOR_COND' THEN DO;
				LINE = '<INPUT TYPE="hidden" NAME="Screenvar" VALUE="LAB_TST_METH_SPEC_DESC">';	PUT LINE; 
				CALL SYMPUT('Screenvar2', 'storage conditions:');
			END;
			IF Screenvar='LAB_TST_METH_SPEC_DESC' AND SaveRptType='ST' THEN DO;
				LINE = '<INPUT TYPE="hidden" NAME="Screenvar" VALUE="SUMQUERY">';   		PUT LINE; 
				CALL SYMPUT('Screenvar2', 'test methods:');
			END;

			**************************************************;
			*** Added V2 - PRODUCT RELEASE OPTION SECTION  ***;
			**************************************************;
			IF SAVERPTTYPE='RE' THEN DO;
			LINE = '<INPUT TYPE="hidden" NAME="PROD_NMQuery" VALUE="'||TRIM(SYMGET('PROD_NMQuery'))||'">'; PUT LINE;
	  		LINE = '<INPUT TYPE="hidden" NAME="CREATE_START_DTQuery" VALUE="'||SYMGET('CREATE_START_DTQuery')||'">';	PUT LINE;
	  		LINE = '<INPUT TYPE="hidden" NAME="CREATE_END_DTQuery" VALUE="'||SYMGET('CREATE_END_DTQuery')||'">';PUT LINE;
			LINE = '<INPUT TYPE="hidden" NAME="STABILITY_SAMP_PRODUCTQuery" VALUE="'||TRIM(SYMGET('STABILITY_SAMP_PRODUCTQuery'))||'">'; PUT LINE;
			END;

			IF Screenvar='RE_HOME' THEN DO;
				LINE = '<INPUT TYPE="hidden" NAME="Screenvar" VALUE="PROD_NM">';   	PUT LINE; 
				CALL SYMPUT('Screenvar2', 'products:');
			END;

			IF Screenvar='PROD_NM' AND SAVERPTTYPE='RE' THEN DO;
				LINE = '<INPUT TYPE="hidden" NAME="Screenvar" VALUE="STABILITY_SAMP_PRODUCT">';   	PUT LINE; 
				CALL SYMPUT('Screenvar2', 'products:');
			END;

			IF Screenvar='STABILITY_SAMP_PRODUCT' AND SAVERPTTYPE='RE' THEN DO;
				LINE = '<INPUT TYPE="hidden" NAME="Screenvar" VALUE="CREATE_START_DT">';   	PUT LINE; 
				CALL SYMPUT('Screenvar2', 'product strengths:');
			END;
			IF Screenvar='CREATE_START_DT' THEN DO;
				LINE = '<INPUT TYPE="hidden" NAME="Screenvar" VALUE="LAB_TST_METH_SPEC_DESC">';	PUT LINE; 
				CALL SYMPUT('Screenvar2', 'manufacture start date and end date:');
			END;
			IF Screenvar='LAB_TST_METH_SPEC_DESC' AND SaveRptType='RE' THEN DO;
			   	LINE = '<INPUT TYPE="hidden" NAME="Screenvar" VALUE="SUMQUERY">';   		PUT LINE; 
				LINE = '<INPUT TYPE="hidden" NAME="CREATE_START_DT" VALUE="'||SYMGET('CREATE_START_DT')||'">';	PUT LINE;
	  			LINE = '<INPUT TYPE="hidden" NAME="CREATE_END_DT" VALUE="'||SYMGET('CREATE_END_DT')||'">';PUT LINE;
				CALL SYMPUT('Screenvar2', 'test methods:');
			END;
			
	  		LINE = '<INPUT TYPE="hidden" NAME="LAB_TST_METH_SPEC_DESCQuery" 
				VALUE="'||SYMGET('LAB_TST_METH_SPEC_DESCQuery')||'">';     			PUT LINE;

		RUN;
*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SEE LINKS SDS                                           *;
*   REQUIREMENT:      SEE LINKS FRS                                           *;
*   INPUT:            Macro variables NumList, Screenvar, Screenvar2.         *;
*   PROCESSING:       Generate HTML code for current screen, Title banner,    *;
*                     screen title,checkbox list and 2 submit buttons, footer *;
*                     banner.  Save the macro variable Screenvar to           *;
*                     Save_Screenvar.                                         *;
*   OUTPUT:           HTML code to browser (file _webout)                     *;
*******************************************************************************;

		DATA _NULL_;
			FILE _WEBOUT;
			SaveRptType="&Save_RptType";
			PUT 	'<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" BORDER="0" CELLPADDING="0" CALLSPACING="0">';
			PUT 	'<TR ALIGN="LEFT" ><TD BGCOLOR="#003366"><BIG><BIG><BIG>';
			LINE=	'<IMG SRC="http://'||"&_server"||'/links/images/gsklogo1.gif" WIDTH="141" HEIGHT="62">'; PUT LINE;
			IF SaveRptType='ST' THEN PUT 	'<FONT FACE=ARIAL COLOR="#FFFFFF"><EM> LINKS </EM> Stability Module</FONT>';
			IF SaveRptType='RE' THEN PUT 	'<FONT FACE=ARIAL COLOR="#FFFFFF"><EM> LINKS </EM> Batch Trending Module</FONT>';
			PUT 	'</BIG></BIG></BIG></TD><TD ALIGN=right BGCOLOR="#003366">';
			PUT 	'</TD></TR>';
			PUT 	'<TR VALIGN="TOP"><TD colspan=2 HEIGHT="87%" BGCOLOR="#ffffdd" ALIGN=center>'; 
		RUN;
		
		*** V3 - Added for date screen to display a different message at the top than the other screens ***;
		%IF %SUPERQ(SCREENVAR)=CREATE_START_DT %THEN %DO;		
		   DATA _NULL_;
			LENGTH LINE $500;
			FILE _WEBOUT;
			LINE = '</BR></BR></BR><TABLE '||"&WIDTH"||'>'; PUT LINE;
			LINE = '<TR><TD ALIGN=left><BIG><EM><STRONG><FONT FACE=ARIAL COLOR="#003366">'; PUT LINE;
			LINE= 'Please select a '||"&Screenvar2"||'</STRONG></FONT></EM></BIG></BIG></TD></TR></TABLE>'; PUT LINE;
			LINE= '<TABLE ALIGN=center BORDER=1 '||"&WIDTH"; PUT LINE;
			LINE= ' STYLE="FONT-family: Arial FONT-SIZE: smaller" BGCOLOR="#FFFFFF" ';  PUT LINE;
			LINE= ' bordercolor="#C0C0C0" bordercolorlight="#C0C0C0" bordercolordark="#C0C0C0">'; PUT LINE;
		   RUN;
		%END;
		%ELSE %IF %SUPERQ(SCREENVAR)=PROD_NM %THEN %DO;
			DATA _NULL_;
				LENGTH LINE $500;
				FILE _WEBOUT;
				LINE = '</BR></BR><TABLE '||"&WIDTH"||'>'; PUT LINE;
				LINE = '<TR><TD ALIGN=left><BIG><EM><STRONG><FONT FACE=ARIAL COLOR="#003366">'; PUT LINE;
				LINE= '</br>Please select up to 8 '||"&Screenvar2"||'</STRONG></FONT></EM></BIG></BIG></TD></TR></TABLE>'; PUT LINE;
				LINE= '<TABLE ALIGN=center BORDER=1 '||"&WIDTH"; PUT LINE;
				LINE= ' STYLE="FONT-family: Arial FONT-SIZE: smaller" BGCOLOR="#FFFFFF" ';  PUT LINE;
				LINE= ' bordercolor="#C0C0C0" bordercolorlight="#C0C0C0" bordercolordark="#C0C0C0">'; PUT LINE;
				LINE="&header1"; PUT LINE;
				LINE="&header2"; PUT LINE;
				LINE="&header3"; PUT LINE;
			RUN;
			%END;
		%ELSE %DO;
		DATA _NULL_;
			LENGTH LINE $500;
			FILE _WEBOUT;
			LINE = '</BR></BR><TABLE '||"&WIDTH"||'>'; PUT LINE;
			LINE = '<TR><TD ALIGN=left><BIG><EM><STRONG><FONT FACE=ARIAL COLOR="#003366">'; PUT LINE;
			LINE= '</br>Please select one or more '||"&Screenvar2"||'</STRONG></FONT></EM></BIG></BIG></TD></TR></TABLE>'; PUT LINE;
			LINE= '<TABLE ALIGN=center BORDER=1 '||"&WIDTH"; PUT LINE;
			LINE= ' STYLE="FONT-family: Arial FONT-SIZE: smaller" BGCOLOR="#FFFFFF" ';  PUT LINE;
			LINE= ' bordercolor="#C0C0C0" bordercolorlight="#C0C0C0" bordercolordark="#C0C0C0">'; PUT LINE;
			LINE="&header1"; PUT LINE;
			LINE="&header2"; PUT LINE;
			LINE="&header3"; PUT LINE;
		RUN;
		%END;
		
		   %LOCAL i;
		   %DO i = 1 %TO &NumList;

		   	%IF %SUPERQ(SCREENVAR)=STABILITY_SAMP_STOR_COND %THEN %DO;
			DATA _NULL_;
				SET DATAlist1;
				WHERE ObsNum=&i;
				IF STABILITY_SAMP_STOR_COND = 'INT' THEN DO;
					CALL SYMPUT('DROPLIST1','"<TD WIDTH=10% ALIGN=left><FONT FACE=arial SIZE=2><STRONG>Initial</STRONG></TD>"');
					CALL SYMPUT('CHECKED','checked');
				END;
				ELSE DO;
					CALL SYMPUT('CHECKED',' ');
				END;
			RUN;
		   	%END;
			************************************************************************;
			*** V2 - Added to create radio box for both create and end date list ***;
			************************************************************************;

		   	DATA _NULL_;
			    LENGTH check $500;
			    SET DATAlist1;
				put prodlist;
			    FILE _WEBOUT;
			    WHERE obsnum=&i;
			    %IF %SUPERQ(SCREENVAR)=CREATE_START_DT %THEN %DO;
			    %END;
			    %ELSE  %IF %SUPERQ(SCREENVAR)=STABILITY_SAMP_PRODUCT %THEN %DO;
				check='<TR><TD WIDTH="1%" ><INPUT TYPE=checkbox '||"&checked"||' NAME='||LEFT("&Screenvar")||' VALUE="'||TRIM(STABILITY_SAMP_PRODUCT)||'">';
			        check2='</TD><FONT FACE=arial SIZE=2>'||TRIM(&droplist1)||TRIM(&droplist2)||TRIM(&droplist3)||TRIM(&DROPLIST4)||'</FONT></TR>';  
			    PUT check;  PUT check2;
			    %END;
			    %ELSE %DO;
				check='<TR><TD WIDTH="1%" ><INPUT TYPE=checkbox '||"&checked"||' NAME='||LEFT("&Screenvar")||' VALUE="'||TRIM(&Screenvar)||'">';
			        check2='</TD><FONT FACE=arial SIZE=2>'||TRIM(&droplist1)||TRIM(&droplist2)||TRIM(&droplist3)||TRIM(&DROPLIST4)||'</FONT></TR>';  
			    PUT check;  PUT check2;
			    %END;
		     	RUN;
			
		%END;

		****************************************************************************;
		***  V2 - Added to create End Date section of Manufacturing Date Screen  ***;
		***  V8 - Modified Date Selection Screen                                 ***;
		****************************************************************************;
		%IF %SUPERQ(SCREENVAR)=CREATE_START_DT %THEN %DO;	
			*****************************************************;
			***  FORM 16: HTML TO CHANGE DATE RANGE MONTH     ***;
			*****************************************************;
		DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT;
			PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD" valign=top align=center><TABLE><TR><TD COLSPAN=3>';
			
			PUT '<FONT SIZE=2 FACE=arial COLOR="#003366"><EM><STRONG>&nbsp;&nbsp;Start Date: </EM></STRONG></FONT></TD></TR>';
		  	PUT '<TR><TD><SELECT NAME="STARTMONTH" SIZE="1" STYLE="FONT-SIZE: SMALL">';

			%IF %SUPERQ(startmonth)=1 %THEN %LET SELMONTH=selected;  %ELSE %LET SELMONTH= ;
	  		LINE='<OPTION '||"&selMONTH"||' VALUE="1">JAN</OPTION>'; PUT LINE;
			%IF %SUPERQ(startmonth)=2 %THEN %LET SELMONTH=selected;  %ELSE %LET SELMONTH= ;
			LINE='<OPTION '||"&selMONTH"||' VALUE="2">FEB</OPTION>'; PUT LINE;
			%IF %SUPERQ(startmonth)=3 %THEN %LET SELMONTH=selected;  %ELSE %LET SELMONTH= ;
			LINE='<OPTION '||"&selMONTH"||' VALUE="3">MAR</OPTION>'; PUT LINE;
			%IF %SUPERQ(startmonth)=4 %THEN %LET SELMONTH=selected;  %ELSE %LET SELMONTH= ;
			LINE='<OPTION '||"&selMONTH"||' VALUE="4">APR</OPTION>'; PUT LINE;
			%IF %SUPERQ(startmonth)=5 %THEN %LET SELMONTH=selected;  %ELSE %LET SELMONTH= ;
			LINE='<OPTION '||"&selMONTH"||' VALUE="5">MAY</OPTION>'; PUT LINE;
			%IF %SUPERQ(startmonth)=6 %THEN %LET SELMONTH=selected;  %ELSE %LET SELMONTH= ;
			LINE='<OPTION '||"&selMONTH"||' VALUE="6">JUN</OPTION>'; PUT LINE;
			%IF %SUPERQ(startmonth)=7 %THEN %LET SELMONTH=selected;  %ELSE %LET SELMONTH= ;
			LINE='<OPTION '||"&selMONTH"||' VALUE="7">JUL</OPTION>'; PUT LINE;
			%IF %SUPERQ(startmonth)=8 %THEN %LET SELMONTH=selected;  %ELSE %LET SELMONTH= ;
			LINE='<OPTION '||"&selMONTH"||' VALUE="8">AUG</OPTION>'; PUT LINE;
			%IF %SUPERQ(startmonth)=9 %THEN %LET SELMONTH=selected;  %ELSE %LET SELMONTH= ;
			LINE='<OPTION '||"&selMONTH"||' VALUE="9">SEP</OPTION>'; PUT LINE;
			%IF %SUPERQ(startmonth)=10 %THEN %LET SELMONTH=selected;  %ELSE %LET SELMONTH= ;
			LINE='<OPTION '||"&selMONTH"||' VALUE="10">OCT</OPTION>'; PUT LINE;
			%IF %SUPERQ(startmonth)=11 %THEN %LET SELMONTH=selected;  %ELSE %LET SELMONTH= ;
			LINE='<OPTION '||"&selMONTH"||' VALUE="11">NOV</OPTION>'; PUT LINE;
			%IF %SUPERQ(startmonth)=12 %THEN %LET SELMONTH=selected;  %ELSE %LET SELMONTH= ;
			LINE='<OPTION '||"&selMONTH"||' VALUE="12">DEC</OPTION>'; PUT LINE;
			PUT '</SELECT></TD>';
	  	RUN;

		DATA _NULL_; 
		STARTMONTH="&STARTMONTH";
		CALL SYMPUT('MAXDAY',31);
		RUN;

		*****************************************************;
		***  FORM 16: HTML TO CHANGE DATE RANGE DAY       ***;
		*****************************************************;
		DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; 
			PUT   '<TD BGCOLOR="#FFFFDD" valign=top align=left>';
		  	PUT '<SELECT NAME="StartDAY" SIZE="1" STYLE="FONT-SIZE: SMALL" >';
			%DO I=1 %TO &MAXDAY;
				%IF %SUPERQ(startDAY)=&I %THEN %LET SELDAY=selected;  
                                                         %ELSE %LET SELDAY= ;
	  			LINE='<OPTION '||"&selDAY"||' VALUE="'||"&I"||'">'||"&I"||'</OPTION>'; PUT LINE;
  			%END;
			PUT '</SELECT></TD>';
	  	RUN;

		*****************************************************;
		***  FORM 16: HTML TO CHANGE DATE RANGE YEAR      ***;
		*****************************************************;
		DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; 
			PUT   '<TD BGCOLOR="#FFFFDD" valign=top align=left>';
		  	PUT '<SELECT NAME="StartYEAR" SIZE="1" STYLE="FONT-SIZE: SMALL" >';
			%DO I=&MINYEAR %TO &MAXYEAR;
				%IF %SUPERQ(startYEAR)=&I %THEN %LET SELYEAR=selected;  
                                                          %ELSE %LET SELYEAR= ;
	  			LINE='<OPTION '||"&selYEAR"||' VALUE="'||"&I"||'">'||"&I"||'</OPTION>'; PUT LINE;
  			%END;
			PUT '</SELECT></TD></TR></TABLE></TD></TR>';
	  	RUN;

		DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT;
			PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD" valign=top align=center><TABLE><TR><TD COLSPAN=3>';
			
			PUT '<FONT SIZE=2 FACE=arial COLOR="#003366"><EM><STRONG>&nbsp;&nbsp;End Date: </EM></STRONG></FONT></TD></TR>';
		  	PUT '<TR><TD><SELECT NAME="ENDMONTH" SIZE="1" STYLE="FONT-SIZE: SMALL">';

			%IF %SUPERQ(ENDMONTH)=1 %THEN %LET SELMONTH=selected;  %ELSE %LET SELMONTH= ;
	  		LINE='<OPTION '||"&selMONTH"||' VALUE="1">JAN</OPTION>'; PUT LINE;
			%IF %SUPERQ(ENDMONTH)=2 %THEN %LET SELMONTH=selected;  %ELSE %LET SELMONTH= ;
			LINE='<OPTION '||"&selMONTH"||' VALUE="2">FEB</OPTION>'; PUT LINE;
			%IF %SUPERQ(ENDMONTH)=3 %THEN %LET SELMONTH=selected;  %ELSE %LET SELMONTH= ;
			LINE='<OPTION '||"&selMONTH"||' VALUE="3">MAR</OPTION>'; PUT LINE;
			%IF %SUPERQ(ENDMONTH)=4 %THEN %LET SELMONTH=selected;  %ELSE %LET SELMONTH= ;
			LINE='<OPTION '||"&selMONTH"||' VALUE="4">APR</OPTION>'; PUT LINE;
			%IF %SUPERQ(ENDMONTH)=5 %THEN %LET SELMONTH=selected;  %ELSE %LET SELMONTH= ;
			LINE='<OPTION '||"&selMONTH"||' VALUE="5">MAY</OPTION>'; PUT LINE;
			%IF %SUPERQ(ENDMONTH)=6 %THEN %LET SELMONTH=selected;  %ELSE %LET SELMONTH= ;
			LINE='<OPTION '||"&selMONTH"||' VALUE="6">JUN</OPTION>'; PUT LINE;
			%IF %SUPERQ(ENDMONTH)=7 %THEN %LET SELMONTH=selected;  %ELSE %LET SELMONTH= ;
			LINE='<OPTION '||"&selMONTH"||' VALUE="7">JUL</OPTION>'; PUT LINE;
			%IF %SUPERQ(ENDMONTH)=8 %THEN %LET SELMONTH=selected;  %ELSE %LET SELMONTH= ;
			LINE='<OPTION '||"&selMONTH"||' VALUE="8">AUG</OPTION>'; PUT LINE;
			%IF %SUPERQ(ENDMONTH)=9 %THEN %LET SELMONTH=selected;  %ELSE %LET SELMONTH= ;
			LINE='<OPTION '||"&selMONTH"||' VALUE="9">SEP</OPTION>'; PUT LINE;
			%IF %SUPERQ(ENDMONTH)=10 %THEN %LET SELMONTH=selected;  %ELSE %LET SELMONTH= ;
			LINE='<OPTION '||"&selMONTH"||' VALUE="10">OCT</OPTION>'; PUT LINE;
			%IF %SUPERQ(ENDMONTH)=11 %THEN %LET SELMONTH=selected;  %ELSE %LET SELMONTH= ;
			LINE='<OPTION '||"&selMONTH"||' VALUE="11">NOV</OPTION>'; PUT LINE;
			%IF %SUPERQ(ENDMONTH)=12 %THEN %LET SELMONTH=selected;  %ELSE %LET SELMONTH= ;
			LINE='<OPTION '||"&selMONTH"||' VALUE="12">DEC</OPTION>'; PUT LINE;
			PUT '</SELECT></TD>';
	  	RUN;

		DATA _NULL_; 
		ENDMONTH="&ENDMONTH";
		/*IF ENDMONTH IN (1, 3, 5, 7, 8, 10,12) THEN CALL SYMPUT('MAXDAY',31);
		ELSE IF ENDMONTH IN (2) THEN CALL SYMPUT('MAXDAY',29);
		ELSE CALL SYMPUT('MAXDAY',30);*/
		CALL SYMPUT('MAXDAY',31);
		RUN;

		DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; 
			PUT   '<TD BGCOLOR="#FFFFDD" align=left valign=top>';
		  	PUT '<SELECT NAME="ENDDAY" SIZE="1" STYLE="FONT-SIZE: SMALL">';
			%DO I=1 %TO &MAXDAY;
				%IF %SUPERQ(ENDDAY)=&I %THEN %LET SELDAY=selected;  
                                                       %ELSE %LET SELDAY= ;
	  			LINE='<OPTION '||"&selDAY"||' VALUE="'||"&I"||'">'||"&I"||'</OPTION>'; PUT LINE;
  			%END;
			PUT '</SELECT></TD>';
	  	RUN;
		DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; 
			PUT   '<TD BGCOLOR="#FFFFDD" align=left valign=top>';
			LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;
		  	PUT '<SELECT NAME="ENDYEAR" SIZE="1" STYLE="FONT-SIZE: SMALL" >';
			%DO I=&MINYEAR %TO &MAXYEAR;
				%IF %SUPERQ(ENDYEAR)=&I %THEN %LET SELYEAR=selected;  
                                                        %ELSE %LET SELYEAR= ;
	  			LINE='<OPTION '||"&selYEAR"||' VALUE="'||"&I"||'">'||"&I"||'</OPTION>'; PUT LINE;
  			%END;
			PUT '</SELECT></TD></TR></TABLE>';
			PUT '</TABLE></BR><FONT SIZE=3 FACE=arial COLOR="#003366"><strong>Available Data</font></strong></BR>';
			RUN;


		DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; SET DATEOUT;
				LINE= '<TABLE WIDTH="40%"><TR align="left"><TD WIDTH="60%" align="left"><FONT SIZE=2 FACE=arial COLOR="#003366"><STRONG>'||TRIM(STABILITY_SAMP_PRODUCT)||'</strong></font></td>'; put line;
                line= '<td WIDTH="40%" align="left"><FONT SIZE=2 FACE=arial COLOR="#003366">'||PUT(DATEPART(MINDATE),DATE9.)||' to '||PUT(DATEPART(MAXDATE),DATE9.)||'</FONT></TD></TR>'; PUT LINE;
		RUN;


		DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; 
			PUT '</TABLE></BR><INPUT TYPE="submit" NAME="Submit" VALUE="       Next       "';
			PUT ' STYLE="background-COLOR: rgb(192,192,192); COLOR: rgb(0,0,0);';
			PUT ' FONT-SIZE: 9pt; FONT-family: Arial ; FONT-weight: bolder;';
			PUT ' LETter-spacing: 0px; text-ALIGN: center; vertical-ALIGN: baseline; ';
			PUT ' BORDER: medium outset; padding-top: 2px; padding-bottom: 4px">';
			PUT '</FORM>'; 
	  	RUN;
	
		DATA _NULL_; FILE _WEBOUT;
	  		PUT '</TD><TD VALIGN=top ALIGN=LEFT BGCOLOR="#E0E0E0">';
	  		PUT '</FONT>';
	  	RUN;

		%END;

	        %IF %SUPERQ(SCREENVAR)^=CREATE_START_DT %THEN %DO;
		DATA _NULL_;
			FILE _WEBOUT;
			Screenvar="&Screenvar";
			SaveRptType="&Save_RptType"; 
	 		line= '</TABLE></BR><INPUT TYPE="submit" NAME="Submit" VALUE="      '||"&Button"||'       "'; put line;
			PUT ' STYLE="background-COLOR: rgb(192,192,192); COLOR: rgb(0,0,0);';
			PUT ' FONT-SIZE: 9pt; FONT-family: Arial ; FONT-weight: bolder;';
			PUT ' LETter-spacing: 0px; text-ALIGN: center; vertical-ALIGN: baseline; ';
			PUT ' BORDER: medium outset; padding-top: 2px; padding-bottom: 4px">';
			PUT '</FORM>'; 
		RUN;
		%END;

		DATA _NULL_;
			LENGTH LINE $2000;
			FILE _WEBOUT;
			Screenvar="&Screenvar";
			SaveRptType="&Save_RptType"; 
			LINE = '<FORM METHOD='||"&METHOD"||' ACTION="'||"&_url"||'">'; 				PUT LINE;
			PUT   '<INPUT TYPE="hidden" NAME="_service" 	VALUE="default">';
			LINE= '<INPUT TYPE="hidden" NAME="_program" 	VALUE='||"LINKS.LRQuery.sas"||'>'; 	PUT LINE;
			LINE= '<INPUT TYPE=hidden   NAME=_server 	VALUE='||SYMGET('_server')||'>';   	PUT LINE;
			LINE= '<INPUT TYPE=hidden   NAME=_port 		VALUE='||SYMGET('_port')||'>';     	PUT LINE;
			LINE= '<INPUT TYPE=hidden   NAME=_sessionid 	VALUE='||SYMGET('_sessionid')||'>';	PUT LINE;
			LINE= '<INPUT TYPE=hidden   NAME=ScreenvarLast 	VALUE='||SYMGET('Screenvar')||'>'; 	PUT LINE;
			LINE = '<INPUT TYPE="hidden" NAME="NoData" 		VALUE="'||SYMGET('NoData')||'">';   	PUT LINE;
	  		*LINE=   '<INPUT TYPE=hidden   NAME=_debug       VALUE="0">';				*PUT LINE;
	  		LINE = '<INPUT TYPE=hidden   NAME=STARTMONTH       	VALUE="'||SYMGET('STARTMONTH')||'">';	PUT LINE;
	  		LINE = '<INPUT TYPE=hidden   NAME=STARTDAY       	VALUE="'||SYMGET('STARTDAY')||'">';	PUT LINE;
	  		LINE = '<INPUT TYPE=hidden   NAME=STARTYEAR       	VALUE="'||SYMGET('STARTYEAR')||'">';	PUT LINE;
	  		LINE = '<INPUT TYPE=hidden   NAME=ENDMONTH       	VALUE="'||SYMGET('ENDMONTH')||'">';	PUT LINE;
	  		LINE = '<INPUT TYPE=hidden   NAME=ENDDAY       		VALUE="'||SYMGET('ENDDAY')||'">';	PUT LINE;
	  		LINE = '<INPUT TYPE=hidden   NAME=ENDYEAR       	VALUE="'||SYMGET('ENDYEAR')||'">';	PUT LINE;
					
			IF Screenvar='PROD_NM' AND SAVERPTTYPE='ST' THEN DO;
				LINE= '<INPUT TYPE="hidden" NAME="PROD_NMQuery" VALUE="'||SYMGET('PROD_NMQuery')||'">';	PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="STABILITY_SAMP_PRODUCTQuery" VALUE="'||SYMGET('STABILITY_SAMP_PRODUCTQuery')||'">';	PUT LINE;
	  			LINE = '<INPUT TYPE=hidden NAME=Screenvar VALUE=STABILITY_SAMP_PRODUCT>';  	PUT LINE; 
				LINE= '<INPUT TYPE="hidden" NAME="STABILITY_STUDY_GRP_CDQuery" 	
				VALUE="'||SYMGET('STABILITY_STUDY_GRP_CDQuery')||'">';	     			PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="STABILITY_STUDY_NBR_CDQuery" 	
				VALUE="'||SYMGET('STABILITY_STUDY_NBR_CDQuery')||'">';	     			PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="STABILITY_SAMP_STOR_CONDQuery" 	
				VALUE="'||SYMGET('STABILITY_SAMP_STOR_CONDQuery')||'">';	     		PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="LAB_TST_METH_SPEC_DESCQuery" VALUE="'||SYMGET('LAB_TST_METH_SPEC_DESCQuery')||'">';	PUT LINE;
			
				END;

			IF Screenvar='STABILITY_SAMP_PRODUCT' AND SAVERPTTYPE='ST' THEN DO;
				LINE= '<INPUT TYPE="hidden" NAME="PROD_NMQuery" VALUE="'||SYMGET('PROD_NMQuery')||'">';	PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="STABILITY_SAMP_PRODUCTQuery" VALUE="'||SYMGET('STABILITY_SAMP_PRODUCTQuery')||'">';	PUT LINE;
	  			LINE = '<INPUT TYPE=hidden NAME=Screenvar VALUE=STABILITY_STUDY_GRP_CD>';  	PUT LINE; 
				LINE= '<INPUT TYPE="hidden" NAME="STABILITY_STUDY_GRP_CDQuery" 	
				VALUE="'||SYMGET('STABILITY_STUDY_GRP_CDQuery')||'">';	     			PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="STABILITY_STUDY_NBR_CDQuery" 	
				VALUE="'||SYMGET('STABILITY_STUDY_NBR_CDQuery')||'">';	     			PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="STABILITY_SAMP_STOR_CONDQuery" 	
				VALUE="'||SYMGET('STABILITY_SAMP_STOR_CONDQuery')||'">';	     		PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="LAB_TST_METH_SPEC_DESCQuery" VALUE="'||SYMGET('LAB_TST_METH_SPEC_DESCQuery')||'">';	PUT LINE;
			
				END;
			IF Screenvar='STABILITY_STUDY_GRP_CD'  THEN DO;
				LINE = '<INPUT TYPE=hidden NAME=Screenvar VALUE=STABILITY_STUDY_NBR_CD>';  	PUT LINE;  
				LINE= '<INPUT TYPE="hidden" NAME="PROD_NMQuery" VALUE="'||SYMGET('PROD_NMQuery')||'">';	PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="STABILITY_SAMP_PRODUCTQuery" VALUE="'||SYMGET('STABILITY_SAMP_PRODUCTQuery')||'">';	PUT LINE;
				LINE= '<INPUT TYPE="hidden" NAME="STABILITY_STUDY_GRP_CDQuery" 	
				VALUE=" ">';	     			PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="STABILITY_STUDY_NBR_CDQuery" 	
				VALUE="'||SYMGET('STABILITY_STUDY_NBR_CDQuery')||'">';	     			PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="STABILITY_SAMP_STOR_CONDQuery" 	
				VALUE="'||SYMGET('STABILITY_SAMP_STOR_CONDQuery')||'">';	     		PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="LAB_TST_METH_SPEC_DESCQuery" VALUE="'||SYMGET('LAB_TST_METH_SPEC_DESCQuery')||'">';	PUT LINE;
			
	  
			END; 
						
			IF Screenvar='STABILITY_STUDY_NBR_CD' THEN DO;
				LINE = '<INPUT TYPE=hidden NAME=Screenvar VALUE=STABILITY_SAMP_STOR_COND>';  	PUT LINE; 
				LINE= '<INPUT TYPE="hidden" NAME="PROD_NMQuery" VALUE="'||SYMGET('PROD_NMQuery')||'">';	PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="STABILITY_SAMP_PRODUCTQuery" VALUE="'||SYMGET('STABILITY_SAMP_PRODUCTQuery')||'">';	PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="STABILITY_STUDY_GRP_CDQuery" 	
				VALUE="'||SYMGET('STABILITY_STUDY_GRP_CDQuery')||'">';	     			PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="STABILITY_STUDY_NBR_CDQuery" 	VALUE=" ">';	PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="STABILITY_SAMP_STOR_CONDQuery" 	
				VALUE="'||SYMGET('STABILITY_SAMP_STOR_CONDQuery')||'">';	     		PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="LAB_TST_METH_SPEC_DESCQuery" VALUE="'||SYMGET('LAB_TST_METH_SPEC_DESCQuery')||'">';	PUT LINE;
			
				END;
			
			IF Screenvar='STABILITY_SAMP_STOR_COND' THEN DO;
				LINE = '<INPUT TYPE=hidden NAME=Screenvar VALUE=LAB_TST_METH_SPEC_DESC>';  	PUT LINE; 
				LINE= '<INPUT TYPE="hidden" NAME="PROD_NMQuery" VALUE="'||SYMGET('PROD_NMQuery')||'">';	PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="STABILITY_SAMP_PRODUCTQuery" VALUE="'||SYMGET('STABILITY_SAMP_PRODUCTQuery')||'">';	PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="STABILITY_STUDY_GRP_CDQuery" 	
				VALUE="'||SYMGET('STABILITY_STUDY_GRP_CDQuery')||'">';	     			PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="STABILITY_STUDY_NBR_CDQuery" 	
				VALUE="'||SYMGET('STABILITY_STUDY_NBR_CDQuery')||'">';	     			PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="STABILITY_SAMP_STOR_CONDQuery" 	
				VALUE=" ">';	     		PUT LINE;
				LINE= '<INPUT TYPE="hidden" NAME="LAB_TST_METH_SPEC_DESCQuery" VALUE="'||SYMGET('LAB_TST_METH_SPEC_DESCQuery')||'">';	PUT LINE;
			
	  			END;

			IF Screenvar='LAB_TST_METH_SPEC_DESC' AND SAVERPTTYPE='ST' THEN DO;
				LINE = '<INPUT TYPE=hidden NAME=Screenvar VALUE=SUMQUERY>';  	PUT LINE; 
				LINE= '<INPUT TYPE="hidden" NAME="PROD_NMQuery" VALUE="'||SYMGET('PROD_NMQuery')||'">';	PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="STABILITY_SAMP_PRODUCTQuery" VALUE="'||SYMGET('STABILITY_SAMP_PRODUCTQuery')||'">';	PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="STABILITY_STUDY_GRP_CDQuery" 	
				VALUE="'||SYMGET('STABILITY_STUDY_GRP_CDQuery')||'">';	     			PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="STABILITY_STUDY_NBR_CDQuery" 	
				VALUE="'||SYMGET('STABILITY_STUDY_NBR_CDQuery')||'">';	     			PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME="STABILITY_SAMP_STOR_CONDQuery" 	
				VALUE="'||SYMGET('STABILITY_SAMP_STOR_CONDQuery')||'">';	     		PUT LINE;
				LINE= '<INPUT TYPE="hidden" NAME="LAB_TST_METH_SPEC_DESCQuery" VALUE="'||SYMGET('LAB_TST_METH_SPEC_DESCQuery')||'">';	PUT LINE;
			
	  			END;
			
			**************************************************;
			*** Added V2 - PRODUCT RELEASE OPTION SECTION  ***;
			**************************************************;
			IF SAVERPTTYPE='RE' THEN DO;
			LINE= '<INPUT TYPE="hidden" NAME="PROD_NMQuery" VALUE="'||SYMGET('PROD_NMQuery')||'">';	PUT LINE;
			LINE= '<INPUT TYPE="hidden" NAME="STABILITY_SAMP_PRODUCTQuery" VALUE="'||SYMGET('STABILITY_SAMP_PRODUCTQuery')||'">';	PUT LINE;
			
			LINE= '<INPUT TYPE="hidden" NAME="CREATE_START_DTQuery"	 VALUE="'||SYMGET('CREATE_START_DTQuery')||'">';	PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME="CREATE_END_DTQuery"	 VALUE="'||SYMGET('CREATE_END_DTQuery')||'">';		PUT LINE;

			IF Screenvar='PROD_NM' THEN DO;
				LINE = '<INPUT TYPE=hidden NAME=Screenvar VALUE=STABILITY_SAMP_PRODUCT>';  		PUT LINE;  
			END; 

			IF Screenvar='STABILITY_SAMP_PRODUCT'  THEN DO;
				LINE = '<INPUT TYPE=hidden NAME=Screenvar VALUE=CREATE_START_DT>';  		PUT LINE;  
			END; 		
			IF Screenvar='CREATE_START_DT' THEN DO;
				LINE = '<INPUT TYPE=hidden NAME=Screenvar VALUE=LAB_TST_METH_SPEC_DESC>';  	PUT LINE;  
			END; 

			**************************************************;
			*** LAST SCREEN BEFORE QUERY CONFIRMATION      ***;
			**************************************************;

	  		LINE= '<INPUT TYPE="hidden" NAME="LAB_TST_METH_SPEC_DESCQuery" VALUE="'||SYMGET('LAB_TST_METH_SPEC_DESCQuery')||'">';	PUT LINE;
			IF Screenvar='LAB_TST_METH_SPEC_DESC' THEN DO;
				LINE = '<INPUT TYPE=hidden NAME=Screenvar VALUE=SUMQUERY>';  			PUT LINE;  
			END; END;
		RUN;

		
			DATA _NULL_;
				LENGTH LINE $500;
					FILE _WEBOUT;
				
				%IF %SUPERQ(SCREENVAR)=CREATE_START_DT %THEN %DO;	
					****************************************************************;
					*** V3 - Removed TRIM() from VALUE section to correct error  ***;
					****************************************************************;
					LINE= '<INPUT TYPE=hidden NAME="CREATE_START_DT" VALUE="&CREATE_START_DT">';PUT LINE;
					LINE= '<INPUT TYPE=hidden NAME="CREATE_END_DT"   VALUE="&CREATE_END_DT">';  PUT LINE;
				%END;
				%ELSE %DO;
					LINE= '<INPUT TYPE=hidden NAME="'||TRIM("&Screenvar")||'" VALUE="ALL">';  PUT LINE;
					LINE= '<INPUT TYPE=hidden NAME="'||TRIM("&Screenvar.0")||'" VALUE="1">';  PUT LINE;
				%END;
			RUN;
		

                *******************************************************************************;
		*** V2 - ADDED TO REMOVE THE SELECT ALL BUTTON FROM THE CREATE DATES SCREEN ***;
                *******************************************************************************;
	        %IF %SUPERQ(SCREENVAR)^=CREATE_START_DT AND %SUPERQ(SCREENVAR) ^=PROD_NM %THEN %DO;
		DATA _NULL_;
			FILE _WEBOUT;
			line= '<INPUT TYPE="submit" NAME="Submit" VALUE="  '||"&button2"||'   "';  put line;
			PUT ' STYLE="background-COLOR: rgb(192,192,192); COLOR: rgb(0,0,0);';
			PUT ' FONT-SIZE: 9pt; FONT-family: Arial ; FONT-weight: bolder;';
			PUT ' LETter-spacing: 0px; text-ALIGN: center; vertical-ALIGN: baseline; ';
			PUT ' BORDER: medium outset; padding-top: 2px; padding-bottom: 4px">';
			PUT '</FORM>';
		RUN;
		%END;

		DATA _NULL_;
			FILE _WEBOUT;
			LENGTH LINE anchor1 anchor2 $500.;
			PUT '</TD></TR>';
			PUT '<TR ALIGN="right" HEIGHT="5%"><TD ALIGN=right BGCOLOR="#003366">';
			
	 	 	LINE = '<A HREF="//'||SYMGET('_server')||'/links/'||"&SAVE_linkshome"||'.ASP?UserRole='|| "%SUPERQ(Save_UserRole)" ||'">'; PUT LINE;
			LINE = '<FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Home</FONT></a>&nbsp&nbsp'; PUT LINE;

			anchor1= '<A HREF="'|| "%SUPERQ(_THISSESSION)" || 
				'&_program='||"LINKS.LRQuery.sas"||
				'&help=HELP"><FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Help</FONT></A>'; 
			PUT anchor1; 

			anchor2= '&nbsp;&nbsp;<A HREF="'|| "%SUPERQ(_THISSESSION)" ||
				'&_program='||"LINKS.LRLogoff.sas"||
				'"><FONT FACE=ARIAL COLOR="#FFFFFF">Log off</FONT></A>&nbsp;&nbsp;'; 
			PUT anchor2; 
  
			PUT '</TD></TR></TABLE></body></html>';
		RUN;
	
	%PUT _ALL_;
%MEND Screens;
***********************************************************************************;
*                       MODULE HEADER                                             *;
*---------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SEE LINKS SDS                                               *;
*   REQUIREMENT:      SEE LINKS FRS                                               *;
*   INPUT: 	MACRO VARIABLES:                                                  *; 
*               SAVE_STABILITY_STUDY_GRP_CD0, 	SAVE_STABILITY_STUDY_GRP_CDLST,   *;
*		SAVE_STABILITY_STUDY_NBR_CD0,   SAVE_STABILITY_STUDY_NBR_CDLST,   *; 
*               SAVE_STABILITY_SAMP_STOR_COND0,	SAVE_STABILITY_SAMP_STOR_CONDLST, *;
*		SAVE_LAB_TST_METH_SPEC_DESC0,   SAVE_LAB_TST_METH_SPEC_DESCLST,   *;
*		SAVE_ITEM_DESCRIPTION0,         SAVE_ITEM_DESCRIPTIONLST,         *;
*		SAVE_CREATE_YEAR0,              SAVE_CREATE_YEARLST,              *;
*		STABILITY_STUDY_GRP_CDQUERY,    STABILITY_STUDY_NBR_CDQUERY,      *;
*               STABILITY_SAMP_STOR_CONDQUERY,	LAB_TST_METH_SPEC_DESCQUERY,      *;
*               ITEM_DESCRIPTIONQUERY,	        CREATE_YEARQUERY,                 *;
*               _PROGRAM, _SERVICE, _SESSIONID,	_PORT, _SERVER, _THISSESSION,     *;
*               SAVE_LINKSHOME,	SAVE_RPTTYPE 	                                  *;
*   PROCESSING:  Create HTML confirmation screen including a summary of		  *;
*		 all user selections.						  *;
*   OUTPUT:   1 HTML screen to browser.                                           *;
***********************************************************************************;
%MACRO QUERYSUM;
%PUT _ALL_;

		%MACRO ACTUALQUERY;  /* Added V10 Determines actual data that user selected vs. selections made*/
 		PROC FREQ DATA=SAVE.lrquery01a NOPRINT; TABLE &QUERYVAR/OUT=SUMQUERY; 
			WHERE  &LAB_TST_METH_SPEC_DESCQUERY2 &SAVE_PRODUCTQUERY3;
		RUN;

		DATA _NULL_; length TempResultLst ResultLst DATALST  $2000 PROD_NM2 $100; SET SUMQUERY ;
		BY &QUERYVAR;
		    RETAIN  VARCOUNT 0 RESULTLST  DATALST ;

			%IF %SUPERQ(QUERYVAR)=PROD_NM %THEN %DO;
			SAVERPTTYPE="&SAVE_RPTTYPE";
			IF COMPRESS(UPCASE(PROD_NM))='ADVAIRDISKUS' AND SAVERPTTYPE='ST' THEN PROD_NM2='ADVAIRDISKUSSTABILITY';
			ELSE IF COMPRESS(UPCASE(PROD_NM))='ADVAIRDISKUS' AND SAVERPTTYPE='RE' THEN PROD_NM2='ADVAIRDISKUSRELEASE';
			ELSE PROD_NM2=PROD_NM;
			%END;

			
		
			IF _n_=1 THEN DO;   /* Added V10 - Creates List of dataset names */
				ResultLst=" ^"||TRIM(&QUERYVAR)||"^ ";
			    VARCOUNT=VARCOUNT+1;   				
				%IF %SUPERQ(QUERYVAR)=PROD_NM %THEN %DO;
					DATALST='OUTSRVE2.LEMETADATA_'||COMPRESS(LEFT(PROD_NM2))||'(&WHERESTAT)';
					%END;
			END;
			ELSE DO;  
   				ResultLst=TRIM(ResultLst) || ", " ||"^"||TRIM(&QUERYVAR)||"^ ";  PUT RESULTLST;
				%IF %SUPERQ(QUERYVAR)=PROD_NM %THEN %DO;
					DATALST= TRIM(DATALST)||'  OUTSRVE2.LEMETADATA_'||COMPRESS(LEFT(PROD_NM2))||'(&WHERESTAT)'; PUT DATALST;
				%END;
				VARCOUNT=VARCOUNT+1;
				PUT VARCOUNT;
			END; 
			
			
		%IF %SUPERQ(SAVE_&QUERYVAR.LST) ^= %THEN %DO;	
		put COUNT resultlst;
		CALL SYMPUT("save_&queryvar.lst",ResultLst); 
		CALL SYMPUT("SAVE_&queryvar.0",VARCOUNT);
		%END;
		
		%IF %SUPERQ(QUERYVAR)=PROD_NM %THEN %DO;
		CALL SYMPUT("SAVE_STABILITY_SAMP_PRODUCT0",VARCOUNT);
		CALL SYMPUT('SAVE_DATAPRODUCT', DATALST);
		%END;
		
		RUN;
		%MEND;

		%LET QUERYVAR=PROD_NM; %ACTUALQUERY;
		%LET QUERYVAR=STABILITY_SAMP_PRODUCT; %ACTUALQUERY;

		%IF %SUPERQ(SAVE_RPTTYPE)=ST %THEN %DO;
			%LET QUERYVAR=STABILITY_STUDY_GRP_CD; %ACTUALQUERY;
			%LET QUERYVAR=STABILITY_STUDY_NBR_CD; %ACTUALQUERY;
			%LET QUERYVAR=STABILITY_SAMP_STOR_COND; %ACTUALQUERY;
			%END;
		%LET QUERYVAR=LAB_TST_METH_SPEC_DESC; %ACTUALQUERY;

%IF &Save_RptType=RE %THEN %DO; 
	
		DATA _NULL_;
			SAVE_CREATE_START_DT	=PUT("&SAVE_CREATE_START_DT",19.);
			LIST_CREATE_START_DT	=DATEPART(SAVE_CREATE_START_DT);
			CALL SYMPUT('LIST_CREATE_START_DT',LIST_CREATE_START_DT);			

			SAVE_CREATE_END_DT	=PUT("&SAVE_CREATE_END_DT",19.);
			LIST_CREATE_END_DT	=DATEPART(SAVE_CREATE_END_DT);
			CALL SYMPUT('LIST_CREATE_END_DT',LIST_CREATE_END_DT);		
				
		RUN;
  %END; 
		
	DATA _NULL_;
			LENGTH LINE $1000;
			FILE _WEBOUT;
			SaveRptType="&Save_RptType";
			PUT '<BODY BGCOLOR="#808080">';
			IF SaveRptType='ST' THEN PUT '<TITLE>LINKS Stability Module</TITLE>';
			IF SaveRptType='RE' THEN PUT '<TITLE>LINKS Batch Trending Module</TITLE>';
			PUT '<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" BORDER="0" CELLPADDING="0" CALLSPACING="0">';
			PUT '<TR ALIGN="LEFT" HEIGHT="8%"><TD BGCOLOR="#003366"><BIG><BIG><BIG>';
			LINE ='<IMG SRC="http://'||"&_server"||'/links/images/gsklogo1.gif" WIDTH="141" HEIGHT="62">'; PUT LINE;
			IF SaveRptType='ST' THEN PUT '<FONT FACE=ARIAL COLOR="#FFFFFF"> LINKS Stability Module</FONT>';
			IF SaveRptType='RE' THEN PUT '<FONT FACE=ARIAL COLOR="#FFFFFF"> LINKS Batch Trending Module</FONT>';
			PUT '</BIG></BIG></BIG></TD></TR>';

			LINE = '<TR VALIGN="TOP"><TD  HEIGHT="84%" BGCOLOR="#ffffdd" ALIGN=center>';
					PUT LINE;
			LINE = '</BR></BR><TABLE WIDTH="80%" STYLE="FONT-family: Arial">'
					||'<TR><TD colspan="2" ALIGN=left><STRONG><BIG><FONT FACE=ARIAL'
					||' COLOR="#003366">You have made the following selections: ';
					PUT LINE;
			LINE=' </BR></BR></BIG></STRONG></TD></TR>';
					PUT LINE;

					%let check=&save_stability_study_grp_cdlst;

			%IF %superq(SAVE_STABILITY_SAMP_PRODUCTLST)= %THEN %LET SAVE_STABILITY_SAMP_PRODUCTLST=&SAVE_PROD_NMLST;
			%ELSE %LET SAVE_STABILITY_SAMP_PRODUCTSUM=&SAVE_STABILITY_SAMP_PRODUCTLST;

			%IF %superq(SAVE_STABILITY_STUDY_GRP_CDLST)= %THEN %LET SAVE_STABILITY_STUDY_GRP_CDSUM=ALL;
			%ELSE %LET SAVE_STABILITY_STUDY_GRP_CDSUM=&SAVE_STABILITY_STUDY_GRP_CDLST;

			%IF %superq(SAVE_STABILITY_STUDY_NBR_CDLST)= %THEN %LET SAVE_STABILITY_STUDY_NBR_CDSUM=ALL;
			%ELSE %LET SAVE_STABILITY_STUDY_NBR_CDSUM=&SAVE_STABILITY_STUDY_NBR_CDLST;

			%IF %superq(SAVE_STABILITY_SAMP_STOR_CONDLST)= %THEN %LET SAVE_STABILITY_SAMP_STOR_CONDSUM=ALL;
			%ELSE %LET SAVE_STABILITY_SAMP_STOR_CONDSUM=&SAVE_STABILITY_SAMP_STOR_CONDLST;

			%IF %superq(SAVE_LAB_TST_METH_SPEC_DESCLST)= %THEN %LET SAVE_LAB_TST_METH_SPEC_DESCSUM=ALL;
			%ELSE %LET SAVE_LAB_TST_METH_SPEC_DESCSUM=&SAVE_LAB_TST_METH_SPEC_DESCLST;

			%IF &Save_RptType=ST %THEN %DO;
				LINE = '<TR><TD valign=top WIDTH="25%" ALIGN=left><STRONG>'
					||TRIM("&save_STABILITY_SAMP_PRODUCT0")
					||' Product(s): </STRONG></TD><TD WIDTH="75%" valign=top ALIGN=left>'
					||TRANWRD(SYMGET('save_STABILITY_SAMP_PRODUCTlst'),'^','"')
					||'</TD></TR>';
					PUT LINE;
				LINE = '<TR><TD valign=top WIDTH="25%" ALIGN=left><STRONG>'
					||TRIM("&save_stability_study_grp_cd0")
					||' Study Group(s): </STRONG></TD><TD WIDTH="75%" valign=top ALIGN=left>'
					||TRANWRD(SYMGET('save_stability_study_grp_cdSUM'),'^','"')
					||'</TD></TR>';
					PUT LINE;
				LINE = '<TR><TD valign=top ALIGN=left><STRONG>'
					||TRIM("&save_stability_study_nbr_cd0")
					||' Study(s): </STRONG></TD><TD valign=top ALIGN=left>'
					||TRANWRD(SYMGET('save_stability_study_nbr_cdSUM'),'^','"')
					||'</TD></TR>';
					PUT LINE;
				
				LINE = '<TR><TD valign=top ALIGN=left><STRONG>'
					||TRIM("&save_stability_samp_stor_cond0")
					||' Storage Condition(s): </STRONG></TD><TD valign=top ALIGN=left>'
					||TRANWRD(SYMGET('save_stability_samp_stor_condSUM'),'^','"')
					||'</TD></TR>';
					PUT LINE;
				LINE = '<TR><TD valign=top ALIGN=left><STRONG>'
					||TRIM("&save_lab_tst_meth_spec_desc0")
					||' Test Method(s): </STRONG></TD><TD valign=top ALIGN=left >'
					||TRANWRD(SYMGET('save_lab_tst_meth_spec_descSUM'),'^','"')
					||'</TD></TR>';
					PUT LINE;
			%END;

			*******************************************************;
			*** Added V2 - PRODUCT RELEASE INFORMATION SECTION  ***;
			*******************************************************;
			%IF &Save_RptType=RE %THEN %DO;
				LINE = '<TR><TD valign=top WIDTH="25%" ALIGN=left><STRONG>'
					||TRIM("&save_STABILITY_SAMP_PRODUCT0")
					||' Products(s): </STRONG></TD><TD WIDTH="75%" valign=top ALIGN=left>'
					||TRANWRD(SYMGET('save_STABILITY_SAMP_PRODUCTlst'),'^','"')
					||'</TD></TR>';
					PUT LINE;
				LINE = '<TR><TD valign=top ALIGN=left><STRONG>'
					||' Start Search Date: </STRONG></TD><TD valign=top ALIGN=left>'
					||put(&LIST_CREATE_START_DT,worddate20.)
					||'</TD></TR>';
					PUT LINE;
				LINE = '<TR><TD valign=top ALIGN=left><STRONG>'
					||' End Search Date: </STRONG></TD><TD valign=top ALIGN=left>'
					||put(&LIST_CREATE_END_DT,worddate20.)
					||'</TD></TR>';
					PUT LINE;
				LINE = '<TR><TD valign=top ALIGN=left><STRONG>'
					||TRIM("&save_lab_tst_meth_spec_desc0")
					||' Test Method(s): </STRONG></TD><TD valign=top ALIGN=left >'
					||TRANWRD(SYMGET('save_lab_tst_meth_spec_descSUM'),'^','"')
					||'</TD></TR>';
					PUT LINE;
			%END;

			LINE = 	'<TR><TD ALIGN=center colspan="2"></BR>'; PUT LINE;
			LINE = 	'<FORM METHOD='||"&METHOD"||' action="'||"&_URL"||'">'; PUT LINE;
			PUT 	'<INPUT TYPE="hidden" NAME="_service" 	VALUE="default">';
			LINE = 	'<INPUT TYPE="hidden" NAME="_program" 	VALUE=LINKS.LRREPORT.sas>'; 		PUT LINE;
			LINE =  '<INPUT TYPE=hidden   NAME=ScreenvarLast  VALUE='||SYMGET('Screenvar')||'>'; 	PUT LINE;
			LINE =  '<INPUT TYPE=hidden   NAME=Screenvar    VALUE=GETRESULTS>';  			PUT LINE; 
	  		*LINE =  '<INPUT TYPE=hidden   NAME=_debug       VALUE="0">';				*PUT LINE;
			LINE = 	'<INPUT TYPE=hidden   NAME=_server 	VALUE='||SYMGET('_server')||'>';	PUT LINE;
			LINE = 	'<INPUT TYPE=hidden   NAME=_port 	VALUE='||SYMGET('_port')||'>';  	PUT LINE;
			LINE = 	'<INPUT TYPE=hidden   NAME=_sessionid 	VALUE='||SYMGET('_sessionid')||'>';  	PUT LINE;		

			LINE = '</BR><p ALIGN=center><STRONG><FONT FACE=ARIAL COLOR="#003366">'
					||'Use the back button to change your selections';  			PUT LINE;
            LINE = '</BR><em>(please wait for the query to finish)</EM></BR></FONT></STRONG>';  	PUT LINE; 
			LINE = '</br><p ALIGN=center><FONT FACE=ARIAL COLOR="#003366"><EM> Note:'
				||'  The query of the LINKS database may take a few minutes.</FONT></EM>';
														PUT LINE;
			PUT '</br></br></br><INPUT TYPE="submit" NAME="Submit" VALUE="  Continue to Reports "';
			PUT ' STYLE="background-COLOR: rgb(192,192,192); COLOR: rgb(0,0,0);';
			PUT ' FONT-SIZE: 9pt; FONT-family: Arial ; FONT-weight: bolder;';
			PUT ' letter-spacing: 0px; text-ALIGN: center; vertical-ALIGN: baseline; ';
			PUT ' BORDER: medium outset; padding-top: 2px; padding-bottom: 4px">';
			PUT '</FORM></TR></TD></TABLE>';
			
			PUT '</TD></TR>';
			PUT '<TR ALIGN="right" HEIGHT="8%"><TD BGCOLOR="#003366">&nbsp;&nbsp;';
	 	 	LINE = '<A HREF="//'||SYMGET('_server')||'/links/'||"&SAVE_linkshome"||'.ASP?UserRole='|| "%SUPERQ(Save_UserRole)" ||'">'; PUT LINE;
			LINE = '<FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Home</FONT></a>&nbsp&nbsp'; 		PUT LINE;

			anchor1= '&nbsp;&nbsp;<A HREF="'|| "%SUPERQ(_THISSESSION)" || 
				'&_program='||"LINKS.LRQuery.sas"||
				'&help=HELP"><FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Help</FONT></A>'; 
			PUT anchor1;
			
			LINE = '&nbsp;&nbsp;<A HREF="'|| "%SUPERQ(_THISSESSION)" ||
				'&_program=LINKS.LRLogoff.sas"><FONT FACE=ARIAL COLOR="#FFFFFF">Log off</FONT></A>'; 
														PUT LINE; 
			PUT '</TD></TR></TABLE></BODY></HTML>';
		RUN;

		%GETRESULTS; 	  
		
		%Parameter_Table;  	
		
        	%Update_DateTime;

%MEND QUERYSUM;
**************************************************************************************;
* Added V9 - GetResults section which reads LeMetadata & LeGenealogy SAS Datasets. *;
**************************************************************************************;
*                       MODULE HEADER                                                *;
*------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: GetResults                                                     *;
*   REQUIREMENT:      N/A                                                            *;
*   INPUT:            Macro variable "query", which contains the WHERE clause        *;
*                     without the WHERE statement.                                   *;
*                     Dataset:  LeMetaData SAS Dataset                               *;
*   PROCESSING:       Merges LeMetadata files based on products chosen               *;
*                     					                                             *;
*   OUTPUT:           Save.LRQueryRes_Database                                       *;
*                     Save.LRQueryRes_Batches                                        *;
*                     Save.LRQueryRes_Parameters                                     *;
**************************************************************************************;
%MACRO GETRESULTS;

PROC FORMAT;
VALUE    $DATECHG   'APR' = '04'
		    'AUG' = '08'
		    'DEC' = '12'
		    'FEB' = '02'
		    'JAN' = '01'
		    'JUL' = '07'
		    'JUN' = '06'
		    'MAR' = '03'  
		    'MAY' = '05'
		    'NOV' = '11'
		    'OCT' = '10'
		    'SEP' = '09'		    
		    ;
RUN;
	%IF %SUPERQ(Save_RptType)=ST %THEN %DO;
		DATA _NULL_;        		
				Query = 	"&Stability_Study_Grp_CdQuery"||' '||
							"&Stability_Study_Nbr_CdQuery"||' '||
        		            "&Stability_Samp_Stor_CondQuery"||' '||
                		    "&Lab_Tst_Meth_Spec_DescQuery";
				Query2 =    "&Stability_Study_Grp_CdQuery"||' '||
							"&Stability_Study_Nbr_CdQuery"||' '||
                		    "&Stability_Samp_Stor_CondQuery";
				
		    CALL SYMPUT('Stor_CondQUery_Quotes',TRANWRD(Query2,'^',"'"));
	            Query=TRANWRD(Query,'$',"%");
	            CALL SYMPUT('QueryQuotes',TRANWRD(Query,'^',"'"));
       		    CALL SYMPUT('QueryQuotes2',' ');
       		    CALL SYMPUT('QueryQuotes3',' ');
		RUN;
	%LET incond=;


	%LET WHERESTAT=%STR(WHERE=(&QueryQuotes STABILITY_STUDY_NBR_CD IS NOT NULL));
	%LET BATCHNBR=%STR(LM.Matl_Nbr As Assembled_Matl_Nbr,LM.Batch_Nbr As Assembled_Batch_Nbr,);
	%LET DROPNBR=%STR(DROP=Assembled_Matl_Nbr Assembled_Batch_Nbr);
	%END;
	************************************************************;
	*** ADDED V5 - For Product Release Query String          ***;
	*** ADDED V12- Modified Date Criteria variables          ***;
	***            Modified Item Description Macro Variable  ***;
	************************************************************;
	%IF %SUPERQ(Save_RptType)=RE %THEN %DO;
		DATA _NULL_;   
			%IF %SUPERQ(STARTDAY)^= %THEN %DO;
				START_D=SUBSTR("&STARTDAY",1);
				START_M=SUBSTR("&STARTMONTH",1);
				START_Y=SUBSTR("&STARTYEAR",1);
				END_D  =SUBSTR("&ENDDAY",1);
				END_M  =SUBSTR("&ENDMONTH",1);
				END_Y  =SUBSTR("&ENDYEAR",1);

				Start_dt  =DHMS(MDY(START_M,START_D,START_Y),0,0,0);
				End_Dt    =DHMS(MDY(END_M,END_D,END_Y),0,0,0);

			        CALL SYMPUT('Start_dhms',"Matl_Mfg_Dt >='"||PUT(Start_dt,DATETIME19.)||"'DT");
				CALL SYMPUT('End_Dhms'  ,"Matl_Mfg_Dt <='"||PUT(End_dt,DATETIME19.)||"'DT");
			%END;
			%ELSE %DO;
			        CALL SYMPUT('Start_dhms',"Matl_Mfg_Dt >='"||PUT(&SAVE_CREATE_START_DT,DATETIME19.)||"'DT");
				CALL SYMPUT('End_Dhms'  ,"Matl_Mfg_Dt <='"||PUT(&SAVE_CREATE_END_DT,DATETIME19.)||"'DT");
			%END;
		
		RUN;
		DATA _NULL_;LENGTH Query Query2 $2500;        		
        		Query = "&Lab_Tst_Meth_Spec_DescQuery";
        		
					IF QUERY ^='' THEN CALL SYMPUT('QueryQuotes',trim(TRANWRD(Query,'^',"'")));
					ELSE CALL SYMPUT('QUERYQUOTES', '');
            		
		RUN;
	***********************************************************;
	%LET incond=and Matl_Mfg_Dt BETWEEN To_Date(&Start_Dhms,'DDMONYYYY:HH24:MI:SS') AND To_Date(&End_Dhms,'DDMONYYYY:HH24:MI:SS');
	%LET incond= AND %STR(&Start_Dhms AND &End_Dhms);

   %LET WHERESTAT=%STR(WHERE=(&QueryQuotes &SAVE_PRODUCTQUERY3 &INCOND));
	

	%LET BATCHNBR=;
	%LET DROPNBR=;
	%END;

*************************************************************************************************;
***** Creates:           Save.LRQueryRes_DataBase File For Report Programs                  *****;
*****                    Save.LRQueryRes_Batches File For Report Programs                   *****;
*************************************************************************************************;

	 
	DATA SAVE.LRQueryRes_DataBase(WHERE=(STABILITY_STUDY_NBR_CD IS NOT NULL))
	     SAVE.LRQueryRes_Batches(WHERE=(STABILITY_STUDY_NBR_CD IS NULL));
	SET  &SAVE_DATAPRODUCT;  /* Added V10 */
	
	RUN;

	PROC SQL;
		CONNECT TO ORACLE(USER=&oraid ORAPW=&orapsw BUFFSIZE=5000 PATH="&orapath" DBINDEX=YES);
		
	                CREATE TABLE LRQueryRes_Parameters AS SELECT * FROM CONNECTION TO ORACLE (
				    SELECT *
                	FROM   Tst_Parm               	TP
		); 
            
			%PUT &SQLXRC;
        	%PUT &SQLXMSG;
        	%LET HSQLXRC = &SQLXRC;
	        %LET HSQLXMSG = &SQLXMSG;
                DISCONNECT FROM ORACLE;
        	QUIT;
        RUN;
		

	%IF %SUPERQ(Save_RptType)=RE %THEN %DO;

	%END;	

%MEND GETRESULTS;

**************************************************************************************;
*                       MODULE HEADER                                                *;
*------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: Parameter_Table                                                *;
*   REQUIREMENT:      N/A                                                            *;
*   INPUT:            TABLE:   Extract from Tst_Parm Table                           *;
*   PROCESSING:       Creates Test Parm File For Use In Reports                      *;
*   OUTPUT:           Save.LRQueryRes_Parameters                                     *;
**************************************************************************************;

%MACRO Parameter_Table;

	PROC COPY IN = WORK OUT=SAVE;
		SELECT LRQueryRes_Parameters / memtype = data;
	RUN;

%MEND Parameter_Table;

**************************************************************************************;
*                       MODULE HEADER                                                *;
*------------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: Update_DateTime                                                *;
*   REQUIREMENT:      N/A                                                            *;
*   INPUT:            TABLE:   Activity_log                                          *;
*   PROCESSING:       Records Last Successful Update Date/Time For Use With Reports  *;
*                                                                                    *;
*   OUTPUT:           Save_Last_Update_Date Macro Variable                           *;
*                     Save_Last_Update_Time Macro Variable                           *;
**************************************************************************************;

%MACRO Update_DateTime;

	PROC SQL;
        	CONNECT TO ORACLE(USER=&oraid ORAPW=&orapsw BUFFSIZE=5000 PATH="&orapath");
                CREATE TABLE UpdActLgChecker AS SELECT * FROM CONNECTION TO ORACLE (
					SELECT MAX(ACTIVITY_DT)
                	FROM Activity_log
                        WHERE Patron_ID = 'SysOper'
                        AND   Request_Txt = 'LELimsGist'
                        AND   Condition_Txt = 'LIMS & GIST Extraction - Successful'
				);
                %PUT &SQLXRC;
                %PUT &SQLXMSG;
                %LET HSQLXRC = &SQLXRC;
                %LET HSQLXMSG = &SQLXMSG;
                DISCONNECT FROM ORACLE;
                QUIT;
	RUN;

	DATA UpdActLgChecker;
		SET UpdActLgChecker;
        Last_Update_Date=PUT(DATEPART(Max_Activity_Dt_),MMDDYY10.);
        Last_Update_Time=PUT(TIMEPART(Max_Activity_Dt_),TIMEAMPM9.);
        PUT Last_Update_Date Last_Update_Time;
        CALL SYMPUT('Save_Last_Update_Date',Last_Update_Date);
        CALL SYMPUT('Save_Last_Update_Time',Last_Update_Time);
    RUN;

%MEND Update_Datetime;

*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SEE LINKS SDS                                           *;
*   REQUIREMENT:      SEE LINKS FRS                                           *;
*   INPUT:            MACRO VARIABLES: _SERVER, SAVE_LINKSHOME, _THISSESSION  *;
*   PROCESSING:       Display warning screen that at least one selection must *;
*		      be made.		                                      *;
*   OUTPUT:           1 HTML screen to web browser                            *;
*******************************************************************************;
%MACRO Warning;
		DATA _NULL_; length LINE $500;
			FILE _WEBOUT; 
			SaveRptType="&Save_RptType";
			PUT 	'<BODY BGCOLOR="#808080">';
			PUT 	'<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" BORDER="0" CELLPADDING="0" CALLSPACING="0">';
			PUT 	'<TR ALIGN="LEFT" HEIGHT="8%"><TD BGCOLOR="#003366"><BIG><BIG><BIG>';
			LINE =	'<IMG SRC="http://'||"&_server"||'/links/images/gsklogo1.gif" WIDTH="141" HEIGHT="62">'; PUT LINE;
		    	IF SaveRptType='ST' THEN PUT 	'<FONT FACE=ARIAL COLOR="#FFFFFF"> LINKS Stability Module</FONT>';
		    	IF SaveRptType='RE' THEN PUT 	'<FONT FACE=ARIAL COLOR="#FFFFFF"> LINKS Batch Trending Module</FONT>';
			PUT 	'</BIG></BIG></BIG></TD></TR>';

			LINE = 	'<TR VALIGN="TOP"><TD  HEIGHT="84%" BGCOLOR="#ffffdd" ALIGN=center></BR></BR></BR></BR>'; PUT LINE;
			PUT 	'<FONT FACE=ARIAL COLOR="#FF0000"><P ALIGN=center><BIG><BIG><STRONG>'; 
			PUT 	'A selection must be made to continue.';
			PUT 	'</BR>Please use your browsers back button to go back to make a selection.</STRONG></FONT>';
			PUT 	'</TD></TR>';
			PUT 	'<TR ALIGN="right" HEIGHT="8%"><TD BGCOLOR="#003366">';
	 	 	LINE = '<A HREF="//'||SYMGET('_server')||'/links/'||"&SAVE_linkshome"||'.ASP?UserRole='|| "%SUPERQ(Save_UserRole)" ||'">'; PUT LINE;
			LINE =  '<FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Home</FONT></a>&nbsp&nbsp'; PUT LINE;
		   
			anchor1= '&nbsp;&nbsp;<A HREF="'|| "%SUPERQ(_THISSESSION)" || 
				'&_program=LINKS.LRQuery.sas&help=HELP">
				<FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Help</FONT></A>'; 
			PUT anchor1; 

			anchor2= '&nbsp;&nbsp;<A HREF="'|| "%SUPERQ(_THISSESSION)" ||
				'&_program=LINKS.LRLogoff.sas">
				<FONT FACE=ARIAL COLOR="#FFFFFF">Log off</FONT></A>&nbsp;&nbsp;'; 
			PUT anchor2; 

		    	PUT '</TD></TR></TABLE></BODY></HTML>';
	  RUN;
%MEND Warning;
*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SEE LINKS SDS                                           *;
*   REQUIREMENT:      SEE LINKS FRS                                           *;
*   INPUT:            MACRO VARIABLES: _SERVER, SAVE_LINKSHOME, _THISSESSION  *;
*   PROCESSING:       Display a help screen.                                  *;
*   OUTPUT:           1 HTML screen to web browser.                           *;
*******************************************************************************;
%MACRO Help;
	DATA _NULL_; length LINE $500; file _WEBOUT;
	  SaveRptType="&Save_RptType";
	  PUT 	'<BODY BGCOLOR="#808080">';
	  PUT 	'<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" BORDER="0" CELLPADDING="0" CALLSPACING="0">';
	  PUT 	'<TR ALIGN="LEFT" ><TD BGCOLOR="#003366"><BIG><BIG><BIG>';
	  LINE=	'<IMG src="http://'||"&_server"||'/links/images/gsklogo1.gif" WIDTH="141" HEIGHT="62">'; PUT LINE;
	  IF SaveRptType='ST' THEN PUT 	'<FONT FACE=ARIAL COLOR="#FFFFFF"><EM> LINKS </EM> Stability Module</FONT>';
	  IF SaveRptType='RE' THEN PUT 	'<FONT FACE=ARIAL COLOR="#FFFFFF"><EM> LINKS </EM> Batch Trending Module</FONT>';
	  PUT 	'</BIG></BIG></BIG></TD></TR>';

	  PUT 	'<TR><TD HEIGHT="87%" BGCOLOR="#FFFFDD" valign=top><p ALIGN=center><STRONG><BIG><BIG>';
	  IF SaveRptType='ST' THEN PUT 	'<FONT FACE=ARIAL COLOR="#FF0000"></BR>LINKS Stability Module Help</BIG></BIG></FONT>';
	  IF SaveRptType='RE' THEN PUT 	'<FONT FACE=ARIAL COLOR="#FF0000"></BR>LINKS Batch Trending Module Help</BIG></BIG></FONT>';
	  PUT 	'</BR></BR>';

	  PUT 	'<TABLE ALIGN=center WIDTH="80%"><TR><TD><FONT FACE=ARIAL COLOR="#003366">';
	  PUT 	'This series of screens provides a way for a LINKS user to set up query parameters for the LINKS database.';
	  PUT 	' Selections made from the checkbox screens will be used to create a temporary dataset which will eliminate the need to';
	  PUT 	'query the LINKS database multiple times. This will minimize processing time within the LINKS interface.'
	  PUT 	'Therefore it is recommended that a user selects all possible criteria needed for an analysis upfront.';
	  PUT 	'</BR></BR>The "Select All" button will select all values in the list and continue to the next screen.  Otherwise,';
	  PUT 	' make individual selections by checking';
	  PUT 	' multiple selections.  Then press the "Next" button. <STRONG> Important:  You must make at least one selection.</STRONG>';
      	  PUT 	' </BR></BR>Upon confirmation of the query parameters, the LINKS database will be queried to create a temporary dataset';
   	  PUT 	' that will be used for the remainder of the session to expediate report generation.  If the system times out while';
	  PUT 	' performing the query, please contact a LINKS Administrator.</FONT>';
	  PUT 	'</TD></TR></BR></BR>';
	  PUT 	'</TABLE>';
	  PUT 	'</TD></TR>';
	  PUT 	'<TR ALIGN="right" ><TD BGCOLOR="#003366">';

 	  LINE = '<A HREF="//'||SYMGET('_server')||'/links/'||"&SAVE_linkshome"||'.ASP?UserRole='|| "%SUPERQ(Save_UserRole)" ||'">'; PUT LINE;
	  LINE = '<FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Home</FONT></a>&nbsp&nbsp'; PUT LINE;

	  anchor= '&nbsp;&nbsp;<A HREF="'|| "%SUPERQ(_THISSESSION)" || 
		'&_program=LINKS.LRLogoff.sas"><FONT FACE=ARIAL COLOR="#FFFFFF">Log off</FONT></A>&nbsp;&nbsp;'; 
	  PUT anchor; 
	  PUT '</TD></TR></TABLE></body></html>';
%MEND Help;
*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SEE LINKS SDS                                           *;
*   REQUIREMENT:      SEE LINKS FRS                                           *;
*   INPUT:            MACRO VARIABLES: _SERVER, SAVE_LINKSHOME, _THISSESSION  *;
*   PROCESSING:       Display the LINKS update screen.                        *;
*   OUTPUT:           1 HTML screen to web browser.                           *;
*******************************************************************************;
%MACRO NoData;

	DATA _NULL_; length LINE $500; file _WEBOUT;
	  SaveRptType="&Save_RptType";NoDataErr="&NoDataErr";
	  PUT 	'<BODY BGCOLOR="#808080">';
	  PUT 	'<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" BORDER="0" CELLPADDING="0" CALLSPACING="0">';
	  PUT 	'<TR ALIGN="LEFT" ><TD BGCOLOR="#003366">';
	  LINE=	'<BIG><BIG><BIG><IMG SRC="http://'||"&_server"||'/links/images/gsklogo1.gif" WIDTH="141" HEIGHT="62">'; PUT LINE;
	  IF SaveRptType='ST' THEN PUT 	'<FONT FACE=ARIAL COLOR="#FFFFFF"><EM> LINKS </EM> Stability Module</FONT>';
	  IF SaveRptType='RE' THEN PUT 	'<FONT FACE=ARIAL COLOR="#FFFFFF"><EM> LINKS </EM> Batch Trending Module</FONT>';
	  PUT 	'</BIG></BIG></BIG></TD></TR>';
	  LINE=   '<TR><TD HEIGHT="87%" BGCOLOR="#FFFFDD" valign=top><p ALIGN=center><STRONG><BIG><BIG>';  PUT LINE;
	  IF NoDataErr='NODATA' THEN 
		PUT '<FONT FACE=ARIAL COLOR="#FF0000"></BR></BR></BR></BR></BR></BR>There is no data for the Date Range you selected.';
	  IF NoDataErr='ENDSTART' THEN 
		PUT '<FONT FACE=ARIAL COLOR="#FF0000"></BR></BR></BR></BR></BR></BR>Date Error: End Date is prior to Start Date.';
	  IF NoDataErr='STARTERR' THEN 
		PUT '<FONT FACE=ARIAL COLOR="#FF0000"></BR></BR></BR></BR></BR></BR>Date Error: Start Date selected is not a valid date.';
	  IF NoDataErr='ENDERR' THEN 
		PUT '<FONT FACE=ARIAL COLOR="#FF0000"></BR></BR></BR></BR></BR></BR>Date Error: End Date selected is not a valid date.';
	  IF NoDataErr='BOTHERR' THEN 
		PUT '<FONT FACE=ARIAL COLOR="#FF0000"></BR></BR></BR></BR></BR></BR>Date Error: Both dates selected are not valid dates.';

	  PUT   '</BIG></BIG></FONT></BR></BR>';
	  PUT '<TABLE ALIGN="center" WIDTH="80%"><TR><TD>';
	  PUT '<EM><FONT FACE=arial COLOR="#003366"><p ALIGN=center>';
	  PUT '</BR>Please use your browsers back button to go back and change your selection.</STRONG></FONT>';
	  PUT '</TD></TR></BR></BR>';
	  PUT '</TABLE>';
	  PUT '</TD></TR>';
	  PUT '<TR ALIGN="right" ><TD BGCOLOR="#003366">';

 	  LINE = '<A HREF="//'||SYMGET('_server')||'/links/'||"&SAVE_linkshome"||'.ASP?UserRole='|| "%SUPERQ(Save_UserRole)" ||'">'; PUT LINE;
	  LINE = '<FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Home</FONT></a>&nbsp&nbsp'; PUT LINE;

	  anchor1= '<A HREF="'|| "%SUPERQ(_THISSESSION)" || 
				'&_program='||"LINKS.LRQuery.sas"||
				'&help=HELP"><FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Help</FONT></A>'; 
	  PUT anchor1; 

	  anchor2= '&nbsp;&nbsp;<A HREF="'|| "%SUPERQ(_THISSESSION)" || 
		'&_program=LINKS.LRLogoff.sas"><FONT FACE=ARIAL COLOR="#FFFFFF">Log off</FONT></A>&nbsp;&nbsp;'; 
	  PUT anchor2; 
	  PUT '</TD></TR></TABLE></body></html>';
%MEND NoData;
*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SEE LINKS SDS                                           *;
*   REQUIREMENT:      SEE LINKS FRS                                           *;
*   INPUT:            MACRO VARIABLES: _SERVER, SAVE_LINKSHOME, _THISSESSION  *;
*   PROCESSING:       Display the LINKS update screen.                        *;
*   OUTPUT:           1 HTML screen to web browser.                           *;
*******************************************************************************;
%MACRO UpdInPrg;
	DATA _NULL_; length LINE $500; file _WEBOUT;
	  SaveRptType="&Save_RptType";
	  PUT 	'<BODY BGCOLOR="#808080">';
	  PUT 	'<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" BORDER="0" CELLPADDING="0" CALLSPACING="0">';
	  PUT 	'<TR ALIGN="LEFT" ><TD BGCOLOR="#003366">';
	  LINE=	'<BIG><BIG><BIG><IMG SRC="http://'||"&_server"||'/links/images/gsklogo1.gif" WIDTH="141" HEIGHT="62">'; PUT LINE;
	  IF SaveRptType='ST' THEN PUT 	'<FONT FACE=ARIAL COLOR="#FFFFFF"><EM> LINKS </EM> Stability Module</FONT>';
	  IF SaveRptType='RE' THEN PUT 	'<FONT FACE=ARIAL COLOR="#FFFFFF"><EM> LINKS </EM> Batch Trending Module</FONT>';
	  PUT 	'</BIG></BIG></BIG></TD></TR>';

	  LINE=   '<TR><TD HEIGHT="87%" BGCOLOR="#FFFFDD" valign=top><p ALIGN=center><STRONG><BIG><BIG>';  PUT LINE;
	  PUT   '<FONT FACE=ARIAL COLOR="#FF0000"></BR></BR></BR>The LINKS database is currently being updated.';
	  PUT   '</BIG></BIG></FONT></BR></BR>';

	  PUT '<TABLE ALIGN="center" WIDTH="80%"><TR><TD>';
	  PUT '<EM><FONT FACE=arial COLOR="#003366"><p ALIGN=center>';
	  PUT "Please wait a few minutes and then use your browser's refresh button to restart LINKS.";
	  PUT '  If the system fails to refresh after 10 minutes, please contact a LINKS administrator.</FONT></EM>';
	  PUT '</TD></TR></BR></BR>';
	  PUT '</TABLE>';
	  PUT '</TD></TR>';
	  PUT '<TR ALIGN="right" ><TD BGCOLOR="#003366">';

 	  LINE = '<A HREF="//'||SYMGET('_server')||'/links/'||"&SAVE_linkshome"||'.ASP?UserRole='|| "%SUPERQ(Save_UserRole)" ||'">'; PUT LINE;
	  LINE = '<FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Home</FONT></a>&nbsp&nbsp'; PUT LINE;

	  anchor1= '<A HREF="'|| "%SUPERQ(_THISSESSION)" || 
				'&_program='||"LINKS.LRQuery.sas"||
				'&help=HELP"><FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Help</FONT></A>'; 
	  PUT anchor1; 

	  anchor2= '&nbsp;&nbsp;<A HREF="'|| "%SUPERQ(_THISSESSION)" || 
		'&_program=LINKS.LRLogoff.sas"><FONT FACE=ARIAL COLOR="#FFFFFF">Log off</FONT></A>&nbsp;&nbsp;'; 
	  PUT anchor2; 
	  PUT '</TD></TR></TABLE></body></html>';
%MEND UpdInPrg;
*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: SEE LINKS SDS                                           *;
*   REQUIREMENT:      SEE LINKS FRS                                           *;
*   INPUT:    MACRO VARIABLES: ScreenVar, Help, Stop                          *;                       
*   PROCESSING:  Controls processing of program depending on input variables. *;
*   OUTPUT:  Multiple HTML screens to web browser.                            *;
*******************************************************************************;
%MACRO Decide;

	
	%IF %SUPERQ(ScreenVar)= AND %SUPERQ(HELP)^=HELP %THEN %init;

	%IF %SUPERQ(ScreenVar)=PROD_NM %THEN 
		%LET RC=%SYSFUNC(appsrv_session(create));			*** Create User Session		***;

	%LET CONDCODE=; %LET CLTDIR=;
	*** Execute GetParm ***;
	OPTIONS NOMPRINT MLOGIC NOSYMBOLGEN;
	%GetParm(SasServer, CtlDir, N);			%LET CtlDir     = &parm;
	OPTIONS MPRINT MLOGIC SYMBOLGEN;
	DATA _NULL_;
		dirrc = SYSTEM("DIR &CtlDir.CkRptFlg.txt >&CtlDir.LRQuery.txt");
		IF dirrc = 1 THEN DO;
			CALL SYMPUT ('CondCode',0);
			dirrc = SYSTEM("DEL &CtlDir.LRQuery.txt");
		END;
		ELSE CALL SYMPUT ('CondCode',12);
	RUN;

	%IF %SUPERQ(HELP)=HELP %THEN %Help;
	%ELSE %DO; 
		%IF &CondCode = 12 %THEN %UpdInPrg;
		%ELSE %DO;
			%Setup;
			%IF %SUPERQ(Stop)= OR %SUPERQ(ScreenVar)=CREATE_START_DT %THEN %DO;
				%IF %SUPERQ(Screenvar)^=SUMQUERY AND %SUPERQ(Screenvar)^=GETRESULTS AND %SUPERQ(Screenvar)^=LRREPORT %THEN %SCREENS;
				%ELSE %IF %SUPERQ(Screenvar)=SUMQUERY %THEN %QUERYSUM;
			%END;
			%ELSE %Warning;
		%END;
	%END; 
%MEND;
%Decide;
