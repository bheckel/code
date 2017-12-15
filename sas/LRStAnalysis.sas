********************************************************************************************;
*                     PROGRAM HEADER                                                        *;
*------------------------------------------------------------------------------------------*;
*  PROJECT NUMBER:  LINKS POT0206                                                          *;
*  PROGRAM NAME: LRSTAnalysis.SAS                  SAS VERSION: 8.2                        *;
*  DEVELOPED BY: Carol Hiser                       DATE: 11/21/2002                        *;
*  PROJECT REPRESENTATIVE: Carol Hiser                                                     *;
*  PURPOSE: Prompts the user to select study analysis, then generates report(s)            *;
*  SINGLE USE OR MULTIPLE USE? (SU OR MU) MU                                               *;
*  PROGRAM ASSUMPTIONS OR RESTRICTIONS: All documentation for this program                 *;
*	is covered under the LINKS report SOP.                                             *;
*------------------------------------------------------------------------------------------*;
*  OTHER SAS PROGRAMS, MACROS OR MACRO VARIABLES USED IN THIS                              *;
*  PROGRAM:   None.                                                                        *;
*------------------------------------------------------------------------------------------*;
*  DESCRIPTION OF OUTPUT:  Output can consist of 7 report types:	                   *;	
*	Scatterplot over Time, Histogram of Individual Results, Summary Statistics         *; 
*	Table, Initial Data vs. Product Release Run Chart, Cascade Impaction 	           *;	
*	Profiles, Study Details.                                                           *;
*   Report can be printed to the screen or as an RTF file.	                           *;
*------------------------------------------------------------------------------------------*;
********************************************************************************************;
*                      HISTORY OF CHANGE                                                   *;
* +-----------+---------+---------------+--------------------------------------------------*;
* |   DATE    | VERSION | NAME         	| Description                                      *;
* +-----------+---------+---------------+--------------------------------------------------*;
*  11/21/2002 |    1.0  | Carol Hiser  	| Original                                         *;
* +----------------------------------------------------------------------------------------*;
*  11/23/2002 |    2.0  | Carol Hiser  	| If testb is testdate and there are no non        *; 
*	      |		|	  	| missing test dates, the program will display     *;
*	      |		|		| warning screen that no valid data exists.        *;
*	      |		|		|                                                  *;
*   	      |		|		| Changed specifications for PRODRELEASE report    *;
*	      |		|		| to use Stability Specifications.  Updated        *;
*	      |		|		| stage definition for Batches dataset to be       *;
*	      |		|		| the same as STABILITY1.  Modified specification  *;
*	      |		|		| footnote for Summary Statistics table.           *;
* 	      |		|		|                                                  *;
*	      |		|		| Corrected footnote for CORR plot.                *;
*	      |		|		| Added date and time to study details footnote.   *;
*	      |		|		|                                                  *;
*	      |		|		| Revised horizontal correlation axis warning      *;
*	      |		|		| code for CORR plot to check only testb.          *;
*	      |		|		| Subsetted MaxData for Corr plot to use           *;
*	      |		|		| only time points in both test a and test b.      *;
* +-----------+---------+---------------+--------------------------------------------------*;
*  12/17/2002 |    3.0  | James Becker  | - Forced all Analysts that are BLANK and         *;
*             |         |               |   'No Data' to read 'No Analyst Data'.           *;
*	      |		|		| - Forced Y-Axis Pixels to 700 if RTF Histograms. *;                                             
*	      |		|		| - Disabled Test Method Drop down box if Test     *;
*	      |		|		|   is Cascade Impaction and Report type is        *;
*	      |		|		|   CIPROFILES.                                    *;
*	      |		|		| - Displayed message on Web Page that if screen   *;
*             |         |               |   printed from Web Browser, and not RTF option,  *;
*             |         |               |   that the report is unofficial.                 *;
* +----------------------------------------------------------------------------------------*;
*  12/18/2002 |    4.0  | Carol Hiser   | - Changed font for histograms to improve clarity *;
*             |         |               | of RTF files. Removed (DYNAMIC) from ODS HTML.   *;
*------------------------------------------------------------------------------------------*;
*  10/21/2003 |    5.0  | James Becker  | - VCC25658 - Amendmemt for MERPS/SAP             *;
*             |         |	        |   IN %MACRO REPORTS:                             *;
*             |         |               |   * Replaced sections refering to Lot_Nbr, to    *;
*             |         |               |     Matl_Nbr & Batch_Nbr.                        *;
*------------------------------------------------------------------------------------------*;
*  01/29/2004 |    6.0  | James Becker  | - VCC29954 - Correlation Plot Changes            *;
*             |         |               |   * Forced all "PEAK" variables to be lower case *;
*             |         |               |     except for comparing macro variables.        *;
*             |         |               |     - This was done through the entire program   *;
*------------------------------------------------------------------------------------------*;
*  14JUN2006  |   7.0   | Carol Hiser   | - VCC45936                                       *;
*	      |		|		|	- Removed references to datasets           *;
*	      |         |		|	  LRQueryRes_Relationships and             *;
*	      |		|		|	  LRQueryRes_Specs		           *;
*	      |		|		|	- Modified code so Initial Data vs 	   *;
*	      |		|		|	  ProdRelease report now works 	           *;
*	      |		|		|       - Removed RSD Data                         *;
*             |         |               |       - Change Test if user changes Product      *;
*             |         |               |       - Modified StudyDesc to reflect genealogy  *;
*             |         |               |         for MDPI, SD and MDI                     *;	
*------------------------------------------------------------------------------------------*;
*  19Jun2006  |   8.0   |  Carol Hiser  |  -VCC45936                                       *;
*                                            Modified to fix StudyDesc error               *;
*                                            Modified Initial vs Prod Release for Advair   *;	
*------------------------------------------------------------------------------------------*;
*  30OCT2006  |   9.0   |  Carol Hiser  | -VCC55049                                        *
*             |         |               |  Fixed specification error                       *;
*------------------------------------------------------------------------------------------*;
*  22JAN2007  |  10.0   | James Becker  |  VCC53434 %Reports                               *;
*             |         |               |   - Modified Reading in new Spec File            *;
*             |         |               |   -                                              *;
********************************************************************************************;
* 		Setup Module	 		 			                   *;
********************************************************************************************;
%LET METHOD=GET;
OPTIONS spool number nodate mlogic mprint symbolgen nosource nosource2 pageno=1; 

%GLOBAL DATATYPE vref href print warning warning2 study product test values vaxis0 haxis0 NUMALLSTUDY
        save_product save_testA save_storage save_studysub2 save_reportype save_prodinit save_condinit save_staginit save_peakinit 
	lowaxis upaxis axisby hlowaxis hupaxis haxisby xpixels0 ypixels0 xpixels ypixels reg0 reg2 reportype VALUE  
 	stageA stageB peakA PeakB class analyst numanalyst numtimes time RPTVALUE
        save_testinitb save_testinit datacheck DATACHECK0 cirptvalue testa testb storage groupvar corrtype NUMSTAGEA NUMSTAGEB
	TESTRPT SAVE_TESTRPTINIT OBSMAXPCT CILOWAXIS CIUPAXIS CIAXISBY INSETN INSETMEAN INSETSTD INSETMIN INSETMAX 
	INSETPNORMAL INSETCPK INSETPOS NORMAL USERLOWAXIS USERUPAXIS USERAXISBY USERHLOWAXIS USERHUPAXIS USERHAXISBY
	reg study0 byvar check HAXISCHK VAXISCHK testanew testbnew stageanew stagebnew peakanew peakbnew CIType
	Low_error Upr_Error Err_Axis RefWarning LowRefLine UprRefLine SpecVal reporttype2
;

****************************************************************************************************;
*                                      MODULE HEADER                                               *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;
*	REQUIREMENT     : See LINKS Report SOP                                                     *;
*       INPUT           : DATASET save.LRQueryRes_Database                                         *;
*       PROCESSING      : Setup initial macro variables. Create a macro Varlist                    *;
*		          to create lists of macro variables for a given dataset and variable.     *;
*		          Generate a list of all products, storage conditions and test methods.    *;
*       OUTPUT          : Initial macro variables.  Dataset LRQueryRes.                            *;
****************************************************************************************************;
	
%MACRO INIT;
	LIBNAME SERVERX 'D:\Sql_Loader\Metadata';

	PROC COPY IN = SAVE OUT=WORK;
		SELECT LRQueryRes_DataBase / memtype = data;		
	RUN;
	PROC COPY IN = SERVERX OUT=WORK;
		SELECT Links_Spec_File / memtype = data;		
	RUN;

	PROC SORT DATA=LRQueryRes_DataBase;
	BY Stability_Samp_Product Stability_Study_Grp_Cd Stability_Study_Nbr_Cd Stability_Samp_Stor_Cond Meth_Spec_Nm INDVL_METH_STAGE_NM;RUN;

	PROC SORT DATA=LRQueryRes_DataBase OUT=Test_Base NODUPKEY;
	BY Stability_Samp_Product Meth_Spec_Nm;RUN;
	DATA _NULL_;SET Test_Base;PUT Stability_Samp_Product Meth_Spec_Nm;RUN;

	DATA LRQUERYRES; SET LRQUERYRES_DATABASE;
		/* If test is dose or content per blister set result to actual units, otherwise use LIMS original results */
		IF UPCASE(LAB_TST_METH_SPEC_DESC) IN ('CU OF EMITTED DOSE IN ADVAIR MDPI', 'ADVAIR CONTENT PER BLISTER') 
			THEN RESULT=INDVL_TST_RSLT_VAL_UNIT;
			ELSE RESULT=INDVL_TST_RSLT_VAL_NUM;

IF UPCASE(LAB_TST_METH_SPEC_DESC) IN ('HPLC RELATED IMP.') THEN LAB_TST_METH_SPEC_DESC='HPLC Related Impurities';
		/* Delete individual missing results */
		IF RESULT = . THEN DELETE;

		/* If product is missing then delete */
		IF UPCASE(STABILITY_SAMP_PRODUCT) = 'ADVAIR DISKUS' THEN DELETE;

		/* Delete non-numeric test methods */
		IF UPCASE(LAB_TST_METH_SPEC_DESC) IN 
		('MLT FOR MDPI STRIPS', 'ADVAIR DISKUS APPEARANCE', 'APPEARANCE', 'MDPI MICROSCOPIC EVALUATION', 'ADVAIR MDPI ID BY UV') THEN DELETE;
		%IF %SUPERQ(DATATYPE)=APP %THEN %DO;  /* Include only approved data */
			WHERE SAMP_STATUS = '17';  
		%END;
	RUN;
/*
	DATA _NULL_; SET LRQueryRes; 
		BY Stability_Samp_Product Stability_Study_Grp_Cd Stability_Study_Nbr_Cd Stability_Samp_Stor_Cond Meth_Spec_Nm INDVL_METH_STAGE_NM;
		RETAIN obs 0;			* Check to see if this is the first execution of the program, if so setup initial ;
		INITCHK="&SAVE_PRODINIT";  	* product, condition, test method, and stage macro variables;
		obs=obs+1; 
		IF (obs=1 AND INITCHK ='') THEN DO;
			CALL SYMPUT('save_prodinit', TRIM(STABILITY_SAMP_PRODUCT));
  			CALL SYMPUT('save_condinit', TRIM(STABILITY_SAMP_STOR_COND));
  			CALL SYMPUT('save_testinit', TRIM(LAB_TST_METH_SPEC_DESC));
  			CALL SYMPUT('save_staginit', TRIM(INDVL_METH_STAGE_NM));
  			CALL SYMPUT('save_peakinit', TRIM(METH_PEAK_NM));
			PUT _ALL_;
		END;
		CALL SYMPUT('DATACHECK0','GO');  * Check for valid data;
	RUN; 
*/
	DATA _NULL_; SET LRQueryRes; 
		BY Stability_Samp_Product Stability_Study_Grp_Cd Stability_Study_Nbr_Cd Stability_Samp_Stor_Cond Meth_Spec_Nm INDVL_METH_STAGE_NM;
		RETAIN obs 0;			/* Check to see if this is the first execution of the program, if so setup initial */
		*WHERE COMPRESS(LAB_TST_METH_SPEC_DESC)=COMPRESS("&TestA") AND "&testA"^="&testB";
		obs=obs+1; 

		INITCHK0="&PRODUCT";  	/*** product, condition and test method macro variables  ***/
		INITCHK1="&SAVE_STAGINIT";
		INITCHK2="&SAVE_PEAKINIT";
		INITCHK3="&SAVE_TESTINIT";
		INITCHK4="&SAVE_CONDINIT";

		IF obs=1 AND INITCHK0 ='' THEN DO;  /* Modified V7 */
		    CALL SYMPUT('STUDY', '');
			CALL SYMPUT('save_prodinit', TRIM(STABILITY_SAMP_PRODUCT));
			CALL SYMPUT('PRODUCT', TRIM(STABILITY_SAMP_PRODUCT));
			PUT STABILITY_SAMP_PRODUCT;
			END;

		IF obs=1 AND INITCHK1 ='' THEN CALL SYMPUT('save_staginit', TRIM(INDVL_METH_STAGE_NM));
		IF obs=1 AND INITCHK2 ='' THEN CALL SYMPUT('save_peakinit', TRIM(METH_PEAK_NM));
  		IF obs=1 AND INITCHK3 ='' THEN CALL SYMPUT('save_testinit', TRIM(LAB_TST_METH_SPEC_DESC));
		IF obs=1 AND INITCHK4 ='' THEN CALL SYMPUT('save_condinit', TRIM(STABILITY_SAMP_STOR_COND));
		
		IF OBS=1 THEN CALL SYMPUT('TESTINIT',TRIM(LAB_TST_METH_SPEC_DESC));
						
		CALL SYMPUT('DATACHECK0','GO');  /* Check for valid data */
	RUN;

	%IF %SUPERQ(DATACHECK0)=GO %THEN %DO;
		%GLOBAL today rpttime IMPFLAG CIFLAG;  
		DATA _NULL_;  /* Create macros for date and time for use in footnotes */
	   		CALL SYMPUT('today',	TRIM(left(put(today(),worddate.))));
	   		CALL SYMPUT('rpttime', 	TRIM(left(put(time(),timeampm9.))));
		RUN;

		DATA _NULL_; /*  Setup initial macro values */
		/* If first execution of the program, set variable product, storage and testa to init variables */
		/* and set report to SCATTER		*/
			*product="&product";		*IF product='' 	     THEN CALL SYMPUT("PRODUCT","&save_prodinit");
			storage="&storage";		IF storage='' 	     THEN CALL SYMPUT("storage","&save_condinit");
			testA="&testa";  		IF testA='' 	     THEN CALL SYMPUT("testA",symget('save_testinit'));
			report="&reportype";		IF report='' 	     THEN CALL SYMPUT('reportype','SCATTER');
			stageA="&stagea";		IF stageA='' 	     THEN CALL SYMPUT('stageA',"&save_staginit");
			PeakA="&peaka";			IF peakA='' 	     THEN CALL SYMPUT('peakA',"&save_peakinit");

		/* Set Scatterplot variable VALUE to MEAN if not specified */
			VALUE="&VALUE";			IF VALUE='' 	     THEN CALL SYMPUT('VALUE','MEAN');

		/* If no report value is specified, set it to MEAN */
			rptvalue="&RPTVALUE";		IF RPTVALUE=''       THEN CALL SYMPUT('rptvalue','MEAN');

		/* Setup Histogram variables to default if not specified */
			analyst="&analyst"; 		IF analyst='' 	     THEN CALL SYMPUT('analyst','ALL');
	  		time="&time"; 			IF time='' 	     THEN CALL SYMPUT('time','ALL');
			class="&class";			IF class=''	     THEN CALL SYMPUT('class','TIME');

		/* Setup Correlation variables to default if not specified */
			corrtype="&corrtype";		IF corrtype='' 	     THEN CALL SYMPUT('corrtype','PLOT');
			groupvar="&groupvar";		IF groupvar='' 	     THEN CALL SYMPUT('groupvar','NONE');

		/* Set horizontal and vertical axis flages if user has entered custom axis values */
			USERHLOWAXIS="&USERHLOWAXIS";  	IF USERHLOWAXIS^=''  THEN CALL SYMPUT('HAXISCHK','USER');
			USERHUPAXIS ="&USERHUPAXIS";   	IF USERHUPAXIS^=''   THEN CALL SYMPUT('HAXISCHK','USER');
			USERHAXISBY ="&USERHAXISBY";   	IF USERHAXISBY^=''   THEN CALL SYMPUT('HAXISCHK','USER');
		
			USERLOWAXIS="&USERLOWAXIS";  	IF USERLOWAXIS^=''   THEN CALL SYMPUT('VAXISCHK','USER');
			USERUPAXIS ="&USERUPAXIS";   	IF USERUPAXIS^=''    THEN CALL SYMPUT('VAXISCHK','USER');
			USERAXISBY ="&USERAXISBY";   	IF USERAXISBY^=''    THEN CALL SYMPUT('VAXISCHK','USER'); 
		RUN;

		DATA _NULL_; 
		/* If the user has changed the product, generate new study list */
			*productchk1=COMPRESS("&save_prodinit");		*productchk2=COMPRESS("&product");  
			PEAKACHK=UPCASE(COMPRESS("&PEAKA"));  		PEAKBCHK=UPCASE(COMPRESS("&PEAKB"));
	 	 	*IF productchk1^=productchk2 THEN CALL SYMPUT('study',''); 
		
			test1chk1=COMPRESS("&save_testinit");	  	test1chk2=COMPRESS("&testA");  test2chk2=COMPRESS("&testb");
			IF test1chk2 IN ("HPLCAdvairMDPlCas.Impaction") THEN CALL SYMPUT('CIFLAG','YES'); /* Setup flag of CI test method */
			IF test1chk1 ^= test1chk2 THEN DO;  		/* If user changes test, reset stage and peak variables */
	    			CALL SYMPUT('stageA',' ');	
				CALL SYMPUT('peakA',' ');
			END;
			IF test1chk2 IN ('HPLCRelatedImp.inAdvairMDPI') THEN DO;
				CALL SYMPUT('IMPFLAG','YES');  		/* Setup flag for impurity test method */
		         	CALL SYMPUT('PEAKA','');	
				CALL SYMPUT('PEAKB','');  		/* Set peak variables to null */
			END;
			IF test1chk2 IN ('ForeignParticulateMatter') AND PEAKACHK = 'TOTALNUMBEROFPARTICLES' THEN CALL SYMPUT('STAGEA','Totals');
			IF test2chk2 IN ('ForeignParticulateMatter') AND PEAKBCHK = 'TOTALNUMBEROFPARTICLES' THEN CALL SYMPUT('STAGEB','Totals');
		RUN;

		DATA _NULL_; 
		**************************************************************************;
		*** V7 - If the user has changed the product, update parameters        ***;
		**************************************************************************;
			productchk1=COMPRESS("&save_prodinit");		productchk2=COMPRESS("&product");  

			IF (productchk1 ^= productchk2) THEN DO;  
			CALL SYMPUT("storage"," ");
					CALL SYMPUT('testA',' ');	
					CALL SYMPUT('TESTB', ' ');
					CALL SYMPUT('stageA',' ');
					CALL SYMPUT('STAGEB', ' ');	
					CALL SYMPUT('peakA',' ');
					CALL SYMPUT('PEAKB',' ');
					CALL SYMPUT('TIME', 'ALL');
					END;
		RUN;

		DATA _NULL_;  /* If testb is not specified, set testb, stageb and peakb variables to testa, stagea and peaka */
			testB="&testB";		TESTA="&TESTA";		
			IF testB='' 		THEN DO;
				CALL SYMPUT("testB",TRIM("&testA")); 
				CALL SYMPUT("stageB","&stageA");
				CALL SYMPUT("peakB","&peakA");
			END;
			IF TESTA ^= TESTB THEN DO;
				REPORTYPE="&REPORTYPE";
			    	IF REPORTYPE= 'CORR' THEN CALL SYMPUT('VALUE','MEAN');
	    		END;
		RUN;

		%GLOBAL RHTEMPFLG ;
		DATA _NULL_;   
	  		CIFLAG="&CIFLAG"; 	TEST2=UPCASE("&TESTB"); 
			/* Reset testb, stageb and peakb variables if testa is not CI and testb is temp or RH since temp and RH
			   data is only available for the Cascade Impaction test */
			IF  CIFLAG^='YES' AND TEST2 IN ('TEMPERATURE', 'RH') THEN DO;
				CALL SYMPUT('TESTB', TRIM("&TESTA"));
				CALL SYMPUT("stageB",TRIM("&stageA"));
				CALL SYMPUT("peakB", TRIM("&peakA"));
			END;
			ELSE IF CIFLAG='YES' AND TEST2 IN ('TEMPERATURE','RH','CINUM') THEN DO;  /* Set flag if testa is CI and testb is temperature or humidity */
				CALL SYMPUT('RHTEMPFLG','YES');
			END;
		RUN;

		DATA _NULL_;   /*  Setup macro values for use in where statements */
		   	CALL SYMPUT('TestAnew',	COMPRESS("&testA"));
		 	CALL SYMPUT('TestBnew',	COMPRESS("&testB"));
		  	CALL SYMPUT('StageAnew',COMPRESS("&stageA", '- '));
		  	CALL SYMPUT('StageBnew',COMPRESS("&stageB", '- '));
		  	CALL SYMPUT('PeakAnew',	COMPRESS("&peakA"));
	 	 	CALL SYMPUT('PeakBnew',	COMPRESS("&peakB"));
		RUN;
	
		/***************************************************************/
		/*  Create macro for creating a macro list of a given variable */
		/***************************************************************/
		%global whereprod;
		%MACRO VarList;  
			OPTIONS nomlogic nomprint nosymbolgen ;
			%GLOBAL NUM&var2 ;
			%LET NUM&Var2 = 0;

			DATA VARLIST0; SET &DATA &WHEREPROD; RUN;

			PROC SORT DATA=VARLIST0 NODUPKEY OUT=varlist1; BY &var; RUN;  /* Generate unique list */

			DATA varlist2; SET varlist1 NOBS=num&var2; BY &var ;
	    		RETAIN obs 0;
				obs=obs+1; OUTPUT;
				CALL SYMPUT("num&var2",num&var2);
			RUN;

			%DO i = 1 %TO &&num&var2;  /* Create macro variable for each value in unique list */
			%GLOBAL &var2&i ;
				DATA _NULL_; SET varlist2;
					WHERE obs=&i;
					put &var;
					CALL SYMPUT("&var2&i",TRIM(&var));
				RUN;
			%END;
			OPTIONS mlogic mprint symbolgen;
		%MEND VARLIST;

		%LET var=STABILITY_SAMP_PRODUCT;	%LET var2=PRODUCT;	%LET DATA=LRQueryRes; 	%varlist;  /* Create list of products */
		%LET var=stability_samp_stor_cond; 	%LET var2=storage;	%LET DATA=LRQueryRes; %let whereprod= (where= (STABILITY_SAMP_PRODUCT="&product"));	%varlist;  /* Create list of storage conditions */
		%LET var=lab_tst_meth_spec_desc;	%LET var2=test;		%LET DATA=LRQueryRes; %let whereprod= (where= (STABILITY_SAMP_PRODUCT="&product"));	%varlist;  /* Create list of tests */

			%IF %SUPERQ(TESTA)= %THEN %DO;

			DATA _NULL_;  /* ADDED V2 */
				CALL SYMPUT('TESTA', "&TEST1");   /* Modified V9.0 (took out compress)*/
				CALL SYMPUT('TESTANEW', COMPRESS("&TEST1"));
             	CALL SYMPUT('TESTB', "&TEST1");  /* Modified V9.0 (took out compress)*/
				CALL SYMPUT('TESTBNEW', COMPRESS("&TEST1"));
				RUN;
			 %END;

			%IF %SUPERQ(STORAGE)= %THEN %DO;

			DATA _NULL_;  /* ADDED V2 */
				CALL SYMPUT('STORAGE', COMPRESS("&STORAGE1"));
				CALL SYMPUT('STORAGENEW', COMPRESS("&STORAGE1"));
             RUN;	
			 %END;

		%GLOBAL INVALIDHAXIS INVALIDVAXIS;	/**  Check to see if user entered valid vertical and horizontal axis values **/
				/** If not, set invalid axis flag **/
		DATA _NULL_; LENGTH HINVALIDNUM1 HINVALIDNUM2 HINVALIDNUM3 HLOWAXISCHK HUPAXISCHK HAXISBYCHK 3 
			HLOWAXISCHKC HUPAXISCHKC HAXISBYCHKC VINVALIDNUM1 VINVALIDNUM2 VINVALIDNUM3 VLOWAXISCHK VUPAXISCHK VAXISBYCHK 3 
			VLOWAXISCHKC VUPAXISCHKC VAXISBYCHKC $10; 

			HAXISCHK="&HAXISCHK";		
			IF HAXISCHK='USER' THEN DO;
				Hlowaxischk="&userhlowaxis";	
	  			Hupaxischk="&userhupaxis";  	
	  			HAXISbychk="&userhaxisby";
				HlowaxischkC="&userhlowaxis";	
	  			HupaxischkC="&userhupaxis";  
	  			HAXISbychkC="&userhaxisby";
				HINVALIDNUM1=HlowaxisCHKC*1;
				HINVALIDNUM2=HupaxisCHKC*1;
				HINVALIDNUM3=HAXISBYCHKC*1;
	
				IF (HINVALIDNUM1=. OR HINVALIDNUM2=. OR HINVALIDNUM3=.)  	THEN CALL SYMPUT('INVALIDHAXIS','YES'); 
				ELSE DO;
					HAXISrange=HupaxisCHK-HlowaxisCHK; 
		  			IF HAXISRANGE^=. AND HAXISrange < HAXISbyCHK 	   	THEN CALL SYMPUT('INVALIDHAXIS','YES'); 
		  			IF (HupaxisCHK^=. AND HlowaxisCHK^=.) AND HupaxisCHK < HlowaxisCHK 	THEN CALL SYMPUT('INVALIDHAXIS','YES'); 
				END;
			END;

			VAXISCHK="&VAXISCHK";
			IF VAXISCHK='USER' THEN DO;
	  			Vlowaxischk  = "&USERlowaxis";	Vupaxischk="&USERupaxis";
	  			Vaxisbychk   = "&USERaxisby";	
				VlowaxischkC = "&USERlowaxis";	VupaxischkC="&USERupaxis";
	  			VaxisbychkC  = "&USERaxisby";
		  		
				VINVALIDNUM1=VLOWAXISCHKC*1;
				VINVALIDNUM2=VUPAXISCHKC*1;
				VINVALIDNUM3=VAXISBYCHKC*1;
				/* Check for invalid numeric values */
				IF (VINVALIDNUM1=. OR VINVALIDNUM2=. OR VINVALIDNUM3=.)  		  THEN CALL SYMPUT('INVALIDVAXIS','YES'); 
				ELSE DO;  /* Check for valid axisrange, lowaxis and upaxis values */
					Vaxisrange=Vupaxischk-Vlowaxischk;
			    		IF Vaxisrange^=. and (Vaxisrange < Vaxisbychk OR Vaxisbychk <=0) THEN CALL SYMPUT('INVALIDVAXIS','YES'); 
					IF Vaxisrange^=. and (Vupaxischk < Vlowaxischk) 		  THEN CALL SYMPUT('INVALIDVAXIS','YES'); 
	 			END;
			END;
		RUN;
	%END;

%MEND INIT;

****************************************************************************************************;
*                                  MODULE HEADER                                                   *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;
*	REQUIREMENT     : See LINKS Report SOP                                                     *;
*       INPUT           : DATASETS: SAVE.LRQUERYRES_DATABASE, SAVE.LRQUERYRES_BATCHES,             *;
*			  SAVE.LRQUERYRES_SPECS.  MACRO VARIABLES: PRODUCT, TESTANEW,              *;
*			  TESTBNEW, STORAGE, REPORTYPE, STAGEA, PEAKA, RHTEMPFLAG.                 *;
*       PROCESSING      : Setup where statements for subsetting by product, storage                *;
*		          condition and test.  Create Stability1 dataset for stability data,       *;
*		          create Batches1 dataset for product release data, create Specs0 for      *;
*		          specification data.                                                      *;
*       OUTPUT          : DATASETS: STABILITY1, BATCHES1, SPECS1.  MACRO VARIABLES:                *;
*			  STAGEA1,...STAGEA#, PEAKA1,...PEAKA#, STAGEB1,....STAGEB#,               *;
*			  PEAKB1,...PEAKB#, NUMSTAGEA, NUMPEAKA, NUMSTAGEB, NUMPEAKB.              *;
*                                                                                                  *;     
****************************************************************************************************;
%MACRO SUBSET1;

	DATA _NULL_;  /* Create where statements for product, storage condition and test.  Where1A is used for stability data, Where1B is used for product release data */
		product=COMPRESS("&product");   reportype="&reportype";  TESTB=UPCASE("&TESTB");
		IF reportype='CORR' AND TESTB NOT IN ('TEMPERATURE','RH','TESTDATE2') THEN DO; /*Select testa and testb for correlation plots */
		  	 /* Select specified products, testa and testb, and storage condition (where1a only) */
			CALL SYMPUT('where1A','WHERE compress(lab_tst_meth_spec_desc) IN ("&testanew","&testBnew") and compress(STABILITY_SAMP_PRODUCT)=COMPRESS("&product") and compress(stability_samp_stor_cond)=COMPRESS("&storage")');
			CALL SYMPUT('where1B','WHERE compress(lab_tst_meth_spec_desc) IN ("&testanew","&testBnew") and compress(STABILITY_SAMP_PRODUCT)=COMPRESS("&product")');
		END;
		ELSE DO;  
			 /* Select specified products, testa only, and storage condition (where1a only) */
			CALL SYMPUT('where1A','WHERE compress(lab_tst_meth_spec_desc) IN ("&testanew") and compress(STABILITY_SAMP_PRODUCT)=compress("&product") and compress(stability_samp_stor_cond)=compress("&storage")');
			CALL SYMPUT('where1B','WHERE compress(lab_tst_meth_spec_desc) IN ("&testanew") and compress(STABILITY_SAMP_PRODUCT)=compress("&product")'); 				
		END;
	RUN;

	%GLOBAL DATACHECK1A DATACHECK1B;
	/* Create dataset for Stability data */
	DATA STABILITY1 ; LENGTH ANALYST $30 STAGE PEAK $50; SET LRQueryRes;	
		&where1A;   /* Select test, condition and product using above created Stability WHERE clause*/
		CALL SYMPUT('DataCheck1A','GO');   /* Set flag if data exists */

		Product	= STABILITY_SAMP_PRODUCT;		/*  Rename/Reformat variables */
		Storage = STABILITY_SAMP_STOR_COND;
		Test	= LAB_TST_METH_SPEC_DESC;  
		Peak	= METH_PEAK_NM;
		IF Peak = 'FLUTICASONE' THEN Peak ='Fluticasone';
		IF Peak = 'SALMETEROL'  THEN Peak ='Salmeterol';
		IF COMPRESS(UPCASE(TEST)) = 'FOREIGNPARTICULATEMATTER' AND COMPRESS(UPCASE(PEAK))='TOTAL' 
			THEN PEAK='Total Number of Particles'; 
		/* Setup Stage variable depending on test */
		IF COMPRESS(TEST) = 'HPLCAdvairMDPlCas.Impaction'  THEN Stage=TRIM(LEFT(INDVL_METH_STAGE_NM)); 
		ELSE IF COMPRESS(TEST)='HPLCRelatedImp.inAdvairMDPI' THEN DO;
			IF INDVL_METH_STAGE_NM='UNSPECIFIED' THEN DO;
				IF INDVL_TST_RSLT_NM^='' THEN STAGE=TRIM(PEAK)||'-'||TRIM(LEFT(INDVL_TST_RSLT_NM));
				ELSE STAGE='Any Unspec. Degradent-'||TRIM(LEFT(PEAK));
			END;
			ELSE IF INDVL_METH_STAGE_NM='TOTAL' THEN STAGE='Total Degradents';
			ELSE IF PEAK ^='NONE' THEN Stage=TRIM(INDVL_METH_STAGE_NM)||'-'||TRIM(PEAK); 
			ELSE Stage=TRIM(INDVL_METH_STAGE_NM);
		END;
		ELSE IF COMPRESS(UPCASE(TEST)) = 'FOREIGNPARTICULATEMATTER' AND
				COMPRESS(UPCASE(INDVL_METH_STAGE_NM))='NONE' THEN STAGE='Totals'; 
		ELSE Stage=INDVL_METH_STAGE_NM; 
			
		Study     = STABILITY_STUDY_NBR_CD;
		/* Modified V4 */
		Analyst   = UPCASE(CHECKED_BY_USER_ID);		IF Analyst IN ('','N/A','NA') THEN Analyst = 'No Analyst Data';	
		Time      = STABILITY_SAMP_TIME_VAL;
		Timeweeks = STABILITY_SAMP_TIME_WEEKS;
		TESTDATE2 = DATEPART(SAMP_TST_DT); 

		Test2    = COMPRESS(tranwrd(LAB_TST_METH_SPEC_DESC,'&','and'));  /* Compress dataset variables for use in where statement */
		Storage2 = COMPRESS(stability_samp_stor_cond);
		Product2 = COMPRESS(PRODUCT);
		Stage2   = COMPRESS(STAGE,'- ');
  		Peak2    = COMPRESS(PEAK);

		FORMAT TESTDATE2 DATE9.;
	RUN;
	
	%IF %SUPERQ(REPORTYPE)=PRODRELEASE %THEN %DO;	/* Create dataset for product release data*/

		LIBNAME OUTDIR 'D:\SQL_LOADER\METADATA';

		PROC SUMMARY DATA=STABILITY1;
			VAR MATL_MFG_DT;
			ID PROD_NM;
			OUTPUT OUT=DATERANGE MIN=MIN_DT MAX=MAX_DT;
		RUN;

		**************************************************************************;
		*** V7 - for Initial Data vs Prod Release                              ***;
		**************************************************************************;

		DATA _NULL_; SET DATERANGE;  
			CALL SYMPUT('MIN_DT', MIN_DT - 64800);
			CALL SYMPUT('MAX_DT', MAX_DT + 64800);
			IF UPCASE(PROD_NM) ^='ADVAIR DISKUS' THEN DO;
			CALL SYMPUT('PRODUCTDATA', COMPRESS(PROD_NM));
			CALL SYMPUT('SETSTATEMENT', 'SET OUTDIR.LEMETADATA_&PRODUCTDATA');
			END;
			ELSE DO;
				CALL SYMPUT('PRODUCTDATA', 'ADVAIRDISKUSRELEASE');
				CALL SYMPUT('SETSTATEMENT', 'set STABILITY1 OUTDIR.LEMETADATA_&PRODUCTDATA');
				END;
		RUN;

		DATA BATCHES; LENGTH STAGE STAGE2 $50; &SETSTATEMENT;  
			&WHERE1B AND MATL_MFG_DT >=&MIN_DT AND MATL_MFG_DT <= &MAX_DT;	/* Select test and product using above created product release WHERE clause */
			
			CALL SYMPUT('DataCheck1B','GO');   /* Set flag if data exists */
			Product		=	STABILITY_SAMP_PRODUCT;
			Test		=	LAB_TST_METH_SPEC_DESC;  /*  Rename/Reformat variables */
			Peak		=	METH_PEAK_NM;
			/* Modified V3 */
			Analyst   = UPCASE(CHECKED_BY_USER_ID);		IF Analyst IN ('','N/A') THEN Analyst = 'No Analyst Data';
			IF PEAK='FLUTICASONE' THEN PEAK='Fluticasone';
			IF PEAK='SALMETEROL' THEN PEAK='Salmeterol';
			IF COMPRESS(UPCASE(TEST)) = 'FOREIGNPARTICULATEMATTER' AND COMPRESS(UPCASE(PEAK))='TOTAL' 
				THEN PEAK='Total Number of Particles'; 
			
			/* Changed V2 to be same as Stability*/
			IF COMPRESS(UPCASE(TEST)) = 'FOREIGNPARTICULATEMATTER' AND COMPRESS(UPCASE(PEAK))='TOTAL' 
				THEN PEAK='Total Number of Particles'; 
			/* Setup Stage variable depending on test */
			IF COMPRESS(TEST) = 'HPLCAdvairMDPlCas.Impaction'  THEN Stage=TRIM(LEFT(INDVL_METH_STAGE_NM)); 
			ELSE IF COMPRESS(TEST)='HPLCRelatedImp.inAdvairMDPI' THEN DO;
				IF INDVL_METH_STAGE_NM='UNSPECIFIED' THEN DO;
					IF INDVL_TST_RSLT_NM^='' THEN STAGE=TRIM(PEAK)||'-'||TRIM(LEFT(INDVL_TST_RSLT_NM));
					ELSE STAGE='Any Unspec. Degradent-'||TRIM(LEFT(PEAK));
				END;
				ELSE IF INDVL_METH_STAGE_NM='TOTAL' THEN STAGE='Total Degradents';
				ELSE IF PEAK ^='NONE' THEN Stage=TRIM(INDVL_METH_STAGE_NM)||'-'||TRIM(PEAK); 
				ELSE Stage=TRIM(INDVL_METH_STAGE_NM);
			END;
			ELSE IF COMPRESS(UPCASE(TEST)) = 'FOREIGNPARTICULATEMATTER' AND COMPRESS(UPCASE(INDVL_METH_STAGE_NM))='NONE' 
				THEN STAGE='Totals'; 
				ELSE Stage=INDVL_METH_STAGE_NM; 	
					
			STAGE2=COMPRESS(STAGE,'- ');
			/* If test is dose or content per blister set result to actual units, otherwise use LIMS original results */
			IF UPCASE(LAB_TST_METH_SPEC_DESC) IN ('CU OF EMITTED DOSE IN ADVAIR MDPI', 'ADVAIR CONTENT PER BLISTER') 
				THEN Result=INDVL_TST_RSLT_VAL_UNIT;
				ELSE RESULT=INDVL_TST_RSLT_VAL_NUM;

			IF STABILITY_STUDY_NBR_CD='' THEN STUDYFLAG=1; 
			ELSE STUDYFLAG=0;

			IF RESULT = . THEN DELETE;	  /* Delete missing data */	
		RUN;

		%IF %SUPERQ(PRODUCTDATA)=ADVAIRDISKUSRELEASE %THEN %DO;  /* added V8 */
		PROC SORT DATA =batches nodupkey ; BY BATCH_Nbr; RUN;
		%END;
/*
		
		proc freq data=batches noprint; table study*batch_nbr/out=check; run;

		data _null_; set check; put study batch_nbr ; run;*/

	%END;
	%ELSE %LET DATACHECK1B=GO;

		**************************************************************************;
		*** V7 - Modified creatation of specification dataset                  ***;
		**************************************************************************;
	DATA SPECS0; LENGTH SPEC_TYPE $25 LOWERI UPPERI LOWERM UPPERM 8 STAGE $50; SET Links_Spec_File; 
		&WHERE1b ;  /* Subset for selected tests and product(s) */
/*		SPEC_TYPE=UPCASE(LAB_TST_DESC);*/
		MEANCHECK=INDEX(SPEC_TYPE,'MEAN');  /*  Setup specification type */
		INDCHECK=INDEX(SPEC_TYPE,'INDIV');

/**		MEANCHECK=INDEXW(SPEC_TYPE,'MEAN');       
		INDCHECK=INDEXW(SPEC_TYPE,'INDIVIDUAL')+INDEXW(SPEC_TYPE,'INDIV')
				+INDEXW(SPEC_TYPE,'INDIVIDUALS')+INDEXW(SPEC_TYPE,'INDI')+INDEXW(SPEC_TYPE,'COUNT')
				+INDEXW(SPEC_TYPE,'PART')+INDEXW(SPEC_TYPE,'APPEARANCE')+INDEXW(SPEC_TYPE,'SIOA')
				+INDEXW(SPEC_TYPE,'SCRE')+INDEXW(SPEC_TYPE,'TOTA')+INDEXW(SPEC_TYPE,'ID B')
				+INDEXW(SPEC_TYPE,'SALM')+INDEXW(SPEC_TYPE,'FLUT');
				IF SPEC_TYPE='FINAL DISSOLUTION RESULT' THEN INDCHECK=1;
		MINCHECK=INDEXW(SPEC_TYPE,'MIN') ;  
		MAXCHECK=INDEXW(SPEC_TYPE,'MAX');
		IF INDEXW(LAB_TST_DESC, 'RSD')>0 THEN DELETE; 
**/
		IF MEANCHECK = 0 AND INDCHECK=0 THEN DELETE; 

		if meancheck>0 then do;   /* Setup Mean specifications */
			SPEC_TYPE='MEAN';
			IF low_limit ^=0 then LOWERM=PUT(LOW_LIMIT,8.2); ELSE LOWERM=.;
			UPPERM=PUT(UPR_LIMIT,8.2);
			END;
		IF INDCHECK>0 THEN DO;  /* Setup Individual specifications */
			SPEC_TYPE='INDIVIDUAL';
			IF LOW_LIMIT ^=0 THEN LOWERI=PUT(LOW_LIMIT,8.2); ELSE LOWERI=.;
			UPPERI=PUT(UPR_LIMIT,8.2);
			END;

		Product	=	STABILITY_SAMP_PRODUCT;  /*  Rename/Reformat variables */
		Test	=	LAB_TST_METH_SPEC_DESC;  
		Peak	=	METH_PEAK_NM;
		IF PEAK='FLUTICASONE' THEN PEAK='Fluticasone';
		IF PEAK='SALMETEROL'  THEN PEAK='Salmeterol';
		IF COMPRESS(UPCASE(TEST)) = 'FOREIGNPARTICULATEMATTER' AND COMPRESS(UPCASE(PEAK))='TOTAL' 
			THEN PEAK='Total Number of Particles'; 

		/* Setup Stage variable depending on test */
		IF COMPRESS(TEST) = 'HPLCAdvairMDPlCas.Impaction'  THEN Stage=TRIM(LEFT(INDVL_METH_STAGE_NM)); 
		ELSE IF COMPRESS(TEST)='HPLCRelatedImp.inAdvairMDPI' THEN DO;
			IF UPCASE(INDVL_METH_STAGE_NM)='TOTAL' THEN STAGE='Total Degradents';
			ELSE IF UPCASE(INDVL_METH_STAGE_NM)='UNSPECIFIED' THEN STAGE='Any Unspec. Degradent-'||TRIM(LEFT(PEAK)); 
			ELSE IF PEAK ^='NONE' THEN Stage=TRIM(INDVL_METH_STAGE_NM)||'-'||TRIM(PEAK); 
			ELSE Stage=TRIM(INDVL_METH_STAGE_NM);
		END;
		ELSE IF COMPRESS(UPCASE(TEST)) = 'FOREIGNPARTICULATEMATTER' THEN DO;  /* Changed V2 */
				IF COMPRESS(UPCASE(INDVL_METH_STAGE_NM))='NONE' THEN STAGE='Totals'; 
		END;
		ELSE Stage=INDVL_METH_STAGE_NM; 
			
		Stage2=COMPRESS(STAGE, '- ');
		IF MEANCHECK>0 THEN CALL SYMPUT('SpecVal','MEAN');
		IF INDCHECK >0 THEN CALL SYMPUT('SpecVal','INDIVIDUAL');
		/*DROP SPEC_TYPE;*/
	RUN;

	/* Select stability specifications */  /*  Changed V2-Took out Product release specs */
		DATA SPECS1; SET SPECS0;
			WHERE SPEC_GROUP='STABILITY';
			IF TXT_LIMIT_A='' THEN DELETE;
		RUN;
		
	%IF %SUPERQ(DATACHECK1A)=GO %THEN %DO;	
		DATA stageA1; SET STABILITY1; /* If stability data exists, generate list of stages and peaks for test A */
			WHERE test2="&testAnew";  /* for use in drop down boxes */
		RUN;

		%LET var=stage; %LET var2=stageA; %LET DATA=stageA1; %varlist;  
		%LET var=peak;  %LET var2=peakA;  %LET DATA=stageA1; %varlist;

		DATA stageB1; SET STABILITY1; /* If stability data exists, generate list of stages and peaks for test B */
			WHERE test2="&testBnew";  /* for use in drop down boxes */
		RUN;
		%LET var=stage; %LET var2=stageB; %LET DATA=stageB1; %varlist;  
		%LET var=peak;  %LET var2=peakB;  %LET DATA=stageB1; %varlist;
    
		%GLOBAL STAGE1NEW PEAK1NEW;
		DATA _NULL_; 
			/***************************************************************************************/	
			StageA="&StageA";  PeakA="&PeakA"; testA="&testA";
			IF INDEX(StageA,'Stage')>0 THEN Flg='Y';ELSE Flg='N';
			IF Flg='Y' THEN CALL SYMPUT('StageAnew',SUBSTR(COMPRESS("&StageA", '- '),6));
			IF Flg='N' THEN CALL SYMPUT('StageAnew',COMPRESS("&StageA", '- '));

	    		IF stageA='' THEN DO;  /* If stageA is null, set it to the first stage in the list */
	       			CALL SYMPUT('stageA',"&stageA1");
				CALL SYMPUT('stageAnew',COMPRESS("&stageA1", '- '));
		    		stageA="&stageA1";
			END;
			IF peakA='' THEN DO;  /* If peakA is null, set it to the first peak in the list */
	    			CALL SYMPUT('peakA',"&peakA1");
				CALL SYMPUT('peakAnew',COMPRESS("&peakA1"));
			END;
				IF testA = 'HPLC Related Imp. In Advair MDPI' THEN DO;
				IF SUBSTR(UPCASE(stageA),1,1)='G' THEN DO;
		    			CALL SYMPUT('peakA',"Salmeterol");
					CALL SYMPUT('peakAnew',"Salmeterol");
					CALL SYMPUT('peakAchk',"Salmeterol");
				END;
				ELSE IF SUBSTR(UPCASE(stageA),1,2)='TO' THEN DO;
		    			CALL SYMPUT('peakA',"NONE");
					CALL SYMPUT('peakAnew',"NONE");
				END;
			END;
			/***************************************************************************************/	
			StageB="&StageB";  PeakB="&PeakB"; testB="&testB";
			IF INDEX(StageB,'Stage')>0 THEN Flg='Y';ELSE Flg='N';
			IF Flg='Y' THEN CALL SYMPUT('StageBnew',SUBSTR(COMPRESS("&StageB", '- '),6));
			IF Flg='N' THEN CALL SYMPUT('StageBnew',COMPRESS("&StageB", '- '));
    			IF stageB='' THEN DO;  /* If stageB is null, set it to the first stage in the list */
	       			CALL SYMPUT('stageB',"&stageB1");
				CALL SYMPUT('stageBnew',COMPRESS("&stageB1", '- '));
		    		stageB="&stageB1";
			END;
			IF peakB='' THEN DO;  /* If peakB is null, set it to the first peak in the list */
	    			CALL SYMPUT('peakB',"&peakB1");
				CALL SYMPUT('peakBnew',COMPRESS("&peakB1"));
			END;
			IF testB = 'HPLC Related Imp. In Advair MDPI' THEN DO;
				IF SUBSTR(UPCASE(stageB),1,1)='G' THEN DO;
		    			CALL SYMPUT('peakB',"Salmeterol");
					CALL SYMPUT('peakBnew',"Salmeterol");
					CALL SYMPUT('peakBchk',"Salmeterol");
				END;
				ELSE IF SUBSTR(UPCASE(stageB),1,2)='TO' THEN DO;
		    			CALL SYMPUT('peakB',"NONE");
					CALL SYMPUT('peakBnew',"NONE");
				END;
			END;
		RUN;    	  

		%IF %SUPERQ(reportype)=CORR %THEN %DO;  /* Execute this code only if report type is CORR and testb is not */
			%IF %SUPERQ(RHTEMPFLG)= AND %SUPERQ(TESTBNEW)^=TESTDATE2 %THEN %DO;		/* TEMPERATURE, RH or TESTDATE2 */

				DATA stageB1; SET STABILITY1;  /* Generate list of stages and peaks for test B for use in drop down boxes*/
					WHERE test2="&testBnew";
				RUN;

				%LET var=stage; %LET var2=StageB; %LET DATA=stageB1; %varlist;
				%LET var=peak;  %LET var2=PeakB;  %LET DATA=stageB1; %varlist;
	
				%GLOBAL PEAKBNEW STAGEBNEW;
				DATA _NULL_; 
					StageB="&StageB";  PeakB="&PeakB";
					IF INDEX(StageB,'Stage')>0 THEN Flg='Y';ELSE Flg='N';
		    			IF StageB='' THEN DO;   /* If stageB is null, set it to the first stage in the list */
						CALL SYMPUT('StageB',"&StageB1");
						IF Flg='Y' THEN CALL SYMPUT('StageBnew',SUBSTR(COMPRESS("&StageB1", '- '),6));
						IF Flg='N' THEN CALL SYMPUT('StageBnew',COMPRESS("&StageB1", '- '));
					END;
					IF PeakB='' THEN DO;  /* If peakB is null, set it to the first peak in the list */
						CALL SYMPUT('PeakB',"&PeakB1");
						CALL SYMPUT('PeakBnew',COMPRESS("&PeakB1"));
					END;
				RUN;    	
			%END; 
		%END;
	%END;
%MEND SUBSET1; 

****************************************************************************************************;
*                                       MODULE HEADER                                              *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *; 
*	REQUIREMENT     : See LINKS Report SOP                                                     *;
*       INPUT           : DATASET STABILITY2, BATCHES2, SPECS2.                                    *; 
*       PROCESSING      : Create where statement for subsetting by stage and peak.                 *;
*		          Create datasets Stability2, Batches2 and Specs2, using where statement.  *;                   
*       OUTPUT          : DATASETS: STABILITY2, BATCHES2, SPECS2. MACRO VARIABLES:                 *;
*		          ALLSTUDY1,..ALLSTUDY#, NUMALLSTUDY, ANALYST1,...ANALYST#, NUMANALYST,    *;
*		          DATACHECK2A, DATACHECK2B.                                                *;
****************************************************************************************************;
%MACRO SUBSET2;
	%GLOBAL DATACHECK2A DATACHECK2B SPECCHK SPECCHKB WHERE2 StagePresent;
	%LET StagePresent=0;
	DATA _NULL_;
		testA="&testA";  reportype="&reportype";
		IF reportype = 'CORR' THEN DO;  /* Generate where clause for stage A and peak A only for CORR reports */
			IF testa NOT IN ('HPLC Related Imp. in Advair MDPI') 
			THEN CALL SYMPUT('where2','WHERE (COMPRESS(test) = "&testanew" and COMPRESS(Stage,"- ")="&stageAnew" and UPCASE(COMPRESS(peak))=UPCASE("&peakAnew")) or 
				          (COMPRESS(test) = "&testBnew" and COMPRESS(Stage, "- ")="&stageBnew" and UPCASE(COMPRESS(peak))=UPCASE("&peakBnew"))') ;
			ELSE CALL SYMPUT('where2','WHERE (COMPRESS(test) = "&testanew" and COMPRESS(Stage,"- ")="&stageAnew" ) or (COMPRESS(test) = "&testBnew" and COMPRESS(Stage, "- ")="&stageBnew" )') ;
		END;

		ELSE  DO;  /* Generate where clause for stage and peak for all other reports */
			IF reportype ^="CIPROFILES" AND testa NOT IN ('HPLC Related Imp. in Advair MDPI', 'Impurities') 
				THEN CALL SYMPUT('where2','WHERE UPCASE(COMPRESS(Stage, "- ")) = UPCASE(COMPRESS("&stageAnew", "- ")) and UPCASE(COMPRESS(Peak)) IN ("'||UPCASE(TRIM("&peakAnew"))||'")');
			ELSE IF REPORTYPE='CIPROFILES' 
				THEN CALL SYMPUT('where2','WHERE UPCASE(COMPRESS(Peak)) IN ("'||UPCASE(TRIM("&peakAnew"))||'")');
			ELSE IF TESTA='HPLC Related Imp. in Advair MDPI' 
				THEN CALL SYMPUT('where2','WHERE COMPRESS(Stage, "- ") IN ("'||TRIM("&stageAnew")||'")');
			ELSE IF upcase(TESTA)='IMPURITIES' THEN 
				CALL SYMPUT('where2','WHERE UPCASE(COMPRESS(Peak)) IN ("'||UPCASE(TRIM("&peakAnew"))||'")');
		END;
	RUN;

	PROC SUMMARY DATA=STABILITY1 NWAY;
	CLASS Product stage;
	OUTPUT OUT=CIOUT
	n(Indvl_Tst_Rslt_Val_Num)=numcnt;
	RUN;

	DATA _NULL_; SET CIOUT;
		WHERE Product = "&Product" AND stage="&StageA";
		CALL SYMPUT('StagePresent',1);
	RUN;
 
	%IF %SUPERQ(StagePresent)=0 %THEN %DO;
		DATA _NULL_; SET CIOUT;
			WHERE Product = "&Product";
			PUT Stage numcnt;
			Obs+1;
			IF _N_ = 1 THEN DO;
				CALL SYMPUT('STAGEANEW',stage);
				CALL SYMPUT('STAGEA',stage);
			END;
		RUN;
	%END;

	DATA _NULL_; SET CIOUT;
		WHERE Product = "&Product";
		PUT Stage numcnt;
		Obs+1;
		IF Obs=06 THEN CALL SYMPUT('CIType','POOLED   ');
		IF Obs=12 THEN CALL SYMPUT('CIType','FULL     ');
		IF Obs=13 THEN CALL SYMPUT('CIType','NONPOOLED');     		
	RUN;

	data _null_ ; set stability1;
	put meth_peak_nm;
	run;

	DATA STABILITY2; SET STABILITY1;
		&where2;   						 	/* Select stage and peak names */
		testbchk="&testb";  /* ADDED V2 */
  		if testbchk='TESTDATE2' and testdate2=. THEN DELETE;
	  	CALL SYMPUT('datacheck2A','GO');  /* Set flag if data exists */
	RUN;

	%IF %SUPERQ(REPORTYPE)=PRODRELEASE %THEN %DO;
	
		DATA BATCHES1; SET BATCHES;					/* Select stage and peak names */
			&WHERE2;						/* Set flag if data exists */
			CALL SYMPUT('datacheck2B','GO');  
		RUN;
	
	%END;
	%ELSE %LET DATACHECK2B=GO;

	%IF %SUPERQ(DATACHECK2A)=GO %THEN %DO;
		DATA SPECS2; SET SPECS1;					/* Select stage and peak names */
			&WHERE2;
			IF TEST="&TESTA" THEN CALL SYMPUT('SPECCHK','YES');	/* Set flag if specs exists for Test A*/
			IF TEST="&TESTB" THEN CALL SYMPUT('SPECCHKB','YES'); 	/* Set flag if specs exists for Test B*/
		RUN;

		/* Create macro variables for all STUDIES in dataset for use in checkbox list */
		%LET var=STUDY; 	%LET VAR2=ALLSTUDY;	%LET DATA=STABILITY1; 	%varlist; 
		/* Create macro variables for all ANALYSTS in dataset for Histograms and Corr reports */
		%LET var=ANALYST; 	%LET VAR2=ANALYST; 	%LET DATA=STABILITY1; 	%varlist; 
	%END;

	DATA _NULL_;
		testAchk  = "&testAnew";
		stageAchk = "&stageAnew";
		testBchk  = "&testBnew";
		stageBchk = "&stageBnew";
		put testAchk stageAchk testBchk stageBchk;
	RUN;

%MEND SUBSET2;

****************************************************************************************************;
*                                    MODULE HEADER                                                 *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;
*	REQUIREMENT     : See LINKS Report SOP                                                     *;
*       INPUT           : DATASETS STABILITY2. MACRO VARIABLES: STUDY0, STUDY1,...STUDY#.          *;
*       PROCESSING      : Create comma separated, quoted list of studies chosen                    *;
*		          from checkbox list to use in where statement.                            *; 
*       OUTPUT DATASET  : STABILITY3. MACRO VARIABLES: WHERESTUDY, STUDYSUB,                       *; 
*		          STUDY0, STUDY1, DATACHECK3.                                              *;
****************************************************************************************************;
%MACRO SUBSET3;
	/* Create list of selected studies from checkboxes. */
	%GLOBAL WhereStudy studysub study0 study1 DATACHECK3 UNAPPFLAG; 

	%IF %SUPERQ(study0)= %THEN %DO;  /* Only one study chosen */
	    %LET study0=1;
	    %LET study1=&study;
	%END;

	%IF %SUPERQ(study)^= %THEN %DO;
		%LOCAL i;	%LET study_list= ;    %LET study_list2= ;
	    	%DO i=1 %TO &study0;
			%LET studysub  = &study_list "&&study&i";	/* Create comma separated list with quotes for WHERE statement */
			%IF &i < &study0 %THEN %DO;
				%LET study_list=&studysub , ;
			%END;
		%END;
	%END;

	%IF %SUPERQ(study)= %THEN 
		%LET WhereStudy=*;  					/* No studies chosen */
		%ELSE %LET WhereStudy=WHERE STABILITY_STUDY_NBR_CD IN (&studysub);

	DATA STABILITY3; SET STABILITY2; 	/* Select studies using study list where clause */
		&WhereStudy;
		IF SAMP_STATUS < '17' THEN CALL SYMPUT('UNAPPFLAG','YES');
		CALL SYMPUT('DataCheck3','GO'); /* Set flag if data exists */
	RUN;
	
	%IF %SUPERQ(DATACHECK3)=GO %THEN %DO;   /* Create study macro variables for all studies in dataset */
		%LET var=study; 	%LET VAR2=STUDY; 	%LET DATA=STABILITY3; 	%varlist;
		%LET study0=&numstudy;
	%END;
%MEND SUBSET3;

****************************************************************************************************;
*                                    MODULE HEADER                                                 *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;
*	REQUIREMENT     : See LINKS Report SOP                                                     *;
*       INPUT           : Datasets Batches1, Stability2, Stability3.                               *; 
*       PROCESSING      : Creates general report datasets and macro variables.                     *;
*       OUTPUT          : General report datasets and macro variables.                             *;
****************************************************************************************************;
%MACRO SETUP;
	/* Setup dataset names and by variables depending on report type */
	%IF %SUPERQ(REPORTYPE)=PRODRELEASE %THEN %DO;   /* Use product release data */
		%LET DSN1=BATCHES1;
		%LET DSN2=BATCHES1;
		%LET BYVAR=BY PRODUCT TEST STAGE2 PEAK Batch_Nbr;
	%END;
	%ELSE %DO; /* Use stability data */
		%LET DSN1=STABILITY3;
		%LET DSN2=STABILITY2;
		%LET BYVAR=BY product test stage2 peak study time;
	%END;

	PROC SORT DATA=&DSN1; &BYVAR; RUN;

	PROC SUMMARY DATA=&DSN1;  /* Calculate summary statistics for designated dataset/by variables */
	  	VAR result;
	   	&BYVAR;
		ID ANALYST;
	  	OUTPUT OUT=Means mean=mean std=std cv=rsd min=min max=max;
	RUN;

	PROC SORT DATA=&DSN1; 	&BYVAR; RUN;
	PROC SORT DATA=Means;   &BYVAR; RUN;

	DATA ALLDATA_WITH_STATS; MERGE &DSN1 means; &BYVAR; RUN;  /* Combine individual results with sum stats */
 
	PROC SORT DATA=ALLDATA_WITH_STATS; BY test stage2 peak; RUN;
	
	/* Added V2 */
	%LET CORRTIMEWHERE= ;
	%IF %SUPERQ(REPORTYPE)=CORR AND %SUPERQ(RHTEMPFLG)= AND %SUPERQ(TESTB)^=TESTDATE2 %THEN %DO;
		DATA TESTA; SET ALLDATA_WITH_STATS; WHERE TEST="&TESTA"; RUN;
		PROC SORT DATA=TESTA NODUPKEY OUT=TESTATIMES; BY TIME;   RUN;
		DATA TESTB; SET ALLDATA_WITH_STATS; WHERE TEST="&TESTB"; RUN;
		PROC SORT DATA=TESTB NODUPKEY OUT=TESTBTIMES; BY TIME;   RUN;
		
		DATA TIMES; MERGE TESTATIMES(IN=A) TESTBTIMES(IN=B); BY TIME; IF A AND B; RUN;
		
		DATA TIMES2; SET TIMES NOBS=NUMTIMES;
			RETAIN OBS 0;
			OBS=OBS+1;
			CALL SYMPUT('NUMTIMESCHK',NUMTIMES);
		RUN;
		
		%LET CORRTIMELIST= ;
		%DO I = 1 %TO &NUMTIMESCHK;
			DATA _NULL_; SET TIMES2;
		   		WHERE OBS=&I;
		   		CALL SYMPUT("CORRTIME&I",TIME);
		   	RUN;
		   
		   	%LET CORRTIMELIST=&CORRTIMELIST &&CORRTIME&I;
		   	%IF &I < &NUMTIMESCHK %THEN %LET CORRTIMELIST=&CORRTIMELIST ,;
	 	%END;
		   
		%LET CORRTIMEWHERE = WHERE TIME IN (&CORRTIMELIST);
	%END;
			
  	PROC SUMMARY DATA=ALLDATA_WITH_STATS;  			/* Calculate min and max summary statistics */
    	VAR mean result std rsd min max;
		BY product test stage2 peak;
		ID STAGE;
		&CORRTIMEWHERE; 				/* Added V2 */
    	OUTPUT OUT=MaxData min=minmean minind minstd minrsd minmin minmax 
                   max=maxmean maxind maxstd maxrsd maxmin maxmax ;
  	RUN;

	DATA MAXDATA; SET MAXDATA;  				/* ADDED V2 */
		IF MINSTD=. THEN MINSTD=0;
		IF MAXSTD=. THEN MAXSTD=0;
		IF MINRSD=. THEN MINRSD=0;
		IF MAXRSD=. THEN MAXRSD=0;
  	RUN;
  	
	%GLOBAL SPECLIST SPECLABEL SPECCHK2 SPECLABEL1 SPECLABEL2 SPECLABEL3 SPECLABEL4 SPECLABEL5
			FOOTNOTE1 FOOTNOTE2 FOOTNOTE3 FOOTNOTE4 FOOTNOTE5 NUMSPECS;

	%LET SPECLABEL=N/A;  %LET NUMSPECS=0;
	%IF %SUPERQ(SPECCHK)=YES OR %SUPERQ(SPECCHKB)=YES %THEN %DO; /* If specifications exist, then proceed. */
		PROC SORT DATA=SPECS2; BY TEST STAGE2 PEAK; RUN;

		PROC SUMMARY DATA=specs2;  /* Calculate min and max specifications */
    		VAR LOWERI UPPERI LOWERM UPPERM;
			BY product test stage2 peak;
			ID STAGE;
    		OUTPUT OUT=maxSPECS min=minLOWI minUPI MINLOWM MINUPM max=maxLOWI maxUPI MAXLOWM MAXUPM;
  		RUN;

		DATA MAXDATA; MERGE MAXDATA MAXSPECS; BY product TEST STAGE2 PEAK; RUN;

		%LET NUMSPECS=1;

		DATA TestASpecs; SET SPECS2;  /* Create dataset with specs for only testA */
			%IF %SUPERQ(IMPFLAG)=YES %THEN %DO;
				WHERE test="&testA" AND COMPRESS(stage,'- ')=COMPRESS("&stageANEW", '- ');  
			%END;
			%ELSE %DO;
				WHERE test="&testA" AND COMPRESS(stage,'- ')=COMPRESS("&stageANEW", '- ') AND UPCASE(peak)=UPCASE("&peakA"); 
			%END;
		RUN;

		/* Create 2 lists of specifications for TestA, one for mean specs and one for individual specs */ 
		PROC SORT DATA=TestASpecs NODUPKEY OUT=PRODSPECS0; BY PRODUCT SPEC_TYPE ; RUN;

		DATA PRODSPECLIST; RETAIN LowLine 250 UprLine 0; LENGTH SPECLISTm speclisti $1000 LOWERIC UPPERIC LOWERMC UPPERMC $15; 
			SET PRODSPECS0 NOBS=NUMSPECS; 
		BY PRODUCT SPEC_TYPE ;
  			RETAIN  OBS OBSALL 0 speclistM SPECLISTI;
			IF FIRST.SPEC_TYPE THEN OBS=1; /* Create counter for each SPEC_TYPE */
			ELSE OBS=OBS+1;
			OBSALL=OBSALL+1; /* Create counter of overall observations */
			/* Convert specifications to character */
			IF LOWERI=. OR LOWERI=0 THEN LOWERIC=''; ELSE LOWERIC=LOWERI;
			IF UPPERI=. THEN UPPERIC=''; ELSE UPPERIC=UPPERI;
			IF LOWERM=. OR LOWERM=0 THEN LOWERMC=''; ELSE LOWERMC=LOWERM;
			IF UPPERM=. THEN UPPERMC=''; ELSE UPPERMC=UPPERM;
			/* Create mean spec list */
			IF OBS=1 AND SPEC_TYPE='MEAN' THEN SPECLISTM=TRIM(LOWERMC)||' '||TRIM(UPPERMC);
			ELSE IF SPEC_TYPE='MEAN' AND OBS > 1 THEN SPECLISTM=TRIM(SPECLISTM)||' '||TRIM(LOWERMC)||' '||TRIM(UPPERMC);
			/* Create individual spec list */
			IF OBS=1 AND SPEC_TYPE='INDIVIDUAL' THEN SPECLISTI=TRIM(LOWERIC)||' '||TRIM(UPPERIC);
			ELSE IF SPEC_TYPE='INDIVIDUAL' AND OBS > 1 THEN SPECLISTI=TRIM(SPECLISTI)||' '||TRIM(LOWERIC)||' '||TRIM(UPPERIC);
			/* If end of dataset then output */
			IF OBSALL=NUMSPECS THEN OUTPUT;
			IF SPEC_TYPE='INDIVIDUAL' THEN DO;
				If loweri=. or loweri=0 then Loweric=0;if upperi=. then upperic=0;
				IF Loweric LT LowLine THEN DO;
					CALL SYMPUT('LowRefLine',TRIM(LEFT(Loweric)));
					LowLine=Loweric;
				END;
				IF Upperic GT UprLine THEN DO;
					CALL SYMPUT('UprRefLine',TRIM(LEFT(Upperic)));
					UprLine=Upperic;
				END;
			END;
			ELSE IF SPEC_TYPE='MEAN' THEN DO;
				If lowerm=. or lowerm=0 then Lowermc=0;if upperm=. then uppermc=0;
				IF Lowermc LT LowLine THEN DO;
				        CALL SYMPUT('LowRefLine',TRIM(LEFT(Lowermc)));
					 LowLine=Lowermc;
				END;	
			        IF Uppermc GT UprLine THEN DO;
					CALL SYMPUT('UprRefLine',TRIM(LEFT(Uppermc)));
					UprLine=Uppermc;
				END;
			END;
			PUT SPEC_TYPE loweri upperi loweric upperic lowerm upperm lowermc uppermc;
  		RUN;

		DATA _NULL_; SET PRODSPECLIST;  /* Setup SpecList macro variable depending on the report statistic */
			value=UPCASE("&value");  reportype="&reportype";
	    		IF (VALUE='MEAN' AND REPORTYPE IN ('SCATTER','CORR')) OR REPORTYPE = 'PRODRELEASE' THEN CALL SYMPUT("SpecList", TRIM(SPECLISTM));
			ELSE IF (VALUE='INDIVIDUAL' AND REPORTYPE IN ('SCATTER','CORR')) OR REPORTYPE='HISTIND' THEN CALL SYMPUT("SpecList", TRIM(SPECLISTI));
  		RUN;

		/* Create macro variable SpecLabel for text version of specification for use in report titles/footnotes */
		
		%IF %SUPERQ(REPORTYPE)=SCATTER      %THEN %LET CHKVALUE=UPCASE(SPEC_TYPE)=UPCASE(SYMGET('VALUE'));
		%IF %SUPERQ(REPORTYPE)=HISTIND      %THEN %LET CHKVALUE=UPCASE(SPEC_TYPE)='INDIVIDUAL';
		%IF %SUPERQ(REPORTYPE)=SUMSTATS     %THEN %LET CHKVALUE=UPCASE(SPEC_TYPE)=UPCASE(SYMGET('RPTVALUE'));
		%IF %SUPERQ(REPORTYPE)=CORR  	    %THEN %LET CHKVALUE=UPCASE(SPEC_TYPE)=UPCASE(SYMGET('VALUE'));
		%IF %SUPERQ(REPORTYPE)=CIPROFILES   %THEN %LET CHKVALUE=UPCASE(SPEC_TYPE)='INDIVIDUAL';
		%IF %SUPERQ(REPORTYPE)=PRODRELEASE  %THEN %LET CHKVALUE=UPCASE(SPEC_TYPE) IN ('MEAN');

		PROC SORT DATA=SPECS2 NODUPKEY OUT=SPEC_TYPE0; BY SPEC_TYPE TXT_LIMIT_A TXT_LIMIT_B TXT_LIMIT_C; RUN;

		DATA SPEC_TYPE1; SET SPEC_TYPE0;
			WHERE &CHKVALUE;
		RUN;
		
		DATA SPEC_TYPE; LENGTH SPEC $750; SET SPEC_TYPE1 NOBS=maxobs; 
			RETAIN OBS 0 SPEC ;
			OBS=OBS+1;
		
			SPEC=TRIM(TXT_LIMIT_A)||TRIM(TXT_LIMIT_B)||TRIM(TXT_LIMIT_C);
			IF OBS=1 THEN DO;
				CALL SYMPUT('SPECLABEL1', 'Specification: '||TRIM(LEFT(SPEC)));
				CALL SYMPUT('FOOTNOTE1', 'FOOTNOTE&K F=ARIAL h=1 "Specification: '||TRIM(LEFT(SPEC))||'"');
			END;
			ELSE DO;
				CALL SYMPUT('SPECLABEL'||TRIM(LEFT(OBS)),TRIM(SPEC)); 
				CALL SYMPUT('FOOTNOTE'||TRIM(LEFT(OBS)), 'FOOTNOTE&K F=ARIAL h=1 "'||TRIM(LEFT(SPEC))||'"');
			END;

			IF OBS=MAXOBS THEN CALL SYMPUT('NUMSPECS',MAXOBS);
	
			CALL SYMPUT('SPECCHK2','YES'); /* Create flag to add/remove spec from table */
		RUN;
  		
		DATA _NULL_; /*** Setup Reference Lines for TestA specifications ***/
 			VALUE=UPCASE("&VALUE");
  			REPORTYPE="&REPORTYPE";  SpecList="&speclist";
  			IF REPORTYPE ='PRODRELEASE' OR VALUE IN ('INDIVIDUAL','MEAN','MIN','MAX') and speclist^='' THEN CALL SYMPUT("vref","vref = &speclist"); 
			IF REPORTYPE ='HISTIND' THEN CALL SYMPUT("HREF","HREF= &SPECLIST");
		RUN;
	%END;

	%ELSE %DO;  /* Setup dummy dataset when specifications do not exist. */
		DATA MAXDATA; SET MAXDATA;
		  minLOWI=.; minUPI=.; MINLOWM=.; MINUPM=.; maxLOWI=.; maxUPI=.; MAXLOWM=.; MAXUPM=.;
		RUN;
	%END;
		
/* Setup axis range values based on the spec if all data is within spec or based on the data if data is outside specs. 
   Setup plot variable and axis labels. */
	%GLOBAL PLOTVAR VALUE2;
	DATA PlotSetup;  SET MaxData;  LENGTH upaxis lowaxis Low_Error Upr_Error 7.3 ;
		REPORT=upcase("&reportype");  VALUE=upcase("&VALUE");
  		/* Setup lower and upper axis values for plotting individuals */
  		IF (VALUE ='INDIVIDUAL' AND REPORT IN ('SCATTER','CORR')) OR REPORT IN ('HISTIND') THEN DO;
	    		IF minind < minlowI or minlowI=. THEN lowaxis=max(0,minind*.9);
					     		 ELSE lowaxis=minlowI*.9;
           
    			IF maxind > maxupI or maxupI=.   THEN upaxis=maxind*1.1;
    							 ELSE upaxis=maxupI*1.1;
        	END;
		/* Setup lower and upper axis values for plotting means */
  		IF (VALUE='MEAN' AND REPORT IN ('SCATTER','CORR')) OR REPORT IN ('PRODRELEASE') THEN DO;
    			IF minlowI ^=. THEN DO;  
      				IF minmean < minlowI     THEN  lowaxis=max(0,minmean*.9);
      						     	 ELSE lowaxis=minlowI*.9; 
    			END;
	
    			ELSE IF minlowm ^=. THEN DO;
      				IF minmean < minlowm 	 THEN lowaxis=max(0,minmean*.9); 
      						     	 ELSE lowaxis=minlowm*.9;
    			END;
 
 	   		ELSE lowaxis=max(0,minmean*.9);  
	    		IF maxupi ^=. THEN DO;
	      			IF maxmean > maxupi 	 THEN upaxis=maxmean*1.1;
      							 ELSE upaxis=maxupi*1.1;
    			END;

	    		ELSE IF maxupm ^=. THEN DO;
      				IF maxmean > maxupm 	 THEN upaxis=maxmean*1.1;
      							 ELSE upaxis=maxupm*1.1;
								 put report minmean maxmean minlowi minlowm maxupi maxupm lowaxis upaxis;
 			END;
	
    			ELSE upaxis= maxmean*1.1;  
				 
		END;  PUT 'hey' LOWAXIS;

		IF REPORT = 'SCATTER' THEN DO;
			/* Setup lower and upper axis values for plotting standard deviation */
  			IF VALUE='STD' THEN DO;
    				lowaxis = max(0, minstd*.9);
    				upaxis = maxstd * 1.1; 
    			END;
			/* Setup lower and upper axis values for plotting RSD */
  			IF VALUE='RSD' THEN DO;
    				lowaxis=max(0, minrsd*.9);
    				upaxis=maxrsd * 1.1;
    			END;
			/* Setup lower and upper axis values for plotting minimums */
  			IF VALUE='MIN' THEN DO;
    				IF minlowi ^=. THEN DO;
      					IF minmin < minlowi 	THEN lowaxis=max(0,minmin*.9);
      								ELSE lowaxis=minlowi*.9;
    				END;
    				ELSE lowaxis=max(0, minmin*.9);
				IF maxupi ^=. THEN DO;
      					IF maxmin > maxupi 	THEN upaxis=maxmin*1.1;
      								ELSE upaxis=maxupi*1.1;
    				END;	   
				ELSE upaxis=maxmin*1.1;
      			END;
			/* Setup lower and upper axis values for plotting maximums */
	    		IF VALUE='MAX' THEN DO;
      				IF minlowi ^=. THEN DO;
      					IF minmax < minlowi 	THEN lowaxis=max(0,minmax*.9);
      								ELSE lowaxis=minlowi*.9;
    				END;
    				ELSE lowaxis=max(0, minmax*.9);
      				IF maxupi ^=. THEN DO;
      					IF maxmax > maxupi 	THEN upaxis=maxmax*1.1;
      								ELSE upaxis=maxupi*1.1;
    				END;	   
    				ELSE upaxis=maxmax*1.1;
		    	END;
		END;
		put report value ' : ' test stage peak;
		IF compress(UPCASE(test))=compress(UPCASE("&TestA")) and UPCASE(compress(stage, '- '))=UPCASE("&StageAnew") and compress(UPCASE(peak))=compress(UPCASE("&PeakA")) THEN DO;
			put report value '1 : ' minmean minstd minind minlowi minlowm lowaxis ' - ' maxmean maxind maxstd maxupi maxupm upaxis;
			Upaxis=round(upaxis,.001);lowaxis=round(lowaxis,.001);   
			Low_Error=lowaxis;Upr_Error=Upaxis;
			/*Err_Axis=round((upr_error-low_error)/5,.001);*/
			Err_Axis=trunc((upr_error-low_error)/5,6);
			CALL SYMPUT('Low_Error',put(low_error,7.3));
			CALL SYMPUT('Upr_Error',put(upr_error,7.3));
			CALL SYMPUT('Err_Axis', put(Err_axis,8.4));
			CALL SYMPUT('LowAxis',put(lowaxis,7.3)); 
			CALL SYMPUT('UpAxis' ,put(upaxis,7.3));
			AxisBy=trunc((upaxis-lowaxis)/5,6);
			CALL SYMPUT('AxisBy', put(AxisBy,8.4));
		END;
		IF UPCASE(test)=UPCASE("&TestB") and UPCASE(stage)=UPCASE("&StageB") and UPCASE(peak)=UPCASE("&PeakB") THEN DO;
			put report value '2 : ' minmean minstd minind minlowi minlowm lowaxis ' - ' maxmean maxind maxstd maxupi maxupm upaxis;
			Upaxis=round(upaxis,.001);lowaxis=round(lowaxis,.001);
			Low_Error=lowaxis;Upr_Error=Upaxis;
			/*Err_Axis=round((upr_error-low_error)/5,.001);*/
			Err_Axis=trunc((upr_error-low_error)/5,6);
			CALL SYMPUT('HLowAxis',put(lowaxis,7.3));
			CALL SYMPUT('HUpAxis' ,put(upaxis,7.3));
			AxisBy=trunc((upaxis-lowaxis)/5,6);
			CALL SYMPUT('HAxisBy', put(AxisBy,8.4));
		END;
	RUN;
	
%Put _All_;	

	%GLOBAL INVALIDAXIS XPIXELS YPIXELS XPIXELS0 YPIXELS0 LOWAXIS UPAXIS AXISBY;   /* Setup Vertical Axis Range. */
	%LET RefWarning=;
	DATA _NULL_; FORMAT INVALIDAXIS $3.;
		SET plotsetup;
		%IF %SUPERQ(IMPFLAG)=YES %THEN %DO;
			WHERE COMPRESS(test)="&testANEW" AND COMPRESS(stage2,'- ')=COMPRESS("&stageANEW", '- ');
		%END;
		%ELSE %DO;
			WHERE COMPRESS(test)="&testANEW" AND COMPRESS(stage,'- ')=COMPRESS("&stageANEW", '- ') AND UPCASE(COMPRESS(peak))=UPCASE("&peakANEW");
		%END;

		reportchk="&reportype";
  		reporttype="&reportype";
		INVALIDAXIS="&INVALIDVAXIS";
		IF LOWAXIS=0 AND UPAXIS=0 THEN DO;
			LOWAXIS=0;
			UPAXIS=1;
		END;
		/* Setup x and y plot size variables */  xpixelchk=SYMGET('xpixels0');	ypixelchk=SYMGET('ypixels0');
  		IF xpixelchk= '' THEN DO;					/* Set xpixels to default */ 
	    		CALL SYMPUT("xpixels", 'xpixels= 700'); CALL SYMPUT("xpixels0", '700'); 
		END;
  		ELSE CALL SYMPUT("xpixels","xpixels=&xpixels0"); /* Set xpixels to user entry */

		IF REPORTCHK IN ('SCATTER','CORR', 'HISTIND','CIPROFILES') THEN sizeinit='500';
	 	IF REPORTCHK='PRODRELEASE' THEN SIZEINIT='400';
	 	
  		IF ypixelchk= '' THEN DO;			/* Set ypixels to default */ 
     			CALL SYMPUT("ypixels", 'ypixels='||COMPRESS(sizeinit)); 
	 		CALL SYMPUT("ypixels0",compress(sizeinit));
  		END;
  		ELSE CALL SYMPUT("ypixels", "ypixels=&YPIXELS0"); /* Set ypixels to user entry */	
	RUN;

	%IF %SUPERQ(REPORTYPE)=CIPROFILES %THEN %DO;
		%GLOBAL TIMETITLE CILOWAXIS CIUPAXIS CIAXISBY CIWARNING; /* Setup CIProfiles axis values */

		DATA _NULL_;	/* Setup where subset statement and time title labels */
  			time="&time";
  			IF time='' or time='ALL' THEN DO;
	     			CALL SYMPUT('CIwhere',' ');
	 			CALL SYMPUT('timetitle','All Time Points');
  			END;
  			ELSE DO; 
    				CALL SYMPUT('CIwhere','WHERE time='||"&time");
				IF time = '0' THEN CALL SYMPUT('timetitle','Initial Time Point');
				              ELSE CALL SYMPUT('timetitle',TRIM("&time")||' Month Time Point');
  			END;
  		RUN;

		DATA CIData;SET ALLDATA_WITH_STATS;  /* Keep only needed stages, reformat stage values */
			&CIwhere;
  			IF stage = "PRESEPARATOR" THEN stage='P';
  			ELSE IF stage = "THROAT"  THEN stage='T';
  			ELSE IF stage = "FILTER"  THEN stage='F';
  			ELSE IF stage = "6-F"     THEN STAGE='6,7&F'; 
			ELSE STAGE=COMPRESS(STAGE, '- ');
			%IF %SUPERQ(CIType)=NONPOOLED %THEN %DO;
	     			IF stage NOT IN ('T','P','0','1','2','3','4','5','6,7&F') THEN DELETE;
			%END;
			%IF %SUPERQ(CIType)=POOLED %THEN %DO;
				IF stage NOT IN ('TP0','12','34','5','6,7&F') THEN DELETE;
			%END;
			%IF %SUPERQ(CIType)=FULL %THEN %DO;
	     			IF stage NOT IN ('T','P','0','1','2','3','4','5','6','7','F') THEN DELETE;
			%END;
		RUN;

		PROC SORT DATA=CIDATA; BY study stage; RUN;  

  		PROC SUMMARY DATA=CIDATA;  /* Calculate means by stage */
  			VAR result;
  			BY study stage;
  			OUTPUT OUT=meanstages mean=CImean;
  		RUN; 

		PROC SUMMARY DATA=meanstages;  /* Calculate the maximum mean */
  			VAR CImean;
  			OUTPUT OUT=maxmeans max=max;
  		RUN; 

		DATA _NULL_; LENGTH LOWAXISCHKC UPAXISCHKC AXISBYCHKC $25 LOWAXISCHK UPAXISCHK AXISBYCHK 3; SET MAXMEANS;
			INVALIDAXIS="&INVALIDVAXIS";
			LOWAXISCHK="&USERLOWAXIS";
			UPAXISCHK="&USERUPAXIS";
			AXISBYCHK="&USERAXISBY";
			/* Check to see if user has entered validated axis values.  If no, then set to default. */
			IF lowaxischk = '' OR INVALIDAXIS='YES' THEN CALL SYMPUT("lowaxis",0);  	  
			IF upaxischk  = '' OR INVALIDAXIS='YES' THEN DO;
 	  			IF MAX < 50       THEN CALL SYMPUT('UPAXIS',50);
				ELSE IF MAX < 75  THEN CALL SYMPUT('UPAXIS',75);
				ELSE IF MAX < 100 THEN CALL SYMPUT('UPAXIS',100);
				ELSE IF MAX < 150 THEN CALL SYMPUT('UPAXIS',150);
				ELSE IF MAX < 200 THEN CALL SYMPUT('UPAXIS',200);
				ELSE IF MAX < 250 THEN CALL SYMPUT('UPAXIS',250);
				ELSE IF MAX < 300 THEN CALL SYMPUT('UPAXIS',300);
				ELSE IF MAX < 350 THEN CALL SYMPUT('UPAXIS',350);
				ELSE IF MAX < 400 THEN CALL SYMPUT('UPAXIS',400);
				ELSE IF MAX < 450 THEN CALL SYMPUT('UPAXIS',450);
				ELSE IF MAX < 500 THEN CALL SYMPUT('UPAXIS',500);
				ELSE                   CALL SYMPUT('UPAXIS',MAX+25);
			END;
			IF axisbychk  = '' OR INVALIDAXIS='YES' THEN CALL SYMPUT("axisby", 5 );
			IF MAX > 150                            THEN CALL SYMPUT("axisby", 10);

			IF UPAXISCHK ^='' AND MAX > Upaxischk AND INVALIDAXIS^='YES' THEN CALL SYMPUT('CIWARNING', 'YES');
		RUN; 
	%END;

	%IF %SUPERQ(REPORTYPE)^=PRODRELEASE %THEN %DO;
		
		PROC SUMMARY DATA=ALLDATA_WITH_STATS;  /**  Calculate overall min and max timepoints for stability data only **/
	  		VAR time;
			%IF %SUPERQ(IMPFLAG)=YES %THEN %DO;
				WHERE COMPRESS(test)="&testANEW" AND COMPRESS(stage2,'- ')="&stageANEW";
			%END;
			%ELSE %DO;
				WHERE COMPRESS(test)="&testANEW" AND COMPRESS(stage,'- ')="&stageANEW" AND UPCASE(COMPRESS(peak))=UPCASE("&peakANEW");
			%END;
			OUTPUT OUT=maxtime min=mintime max=maxtime;
		RUN;
	%END;

	%IF %SUPERQ(REPORTYPE2) ^= STUDYDESC %THEN %DO;
	/* If report type is SCATTER then horizontal axis data is in maxtime */
	%IF %SUPERQ(REPORTYPE)=SCATTER %THEN %LET DSNHAXIS=MAXTIME; 
	/* For all other reports horizontal axis data is in PlotSetup */
				       %ELSE %LET DSNHAXIS=PLOTSETUP;	
	%GLOBAL HLOWAXIS HUPAXIS HAXISBY;
	DATA _NULL_; 
		SET &DSNHAXIS;		
		%IF %SUPERQ(REPORTYPE)=SCATTER %THEN %DO;  	/* If there are > 3 months of timepoints, then set maximum time axis to		*/
			IF maxtime > 3 THEN DO;			/*  maxtime + 3 months and increment by 3.  Otherwise set maximum time axis 	*/
    				maxhaxis=maxtime + 3;  	  	/*  to maxtime + 1 month and increment by 1.  					*/
    				haxisby=3; 
  			END;
	  		ELSE DO;
    				maxhaxis=4;
    				haxisby=1;
  			END;
		%END;

		%IF %SUPERQ(REPORTYPE)=CORR %THEN %DO;  	/* Subset for reportype = CORR to select only testB data */
			%IF %SUPERQ(IMPFLAG)=YES %THEN %DO;
				WHERE COMPRESS(test)="&testBNEW" AND COMPRESS(stage2,'- ')=COMPRESS("&stageBNEW", '- ');
			%END;
			%ELSE %DO;
				WHERE COMPRESS(test)="&testBNEW" AND COMPRESS(stage,'- ')=COMPRESS("&stageBNEW", '- ') AND UPCASE(COMPRESS(peak))=UPCASE("&peakBNEW");
			%END;
		%END;

		INVALIDAXIS="&INVALIDHAXIS"; HAXISCHK="&HAXISCHK";  USERHLOWAXIS="&USERHLOWAXIS"; USERHUPAXIS="&USERHUPAXIS"; USERHAXISBY="&USERHAXISBY";
		/* Check to see if user entered valid axis values, otherwise set to default */
		%IF %SUPERQ(REPORTYPE)=SCATTER %THEN %DO;
			IF INVALIDAXIS='YES' OR (HAXISCHK^='USER')  THEN CALL SYMPUT('hlowaxis', 0); 		ELSE CALL SYMPUT('HLOWAXIS',"&USERHLOWAXIS");
			IF INVALIDAXIS='YES' OR (HAXISCHK^='USER')  THEN CALL SYMPUT('hupaxis',maxhaxis); 	ELSE CALL SYMPUT('HUPAXIS',"&USERHUPAXIS");
			IF INVALIDAXIS='YES' OR (HAXISCHK^='USER')  THEN CALL SYMPUT('haxisby',haxisby); 	ELSE CALL SYMPUT('HAXISBY',"&USERHAXISBY");
		%END;
		%IF %SUPERQ(reportype) = CORR %THEN %DO;
			IF INVALIDAXIS='YES' OR (HAXISCHK^='USER')  THEN CALL SYMPUT('hlowaxis', put(lowaxis,7.3)); ELSE CALL SYMPUT('HLOWAXIS',"&USERHLOWAXIS");
			IF INVALIDAXIS='YES' OR (HAXISCHK^='USER')  THEN CALL SYMPUT('hupaxis', put(upaxis,7.3));   ELSE CALL SYMPUT('HUPAXIS',"&USERHUPAXIS");
			IF INVALIDAXIS='YES' OR (HAXISCHK^='USER')  THEN CALL SYMPUT('haxisby',put((upaxis-lowaxis)/5,7.3)); ELSE CALL SYMPUT('HAXISBY',"&USERHAXISBY");
		%END;
	RUN;
		
	%GLOBAL FOOTNOTE HWARNING VWARNING WARNING userupaxis userlowaxis HAXIS HAXISHIST;

	%IF %SUPERQ(REPORTYPE)=SCATTER %THEN %LET DSN=MAXTIME;
	%ELSE %LET DSN=MAXDATA;

	DATA HAXIS; SET &DSN; /**  Setup axis statements for horizontal axis **/
		CALL SYMPUT("HAXIS","ORDER= (&hlowaxis TO &hupaxis BY &haxisby)");   /* For SCATTER and CORR plots */
  		VALUE="&VALUE";REPORTYPE="&REPORTYPE";
		HAXISCHK="&HAXISCHK";
		minchk="&hlowaxis";  	/**  Check to see if user axis values do not include all data points.  If not  **/
  		maxchk="&hupaxis";  	/**  setup warning macro variable.  Setup warning2 macro variable to alert user with **/				        	
  		IF HAXISCHK='USER' THEN DO;  /**  asterisk that slopes were calculated inside of data range **/
			%IF %SUPERQ(REPORTYPE)=SCATTER %THEN %DO;
	    			IF (mintime < minchk) OR (maxtime > maxchk) THEN DO;
	      				CALL SYMPUT('Hwarning','YES');
	      				CALL SYMPUT('warning2','*');
    				END;
				ELSE CALL SYMPUT('HWARNING',' ');
			%END;
			%IF %SUPERQ(REPORTYPE)=CORR %THEN %DO;
				IF TEST="&TESTB" THEN DO;  /* Added V2 */
					IF VALUE='MEAN' AND ((minMEAN < minCHK) OR (maxMEAN > maxchk))          THEN CALL SYMPUT('Hwarning','YES');
			   		ELSE IF VALUE='INDIVIDUAL' AND ((minIND < minCHK) OR (maxIND > maxchk)) THEN CALL SYMPUT('Hwarning','YES');
					ELSE CALL SYMPUT('HWARNING',' ');
				END;
			%END;
		END;
	RUN;

   	%GLOBAL VAXIS MIDPOINTS;	/*  Setup vertical axis and histogram midpoints for TestA only.  */
							    /*	Create warning MACRO variables if data exists outside of user */
	DATA VAXIS; SET maxdata;	/*	defined axis range. */
  		%IF %SUPERQ(IMPFLAG)=YES %THEN %DO;  /* Select only testa data */
			WHERE test="&testA" AND COMPRESS(stage,'- ')="&stageANEW";
		%END;
		%ELSE %DO;
			WHERE test="&testA" AND COMPRESS(stage,'- ')="&stageANEW" AND UPCASE(peak)=UPCASE("&peakA");
		%END;
  		VALUE="&VALUE";
  		lowaxischk2=TRIM(LEFT("&lowaxis"));  upaxischk2=TRIM(LEFT("&upaxis"));  AXISBYCHK=TRIM(LEFT("&AXISBY"));
  		reporttype="&reportype";
		INVALIDAXIS="&INVALIDVAXIS";
		VAXISCHK="&VAXISCHK";
		if reporttype ^= 'STUDYDESC' THEN DO;
		CALL SYMPUT("VAXIS","ORDER= (&lowaxis TO &upaxis BY &axisby)");  /** Setup vertical axis statement **/
		IF upaxischk2<0.01 or axisbyCHK<0.01 THEN CALL SYMPUT('MIDPOINTS','');
  		ELSE CALL SYMPUT('HAXISHIST','midpoints='||put(&lowaxis,7.2)||' TO '||put(&upaxis,7.2)||' BY '||put(&axisby,7.2));  /** Setup histogram midpoints statement **/
		END;
   		IF reporttype IN ('CORR') AND TEST="&TESTA" THEN DO;  /**  Check to see if user axis values do not include all data points.   **/
			IF VAXISCHK='USER' THEN DO;	
				put test value minmean lowaxischk2 maxmean upaxischk2;
				/**  If not, setup warning flag.  **/
				IF  (VALUE='MEAN' and ((minmean < lowaxischk2) 		OR (maxmean > upaxischk2))) OR
				    (VALUE='INDIVIDUAL' and ((minind < lowaxischk2) 	OR (maxind > upaxischk2)))    
				    THEN CALL SYMPUT('vwarning','YES');	
			END;  
   		END;
		IF lowaxischk2=upaxischk2 AND INVALIDAXIS ^='YES' THEN CALL SYMPUT('VAXIS','');
   	PUT _ALL_;			
	RUN;
	/************************************************************************************************************************************************************/
	/* Setup statistics to print next to study numbers in menu */
	%IF %SUPERQ(REPORTYPE)=SCATTER OR %SUPERQ(REPORTYPE)=SUMSTATS %THEN %DO; 
		DATA _NULL_; 
			INVALIDHAXISCHK="&INVALIDHAXIS";
	   		REPORTYPECHK="&REPORTYPE";	
			MINTIMECHK="&USERHLOWAXIS";
			MAXTIMECHK="&USERHUPAXIS";
			HAXISCHK="&HAXISCHK";
			/* If user time axis values are valid for scatter plot report, set up where statement to subset time points */	
			IF HAXISCHK='USER' AND REPORTYPECHK='SCATTER' AND INVALIDHAXISCHK ^= 'YES' THEN DO; /*Subset to include user selected timepoints if applicable.  */
	    			IF mintimechk^=''      AND maxtimechk ^= '' THEN CALL SYMPUT('whereaxistime',"WHERE time >= &USERhlowaxis and time <= &USERhupaxis");
	    			ELSE IF mintimechk=''  AND maxtimechk ^= '' THEN CALL SYMPUT('whereaxistime',"WHERE time <= &USERhupaxis");
	    			ELSE IF mintimechk^='' AND maxtimechk  = '' THEN CALL SYMPUT('whereaxistime',"WHERE time >= &USERhlowaxis");
	    			ELSE IF mintimechk=''  AND maxtimechk  = '' THEN CALL SYMPUT('whereaxistime',"*");
			END;
			ELSE CALL SYMPUT('whereaxistime',"*");  /* Set where statement to null */
		RUN;

		PROC SORT DATA=STABILITY2; BY product test stage stage2 peak study; RUN;

  		ODS LISTING CLOSE;  /* Calculate linear slopes for every study, subsetting with where statement. */
  		PROC MIXED DATA=STABILITY2 METHOD=REML;
	    		BY product test stage stage2 peak study;
    			MODEL result = time/s cl htype=1;
    			MAKE 'solutionf' OUT=SLOPES0;
    			&whereaxistime;
  		RUN;
  		ODS LISTING;
  		
  		%LET SLOPEDATA=NO;
  		DATA _NULL_; SET SLOPES0;
  			CALL SYMPUT('SLOPEDATA','YES');
  		RUN;
  		
  		%IF %SUPERQ(SLOPEDATA)=YES %THEN %DO;
			DATA slopes; SET slopes0;  /* Format slopes dataset */
    				slope=estimate;	
				WHERE UPCASE(effect)='TIME';
    				KEEP product test stage stage2 peak study  slope;
    				FORMAT slope 4.3;
  			RUN;
		%END;
  		%ELSE %DO;
  			PROC SORT DATA=STABILITY2 NODUPKEY OUT=SLOPENULL; BY PRODUCT TEST STAGE STAGE2 PEAK STUDY;RUN;
  			
  			DATA SLOPES; SET SLOPENULL;
  				SLOPE=0;
  				FORMAT SLOPE 4.3;
  			RUN;
		%END;

		%IF %SUPERQ(REPORTYPE)=SUMSTATS %THEN %DO;

			DATA SLOPES0; SET SLOPES0;
				stability_study_nbr_cd=study;
			RUN;
			/* Setup slopes dataset for summary statistics report subsetting using WHERESTUDY variable*/
			DATA SUMSLOPES; SET SLOPES0; &WHERESTUDY;  RUN;
		%END;
	%END;

	%IF %SUPERQ(REPORTYPE)=HISTIND AND %SUPERQ(CLASS)=STUDY %THEN %DO;
		/* Calculate normal probability p-values for each study for histogram report */
		DATA _NULL_;
			time0=TRIM("&time");  /* If time is not specified, then set to ALL */
	   		IF time0='' OR TIME0='ALL' THEN CALL SYMPUT('wheretime','*');
 						   ELSE CALL SYMPUT('wheretime',"WHERE time="||"&time");
		RUN;
		PROC SORT DATA=STABILITY2; BY STUDY; RUN;
		PROC UNIVARIATE NOPRINT DATA=STABILITY2;
			VAR RESULT;
			BY STUDY;
			&WHERETIME;
			OUTPUT OUT=NORMALOUT PROBN=PROBN;
		RUN;
	%END;
%end;
	%IF %SUPERQ(REPORTYPE)=SCATTER %THEN %DO;
		/* Merge slopes back into original dataset. */
 		PROC SORT DATA=STABILITY2; 	BY product test stage2 peak study; RUN;
  		PROC SORT DATA=slopes; 		BY product test stage2 peak study; RUN;

		DATA ALLDATA_WITH_SLOPES; MERGE STABILITY2 slopes; BY product test stage2 peak study;  RUN;

		%DO i = 1 %TO &NUMALLSTUDY;	/**  Create MACRO variables for each study's slope. **/
   			%GLOBAL STAT&i STATdesc;
			DATA test1only; SET ALLDATA_WITH_SLOPES;
				&WHERE2 AND test2="&testANEW";
			RUN;

			PROC SORT DATA=test1only NODUPKEY OUT=study1; BY study stability_study_purpose_txt slope; RUN;

			DATA study2; SET study1; BY study stability_study_purpose_txt slope;
				RETAIN obs 0;
				obs=obs+1; OUTPUT;
			RUN;

			DATA _NULL_; SET study2;
				WHERE obs=&i;
     				VALUE=upcase("&VALUE");		/** If REPORT is on means or individuals then create MACRO variable for */
	  			reportype=upcase("&reportype"); 	/** slope title and MACRO variables for each study's slope ***/
				IF reportype='SCATTER' and VALUE IN  ('MEAN','INDIVIDUAL') THEN DO; 
        				CALL SYMPUT('STATdesc','<SMALL>* Estimated Linear Slope</SMALL>'); 
        				CALL SYMPUT("STAT&i",'Slope*=('||PUT(slope,6.3)||')'); 
      				END;
    			RUN;
  		%END;
	%END;
	%ELSE %IF %SUPERQ(REPORTYPE)=HISTIND AND %SUPERQ(CLASS)=STUDY %THEN %DO;
		%DO i = 1 %TO &NUMALLSTUDY;	/**  Create MACRO variables for each study's normal test p-value. **/
	 		%GLOBAL STAT&i STATDESC;
		
			DATA PROBN0; SET NORMALOUT; BY study;
      				RETAIN obs 0;
      				obs=obs+1; OUTPUT;
    			RUN;

			DATA _NULL_; SET PROBN0;
      				WHERE obs=&i;
      				CALL SYMPUT('STATdesc','<SMALL>* Normal test p-value</SMALL>'); 
        			CALL SYMPUT("STAT&i",'('||PUT(probn,6.3)||')*'); 
    			RUN;
  		%END;
	%END;
	%ELSE %DO;
		%DO i = 1 %TO &NUMALLSTUDY;	/**  Create null MACRO variables for each study's statistic. **/
	 		%GLOBAL STAT&i STATdesc;
		%END;
	%END;
	
	/********************************************************************************************************************************/
	/* Create title variables */
	%LET numprods=0;%LET numprods2=0;
	PROC SORT DATA=ALLDATA_WITH_STATS NODUPKEY OUT=product0; BY product; RUN; /** Create dataset with one observation per product **/

  	DATA prodlist; SET product0 NOBS=numprods; BY product;
    		RETAIN obs 0;
    		obs=obs+1; OUTPUT;
    		CALL SYMPUT('numprods',numprods);
    		CALL SYMPUT('numprods2',numprods-1);
  	RUN;
  							
   	%LOCAL i;							
   	%DO i = 1 %TO &numprods;
   		DATA _NULL_; SET prodlist;
       			WHERE obs=&i;
       			CALL SYMPUT("selproduct&i",product);  
   		RUN;
   	%END;

   	%LET prodlist0= ;
   	%DO i = 1 %TO &numprods;
   		DATA _NULL_; 
   		%LET prodlist=&prodlist0 &&selproduct&i;
   		%IF &i < &numprods %THEN %DO;
 	        	%IF &numprods=2 	  %THEN %LET prodlist0=&prodlist and;  /** If there are only 2 products, separate by the word 'and' **/
 			%ELSE %IF &i = &numprods2 %THEN %LET prodlist0=&prodlist and;  /** Other wise separate by commas except for final 2 products separate by 'and' **/
 			%ELSE  			  %LET prodlist0=&prodlist ,;
     		%END;
    	%END;

	%GLOBAL TITLE_product TITLE_STORAGE TITLE_test TITLE_testb TITLE_PEAKA TITLE_PEAKb;
	%LET TITLE_product=&prodlist;	/** Create MACRO variable for product for use in title statements**/

	DATA _NULL_; SET ALLDATA_WITH_STATS;  /** Create MACRO variable for storage condition for use in title statements **/
		CALL SYMPUT('TITLE_storage',TRIM(storage)||'% RH');
	RUN;

	DATA _NULL_;
	    	peakA="&peakA";  TESTA="&TESTA";
		stageA="&stageA"; 
		IMPFLAG="&IMPFLAG"; /** Create MACRO variable for test A for use in title statements **/
	    	IF STAGEA not IN ('NONE','') THEN CALL SYMPUT('TITLE_test',TRIM("&testA")||' Stage: '||left(TRIM(STAGEA)));
		ELSE CALL SYMPUT('TITLE_test',TRIM("&testA"));
		IF PEAKA not IN ('NONE','') AND IMPFLAG^='YES' 
			THEN CALL SYMPUT('TITLE_PEAKA', TRIM(PEAKA)); /** Create MACRO variable for peak A for use in title statements **/

		TESTB="&TESTB";peakb="&peakb";stageb="&stageb";
	    	 /** Create MACRO variable for test B for use in title statements **/
		IF STAGEB not IN ('NONE','') THEN CALL SYMPUT('TITLE_testb',TRIM("&testb")||' Stage: '||left(TRIM(STAGEb)));
		ELSE CALL SYMPUT('TITLE_testb',TRIM("&testb"));
		IF PEAKb not IN ('NONE','') AND TESTB NOT IN ('HPLC Related Imp. in Advair MDPI') 
		THEN CALL SYMPUT('TITLE_PEAKb', TRIM(PEAKb));  /** Create MACRO variable for peak B for use in title statements **/
	RUN;

	%IF %SUPERQ(studysub)= %THEN %LET subset="NULL";    	/* Create check MACRO variables to check study checkboxes */
			       %ELSE %LET subset=&studysub;	/* when study is selected. */

	%DO i = 1 %TO &NUMALLSTUDY;     
    		%GLOBAL check&i;
      		DATA _NULL_;
			studychk=TRIM("&&ALLstudy&i");
			studychk2="&study";
			IF studychk2='' or studychk IN (&subset) THEN CALL SYMPUT("check&i",'checked'); /* Check all by default or check only those studies selected */
			ELSE CALL SYMPUT("check&i",'');
      		RUN;
     	%END;

	%IF %SUPERQ(REPORTYPE)^=PRODRELEASE %THEN %DO;
 		PROC SORT DATA=ALLDATA_WITH_STATS OUT=times NODUPKEY; BY time; RUN;  /* Count number of timepoints for timepoint dropdown menu */

  		DATA times2; SET times NOBS=numtimes; 
  			RETAIN numobs 0;
    		numobs=numobs+1; OUTPUT;
    		CALL SYMPUT('numtimes', numtimes);
  		RUN;
  	
  		%LOCAL i;
  		%DO i = 1 %TO &numtimes;	
 	  		%GLOBAL time&i timetitle&i;
  			DATA _NULL_; SET times2;  /* Setup time labels for drop down boxes */
    				WHERE numobs=&i;
    				CALL SYMPUT("time&i",time);
    				IF time=0      THEN CALL SYMPUT("timetitle&i",'Initial');
				ELSE IF time=1 THEN CALL SYMPUT("timetitle&i",'1 Month');
    				ELSE                CALL SYMPUT("timetitle&i",TRIM(time)||' Months');
  			RUN; 
		%END;
	%END;

  	/****************************************************************************************************************/
	%GLOBAL testAchk TESTBchk STAGEBchk PEAKBCHK condchk prodchk stageAchk peakAchk; /** Setup comparison variables **/

	DATA _NULL_ ;
  		CALL SYMPUT('testachk', TRIM("&testA"));
  		CALL SYMPUT('testbchk', TRIM("&testB"));
  		CALL SYMPUT('condchk',  COMPRESS("&storage"));
  		CALL SYMPUT('prodchk',  TRIM("&product"));
  		CALL SYMPUT('stageAchk', TRIM("&stageA"));
  		CALL SYMPUT('peakachk',  TRIM("&peakA"));
  		CALL SYMPUT('stagebchk',TRIM("&stageB"));
  		CALL SYMPUT('peakbchk', TRIM("&peakB"));
	RUN;

	%GLOBAL _REPLAY2;
	DATA _NULL_; LENGTH replay $ 23767 dummy $40;  /*Setup replay macros based on current time to ensure new */
  		replay=symget('_replay');		/* graph is displayed for each request.  */
  		dummy= PUT(datetime(), best12.);
  		replay = tranwrd(replay,'&_entry=','&dummy=' ||COMPRESS(dummy)|| '&_entry=');
  		CALL SYMPUT('_replay2',TRIM(replay));
	RUN;
		
%MEND SETUP;

****************************************************************************************************;
*                                      MODULE HEADER                                               *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;
*	REQUIREMENT     : See LINKS Report SOP                                                     *;
*       INPUT           : Macro variable: _replay                                                  *;
*       PROCESSING      : This code will be used if the user wants to save or print                *;
*			  a LINKS report.   It also does the following:                            *;
*			  Sets up macro variables to ensure a new graph is displayed for each      *;
*			  request.  Opens ODS RTF statement.                                       *;
*			  Sets up ODS close statement and device name.                             *;
*       OUTPUT          : Macro variable _replay2, close, device.                                  *;
****************************************************************************************************;
%MACRO Warnings;
%PUT _ALL_;  %IF %superq(reportype2) ^= STUDYDESC %THEN %DO;
	DATA _NULL_;SET maxdata;	
  		%IF %SUPERQ(IMPFLAG)=YES %THEN %DO;  /* Select only testa data */
			WHERE test="&testA" AND COMPRESS(stage,'- ')="&stageANEW";
		%END;
		%ELSE %DO;
			WHERE test="&testA" AND COMPRESS(stage,'- ')="&stageANEW" AND UPCASE(peak)=UPCASE("&peakA");
		%END;
  		VALUE="&VALUE";
  		lowaxischk2=TRIM(LEFT("&lowaxis"));     upaxischk2=TRIM(LEFT("&upaxis"));      AXISBYCHK=TRIM(LEFT("&AXISBY"));
  		lowuserchk2="&USERLOWAXIS";  upuserchk2="&USERUPAXIS";  
  		reporttype="&reportype";
		INVALIDAXIS="&INVALIDVAXIS";
		VAXISCHK="&VAXISCHK";

		IF lowaxischk2=upaxischk2 AND INVALIDAXIS ^='YES' THEN CALL SYMPUT('VAXIS','');
		IF upaxischk2<0.01 or axisbyCHK<0.01 THEN CALL SYMPUT('MIDPOINTS','');
  		ELSE CALL SYMPUT('HAXISHIST','midpoints='||put(&lowaxis,7.2)||' TO '||put(&upaxis,7.2)||' BY '||put(&axisby,7.2));  /** Setup histogram midpoints statement **/
  
  		/* revised V2 */ 
		IF reporttype IN ('SCATTER', 'PRODRELEASE', 'CORR', 'HISTIND')  THEN DO;  /**  Check to see if user axis values do not include all data points.   **/
   			IF VAXISCHK='USER' THEN DO;			 /**  If not, setup warning flag.  **/
    				IF  (VALUE='MEAN' and ((minmean < lowaxischk2) 		OR (maxmean > upaxischk2))) OR
       	   		  	    (VALUE='INDIVIDUAL' and ((minind < lowaxischk2) 	OR (maxind > upaxischk2)))  OR    
           		   	    (VALUE='MIN' and ((minmin < lowaxischk2) 		OR (maxmin > upaxischk2)))  OR 
               		 	    (VALUE='MAX' and ((minmax < lowaxischk2) 		OR (maxmax > upaxischk2)))  OR
       		   		    (VALUE='STD' and ((minstd < lowaxischk2) 		OR (maxstd > upaxischk2)))  OR
               		            (VALUE='RSD' and ((minrsd < lowaxischk2) 		OR (maxrsd > upaxischk2)))  THEN 
	    				CALL SYMPUT('vwarning','YES');
			END;  
		END;
		IF reporttype IN ('SCATTER', 'PRODRELEASE', 'CORR', 'HISTIND')  THEN DO;  /**  Check to see if user axis values do not include all data points.   **/
   			IF VAXISCHK='USER' THEN DO;			 /**  If not, setup warning flag.  **/
    				IF  (VALUE='MEAN' and ((minmean < lowuserchk2) 		OR (maxmean > upuserchk2))) OR
       	   		  	    (VALUE='INDIVIDUAL' and ((minind < lowuserchk2) 	OR (maxind > upuserchk2)))  OR    
           		   	    (VALUE='MIN' and ((minmin < lowuserchk2) 		OR (maxmin > upuserchk2)))  OR 
               		 	    (VALUE='MAX' and ((minmax < lowuserchk2) 		OR (maxmax > upuserchk2)))  OR
       		   		    (VALUE='STD' and ((minstd < lowuserchk2) 		OR (maxstd > upuserchk2)))  OR
               		            (VALUE='RSD' and ((minrsd < lowuserchk2) 		OR (maxrsd > upuserchk2)))  THEN 
	    				CALL SYMPUT('vwarning','YES');
			END;  
		END;
	RUN;

	DATA _NULL_;  /* Setup Warning macro variables */
		FORMAT UprRefLine LowRefLine 7.;
		VAXISCHK="&VAXISCHK";
		USERUPAXIS="&USERUPAXIS";
		UprRefLine="&UprRefLine";
		USERLOWAXIS="&USERLOWAXIS";
		LowRefLine="&LowRefLine";
		%IF %SUPERQ(VALUE)=%SUPERQ(SPECVAL) AND %SUPERQ(REPORTYPE)^=CORR %THEN %DO;
			%IF %SUPERQ(VAXISCHK)=USER AND %SUPERQ(USERUPAXIS)^= AND %SUPERQ(USERLOWAXIS)^= AND %SUPERQ(UPRREFLINE)^= AND %SUPERQ(LOWREFLINE)^= %THEN %DO;
				%IF %SUPERQ(UprRefLine)^=0 AND %SUPERQ(LowRefLine)^=0 AND 
					(%SUPERQ(USERUPAXIS) < %SUPERQ(UprRefLine) OR %SUPERQ(USERLOWAXIS) > %SUPERQ(LowRefLine)) %THEN %DO;
					CALL SYMPUT('INVALIDAXIS','YES');
					CALL SYMPUT('RefWarning','YES');
				%END;
				%IF %SUPERQ(UprRefLine)=0 AND %SUPERQ(USERLOWAXIS) > %SUPERQ(LowRefLine) %THEN %DO;
					CALL SYMPUT('INVALIDAXIS','YES');
					CALL SYMPUT('RefWarning','YES');
				%END;
				%IF &LowRefLine=0 AND &USERUPAXIS < &UprRefLine %THEN %DO;
					CALL SYMPUT('INVALIDAXIS','YES');
					CALL SYMPUT('RefWarning','YES');
				%END;
			%END;
		%END;
	RUN;

	/* Print warning for invalid user axis values */
  	%IF %SUPERQ(PRINT)^=ON %THEN %DO;
		%IF (%SUPERQ(INVALIDVAXIS)=YES OR %SUPERQ(INVALIDHAXIS)=YES) %THEN %DO;
			DATA _NULL_; FILE _WEBOUT;
				PUT '</BR><P ALIGN=CENTER><STRONG><FONT FACE=ARIAL COLOR=RED>**NOTE: You entered invalid axis values.  Default axis values were used.**</FONT></STRONG></BR>';
				CALL SYMPUT('INVALIDAXIS','YES');
				lowaxis=put(&low_error,7.3);CALL SYMPUT('Lowaxis',lowaxis);
				upaxis=put(&upr_error,7.3); CALL SYMPUT('Upaxis',upaxis);
				axisby=put(&err_axis,8.4);  CALL SYMPUT('axisby',axisby);
	 		RUN;
			
		%END;
		%IF %SUPERQ(INVALIDMAXAXIS)=YES  %THEN %DO;
			DATA _NULL_; FILE _WEBOUT;
				PUT '</BR><P ALIGN=CENTER><STRONG><FONT FACE=ARIAL COLOR=RED>**NOTE: You entered an invalid max axis value.  Default axis value was used.**</FONT></STRONG></BR>';
	 		RUN;
		%END;
	%END;

	DATA _NULL_;  /* Setup Warning macro variables */
		reportchk="&reportype";lowaxis=TRIM(LEFT("&lowaxis"));upaxis=TRIM(LEFT("&upaxis"));
		IF reportchk='HISTIND' THEN  divisor=40; 	/* If the plot is a histogram THEN SET the axisby divisor to 40 */
  		                       ELSE  divisor=5 ;        /* and the ypixels to 700,otherwise SET the axisby divisor to 5 */
								/* and the ypixels to 400. */
		INVALIDAXIS="&INVALIDVAXIS"; VAXISCHK="&VAXISCHK";
		USERLOWAXIS="&USERLOWAXIS"; USERUPAXIS="&USERUPAXIS"; USERAXISBY="&USERAXISBY";	
		/* Check to see if user has entered valid axis values.  If no, then set to default. */
		AXISBY=(upaxis-lowaxis)/divisor;
		%IF %SUPERQ(INVALIDAXIS)=YES OR %SUPERQ(INVALIDVAXIS)=YES OR %SUPERQ(VAXISCHK)^=USER  
			%THEN %DO;
				CALL SYMPUT("lowaxis",PUT(lowaxis,7.3)); 
			        CALL SYMPUT("upaxis", PUT(upaxis,7.3));    
				CALL SYMPUT("axisby", axisby);          
			%END;
		        %ELSE %DO;
				CALL SYMPUT("LOWAXIS","&USERLOWAXIS");   
				CALL SYMPUT("AXISBY","&USERAXISBY");	 
		        	CALL SYMPUT("UPAXIS","&USERUPAXIS");	  
			%END;	  
		REFWARNING="&REFWARNING";
		HWARNING="&HWARNING";INVALIDHAXIS="&INVALIDHAXIS";
		VWARNING="&VWARNING";INVALIDVAXIS="&INVALIDVAXIS";
		REPORTYPE="&REPORTYPE";
		IF REFWARNING='' THEN DO;
			IF (HWARNING='' AND INVALIDHAXIS='') AND (VWARNING='YES' OR INVALIDVAXIS='YES') THEN DO;
			IF REPORTYPE='PRODRELEASE' THEN CALL SYMPUT('WARNING', 'FOOTNOTE F=ARIAL H=1.2 COLOR=red "**NOTE: Data points exist outside user defined axis range. Default axis used.**"');
			                           ELSE CALL SYMPUT('WARNING', 'FOOTNOTE F=ARIAL H=1.2 COLOR=red "**NOTE: Data points exist outside user defined vertical axis range.**"');
			END;
			ELSE IF (HWARNING='YES' OR INVALIDHAXIS='YES') AND (VWARNING='' AND INVALIDVAXIS='')   
						   THEN CALL SYMPUT('WARNING', 'FOOTNOTE F=ARIAL H=1.2 COLOR=red "**NOTE: Data points exist outside user defined horizontal axis range.**"');
	  		ELSE IF (HWARNING='YES' OR INVALIDHAXIS='YES') AND (VWARNING='YES' OR INVALIDVAXIS='YES')
						   THEN CALL SYMPUT('WARNING', 'FOOTNOTE F=ARIAL H=1.2 COLOR=red "**NOTE: Data points exist outside both user defined axis ranges.**"');
	  		ELSE                            CALL SYMPUT('WARNING','');
		END;
PUT reportchk upaxis lowaxis axisby divisor;
	RUN;

	%IF %SUPERQ(REFWARNING)^= AND %SUPERQ(INVALIDVAXIS)= AND %SUPERQ(INVALIDHAXIS)= %THEN %DO;
		DATA _NULL_; FILE _WEBOUT;
			PUT	"<P ALIGN=CENTER><BR><STRONG><FONT FACE=ARIAL COLOR=RED>**NOTE: Reference Lines exist outside user defined axis range. Default axis used.**</FONT></STRONG></BR>";
		RUN;
	%END;
	%IF %SUPERQ(REPORTYPE)^=CORR AND %SUPERQ(REPORTYPE)^=SCATTER %THEN %DO;

		%IF %SUPERQ(WARNING)^= AND %SUPERQ(REFWARNING)= AND %SUPERQ(INVALIDVAXIS)= AND %SUPERQ(INVALIDHAXIS)= %THEN %DO;
			DATA _NULL_; FILE _WEBOUT;
				PUT	"<P ALIGN=CENTER><BR><STRONG><FONT FACE=ARIAL COLOR=RED>**NOTE: Data points exist outside user defined axis range. Default axis used.**</FONT></STRONG></BR>";
			RUN;
			DATA _NULL_;
				CALL SYMPUT("VAXIS","ORDER= (&low_error TO &upr_error BY &Err_Axis)"); /** Setup vertical axis statement **/
				lowaxis=put(&low_error,7.3);CALL SYMPUT('Lowaxis',lowaxis);
				upaxis=put(&upr_error,7.3); CALL SYMPUT('Upaxis',upaxis);
				axisby=put(&err_axis,8.4);  CALL SYMPUT('axisby',axisby);
			RUN;
		%END;

	%END;

	DATA _NULL_;
		
		CALL SYMPUT("VAXIS","ORDER= (&lowaxis TO &upaxis BY &axisby)"); /** Setup vertical axis statement **/
  		CALL SYMPUT('HAXISHIST','midpoints='||put(&lowaxis,7.2)||' TO '||put(&upaxis,7.2)||' BY '||put(&axisby,7.4));  /** Setup histogram midpoints statement **/
		
	RUN;
	%END;
%PUT _all_;
%MEND Warnings;
****************************************************************************************************;
*                                      MODULE HEADER                                               *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;
*	REQUIREMENT     : See LINKS Report SOP                                                     *;
*       INPUT           : Macro variable: _replay                                                  *;
*       PROCESSING      : This code will be used if the user wants to save or print                *;
*			  a LINKS report.   It also does the following:                            *;
*			  Sets up macro variables to ensure a new graph is displayed for each      *;
*			  request.  Opens ODS RTF statement.                                       *;
*			  Sets up ODS close statement and device name.                             *;
*       OUTPUT          : Macro variable _replay2, close, device.                                  *;
****************************************************************************************************;
%MACRO Print;
	%GLOBAL close device ;

	/* Added V3 */   
	%IF %SUPERQ(REPORTYPE)=HISTIND %THEN %DO;
		DATA _NULL_;       
			CALL SYMPUT("ypixels", "ypixels=700");
		RUN;
	%END;

	DATA _NULL_;
 		rc=appsrv_header('Content-disposition',"attachment; FILEname=LINKS&reportype.&save_uid..rtf");
	RUN;

	ODS PATH work.templat(update) sasuser.templat(read)
		sashelp.tmplmst(read);

	/* Define RTF file style */
	proc template;
     	define style styles.newrtf;
       		parent=styles.rtf;
       		replace fonts /
        	'TitleFont2' = ("Arial",6pt,Bold Italic)
           	'TitleFont' = ("Arial",6pt,Bold Italic)
           	'StrongFont' = ("Arial",10pt,Bold)
           	'EmphasisFont' = ("Arial",10pt,Italic)
           	'FixedEmphasisFont' = ("Arial",9pt,Italic)
           	'FixedStrongFont' = ("Arial",9pt,Bold)
           	'FixedHeadingFont' = ("Arial",9pt,Bold)
           	'BatchFixedFont' = ("Arial",6.7pt)
           	'FixedFont' = ("Arial",6pt)
           	'headingEmphasisFont' = ("Arial",11pt,Bold Italic)
           	'headingFont' = ("Arial",5pt,Bold)	    
           	'docFont' = ("Arial",8pt);
		style Data from Data /
          	font=('Arial',7pt);

       		style Header from HeadersAndFooters /
          	font=('Arial',7pt,Bold);
           
		style cellcontents /
         	font=fonts("cellfont");
      		style header /
         	font=fonts("headingfont");
      
		replace Body from Document
      		"Controls the Body file." /
      		bottommargin = 0.25in
      		topmargin = 0.25in
      		rightmargin = 0.25in
      		leftmargin = 0.25in;
       	end;
   	run;

	ODS LISTING CLOSE;
	ODS RTF BODY=_WEBOUT (URL=&_REPLAY2) style=styles.newrtf;
	ODS NOPROCTITLE;

	%LET close=ODS RTF CLOSE;
	%LET device=JPEG;
	
%MEND Print;

****************************************************************************************************;
*                                      MODULE HEADER                                               *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;
*	REQUIREMENT     : See LINKS Report SOP                                                     *;
*       INPUT           : Macro variables: _Replay2, _SERVICE, _PROGRAM, _SERVER, _PORT,           *;
*			_SESSIONID, STUDY0, STUDY1,...STUDY#, LOWAXIS, UPAXIS, AXISBY,             *;
*			USERLOWAXIS, USERUPAXIS, USERAXISBY, HLOWAXIS, HUPAXIS, HAXISBY,           *;
*			USERHLOWAXIS, USERHUPAXIS, USERHAXISBY, PRODUCT, STORAGE, TESTA,           *;
*			STAGEA, PEAKA, TESTB, STAGEB, PEAKB, REPORTYPE, VALUE, CLASS, ANALYST,     *;
*			TIME, RPTVALUE, REPORTYPE, GROUPVAR, CORRTYPE, XPIXELS0, YPIXELS0,         *;
*			NUMPRODUCT, PRODUCT1,...PRODUCT#, NUMSTORAGE, STORAGE1,...STORAGE#,        *;
*			NUMTESTS, TEST1,...,TEST#, NUMSTAGES, STAGEA1,...,STAGEA#, NUMPEAKS,       *;
*			PEAKA1,...,PEAKA#, NUMANALYST, ANALYST1,...ANALYST#, NUMTIMES,             *;
*			TIME1,...,TIME#, NUMSTAGEB, STAGEB1,...,STAGEB#, NUMPEAKB,                 *;
*                       PEAKB1,...,PEAKB#, REG0, REG2.                                             *;                                                                           *;
*                                                                                                  *;
*       PROCESSING    : This code will setup the device and ODS close macro variables.             *;
*			It will also open the ODS HTML statement.                                  *;
*			This code will also create 20 drop down box menu HTML forms located        *;
*			on the left of the screen.  The forms will be automatically submitted      *; 
*			upon a change in one of the drop down boxes by the user.                   *;
*                                                                                                  *; 
*       OUTPUT        : 20 HTML forms with drop down boxes output to screen.                       *;
****************************************************************************************************;

%MACRO WEBOUT;

	%GLOBAL DEVICE CLOSE ;
	%LET close = ODS HTML CLOSE;
	%LET device=GIF;
	
	/* Setup standard form variables */
	%MACRO THISSESSION;
		PUT   '<INPUT TYPE="hidden" NAME="_service" VALUE="default">';
  		LINE= '<INPUT TYPE="hidden" NAME="_program" VALUE="'||"links.LRStAnalysis.sas"	||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=_server    VALUE="'||symget('_server')	   	||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=_port      VALUE="'||symget('_port')		||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=_sessionid VALUE="'||symget('_sessionid')	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=_DEBUG     VALUE="0">'; 				PUT LINE; 
  	%MEND;

	/* Setup study list variables */
	%MACRO STUDIES;
	       	%IF %SUPERQ(study)^= %THEN %DO;
    	   		LINE='<INPUT TYPE="hidden" NAME=study0  VALUE="'||COMPRESS("&study0")  	||'">'; PUT LINE;
    		      	LINE='<INPUT TYPE="hidden" NAME=study   VALUE="'||COMPRESS("&study")   	||'">'; PUT LINE;
    		    	%DO i = 1 %TO &study0;
        	  		LINE='<INPUT TYPE="hidden" NAME=study'||"&i"||' VALUE="'||COMPRESS("&&study&i")||'">'; PUT LINE;
        		%END;
     		%END;
	%MEND STUDIES;
    /* Changed length V */
	DATA _NULL_; LENGTH LINE anchor $3000;  /* Create html table for drop down menus and checkboxes. */
  		FILE _WEBOUT;

  		/* Set up LINKS banner */	/* Modified V3 */
   		PUT '<BODY BGCOLOR="#808080"><TITLE>LINKS Stability Analysis Tools - Unofficial Report If Printed From Web Browser</TITLE></BODY>';
  		PUT '<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" BORDER="1" BORDERCOLOR="#003366" CELLPADDING="0" CELLSPACING="0">';
  		PUT '<TR ALIGN="LEFT" ><TD COLSPAN=2 BGCOLOR="#003366">';
  		PUT '<TABLE ALIGN=left VALIGN=top HEIGHT="100%" WIDTH="100%"><TR><TD ALIGN=left><BIG><BIG><BIG>';
		LINE= '<IMG SRC="//'||"&_server"||'/links/images/gsklogo1.gif" WIDTH="141" HEIGHT="62">'; PUT LINE;
  		PUT '<FONT FACE=ARIAL COLOR="#FFFFFF"><EM> LINKS </EM> Stability Module</FONT></BIG></BIG></BIG></TD>';

		/* Setup hyperlink to Stability Menu */
		ANCHOR= '<TD ALIGN=RIGHT><A HREF="'|| "%SUPERQ(_THISSESSION)" ||
		'&_program=links.LRReport.sas"><FONT FACE=ARIAL color="#FFFFFF">Back to Stability Menu</FONT></A>';
		PUT ANCHOR; 

		/* Setup link to print or save LINKS report */
  		anchor= '<TD ALIGN=right><A HREF="'|| "%superq(_THISSESSION)" ||'&print=ON
		&_program='		||"links.LRSTAnalysis.sas"	||
		'&lowaxis='		||"&lowaxis"		   	||
  		'&upaxis='		||"&upaxis" 		   	||
  		'&axisby='		||"&axisby" 		   	||
		'&USERlowaxis='		||"&USERlowaxis"		||
  		'&USERupaxis='		||"&USERupaxis" 		||
  		'&USERaxisby='		||"&USERaxisby" 		||
  		'&hlowaxis='		||"&hlowaxis"	   	   	||
 		'&hupaxis='		||"&hupaxis"		   	||
  		'&haxisby='		||"&haxisby"		   	||
		'&USERhlowaxis='	||"&USERhlowaxis"	   	||
 		'&USERhupaxis='		||"&USERhupaxis"		||
  		'&USERhaxisby='		||"&USERhaxisby"		||
		'&product='		||"&product"			||
		'&storage='		||"&storage"	       		||
		'&testA='		||"&testa"		  	||
		'&stageA='		||"&stageA"	       		||
		'&peakA='		||"&peakA"			||
 		'&VALUE='		||"&VALUE"	       		||
  		'&class='		||"&class"	       		||
 		'&analyst='		||"&analyst"	       		||
  		'&time='		||"&time"	           	||
  		'&rptvalue='		||"&rptvalue"	       		||
  		'&testB='		||"&testB"	       		||
  		'&StageB='		||"&StageB"	       		||
  		'&PeakB='		||"&PeakB"	       		||
  		'&reportype='		||"&reportype"	   		||
		'&groupvar='		||"&groupvar"			||
		'&corrtype='		||"&corrtype"			||
		'&REG0='		||"&REG0"			||
		'&REG2='		||"&REG2"			||
		'&DATATYPE='	  	||"&DATATYPE"			||
		'&study0='		||"&study0"			||
		%DO I = 1 %TO &STUDY0;
			"STUDY&i="	||'"'||TRIM("&&STUDY&i")   ||'"'||
		%END;
		'"><FONT FACE=ARIAL COLOR="#FFFFFF">Print or Save Analysis</FONT></A></TD></TR></TABLE>'; 
	    	PUT anchor; 

  		PUT '</TD></TR>';

  	RUN;
	ODS HTML BODY=_WEBOUT /* Removed V4 (DYNAMIC)*/ RS=NONE PATH=&_TMPCAT (URL=&_REPLAY2);

	/* FORM 1: HTML to change data status. */
	DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; 
  		PUT   '<FONT FACE=arial SIZE=1>';
  		PUT   '<TR HEIGHT="87%"><TD BGCOLOR="#ffffdd" nowrap HEIGHT="25" WIDTH="20%" ALIGN="left" VALIGN="top">';
		PUT   '<TABLE WIDTH="100%" BORDER="0" ><TR ><TD BORDER="0" >';
		LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

		%THISSESSION;  	

  		LINE= '<INPUT TYPE="hidden" NAME=upaxis     VALUE="'||TRIM("&upaxis") 	   	||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=lowaxis    VALUE="'||TRIM("&lowaxis")	   	||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=axisby     VALUE="'||TRIM("&axisby") 	   	||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=hupaxis    VALUE="'||TRIM("&hupaxis")	   	||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=hlowaxis   VALUE="'||TRIM("&hlowaxis")	   	||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=haxisby    VALUE="'||TRIM("&haxisby")	   	||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=xpixels0   VALUE="'||TRIM("&xpixels0")	  	||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=ypixels0   VALUE="'||TRIM("&ypixels0")	   	||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=REG0       VALUE="'||TRIM("&REG0")	   	||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=REG2       VALUE="'||TRIM("&REG2")	   	||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=storage    VALUE="'||TRIM("&storage")	    	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="'||TRIM(symget("testA"))	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="'||TRIM("&stageA")	    	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="'||TRIM("&peakA")	    	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=testB      VALUE="'||TRIM("&testB")	    	||'">'; PUT LINE; 
 		LINE= '<INPUT TYPE="hidden" NAME=StageB     VALUE="'||TRIM("&StageB")	    	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=PeakB      VALUE="'||TRIM("&PeakB")	    	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=rptvalue   VALUE="'||TRIM("&rptvalue")	    	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=VALUE      VALUE="'||TRIM("&VALUE")   		||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=class      VALUE="'||TRIM("&class")   		||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=analyst    VALUE="'||TRIM("&analyst")     	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=time       VALUE="'||TRIM("&time")	       	||'">'; PUT LINE; 
   		LINE= '<INPUT TYPE="hidden" NAME=groupvar   VALUE="'||TRIM("&groupvar")    	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=corrtype   VALUE="'||TRIM("&corrtype")    	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="'||TRIM("&product")	    	||'">'; PUT LINE; 
		PUT '<STRONG><SMALL><FONT FACE="Arial" COLOR="#003366">Data Status:</FONT></SMALL></STRONG>';
  		PUT '</br>&nbsp;&nbsp;&nbsp;<SELECT NAME="DataType" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';

  		%IF %SUPERQ(DATATYPE)=ALL %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
      		LINE= '<OPTION '||"&SELECT"||' VALUE="ALL">All Data</OPTION>'; PUT LINE;
    		%IF %SUPERQ(DATATYPE)=APP %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
      		LINE= '<OPTION '||"&SELECT"||' VALUE="APP">Approved Data Only</OPTION>'; PUT LINE;	

      		PUT '</SELECT></TD></TR></FORM>';
  	RUN;
  	
	/* FORM 2: HTML to change product.  Select current product.   */
  	DATA _NULL_; LENGTH LINE $1000 ;  
  		FILE _WEBOUT;
  		PUT   '<FONT FACE=arial SIZE=1>';
  		PUT   '<TR BGCOLOR="#ffffdd"><TD BGCOLOR="#FFFFDD">';
  		LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

		%THISSESSION;

  		LINE= '<INPUT TYPE="hidden" NAME=xpixels0   VALUE="'||TRIM("&xpixels0")		||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=ypixels0   VALUE="'||TRIM("&ypixels0")		||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="'||TRIM("&stageA")	    	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=storage    VALUE="'||TRIM("&storage")	    	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="'||TRIM("&testA")	   	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=VALUE      VALUE="'||TRIM("&VALUE")	   	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=class      VALUE="'||TRIM("&class")	   	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=analyst    VALUE="'||TRIM("&analyst")	   	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=time       VALUE="'||TRIM("&time")	       	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=rptvalue   VALUE="'||TRIM("&rptvalue")	   	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=testB      VALUE="'||TRIM("&testB")	   	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=StageB     VALUE="'||TRIM("&StageB")	   	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=PeakB      VALUE="'||TRIM("&PeakB")	   	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=DataType   VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=GROUPVAR   VALUE="'||TRIM("&GROUPVAR")	    	||'">'; PUT LINE; 
 		LINE= '<INPUT TYPE="hidden" NAME=CORRTYPE   VALUE="'||TRIM("&CORRTYPE")	    	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=REG0       VALUE="'||TRIM("&REG0")	   	||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=REG2       VALUE="'||TRIM("&REG2")	   	||'">'; PUT LINE;
		
		PUT '<STRONG><SMALL><FONT FACE="Arial" COLOR="#003366">Product:</FONT></SMALL></STRONG>';
  		PUT '</br>&nbsp;&nbsp;&nbsp;<SELECT NAME="Product" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';

  		%LOCAL i;
	    	%DO i = 1 %TO &numproduct;   
      			%LET temp="&&product&i"; 
      			%LET temp2="&prodchk";   
      			%IF &temp=&temp2 %THEN %LET SELECT=selected; 	/* If current product = product in list, select product. */
      				 	 %ELSE %LET SELECT= ;		/* Otherwise, don't select it. */
      			LINE= '<OPTION '||"&SELECT"||' VALUE="'||"&&product&i"||'">'||"&&product&i"||'</OPTION>'; PUT LINE;
    		%END;
    	      	
  		PUT '</SELECT></TD></TR></FORM>';
  	RUN;
 		
	%IF %SUPERQ(REPORTYPE)^=PRODRELEASE %THEN %DO;
		DATA _NULL_; LENGTH LINE $1000 ; 
  			FILE _WEBOUT;  /* FORM 3: HTML to change storage condition. Select current storage condition. */
  			PUT   '<TR BGCOLOR="#ffffdd"><TD BGCOLOR="#FFFFDD">';
			LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;
			%THISSESSION;
			LINE= '<INPUT TYPE="hidden" NAME=lowaxis    VALUE="'||TRIM("&lowaxis")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=upaxis     VALUE="'||TRIM("&upaxis") 		||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=axisby     VALUE="'||TRIM("&axisby") 		||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=hlowaxis   VALUE="'||TRIM("&hlowaxis")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=hupaxis    VALUE="'||TRIM("&hupaxis")		||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=haxisby    VALUE="'||TRIM("&haxisby")		||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=xpixels0   VALUE="'||TRIM("&xpixels0")		||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=ypixels0   VALUE="'||TRIM("&ypixels0")		||'">'; PUT LINE;
 			LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="'||TRIM("&product")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="'||TRIM("&testA")	    	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="'||TRIM("&stageA")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="'||TRIM("&peakA")	   	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=DataType   VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=VALUE      VALUE="'||TRIM("&VALUE")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=class      VALUE="'||TRIM("&class")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=analyst    VALUE="'||TRIM("&analyst")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=rptvalue   VALUE="'||TRIM("&rptvalue")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testB      VALUE="'||TRIM("&testB")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=StageB     VALUE="'||TRIM("&StageB")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=PeakB      VALUE="'||TRIM("&PeakB")	    	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=GROUPVAR   VALUE="'||TRIM("&GROUPVAR")	   	||'">'; PUT LINE; 
 			LINE= '<INPUT TYPE="hidden" NAME=CORRTYPE   VALUE="'||TRIM("&CORRTYPE")	   	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=REG0       VALUE="'||TRIM("&REG0")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=REG2       VALUE="'||TRIM("&REG2")	   	||'">'; PUT LINE;
		
			%STUDIES;
  
			PUT '<STRONG><SMALL><FONT FACE="Arial" COLOR="#003366">Storage Condition:</FONT></SMALL></STRONG>';
  			PUT '</br>&nbsp;&nbsp;&nbsp;<SELECT NAME="Storage" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';

  			%LOCAL i;
    			%DO i = 1 %TO &numstorage;   
			      	%LET temp="&&storage&i";  /* Select current storage condition */
      				%LET temp2="&condchk";
      				%IF &temp=&temp2 %THEN %LET SELECT=selected;
      				                 %ELSE %LET SELECT= ;
      				line= '<OPTION '||"&SELECT"||' VALUE="'||"&&storage&i"||'">'||"&&storage&i"||'</OPTION>'; PUT line;
    			%END;
   	
	 		PUT '</SELECT></TD></TR></FORM>';
		RUN;
	%END;

	DATA _NULL_; LENGTH LINE $1000 ;   /* FORM 4: HTML to change test.  Select current test. */
  		FILE _WEBOUT;  
		reportype="&reportype";									/* Added V3 */
		IF REPORTYPE ^='CIPROFILES' THEN DO;							/* Added V3 */
  			PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
			LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

			%THISSESSION;

  			LINE= '<INPUT TYPE="hidden" NAME=xpixels0   VALUE="'||TRIM("&xpixels0")		||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=ypixels0   VALUE="'||TRIM("&ypixels0")		||'">'; PUT LINE;
			LINE= '<INPUT TYPE="hidden" NAME=REG0       VALUE="'||TRIM("&REG0")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=REG2       VALUE="'||TRIM("&REG2")	   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=storage    VALUE="'||TRIM("&storage")	       	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="'||TRIM("&reportype")   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=VALUE      VALUE="'||TRIM("&VALUE")       	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=class      VALUE="'||TRIM("&class")       	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=analyst    VALUE="'||TRIM("&analyst")	      	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=time       VALUE="'||TRIM("&time")	        ||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=rptvalue   VALUE="'||TRIM("&rptvalue")	      	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testB      VALUE="'||TRIM("&testB")	   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=StageB     VALUE="'||TRIM("&StageB")	   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=PeakB      VALUE="'||TRIM("&PeakB")	    	||'">'; PUT LINE; 
   			LINE= '<INPUT TYPE="hidden" NAME=CORRTYPE   VALUE="'||TRIM("&CORRTYPE")	    	||'">'; PUT LINE;
			LINE= '<INPUT TYPE="hidden" NAME=DataType   VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="'||TRIM("&product")	       	||'">'; PUT LINE; 

			%STUDIES;

  			PUT '<STRONG><SMALL><FONT FACE="Arial" COLOR="#003366">Test Method:</FONT></SMALL></STRONG>';
  			PUT '</br>&nbsp;&nbsp;&nbsp;<SELECT NAME="TestA" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';
  	    		%LOCAL i;
    			%DO i = 1 %TO &numtest;   /* Select current test */
		      		%LET temp="&&test&i";
	      			%LET temp2="&testachk";			
	      			%IF &temp=&temp2 %THEN %LET SELTEST=selected;
	      			%ELSE %LET selTEST= ;
			    	line= '<OPTION '||"&SELTEST"||' VALUE="'||"&&test&i"||'">'||
                                      '<FONT FACE=arial SIZE="1">'||"&&test&i"||'</FONT></OPTION>'; PUT line;
		    	%END;
			      	
	  		PUT '</SELECT></TD></TR></FORM>';
		END;											/* Added V3 */
 	RUN;

	DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; /* FORM 5: HTML TO CHANGE STAGE IF STAGE EXISTS */
  		numstages="&numstageA";	reportype="&Reportype";  PEAKA=COMPRESS(UPCASE("&PEAKA"));
  		IF numstages>1 and reportype ^= 'CIPROFILES' AND (peaka^='TOTALNUMBEROFPARTICLES') THEN DO;
  			PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
			LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

			%THISSESSION;

			LINE= '<INPUT TYPE="hidden" NAME=xpixels0   VALUE="'||TRIM("&xpixels0")		||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=ypixels0   VALUE="'||TRIM("&ypixels0")		||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="'||TRIM("&product")	   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=storage    VALUE="'||TRIM("&storage")	   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="'||TRIM(symget("testA"))	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="'||TRIM("&peakA")	   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="'||TRIM("&reportype")	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=VALUE      VALUE="'||TRIM("&VALUE")	   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=class      VALUE="'||TRIM("&class")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=analyst    VALUE="'||TRIM("&analyst")	   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=time       VALUE="'||TRIM("&time")	       	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=rptvalue   VALUE="'||TRIM("&rptvalue")	   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testB      VALUE="'||TRIM("&testB")		||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=StageB     VALUE="'||TRIM("&StageB")		||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=PeakB      VALUE="'||TRIM("&PeakB")   		||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=GROUPVAR   VALUE="'||TRIM("&GROUPVAR")	    	||'">'; PUT LINE; 
 			LINE= '<INPUT TYPE="hidden" NAME=CORRTYPE   VALUE="'||TRIM("&CORRTYPE")	    	||'">'; PUT LINE;
			LINE= '<INPUT TYPE="hidden" NAME=REG0       VALUE="'||TRIM("&REG0")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=REG2       VALUE="'||TRIM("&REG2")	   	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=DataType   VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE; 
			
			%STUDIES;

			CIFLAG="&CIFLAG";  /* Setup drop down box label */
  			IF CIFLAG NOT IN ("YES") 
				THEN PUT '<STRONG><FONT  FACE="Arial" SIZE="2" COLOR="#003366">&nbsp;&nbsp;&nbsp;<EM>Test Parameter:</EM></FONT></STRONG>';
  				ELSE PUT '<STRONG><FONT  FACE="Arial" SIZE="2" COLOR="#003366">&nbsp;&nbsp;&nbsp;<EM>CI Stage:</EM></FONT></STRONG>';
  
  			PUT '</br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
  			LINE= '<SELECT NAME="stageA" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">'; PUT LINE;

  			%LOCAL i;
	    		%DO i = 1 %TO &numstageA;   
     				%LET temp="&&stageA&i";  /* Select current stage */
      				%LET temp2="&stageAchk";
      				%IF &temp=&temp2 %THEN %LET selstage=selected;
      						 %ELSE %LET selstage= ;
      				line= '<OPTION '||"&selstage"||' VALUE="'||"&&stageA&i"||'">'||"Stage: &&stageA&i"||'</OPTION>'; PUT line;
    			%END;

			PUT '</SELECT></TD></TR></FORM>';
  		END;
	RUN;

	DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; /* FORM 6: HTML TO CHANGE PEAK IF PEAKS EXISTS */
  		numpeak="&numpeakA";	testa=TRIM("&testa");
  		IF numpeak>1 and testa not IN ('HPLC Related Imp. in Advair MDPI') THEN DO;
			PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
			LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;
			%THISSESSION;
			LINE= '<INPUT TYPE="hidden" NAME=xpixels0    VALUE="'||TRIM("&xpixels0")	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=ypixels0    VALUE="'||TRIM("&ypixels0")	||'">'; PUT LINE;
			LINE= '<INPUT TYPE="hidden" NAME=REG0        VALUE="'||TRIM("&REG0")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=REG2        VALUE="'||TRIM("&REG2")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=storage     VALUE="'||TRIM("&storage")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testA       VALUE="'||TRIM(symget("testA"))	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=stageA      VALUE="'||TRIM("&stageA")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testB       VALUE="'||TRIM("&testB")		||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=StageB      VALUE="'||TRIM("&StageB")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=PeakB       VALUE="'||TRIM("&PeakB")  		||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=reportype   VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=rptvalue    VALUE="'||TRIM("&rptvalue")	||'">'; PUT LINE; 
   			LINE= '<INPUT TYPE="hidden" NAME=VALUE       VALUE="'||TRIM("&VALUE")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=time        VALUE="'||TRIM("&time")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=class       VALUE="'||TRIM("&class")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=analyst     VALUE="'||TRIM("&analyst")	    	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=GROUPVAR    VALUE="'||TRIM("&GROUPVAR")	||'">'; PUT LINE; 
 			LINE= '<INPUT TYPE="hidden" NAME=CORRTYPE    VALUE="'||TRIM("&CORRTYPE")	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=DataType    VALUE="'||TRIM("&DataType")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=product     VALUE="'||TRIM("&product")	    	||'">'; PUT LINE; 
		
			%STUDIES;

			PUT '<STRONG><FONT  FACE="Arial" SIZE="2" COLOR="#003366" ><EM>';
			/* Setup drop down box label */
			IF TESTA IN ('Foreign Particulate Matter') 
				THEN	PUT '&nbsp;&nbsp;&nbsp;Particle Size:'; 	
				ELSE	PUT '&nbsp;&nbsp;&nbsp;Drug Substance:';	
			PUT '</EM></FONT></STRONG>';
			PUT '</br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			PUT '<SELECT NAME="PeakA" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';

			%LOCAL i;
    			%DO i = 1 %TO &numpeakA;   
	    			%LET temp="&&peakA&i";  /* Select current peak */
		        	%LET temp2="&peakAchk";
      				%IF %UPCASE(&temp)=%UPCASE(&temp2) %THEN %LET selpeak=selected;
      						 %ELSE %LET selpeak= ;
	        		line= '<OPTION '||"&selpeak"||' VALUE="'||"&&peakA&i"||'">'||"&&peakA&i"||'</OPTION>'; 
				PUT line;
    			%END;	  
  
	 	  	PUT '</SELECT></TD></TR></FORM>';
  		END;
	RUN;
	
	DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; /* FORM 7: HTML to change report type */
  		PUT   '<TR><TD ><HR></tD></tR>'; 
   		PUT '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
		LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

		%THISSESSION;

  		LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="'||TRIM("&product")	       	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=storage    VALUE="'||TRIM("&storage")	       	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="'||TRIM(symget("testA"))	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="'||TRIM("&stageA")	       	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="'||TRIM("&peakA")	       	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=DataType   VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE; 
   		
  		%STUDIES;  

  		PUT '<STRONG><SMALL><FONT FACE="Arial" COLOR="#003366">Report:</FONT><SMALL></STRONG>';
  		PUT '</br>&nbsp;&nbsp;&nbsp;<SELECT NAME="Reportype" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';

  		%MACRO stats;
	    		%IF %SUPERQ(reportype2)=%SUPERQ(reportype) 
				%THEN %LET selectstat=selected; /* Select current report */
	    			%ELSE %LET selectstat= ;
	       		line='<OPTION '||"&selectstat"||' VALUE="'||"&reportype2"||'">'||"&reportype3"||'</OPTION>'; PUT line;
  		%MEND;

  		%LET reportype2=SCATTER; 	%LET reportype3=Scatter Plot by Time Point; 		%stats;
  		%LET reportype2=HISTIND; 	%LET reportype3=Histogram of Individual Results; 	%stats;
  		%LET reportype2=SUMSTATS; 	%LET reportype3=Summary Statistics Table;		%stats;
  		%LET reportype2=CORR; 		%LET reportype3=Correlation Analysis; 			%stats;  
		%LET reportype2=PRODRELEASE; 	%LET reportype3=Initial Data vs. Product Release;  	%stats;  
  	RUN;

  	%LET reportype2= ;
  	%LET reportype3= ;
 
 	DATA _NULL_;  /* SETUP VARIABLES FOR CI PROFILES */
  		CIFLAG="&CIFLAG";
  		IF CIFLAG='YES' THEN DO;
     			CALL SYMPUT('reportype2','CIPROFILES');
		 	CALL SYMPUT('reportype3','Cascade Impaction Profiles');
  		END;
  	RUN;

  	DATA _NULL_; FILE _WEBOUT;
  		CIFLAG="&CIFLAG";
  		IF CIFLAG='YES' THEN %stats;
	    	PUT '</SELECT></TD></TR></FORM>';
  	RUN;

  	DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT;  /* FORM 8: HTML to change scatterplot statistic */

  		%IF %SUPERQ(REPORTYPE)=SCATTER %THEN %DO;
   			PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
			LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

			%THISSESSION;

	  		LINE= '<INPUT TYPE="hidden" NAME=hlowaxis   VALUE="'||TRIM("&hlowaxis")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=hupaxis    VALUE="'||TRIM("&hupaxis")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=haxisby    VALUE="'||TRIM("&haxisby")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=xpixels0   VALUE="'||TRIM("&xpixels0")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=ypixels0   VALUE="'||TRIM("&ypixels0")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="'||TRIM("&product")	   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=storage    VALUE="'||TRIM("&storage")	   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="'||TRIM(symget("testA"))	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="'||TRIM("&stageA")	   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="'||TRIM("&peakA")	   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=DataType   VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE; 
  			
  			%STUDIES;

  			PUT '<STRONG><FONT  FACE="Arial" SIZE="2" COLOR="#003366"><EM>&nbsp;&nbsp;&nbsp;Plot Statistic:</EM></br></FONT></STRONG>';
  			PUT '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<SELECT NAME="VALUE" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';
  			%IF %SUPERQ(VALUE)=MEAN 	%THEN %LET selreport=selected;
				  			%ELSE %LET selreport= ;
  			LINE= '<OPTION '||"&SELREPORT"||' VALUE="MEAN">Mean</OPTION>'; PUT LINE;
  			%IF %SUPERQ(VALUE)=STD  	%THEN %LET selreport=selected;
  							%ELSE %LET selreport= ;
  			LINE= '<OPTION '||"&SELREPORT"||' VALUE="STD">Standard Deviation</OPTION>'; PUT LINE;
  			%IF %SUPERQ(VALUE)=RSD 		%THEN %LET selreport=selected;
  							%ELSE %LET selreport= ;
  			LINE= '<OPTION '||"&SELREPORT"||' VALUE="RSD">RSD</OPTION>'; PUT LINE;
  			%IF %SUPERQ(VALUE)=INDIVIDUAL   %THEN %LET selreport=selected;
  							%ELSE %LET selreport= ;
 			LINE= '<OPTION '||"&SELREPORT"||' VALUE="INDIVIDUAL">Individual Results</OPTION>'; PUT LINE;
  			%IF %SUPERQ(VALUE)=MIN 		%THEN %LET selreport=selected;
  							%ELSE %LET selreport= ;
  			LINE= '<OPTION '||"&SELREPORT"||' VALUE="MIN">Minimum</OPTION>'; PUT LINE;
  			%IF %SUPERQ(VALUE)=MAX 		%THEN %LET selreport=selected;
  							%ELSE %LET selreport= ;
  			LINE= '<OPTION '||"&SELREPORT"||' VALUE="MAX">Maximum</OPTION>'; PUT LINE;
  			PUT '</SELECT></TD></TR></FORM>';
		
		%END;
	RUN;

	DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT;
 	%IF %SUPERQ(reportype)=HISTIND %THEN %DO;  /* FORM 9: HTML to change histogram class variable */
  		  		
  			PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
			LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

			%THISSESSION;

			LINE= '<INPUT TYPE="hidden" NAME=lowaxis    VALUE="'||TRIM("&lowaxis")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=upaxis     VALUE="'||TRIM("&upaxis") 	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=axisby     VALUE="'||TRIM("&axisby") 	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=hlowaxis   VALUE="'||TRIM("&hlowaxis")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=hupaxis    VALUE="'||TRIM("&hupaxis")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=haxisby    VALUE="'||TRIM("&haxisby")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="'||TRIM("&product")	   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=storage    VALUE="'||TRIM("&storage")	   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="'||TRIM(symget("testA"))	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="'||TRIM("&stageA")	   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="'||TRIM("&peakA")	   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="'||TRIM("&reportype")   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=time       VALUE="'||TRIM("&time")	       	||'">'; PUT LINE; 
			LINE='<INPUT TYPE="hidden"  NAME=ObsMaxPct  VALUE="'||TRIM("&ObsMaxPct")   	||'">'; PUT LINE;
			LINE= '<INPUT TYPE="hidden" NAME=DataType   VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE; 
   		
  			%STUDIES;

  			PUT '<STRONG><FONT  FACE="Arial" SIZE="2" COLOR="#003366"><EM>&nbsp;&nbsp;&nbsp;Comparative Variable:</EM></br></FONT></STRONG>';
	  		PUT '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<SELECT NAME="class" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';
	  		%IF %SUPERQ(class)=TIME 		%THEN %LET selclass=selected;
				  				%ELSE %LET selclass= ;
   			LINE= '<OPTION '||"&SELCLASS"||' VALUE="TIME">Time Point</OPTION>'; PUT LINE; 
  			%IF %SUPERQ(class)=STUDY 		%THEN %LET selclass=selected;
  								%ELSE %LET selclass= ;
   			LINE= '<OPTION '||"&SELCLASS"||' VALUE="STUDY">Study</OPTION>'; PUT LINE; 
			ROLECHK="&SAVE_USERROLE";
  			%IF %SUPERQ(SAVE_USERROLE)=LevelA %THEN %DO;
				%IF %SUPERQ(class)=ANALYST 	%THEN %LET selclass=selected;
  								%ELSE %LET selclass= ;
  				%IF %superq(numanalyst) > 0 %THEN %DO; 
					LINE= '<OPTION '||"&SELCLASS"||' VALUE="ANALYST">Analyst</OPTION>'; PUT LINE; 
				%END;
			%END;
  			PUT '</SELECT></TD></TR></FORM>';
		RUN;

		DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; /* FORM 10: HTML TO LIST ANALYSTS */
	  	
		%IF %SUPERQ(class)=ANALYST %THEN %DO;
	    		%IF %SUPERQ(numanalyst)>0 %THEN %DO;
				PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
				LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

				%THISSESSION;

				LINE= '<INPUT TYPE="hidden" NAME=lowaxis    VALUE="'||TRIM("&lowaxis")	   	||'">'; PUT LINE;
				LINE= '<INPUT TYPE="hidden" NAME=upaxis     VALUE="'||TRIM("&upaxis") 	   	||'">'; PUT LINE;
				LINE= '<INPUT TYPE="hidden" NAME=axisby     VALUE="'||TRIM("&axisby") 	   	||'">'; PUT LINE;
				LINE= '<INPUT TYPE="hidden" NAME=hlowaxis   VALUE="'||TRIM("&hlowaxis")	   	||'">'; PUT LINE;
				LINE= '<INPUT TYPE="hidden" NAME=hupaxis    VALUE="'||TRIM("&hupaxis")	   	||'">'; PUT LINE;
				LINE= '<INPUT TYPE="hidden" NAME=haxisby    VALUE="'||TRIM("&haxisby")	   	||'">'; PUT LINE;
				LINE= '<INPUT TYPE="hidden" NAME=xpixels0   VALUE="'||TRIM("&xpixels0")	   	||'">'; PUT LINE;
				LINE= '<INPUT TYPE="hidden" NAME=ypixels0   VALUE="'||TRIM("&ypixels0")	   	||'">'; PUT LINE;
				LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="'||TRIM("&product")	   	||'">'; PUT LINE; 
				LINE= '<INPUT TYPE="hidden" NAME=storage    VALUE="'||TRIM("&storage")	   	||'">'; PUT LINE; 
				LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="'||TRIM(symget("testA"))	||'">'; PUT LINE; 
				LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="'||TRIM("&stageA")	   	||'">'; PUT LINE; 
				LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="'||TRIM("&peakA")	   	||'">'; PUT LINE; 
				LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="'||TRIM("&reportype")   	||'">'; PUT LINE; 
				LINE= '<INPUT TYPE="hidden" NAME=class      VALUE="'||TRIM("&class")	   	||'">'; PUT LINE; 
				LINE= '<INPUT TYPE="hidden" NAME=time       VALUE="'||TRIM("&time")	       	||'">'; PUT LINE; 
				LINE= '<INPUT TYPE="hidden" NAME=ObsMaxPct  VALUE="'||TRIM("&ObsMaxPct")	||'">'; PUT LINE;
				LINE= '<INPUT TYPE="hidden" NAME=DataType   VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE; 

				%studies;
				 
	  			PUT '<FONT SIZE="2" FACE=Arial COLOR="#003366"><EM><STRONG>&nbsp;&nbsp;&nbsp;Analyst: </EM></br></STRONG></FONT>';
	  			PUT '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<SELECT NAME="analyst" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';
	
	 			%LOCAL i;
	  			%DO i = 1 %TO &numanalyst;   /* Select current analyst */
					%IF &analyst EQ 'N/A' %THEN %LET analyst=None;
					%LET temp=&&analyst&i;
							 
					%put _ALL_;
		  			%IF %SUPERQ(TEMP)=&ANALYST %THEN %LET SELECT=selected; %ELSE %LET SELECT= ; 
	      				LINE='<OPTION '||"&SELECT"||' VALUE="'||COMPRESS("&&analyst&i")||'">'||TRIM("&&analyst&i")||'</OPTION>'; PUT LINE;
	  			%END;
  
				%IF %SUPERQ(NUMANALYST)>1 %THEN %DO;  /* Include selection for all analysts */
	    				%IF %SUPERQ(analyst)=ALL %THEN %LET SELECT=SELECTED;  %ELSE %LET SELECT=;
	  				LINE='<OPTION '||"&SELECT"||' VALUE="ALL">All Analysts</OPTION>'; PUT LINE; 
				%END;
  					
				PUT '</SELECT></TD></TR></FORM>';
  			%END;	
  		%END;
		RUN;

		DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; /* FORM 11: HTML TO CHANGE TIME POINT */
	  		PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD" >';
			LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

			%THISSESSION;

			LINE= '<INPUT TYPE="hidden" NAME=lowaxis    VALUE="'||TRIM("&lowaxis")	   	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=upaxis     VALUE="'||TRIM("&upaxis") 	   	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=axisby     VALUE="'||TRIM("&axisby") 	   	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=hlowaxis   VALUE="'||TRIM("&hlowaxis")	   	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=hupaxis    VALUE="'||TRIM("&hupaxis")	   	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=haxisby    VALUE="'||TRIM("&haxisby")	   	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=xpixels0   VALUE="'||TRIM("&xpixels0")	   	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=ypixels0   VALUE="'||TRIM("&ypixels0")	   	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="'||TRIM("&product")	    	||'">'; PUT LINE; 
	  		LINE= '<INPUT TYPE="hidden" NAME=storage    VALUE="'||TRIM("&storage")	    	||'">'; PUT LINE; 
	  		LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="'||TRIM(symget("testA")) 	||'">'; PUT LINE; 
	  		LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="'||TRIM("&stageA")	    	||'">'; PUT LINE; 
	  		LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="'||TRIM("&peakA")	    	||'">'; PUT LINE; 
	  		LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="'||TRIM("&reportype")    	||'">'; PUT LINE; 
	  		LINE= '<INPUT TYPE="hidden" NAME=class      VALUE="'||TRIM("&class")	    	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=ObsMaxPct  VALUE="'||TRIM("&ObsMaxPct")	||'">'; PUT LINE;
			LINE= '<INPUT TYPE="hidden" NAME=DataType   VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE; 

	   		%studies;
		
	  		PUT '<FONT SIZE="2" FACE=Arial COLOR="#003366"><EM><STRONG>&nbsp;&nbsp;&nbsp;Time Point: </EM></br></STRONG></FONT>';
	  		PUT '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<SELECT NAME="time" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';

			%DO i = 1 %TO &numtimes;  /* Select current time point */
				%LET temp=&&time&i;
		  		%IF &temp=&time %THEN %LET SELECT=selected; 
						%ELSE %LET SELECT= ; 
		      		LINE='<OPTION '||"&SELECT"||' VALUE="'||COMPRESS("&&time&i")||'">'||TRIM("&&timetitle&i")||'</OPTION>'; PUT LINE;
			%END;
  
	    		time="&time";  /* Include selection for all time points */
	  		IF time='ALL' THEN DO;
	  			LINE='<OPTION selected VALUE="ALL">All Time Points</OPTION>'; PUT LINE; 
			END;
	  		ELSE DO;
	   			LINE='<OPTION VALUE="ALL">All Time Points</OPTION>'; PUT LINE; 
			END;
	  		PUT '</SELECT></TD></TR></FORM>';
		RUN;
	%END;
  	
  	%IF %SUPERQ(reportype)=SUMSTATS %THEN %DO;
		DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; /* FORM 12: HTML TO CHANGE TABLE STATISTIC */
			PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
			LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

			%THISSESSION; 	

			LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="'||TRIM("&product")	       	||'">'; PUT LINE; 
	  		LINE= '<INPUT TYPE="hidden" NAME=storage    VALUE="'||TRIM("&storage")	       	||'">'; PUT LINE; 
	  		LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="'||TRIM(symget("testA"))    	||'">'; PUT LINE; 
	  		LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="'||TRIM("&stageA")	       	||'">'; PUT LINE; 
	  		LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="'||TRIM("&peakA")	       	||'">'; PUT LINE; 
	  		LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=DataType   VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE; 
	
			%STUDIES; 

	  		PUT '<STRONG><FONT  FACE="Arial" SIZE="2" COLOR="#003366"><EM>&nbsp;&nbsp;&nbsp;Table Statistic:</EM></br></STRONG>';		
	  		PUT '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<SELECT NAME="rptvalue" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';
			%IF %SUPERQ(rptvalue)=N %THEN 		%LET selreport=selected;
	  							%ELSE %LET selreport= ;
	  		LINE= '<OPTION '||"&SELREPORT"||' VALUE="N">Sample Size</OPTION>'; PUT LINE;
			%IF %SUPERQ(rptvalue)=MEAN 		%THEN %LET selreport=selected;
	  							%ELSE %LET selreport= ;
	  		LINE= '<OPTION '||"&SELREPORT"||' VALUE="MEAN">Mean</OPTION>'; PUT LINE;
	  		%IF %SUPERQ(rptvalue)=STD 		%THEN %LET selreport=selected;
	  							%ELSE %LET selreport= ;
	  		LINE= '<OPTION '||"&SELREPORT"||' VALUE="STD">Standard Deviation</OPTION>'; PUT LINE;
	  		%IF %SUPERQ(rptvalue)=RSD 		%THEN %LET selreport=selected;
	  							%ELSE %LET selreport= ;
	  		LINE= '<OPTION '||"&SELREPORT"||' VALUE="RSD">RSD</OPTION>'; PUT LINE;
	  		%IF %SUPERQ(rptvalue)=INDIVIDUAL 	%THEN %LET selreport=selected;
	  							%ELSE %LET selreport= ;
	  		LINE= '<OPTION '||"&SELREPORT"||' VALUE="INDIVIDUAL">Individual Results</OPTION>'; PUT LINE;
 	 		%IF %SUPERQ(rptvalue)=MIN 		%THEN %LET selreport=selected;
 	 							%ELSE %LET selreport= ;
 	 		LINE= '<OPTION '||"&SELREPORT"||' VALUE="MIN">Minimum</OPTION>'; PUT LINE;
 	 		%IF %SUPERQ(rptvalue)=MAX 		%THEN %LET selreport=selected;
 	 							%ELSE %LET selreport= ;
 	 		LINE= '<OPTION '||"&SELREPORT"||' VALUE="MAX">Maximum</OPTION>'; PUT LINE;
 	 		%IF %SUPERQ(rptvalue)=SLOPES 		%THEN %LET selreport=selected;
 	 							%ELSE %LET selreport= ;
 	 		LINE= '<OPTION '||"&SELREPORT"||' VALUE="SLOPES">Estimated Linear Slope</OPTION>'; PUT LINE;
 	 		PUT '</SELECT></TD></TR></FORM>';
		RUN;
	%END;	

 	%IF %SUPERQ(reportype)=CORR %THEN %DO;
		DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; /* FORM 13: HTML FOR 2ND TEST METHOD */
	  		PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
			LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

			%THISSESSION;	

			LINE= '<INPUT TYPE="hidden" NAME=lowaxis    VALUE="'||TRIM("&lowaxis")	   	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=upaxis     VALUE="'||TRIM("&upaxis") 	   	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=axisby     VALUE="'||TRIM("&axisby") 	   	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=xpixels0   VALUE="'||TRIM("&xpixels0")	   	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=ypixels0   VALUE="'||TRIM("&ypixels0")	   	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="'||TRIM("&product")	   	||'">'; PUT LINE; 
	  		LINE= '<INPUT TYPE="hidden" NAME=storage    VALUE="'||TRIM("&storage")	   	||'">'; PUT LINE; 
	  		LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="'||TRIM(symget("testA"))	||'">'; PUT LINE; 
	  		LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="'||TRIM("&stageA")	    	||'">'; PUT LINE; 
	  		LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="'||TRIM("&peakA")	    	||'">'; PUT LINE; 
	   		LINE= '<INPUT TYPE="hidden" NAME=time       VALUE="'||TRIM("&time")	       	||'">'; PUT LINE; 
	     		LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
	  		LINE= '<INPUT TYPE="hidden" NAME=CORRTYPE   VALUE="'||TRIM("&CORRTYPE")	    	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=VALUE	    VALUE="'||TRIM("&VALUE")		||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=DataType   VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE; 

	 		%STUDIES;

			PUT '<STRONG><FONT  FACE="Arial" SIZE="2" COLOR="#003366"><EM>&nbsp;&nbsp;&nbsp;2nd Correlation Variable: </EM></br>';		
	  		PUT '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<SELECT NAME="testB" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';
    
	    		%LOCAL i;
	    		%DO i = 1 %TO &numtest;    /* Select current test B method */
				%LET temp="&&test&i";
	      			%LET temp2="&testBchk";
      				%IF &temp=&temp2 %THEN %LET selTEST=selected;
      				                 %ELSE %LET selTEST= ;
				line= '<OPTION '||"&selTEST"||' VALUE="'||"&&test&i"||'">'||'<FONT FACE=arial SIZE="1">'||"&&test&i"||'</FONT></OPTION>'; PUT line;
			%END;

			/* Include options for testdate and temperature and RH */
		  	%IF %SUPERQ(TESTB)=TESTDATE2 %THEN %LET SELTEST=selected;
	  					     %ELSE %LET SELTEST= ;
	 		LINE='<OPTION '||"&selTEST"||' VALUE="TESTDATE2">Test Date</OPTION>'; PUT LINE;
  
			%IF %SUPERQ(CIFLAG)=YES %THEN %DO;
	  			%IF %SUPERQ(TESTB)=TEMPERATURE 	%THEN %LET SELTEST=selected;
	  						       	%ELSE %LET SELTEST= ;
	  	 		LINE='<OPTION '||"&selTEST"||' VALUE="TEMPERATURE">CI Temperature</OPTION>'; PUT LINE;
	
	  			%IF %SUPERQ(TESTB)=RH 		%THEN %LET SELTEST=selected;
	  					       		%ELSE %LET SELTEST= ;
				LINE='<OPTION '||"&selTEST"||' VALUE="RH">CI Relative Humidity</OPTION>'; PUT LINE;
	
				%IF %SUPERQ(TESTB)=CINUM 	%THEN %LET SELTEST=selected;
	  							%ELSE %LET SELTEST= ;
				LINE='<OPTION '||"&selTEST"||' VALUE="CINUM">CI Stack Number</OPTION>'; PUT LINE;
			%END;

			PUT '&nbsp;&nbsp;&nbsp;</SELECT></TD></TR></FONT></FORM>';
		RUN;

	  	%IF %SUPERQ(RHTEMPFLG)= and %SUPERQ(TESTB)^=TESTDATE2 %THEN %DO;
			DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; /* FORM 14: HTML TO CHANGE STAGE B IF STAGE EXISTS */
		  	  	numstages="&numStageB";  PEAKB=UPCASE(COMPRESS("&PEAKB"));
		  		IF numstages > 1 AND (peakB^='TOTALNUMBEROFPARTICLES') THEN DO;
		  			PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD" >';
					LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;
	
					%THISSESSION;
	
					LINE= '<INPUT TYPE="hidden" NAME=lowaxis    VALUE="'||TRIM("&lowaxis")	   	||'">'; PUT LINE;
		  			LINE= '<INPUT TYPE="hidden" NAME=upaxis     VALUE="'||TRIM("&upaxis") 	   	||'">'; PUT LINE;
		  			LINE= '<INPUT TYPE="hidden" NAME=axisby     VALUE="'||TRIM("&axisby") 	   	||'">'; PUT LINE;
		  			LINE= '<INPUT TYPE="hidden" NAME=xpixels0   VALUE="'||TRIM("&xpixels0")	   	||'">'; PUT LINE;	
  					LINE= '<INPUT TYPE="hidden" NAME=ypixels0   VALUE="'||TRIM("&ypixels0")	   	||'">'; PUT LINE;
	  				LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="'||TRIM("&product")	    	||'">'; PUT LINE; 
  					LINE= '<INPUT TYPE="hidden" NAME=storage    VALUE="'||TRIM("&storage")	    	||'">'; PUT LINE; 
  					LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="'||TRIM(symget("testA")) 	||'">'; PUT LINE; 
  					LINE= '<INPUT TYPE="hidden" NAME=testB      VALUE="'||TRIM(symget("testB")) 	||'">'; PUT LINE;
  					LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="'||TRIM("&stageA")	    	||'">'; PUT LINE; 
  					LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="'||TRIM("&peakA")	    	||'">'; PUT LINE; 
   					LINE= '<INPUT TYPE="hidden" NAME=PeakB      VALUE="'||TRIM("&PeakB")	    	||'">'; PUT LINE; 
   					LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
   					LINE= '<INPUT TYPE="hidden" NAME=time       VALUE="'||TRIM("&time")	        ||'">'; PUT LINE; 
  					LINE= '<INPUT TYPE="hidden" NAME=GROUPVAR   VALUE="'||TRIM("&GROUPVAR")	    	||'">'; PUT LINE; 
  					LINE= '<INPUT TYPE="hidden" NAME=CORRTYPE   VALUE="'||TRIM("&CORRTYPE")	    	||'">'; PUT LINE; 
					LINE= '<INPUT TYPE="hidden" NAME=VALUE	    VALUE="'||TRIM("&VALUE")		||'">'; PUT LINE; 
					LINE= '<INPUT TYPE="hidden" NAME=DataType   VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE; 		

					%STUDIES;

		  			test=symget('testb');  /* Setup drop down box label */
		  			IF COMPRESS(TEST) ^= 'HPLCAdvairMDPlCas.Impaction' THEN 
		  			PUT '<STRONG><FONT  FACE="Arial" SIZE="2" COLOR="#003366">&nbsp;&nbsp;&nbsp;<EM>2nd Variable Test Parameter:</EM></FONT></STRONG></br>';	
		  			ELSE PUT '<STRONG><FONT  FACE="Arial" SIZE="2" COLOR="#003366">&nbsp;&nbsp;&nbsp;<EM>2nd Variable CI Stage:</EM></FONT></STRONG></br>';	
		  			PUT '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<SELECT NAME="StageB" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';
  
			  	    	%LOCAL i;
    					%DO i = 1 %TO &numStageB;    /* Select current Stage B */
					    	%LET temp="&&StageB&i";
      						%LET temp2="&stagebchk";
      						%IF &temp=&temp2 %THEN %LET selstage=selected;
      								 %ELSE %LET selstage= ;
				    		line= '<OPTION '||"&selstage"||' VALUE="'||"&&StageB&i"||'">'||"Stage: &&StageB&i"||'</OPTION>'; PUT line;
		    			%END;

					PUT '</SELECT></TD></TR></FORM>';
	  			END;
			RUN;

			DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; /* FORM 15: HTML FOR 2ND PEAK */
				testb=trim("&Testb");
	  			numpeak="&numPeakB";
		  		IF numpeak > 1 and testb not IN ('HPLC Related Imp. in Advair MDPI') THEN DO;
		  			PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
					LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

				%THISSESSION;	

				LINE= '<INPUT TYPE="hidden" NAME=lowaxis    VALUE="'||TRIM("&lowaxis")	   	||'">'; PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME=upaxis     VALUE="'||TRIM("&upaxis") 	   	||'">'; PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME=axisby     VALUE="'||TRIM("&axisby") 	   	||'">'; PUT LINE;
  				LINE= '<INPUT TYPE="hidden" NAME=xpixels0   VALUE="'||TRIM("&xpixels0")	   	||'">'; PUT LINE;
  				LINE= '<INPUT TYPE="hidden" NAME=ypixels0   VALUE="'||TRIM("&ypixels0")	   	||'">'; PUT LINE;
  				LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="'||TRIM("&product")	    	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=storage    VALUE="'||TRIM("&storage")	    	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="'||TRIM(symget("testA")) 	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=testB      VALUE="'||TRIM(symget("testB")) 	||'">'; PUT LINE;
  				LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="'||TRIM("&stageA")	    	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="'||TRIM("&peakA")	    	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=StageB     VALUE="'||TRIM("&StageB")	    	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=class      VALUE="'||TRIM("&class")	    	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=time       VALUE="'||TRIM("&time")	        ||'">'; PUT LINE; 
	 			LINE= '<INPUT TYPE="hidden" NAME=GROUPVAR   VALUE="'||TRIM("&GROUPVAR")	    	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=CORRTYPE   VALUE="'||TRIM("&CORRTYPE")	    	||'">'; PUT LINE; 
 				LINE= '<INPUT TYPE="hidden" NAME=VALUE	    VALUE="'||TRIM("&VALUE")		||'">'; PUT LINE; 
				LINE= '<INPUT TYPE="hidden" NAME=DataType   VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE; 	

				%STUDIES;

	  			PUT '<STRONG><FONT  FACE="Arial" SIZE="2" COLOR="#003366"><EM>';
				IF TESTB IN ('Foreign Particulate Matter') THEN
					PUT '&nbsp;&nbsp;&nbsp;2nd Variable Particle Size:'; 	
				ELSE
  					PUT '&nbsp;&nbsp;&nbsp;2nd Variable Drug Substance:';	
  				PUT '</EM></br></FONT></STRONG>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<SELECT NAME="PeakB" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';

				%LOCAL i;
		    		%DO i = 1 %TO &numPeakB;   
		 			%LET temp="&&PeakB&i";
		      			%LET temp2="&PeakBCHK";
		      			%IF &temp=&temp2 %THEN %LET selpeak=selected;
		      			%ELSE %LET selpeak= ;
					line= '<OPTION '||"&selpeak"||' VALUE="'||"&&PeakB&i"||'">'||"&&PeakB&i"||'</OPTION>'; PUT line;
		    		%END;	  
  
  				PUT '</SELECT></TD></TR></FORM>';
  			END;
  		%END;
		RUN;

		DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; /* FORM 16: HTML TO CHANGE TIME POINT */
			PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
			LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

			%THISSESSION;

			LINE= '<INPUT TYPE="hidden" NAME=lowaxis    VALUE="'||TRIM("&lowaxis")	   	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=upaxis     VALUE="'||TRIM("&upaxis") 	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=axisby     VALUE="'||TRIM("&axisby") 	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=hlowaxis   VALUE="'||TRIM("&hlowaxis")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=hupaxis    VALUE="'||TRIM("&hupaxis")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=haxisby    VALUE="'||TRIM("&haxisby")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=xpixels0   VALUE="'||TRIM("&xpixels0")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=ypixels0   VALUE="'||TRIM("&ypixels0")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=storage    VALUE="'||TRIM("&storage")	    	||'">'; PUT LINE; 

  			LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="'||TRIM(symget("testA")) 	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="'||TRIM("&stageA")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="'||TRIM("&peakA")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testB      VALUE="'||TRIM("&testB")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=StageB     VALUE="'||TRIM("&StageB")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=PeakB      VALUE="'||TRIM("&PeakB")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=RptValue   VALUE="'||TRIM("&rptvalue")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=Value      VALUE="'||TRIM("&Value")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=Class      VALUE="'||TRIM("&Class")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=Analyst    VALUE="'||TRIM("&Analyst")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=GROUPVAR   VALUE="'||TRIM("&GROUPVAR")	    	||'">'; PUT LINE; 
   			LINE= '<INPUT TYPE="hidden" NAME=CORRTYPE   VALUE="'||TRIM("&CORRTYPE")	    	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=DataType   VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="'||TRIM("&product")	    	||'">'; PUT LINE; 

			%STUDIES;

	  		PUT '<FONT SIZE=2 FACE=arial COLOR="#003366"><EM><STRONG>&nbsp;&nbsp;&nbsp;Time Point: </EM></br></STRONG></FONT>';
  			PUT '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<SELECT NAME="time" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';

	  		%LOCAL i;
  			%DO i = 1 %TO &numtimes;  /* Select current time */
				%LET temp=&&time&i;
	  			%IF &temp=&time %THEN %LET SELECT=selected; %ELSE %LET SELECT= ; 
      				LINE='<OPTION '||"&SELECT"||' VALUE="'||COMPRESS("&&time&i")||'">'||TRIM("&&timetitle&i")||'</OPTION>'; 
				PUT LINE;
			%END;
   
  			time="&time";
  			IF time='ALL' THEN DO;
  				LINE='<OPTION selected VALUE="ALL">All Time Points</OPTION>'; PUT LINE; 
			END;
  			ELSE DO;
   				LINE='<OPTION VALUE="ALL">All Time Points</OPTION>'; PUT LINE; 
			END;
  			PUT '</SELECT></TD></TR></FORM>';
		RUN;

		DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; /* FORM 17: HTML TO CHANGE RESULT TYPE */
   			testa="&testa"; testb="&testb"; rhtempflg="&rhtempflg";
 			IF testa=testb or rhtempflg='YES' THEN DO;
 		 		PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
				LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

				%THISSESSION;

				LINE= '<INPUT TYPE="hidden" NAME=lowaxis    VALUE="'||TRIM("&lowaxis")	   	||'">'; PUT LINE;
		  		LINE= '<INPUT TYPE="hidden" NAME=upaxis     VALUE="'||TRIM("&upaxis") 	   	||'">'; PUT LINE;
		  		LINE= '<INPUT TYPE="hidden" NAME=axisby     VALUE="'||TRIM("&axisby") 	   	||'">'; PUT LINE;
		  		LINE= '<INPUT TYPE="hidden" NAME=hlowaxis   VALUE="'||TRIM("&hlowaxis")	   	||'">'; PUT LINE;	
		  		LINE= '<INPUT TYPE="hidden" NAME=hupaxis    VALUE="'||TRIM("&hupaxis")	   	||'">'; PUT LINE;
		  		LINE= '<INPUT TYPE="hidden" NAME=haxisby    VALUE="'||TRIM("&haxisby")	   	||'">'; PUT LINE;
		  		LINE= '<INPUT TYPE="hidden" NAME=xpixels0   VALUE="'||TRIM("&xpixels0")	   	||'">'; PUT LINE;
		  		LINE= '<INPUT TYPE="hidden" NAME=ypixels0   VALUE="'||TRIM("&ypixels0")	   	||'">'; PUT LINE;
		  		LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="'||TRIM("&product")	    	||'">'; PUT LINE; 
		  		LINE= '<INPUT TYPE="hidden" NAME=storage    VALUE="'||TRIM("&storage")	    	||'">'; PUT LINE; 
		  		LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="'||TRIM(symget("testA"))	||'">'; PUT LINE; 
		  		LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="'||TRIM("&stageA")	    	||'">'; PUT LINE; 
		  		LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="'||TRIM("&peakA")	    	||'">'; PUT LINE; 
		  		LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=Class      VALUE="'||TRIM("&Class")	    	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=Analyst    VALUE="'||TRIM("&Analyst")	    	||'">'; PUT LINE; 
		  		LINE= '<INPUT TYPE="hidden" NAME=RptValue   VALUE="'||TRIM("&rptvalue")	    	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=testB      VALUE="'||TRIM("&testB")	    	||'">'; PUT LINE; 
 				LINE= '<INPUT TYPE="hidden" NAME=StageB     VALUE="'||TRIM("&StageB")	    	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=PeakB      VALUE="'||TRIM("&PeakB")	    	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=time       VALUE="'||TRIM("&time")	        ||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=CORRTYPE   VALUE="'||TRIM("&CORRTYPE")	    	||'">'; PUT LINE; 
 				LINE= '<INPUT TYPE="hidden" NAME=groupvar   VALUE="'||TRIM("&groupvar")	    	||'">'; PUT LINE; 
				LINE= '<INPUT TYPE="hidden" NAME=DataType   VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE; 

				%STUDIES;

		  		PUT '<FONT SIZE=2 FACE=arial COLOR="#003366"><EM><STRONG>&nbsp;&nbsp;&nbsp;Result Type: </EM></br></STRONG></FONT>';
		  		PUT '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<SELECT NAME="VALUE" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';

				%IF %SUPERQ(VALUE)=MEAN %THEN %LET SELECTtype=selected;
				%ELSE %LET SELECTtype= ;
		  		LINE='<OPTION '||"&selecttype"||' VALUE="MEAN">Time Point Means</OPTION>'; PUT LINE;
  
				%IF %SUPERQ(VALUE)=INDIVIDUAL %THEN %LET SELECTtype=selected;
		  		%ELSE %LET SELECTtype= ;
		  		LINE='<OPTION '||"&selecttype"||' VALUE="INDIVIDUAL">Time Point Individuals</OPTION>'; PUT LINE;

				PUT '</SELECT></TD></TR></FORM>';
	 		END;
		RUN;

		DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; /* FORM 18: HTML TO CHANGE GROUP VARIABLE */
	  		testa="&testa"; testb="&testb";  		
	 		PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
			LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

			%THISSESSION;		

			LINE= '<INPUT TYPE="hidden" NAME=lowaxis    VALUE="'||TRIM("&lowaxis")	   	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=upaxis     VALUE="'||TRIM("&upaxis") 	   	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=axisby     VALUE="'||TRIM("&axisby") 	   	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=hlowaxis   VALUE="'||TRIM("&hlowaxis")	   	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=hupaxis    VALUE="'||TRIM("&hupaxis")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=haxisby    VALUE="'||TRIM("&haxisby")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=xpixels0   VALUE="'||TRIM("&xpixels0")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=ypixels0   VALUE="'||TRIM("&ypixels0")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="'||TRIM("&product")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=storage    VALUE="'||TRIM("&storage")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="'||TRIM(symget("testA")) 	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="'||TRIM("&stageA")	    	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="'||TRIM("&peakA")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testB      VALUE="'||TRIM("&testB")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=StageB     VALUE="'||TRIM("&StageB")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=PeakB      VALUE="'||TRIM("&PeakB")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=RptValue   VALUE="'||TRIM("&rptvalue")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=Value      VALUE="'||TRIM("&Value")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=Class      VALUE="'||TRIM("&Class")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=Analyst    VALUE="'||TRIM("&Analyst")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=time       VALUE="'||TRIM("&time")	       	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=CORRTYPE   VALUE="'||TRIM("&CORRTYPE")	    	||'">'; PUT LINE; 
 			LINE= '<INPUT TYPE="hidden" NAME=ResultTYPE VALUE="'||TRIM("&ResultTYPE")	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=DataType   VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE; 

			%studies;

	  		PUT '<FONT SIZE=2 FACE=arial COLOR="#003366"><EM><STRONG>&nbsp;&nbsp;&nbsp;Group Variable: </EM></br></STRONG></FONT>';
	  		PUT '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<SELECT NAME="groupvar" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';

			%IF %SUPERQ(GROUPVAR)=NONE %THEN %LET SELECTGRP=selected;
	  		%ELSE %LET SELECTGRP= ;
	  			LINE='<OPTION '||"&selectGRP"||' VALUE="NONE">None</OPTION>'; PUT LINE;

	  		%IF %SUPERQ(GROUPVAR)=STUDY %THEN %LET SELECTGRP=selected;
	  		%ELSE %LET SELECTGRP= ;
			LINE='<OPTION '||"&selectGRP"||' VALUE="STUDY">Study</OPTION>'; PUT LINE;
	
	  		CIFLAG="&CIFLAG";
	  		resulttype="&VALUE";
			%IF %SUPERQ(SAVE_USERROLE)=LevelA %THEN %DO;
		  		IF  (CIFLAG ^= 'YES') AND (testa=testb) THEN DO;
		  			%IF %SUPERQ(GROUPVAR)=ANALYST %THEN %LET SELECTGRP=selected;
		  			%ELSE %LET SELECTGRP= ;
  
		  			LINE='<OPTION '||"&selectGRP"||' VALUE="ANALYST">Analyst </OPTION>'; PUT LINE;
		  		END;
			%END;

			PUT '</SELECT></TD></TR></FORM>';
  
  		RUN;

		  DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; /* FORM 19: HTML TO CHANGE TYPE OF CORR ANALYSIS */
			PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
			LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

			%THISSESSION; 	

			LINE= '<INPUT TYPE="hidden" NAME=lowaxis    VALUE="'||TRIM("&lowaxis")	   	||'">'; PUT LINE;
		  	LINE= '<INPUT TYPE="hidden" NAME=upaxis     VALUE="'||TRIM("&upaxis") 	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=axisby     VALUE="'||TRIM("&axisby") 	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=hlowaxis   VALUE="'||TRIM("&hlowaxis")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=hupaxis    VALUE="'||TRIM("&hupaxis")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=haxisby    VALUE="'||TRIM("&haxisby")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=xpixels0   VALUE="'||TRIM("&xpixels0")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=ypixels0   VALUE="'||TRIM("&ypixels0")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=storage    VALUE="'||TRIM("&storage")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="'||TRIM(symget("testA")) 	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="'||TRIM("&stageA")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="'||TRIM("&peakA")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testB      VALUE="'||TRIM("&testB")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=StageB     VALUE="'||TRIM("&StageB")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=PeakB      VALUE="'||TRIM("&PeakB")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=RptValue   VALUE="'||TRIM("&rptvalue")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=Value      VALUE="'||TRIM("&Value")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=Class      VALUE="'||TRIM("&Class")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=Analyst    VALUE="'||TRIM("&Analyst")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=time       VALUE="'||TRIM("&time")	       	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=groupvar   VALUE="'||TRIM("&groupvar")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=ResultTYPE VALUE="'||TRIM("&ResultTYPE")	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=DataType   VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="'||TRIM("&product")	    	||'">'; PUT LINE; 

   	 		%studies;

		  	PUT '<FONT SIZE=2 FACE=arial COLOR="#003366"><EM><STRONG>&nbsp;&nbsp;&nbsp;Analysis Type: </EM></br></STRONG></FONT>';
		  	PUT '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<SELECT NAME="corrtype" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';

			%IF %SUPERQ(corrtype)=PLOT %THEN %LET SELCORR=selected;
		  	%ELSE %LET SELCORR= ;
	  		LINE='<OPTION '||"&selCORR"||' VALUE="PLOT">Scatter Plot</OPTION>'; PUT LINE;
  
		  	%IF %SUPERQ(corrtype)=TABLE %THEN %LET SELCORR=selected;
		  	%ELSE %LET SELCORR= ;
		    	Line='<OPTION '||"&selCORR"||' VALUE="TABLE">Summary Statistics</OPTION>'; PUT LINE;
	
			PUT '</SELECT></TD></TR></FORM>';
	%END;
	  	RUN;

  	%IF %SUPERQ(reportype)=CIPROFILES %THEN %DO;
  		DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; /* FORM 20: HTML TO CHANGE TIME POINT */
  			PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD" >';
			LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

			%THISSESSION; 	

			LINE= '<INPUT TYPE="hidden" NAME=lowaxis   	VALUE="'||TRIM("&lowaxis")	||'">'; PUT LINE;
		  	LINE= '<INPUT TYPE="hidden" NAME=upaxis    	VALUE="'||TRIM("&upaxis") 	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=axisby    	VALUE="'||TRIM("&axisby")	||'">'; PUT LINE;
			LINE= '<INPUT TYPE="hidden" NAME=USERlowaxis   	VALUE="'||TRIM("&USERlowaxis")	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=USERupaxis    	VALUE="'||TRIM("&USERupaxis") 	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=USERaxisby    	VALUE="'||TRIM("&USERaxisby") 	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=xpixels0    	VALUE="'||TRIM("&xpixels0")	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=ypixels0    	VALUE="'||TRIM("&ypixels0")	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=product     	VALUE="'||TRIM("&product")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=storage     	VALUE="'||TRIM("&storage")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testA       	VALUE="'||TRIM(symget("testA")) ||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=stageA      	VALUE="'||TRIM("&stageA")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=peakA       	VALUE="'||TRIM("&peakA")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=reportype   	VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=class       	VALUE="'||TRIM("&class")	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=DataType       VALUE="'||TRIM("&DataType")	||'">'; PUT LINE; 

		 	%STUDIES;

		  	PUT '<FONT SIZE="2" FACE=Arial COLOR="#003366"><EM><STRONG>&nbsp;&nbsp;&nbsp;Time Point: </EM></br></STRONG></FONT>';
		 	PUT '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<SELECT NAME="time" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';

		    	%LOCAL i;
  			%DO i = 1 %TO &numtimes; /* Select current time point */	
			    	%LET temp=&&time&i;
				%IF &temp=&time %THEN %LET SELECT=selected; %ELSE %LET SELECT= ; 
			    	LINE='<OPTION '||"&SELECT"||' VALUE="'||COMPRESS("&&time&i")||'">'||TRIM("&&timetitle&i")||'</OPTION>'; PUT LINE;
		    	%END;

			time="&time"; /* Include selection for all time points */
		  	IF time='ALL' THEN DO;
		  		LINE='<OPTION selected VALUE="ALL">All Time Points</OPTION>'; PUT LINE; 
			END;
		  	ELSE DO;
   				LINE='<OPTION VALUE="ALL">All Time Points</OPTION>'; PUT LINE; 
			END;
		  	PUT '</SELECT></TD></TR></FORM>';
		  RUN;
	  %END;

	  /* FORM 21: HTML to create study checkboxes with links to study description table */
	  %IF %SUPERQ(REPORTYPE)^=PRODRELEASE %THEN %DO;
		  DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; 
  			PUT   '<TR><TD ><HR></tD></tR>'; 
  			PUT '<TR><TD BGCOLOR="#FFFFDD">';
			LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

			%THISSESSION;  	

			LINE= '<INPUT TYPE="hidden" NAME=lowaxis    VALUE="'||TRIM("&lowaxis")	   	||'">'; PUT LINE;
		  	LINE= '<INPUT TYPE="hidden" NAME=upaxis     VALUE="'||TRIM("&upaxis") 	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=axisby     VALUE="'||TRIM("&axisby") 	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=hlowaxis   VALUE="'||TRIM("&hlowaxis")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=hupaxis    VALUE="'||TRIM("&hupaxis")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=haxisby    VALUE="'||TRIM("&haxisby")	   	||'">'; PUT LINE;
			LINE= '<INPUT TYPE="hidden" NAME=lowaxis    VALUE="'||TRIM("&USERlowaxis") 	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=upaxis     VALUE="'||TRIM("&USERupaxis")  	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=axisby     VALUE="'||TRIM("&USERaxisby") 	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=hlowaxis   VALUE="'||TRIM("&USERhlowaxis")	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=hupaxis    VALUE="'||TRIM("&USERhupaxis")	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=haxisby    VALUE="'||TRIM("&USERhaxisby")	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=xpixels0   VALUE="'||TRIM("&xpixels0")	  	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=ypixels0   VALUE="'||TRIM("&ypixels0")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=REG0       VALUE="'||TRIM("&REG0")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=REG2       VALUE="'||TRIM("&REG2")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=storage    VALUE="'||TRIM("&storage")	    	||'">'; PUT LINE; 

  			LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="'||TRIM(symget("testA"))	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="'||TRIM("&stageA")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="'||TRIM("&peakA")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testB      VALUE="'||TRIM("&testB")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=PeakB      VALUE="'||TRIM("&PeakB")	    	||'">'; PUT LINE; 
 			LINE= '<INPUT TYPE="hidden" NAME=StageB     VALUE="'||TRIM("&StageB")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=rptvalue   VALUE="'||TRIM("&rptvalue")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=time       VALUE="'||TRIM("&time")	       	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=VALUE      VALUE="'||TRIM("&VALUE")   		||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=class      VALUE="'||TRIM("&class")   		||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=analyst    VALUE="'||TRIM("&analyst")     	||'">'; PUT LINE; 
   			LINE= '<INPUT TYPE="hidden" NAME=groupvar   VALUE="'||TRIM("&groupvar")    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=corrtype   VALUE="'||TRIM("&corrtype")    	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=DataType   VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="'||TRIM("&product")	    	||'">'; PUT LINE; 
		   	LINE= '<STRONG><FONT SIZE="2" FACE="Arial" COLOR="#003366">Add/Remove Studies: </FONT></STRONG>'; PUT LINE;
		RUN;

		%LOCAL i; /* Create anchor tag for each study to display study description table. Include statistic if applicable. */  
		%DO i = 1 %TO &NUMALLSTUDY;  
			DATA _NULL_; LENGTH LINE LINE2 $1000; FILE _WEBOUT;
  				line2= 	'<br><SMALL>&nbsp;&nbsp;&nbsp;<INPUT TYPE=checkbox NAME=study VALUE="'||
					TRIM("&&allstudy&i") || '" ' || "&&check&i" || '><a HREF="' || "%superq(_THISSESSION)" ||
      					'&_program=' || "links.LRSTANALYSIS.sas" || '&study=' || TRIM("&&allstudy&i") ||	
	  				'&REPORTYPE2=STUDYDESC"><FONT FACE=ARIAL>' || "&&allstudy&i" || '</FONT></a><FONT FACE=ARIAL> ' ||
					"&&STAT&i"||'</FONT></SMALL>'; PUT line2 ;
  		%END;
  		LINE='</BR><FONT FACE="ARIAL">'||"&STATdesc"||'</FONT>'; PUT LINE;
  		warning="&warning2";
  		IF warning='*' THEN DO; /* Print warning if applicable */
  			PUT "<SMALL><FONT SIZE=2 FACE=Arial COLOR=red>(Calculated between &hlowaxis and &hupaxis month time points only)</FONT></SMALL>";
	    	END;

	  	PUT '</br><INPUT TYPE="submit" NAME="submit" VALUE="Add/Remove Studies"></br></TD></TR></FORM>';
		RUN;
	%END;

  	DATA _NULL_; FILE _WEBOUT;
  		PUT   '<TR><TD ><HR></tD></tR></TABLE>'; 
  		PUT '</TD><TD VALIGN=top BGCOLOR="#E0E0E0">';
  		PUT '</FONT>';
  	RUN;
  

%MEND WEBOUT;

****************************************************************************************************;
*                                      MODULE HEADER                                               *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;
*	REQUIREMENT     : See LINKS Report SOP                                                     *;
*       INPUT           : Macro variables: VALUE , Datasets: STABILITY3, MAXTIME, XPIXELS          *;
*			  YPIXELS.  DATASET: STABILITY3.                                           *;
*       PROCESSING      : Calculate summary statistics by time point.                              *;
*			  Generate scatter plot over time with or without linear, quadratic or     *;
*			  cubic regression line, with or without confidence and prediction bounds. *;
*			  Include specification in a footnote if applicable to the data.  Print a  *;
*			  warning footnote if data exists outside user defined axis range.         *;           
*       OUTPUT          : 1 scatterplot to web browser or RTF file.                                *; 
****************************************************************************************************;
   
%MACRO SCATTERPLOT;
	%WARNINGS;

	/* Setup macro variables depending on value of VALUE variable */
	DATA _NULL_;  
 		VALUE=upcase("&VALUE");
  		IF VALUE ='INDIVIDUAL' THEN DO;	CALL SYMPUT('PLOTVAR','result'); CALL SYMPUT('VALUE2','Individual Results');	END;
  		IF VALUE ='MEAN'       THEN DO; CALL SYMPUT('PLOTVAR','Mean');   CALL SYMPUT('VALUE2','Mean');			END;
  		IF VALUE ='STD'        THEN DO; CALL SYMPUT('PLOTVAR','Std');	 CALL SYMPUT('VALUE2','Std Dev');  		END;
  		IF VALUE ='RSD'        THEN DO; CALL SYMPUT('PLOTVAR','RSD');	 CALL SYMPUT('VALUE2','RSD'); 			END;
  		IF VALUE ='MIN'        THEN DO; CALL SYMPUT('PLOTVAR','MIN');	 CALL SYMPUT('VALUE2','Minimum'); 		END;
    		IF VALUE ='MAX'        THEN DO; CALL SYMPUT('PLOTVAR','MAX');    CALL SYMPUT('VALUE2','Maximum');		END;
	RUN;
	
	PROC SORT DATA=STABILITY3; BY product study test stage peak time; RUN;

	/* Calculate summary statistics for each time point */
	PROC SUMMARY DATA=STABILITY3;
	  	VAR result;
	   	BY product test stage peak study time;
		ID ANALYST;
	  	OUTPUT OUT=SCATTERSUM mean=mean std=std cv=rsd min=min max=max;
	RUN;

	PROC SORT DATA=SCATTERSUM; BY product test stage peak study time; RUN;
	PROC SORT DATA=STABILITY3; BY product test stage peak study time; RUN;

	/* Merge summary statistics back with individual results */
	DATA SCATTERSUM2; MERGE STABILITY3 SCATTERSUM; 
	BY product test stage peak study time;  
		IF std=. THEN std=0;  /* ADDED V2 */
		IF rsd=. THEN RSD=0;
	RUN;

	%GLOBAL regtitle reg reg0 reg2 MAXTIMECHK;  /* Setup plot regression lines/curves and confidence bounds. */
	
	DATA _NULL_; SET MAXTIME;/** Remove regression lines/curves and title if plot not on means or individuals ***/
  		VALUE=upcase("&VALUE");    /** If maximum time point is initial then remove regression line/confidence bounds **/
		IF maxtime=0 THEN CALL SYMPUT('MAXTIMECHK','0');
    		IF VALUE NOT IN ('MEAN','INDIVIDUAL') OR maxtime=0 THEN DO;
    			CALL SYMPUT('reg0','NONE');
    			CALL SYMPUT('reg2','NONE');
  		END;
	RUN;

	DATA _NULL_; LENGTH reg0 reg2 $5 regtitle regtitle2 $50;  /**  Setup regression line and no confidence bounds **/ 
  		reg0=upcase("&reg0");								  /**  as default. Setup regression titles **/
  		reg2=upcase("&reg2");
  		IF reg0='' 		THEN reg0='RL';	
  		IF reg0='RL' 	THEN regtitle=	'with Overlaid Linear Regression Line';
		IF reg0='RQ' 	THEN regtitle=	'with Overlaid Quadratic Regression Curve';
  		IF reg0='RC' 	THEN regtitle=	'with Overlaid Cubic Regression Curve';
  		IF reg0='NONE' 	THEN regtitle=	' ';
      
  		IF reg2='NONE' 	THEN regtitle2=	'';
  		IF reg2='CLM95' THEN regtitle2=	' + 95% Mean Confidence Bounds';
  		IF reg2='CLM99' THEN regtitle2=	' + 99% Mean Confidence Bounds';
  		IF reg2='CLI95' THEN regtitle2= ' + 95% Indiv. Confidence Bounds';
  		IF reg2='CLI99' THEN regtitle2=	' + 99% Indiv. Confidence Bounds';
  		IF reg2='' 		THEN regtitle2=	'';
    
  		CALL SYMPUT('regtitle',TRIM(regtitle)||left(TRIM(regtitle2)));
   		IF REG0='NONE' THEN CALL SYMPUT('reg', 'NONE');   /** Setup regression interpolate value for symbol statement **/
		ELSE IF REG0^='NONE' AND REG2='NONE' THEN CALL SYMPUT('reg', TRIM(reg0));
		ELSE CALL SYMPUT('reg', TRIM(reg0)||left(reg2));
	RUN;

	GOPTIONS reset=all;  /**  Setup goptions **/
	GOPTIONS device=&device display;
	GOPTIONS &xpixels &ypixels  gsfmode=replace  BORDER ;

	DATA _NULL_; 		/** IF there is only one study, set first plot symbol to star, otherwise set to 'A' **/
	    	numstudychk="&STUDY0";
	    	IF numstudychk='1' THEN CALL SYMPUT('symbol1','star');
	    	ELSE CALL SYMPUT('symbol1','A');
	RUN;

	symbol1  i=&reg c=black   v="&symbol1";		/** Setup remaining symbol statements **/
  	symbol2  i=&reg c=red     v="B";
  	symbol3  i=&reg c=blue    v="C";
  	symbol4  i=&reg c=green   v="D";
  	symbol5  i=&reg c=orange  v="E";
  	symbol6  i=&reg c=brown   v="F";
  	symbol7  i=&reg c=cyan    v="G";
  	symbol8  i=&reg c=magenta v="H";
  	symbol9  i=&reg c=yellow  v="I";
  	symbol10 i=&reg c=gray    v="J";
  	symbol11 i=&reg c=navy    v="K";
  	symbol12 i=&reg c=purple  v="L";
  	symbol13 i=&reg c=red     v="M";
  	symbol14 i=&reg c=blue    v="N";
  	symbol15 i=&reg c=green   v="O";
  	symbol16 i=&reg c=orange  v="P";
  	symbol17 i=&reg c=brown   v="Q";
  	symbol18 i=&reg c=cyan    v="R";
  	symbol19 i=&reg c=magenta v="S";
  	symbol20 i=&reg c=yellow  v="T";
  	symbol21 i=&reg c=gray    v="U";
  	symbol22 i=&reg c=navy    v="V";
  	symbol23 i=&reg c=purple  v="W";
  	symbol23 i=&reg c=red     v="X";
  	symbol25 i=&reg c=black   v="Y";
  	symbol26 i=&reg c=blue    v="Z";

	/**  Setup titles, legend and axis **/
	TITLE  h=1 F=SWISSB "&TITLE_product &TITLE_test &TITLE_PEAKA - &TITLE_storage Storage Condition"; 
 	TITLE2 h=1 F=SWISSB "Scatterplot &regtitle";

	LEGEND1 LABEL=(HEIGHT=1 'Study');
  	AXIS1 OFFSET=(5,5) LABEL=(FONT=SIMPLEX "Time Point (Months)") &HAXIS;
  	AXIS2 LABEL=(a=90 FONT=SIMPLEX "&VALUE2") &VAXIS;

  	DATA _NULL_; FILE _WEBOUT;	/**  Print warning footnote if data exists outside axis range **/
	    	&warning;
  	RUN;
	/* Setup remaining footnotes */
	%IF %SUPERQ(SPECCHK2)=YES %THEN %DO;
		%DO I = 1 %TO &NUMSPECS;
			%LET K=%EVAL(&I+1);
			&&FOOTNOTE&I;
		%END;
		%LET J = %EVAL(&NUMSPECS+2);
		FOOTNOTE&J H=.2 ' ';
		%LET J = %EVAL(&NUMSPECS+3);
  		FOOTNOTE&J F=ARIAL j=l h=.95 "Generated by the LINKS System on &today at &rpttime" j=r "Data last updated: &Save_Last_Update_Date at &Save_Last_Update_Time";
		%LET J = %EVAL(&NUMSPECS+4);
		FOOTNOTE&J H=.2 ' ';
		%IF %SUPERQ(UNAPPFLAG)=YES %THEN %DO;
			%LET J = %EVAL(&NUMSPECS+5);
			FOOTNOTE&J C=RED F=ARIAL J=C H=.95 'Report contains approved and unapproved data. '; 
			%LET J = %EVAL(&NUMSPECS+6);
			FOOTNOTE&J H=.2 ' ';
		%END;
	%END;
	%ELSE %DO;
		FOOTNOTE2 H=.3 ' ';
  		FOOTNOTE3 F=ARIAL j=L h=.95 "Generated by the LINKS System on &today at &rpttime" j=r "Data last updated: &Save_Last_Update_Date at &Save_Last_Update_Time";
  		FOOTNOTE4 H=.3 ' ';
		%IF %SUPERQ(UNAPPFLAG)=YES %THEN %DO;
			FOOTNOTE5 F=ARIAL C=RED J=C H=.95 'Report contains approved and unapproved data. '; 
			FOOTNOTE6 H=.3 ' ';
		%END;
	%END;

	PROC GPLOT DATA=SCATTERSUM2;		/** Generate plot **/
    	PLOT &PLOTVAR * time=study/
    	HAXIS=axis1 VAXIS=axis2 
    	&vref LEGEND=legend1   ;
	RUN;
	
%MEND SCATTERPLOT;

****************************************************************************************************;
*                                     MODULE HEADER                                                *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;
*	REQUIREMENT     : See LINKS Report SOP                                                     *; 
*       INPUT           : MACRO VARIABLES: HREF, MAXPERCENT, TIME, CLASS, ANALYST,                 *;
*			  NUMTIMES, MAXPERCENT, OBSMAXPCT, TITLE_product, TITLE_test,              *;
*			  TITLE_PEAKA, STORAGE, INVALIDVAXIS, SPECLABEL1, SPECLABEL2               *;
*       PROCESSING      : Setup variables needed to generate comparative histograms                *;
*			  by time, study or analyst.                                               *; 
*       OUTPUT          : 1 COMPARATIVE HISTOGRAM to web browser or RTF file.                      *;
****************************************************************************************************;

%MACRO HIST;
	DATA timefmt2; LENGTH LABEL $10; SET times(KEEP=time);  /* Create time format */
  		RETAIN fmtname 'fmttime' TYPE 'N';
  		IF time=0 THEN LABEL='Initial';
  		ELSE IF time=1 THEN LABEL='1 Month';
  		ELSE IF time>1 THEN LABEL=COMPRESS(time)||' Months';
		start=time;
  	RUN;

  	PROC FORMAT CNTLIN=timefmt2; RUN;

	DATA _NULL_;  /* If there are no specifications, set href to null */
	    	href=UPCASE(COMPRESS("&href"));
	    	IF href='HREF=' THEN CALL SYMPUT('href',' ');
  	RUN;
 
	%GLOBAL maxpercent;

	DATA _NULL_;
   		time0=TRIM("&time");
   		analyst0=TRIM("&analyst");  
		class=TRIM("&class");
		maxpercent="&maxpercent";
		obsmaxpct="&obsmaxpct";

   		IF time0='' OR TIME0='ALL' THEN DO;
			time1="ALL";  /* If time is not specified, then set to ALL */
			CALL SYMPUT('wheretime','*');
		END;
   		ELSE DO;
			time1="&time";
   			CALL SYMPUT('wheretime',"WHERE time="||"&time");
		END;

   		IF time1='0'        THEN CALL SYMPUT("timetitle",'Initial Time Point');
    		ELSE IF time1='ALL' THEN CALL SYMPUT("timetitle",'All Time Points');
		ELSE                     CALL SYMPUT("timetitle",TRIM(time1)||' Month Time Point');

   		IF class='TIME' THEN DO;
   			IF time1 ^= 'ALL' THEN CALL SYMPUT('numrows',1);
   			ELSE CALL SYMPUT('numrows',"&numtimes");
		END;
						
		/* Check for invalid user axis values, if invalid axis, set to null */
		IF MAXPERCENT ^= '' AND OBSMAXPCT ^= '' THEN DO;
			difference=maxpercent-obsmaxpct;
			IF difference =. OR difference < 0 THEN DO;
				CALL SYMPUT('MAXPERCENT',' ');
				CALL SYMPUT('INVALIDMAXAXIS','YES');
			END;
		END;
  	RUN;

	/* Subset data set for specified time point(s) */
	DATA ALLDATA_WITH_STATS; SET ALLDATA_WITH_STATS;
  		&wheretime;
		LABEL time ='Time Point';
  	RUN;

  	%IF %SUPERQ(class)=ANALYST %THEN %DO; 
  		PROC SORT DATA=ALLDATA_WITH_STATS NODUPKEY OUT=analyst2; BY analyst; RUN;

  		DATA analyst3; SET analyst2 NOBS=numanalyst;
  			class="&class";
  			analyst0="&analyst";
  			IF analyst0='' OR analyst0='ALL' THEN DO;
				analyst1='ALL';  /* If no analyst specified set to ALL */
				CALL SYMPUT('whereanalyst','*');
				CALL SYMPUT('numrows',numanalyst);
			END;
   			ELSE DO;
				analyst1="&analyst";
				CALL SYMPUT('whereanalyst','WHERE analyst=TRIM("&analyst")');
				CALL SYMPUT('numrows',1);
			END;
  		RUN;

		/* Subset data set for specified analyst(s) */
  		DATA ALLDATA_WITH_STATS; SET ALLDATA_WITH_STATS;
  			&whereanalyst;
  		RUN;
	%END;

	/* Create unique list of studies */
	PROC SORT DATA=ALLDATA_WITH_STATS NODUPKEY OUT=STUDYOUT; BY STUDY; RUN;
  	%GLOBAL NUMROWS;
	%IF %SUPERQ(class)=STUDY %THEN %DO;
		DATA _NULL_; SET STUDYOUT NOBS=STUDYCNT;
			CALL SYMPUT('NUMROWS',STUDYCNT); /* If class is Study then set numrows to number of studies */
		RUN;
	%END;
    /* Generate comma delimited list of studies for use in footnote */
	DATA _NULL_; LENGTH STUDYLIST $500; SET STUDYOUT NOBS=MAXOBS;
		RETAIN OBS 0 STUDYLIST;
		OBS=OBS+1;
		IF OBS=1 THEN STUDYLIST=TRIM(STUDY);
		ELSE STUDYLIST=TRIM(STUDYLIST)||', '||TRIM(STUDY);
		IF OBS=MAXOBS THEN CALL SYMPUT('STUDYLIST',TRIM(STUDYLIST));
	RUN;
 
	/* Set default chart size depending on number of rows */
	%IF %SUPERQ(NUMROWS)>7 %THEN %DO;
		%LET YPIXELS=ypixels=800;
		%LET YPIXELS0=800;
	%END;
	%IF %SUPERQ(NUMROWS)>10 %THEN %DO;
		%LET YPIXELS=Ypixels=1000;
		%LET YPIXELS0=1000;
	%END;
	
	/*****************/
	     %WARNINGS;
	/*****************/

	DATA _NULL_;  /* Setup vertical axis values */
		maxpercent="&maxpercent";
		IF maxpercent='' THEN CALL SYMPUT('VAXIS',' '); 
		ELSE CALL SYMPUT('VAXIS',"VAXIS=0 TO &MAXPERCENT");
	RUN;

  	GOPTIONS reset=all;  /**  Setup goptions **/
	GOPTIONS device=&device display;
	GOPTIONS &xpixels &ypixels  gsfmode=replace  BORDER /* Added V4 */ ftext=simplex;

    	TITLE H=1 F=SWISSB "&TITLE_product &TITLE_test &TITLE_PEAKA";  /** Setup title and footnote **/
  	TITLE2 H=1 F=SWISSB "&TITLE_storage Storage Condition, &timetitle. ";

  	%IF %SUPERQ(CLASS)^=STUDY %THEN %DO;
  		FOOTNOTE H=1.2 F=ARIAL "Studies Included:  &studylist";
  	%END;

	%IF %SUPERQ(SPECCHK)=YES %THEN %DO;
		%DO I = 1 %TO &NUMSPECS;
			%LET K=%EVAL(&I+1);
			&&FOOTNOTE&I;
		%END;
		%LET J = %EVAL(&NUMSPECS+2);
		FOOTNOTE&J H=.2 ' ';
		%LET J = %EVAL(&NUMSPECS+3);
  		FOOTNOTE&J F=ARIAL j=l h=.95 "Generated by the LINKS System on &today at &rpttime" j=r "Data last updated: &Save_Last_Update_Date at &Save_Last_Update_Time";
		%LET J = %EVAL(&NUMSPECS+4);
		FOOTNOTE&J H=.2 ' ';
		%IF %SUPERQ(UNAPPFLAG)=YES %THEN %DO;
			%LET J = %EVAL(&NUMSPECS+5);
			FOOTNOTE&J C=RED F=ARIAL J=C H=.95 'Report contains approved and unapproved data. '; 
			%LET J = %EVAL(&NUMSPECS+6);
			FOOTNOTE&J H=.2 ' ';
		%END;
	%END;
	%ELSE %DO;
		FOOTNOTE2 H=.3 ' ';
  		FOOTNOTE3 F=ARIAL j=L h=.95 "Generated by the LINKS System on &today at &rpttime" j=r "Data last updated: &Save_Last_Update_Date at &Save_Last_Update_Time";
  		FOOTNOTE4 H=.3 ' ';
		%IF %SUPERQ(UNAPPFLAG)=YES %THEN %DO;
			FOOTNOTE5 F=ARIAL C=RED J=C H=.95 'Report contains approved and unapproved data. '; 
			FOOTNOTE6 H=.3 ' ';
		%END;
	%END;

  	/** Generate histograms **/
  	PROC CAPABILITY DATA= ALLDATA_WITH_STATS noprint normaltest;                                            
    	VAR result;                                                                
    	LABEL result="Individual Results";   
     	COMPHISTOGRAM /   
       		CLASS=&class 
       		NROWS=&numrows      
       		NCOLS=1
       		&href 
       		&HAXIShist nocurvelegend
	   		&VAXIS OUTHISTOGRAM=OUTPCT;                                                                           
   			FORMAT time fmttime.; 
  	RUN;     

	PROC SUMMARY DATA=OUTPCT;  /* Determine observed maximum percentage of histograms */
	  	VAR _OBSPCT_;
	  	OUTPUT OUT=MAXPCT MAX=MAXPCT;
	RUN;

	%GLOBAL OBSMAXPCT;
	DATA _NULL_; SET MAXPCT;
		MAXPERCENT="&MAXPERCENT";
		IF MAXPERCENT='' THEN CALL SYMPUT('MAXPERCENT',ceil(MAXPCT));
		CALL SYMPUT('OBSMAXPCT',ceil(MAXPCT));
	RUN;
%MEND Hist;

****************************************************************************************************;
*                                        MODULE HEADER                                             *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *; 
*	REQUIREMENT     : See LINKS Report SOP                                                     *; 
*       INPUT           : MACRO VARIABLES: RPTVALUE, SPECLABEL. DATASET: STABILITY3                *;
*       PROCESSING      : Generate summary statistics table by time point for a                    *;
*		          user chosen statistic.If the report is for individual results,           *;
*	   	          put all results in a comma delimited list in one cell per timepoint      *;
*		          for each study.  Time points should be listed horizontally across        *;
*		          the table.                                                               *; 
*       OUTPUT          : 1 summary statistics table to Web browser or RTF file.                   *;
****************************************************************************************************;

%MACRO SumStats;
	%WARNINGS;

	/* Setup macro variable for style of table headers */
	%LET styleheader=STYLE(header)=[FONT_SIZE=2 background=#C0C0C0 foreground=black];

	%GLOBAL time_list maxobs;
	/* Generate unique list of time points */
	PROC SORT DATA=ALLDATA_WITH_STATS NODUPKEY OUT=timeout; BY timeweeks ; RUN;

	DATA timeout2; SET timeout NOBS=maxobs; BY timeweeks ;
  		RETAIN numobs 0;
  		numobs = numobs+1; OUTPUT;
  		CALL SYMPUT('maxobs', maxobs);
	RUN;

	%LOCAL i j;
	/* Setup macro variables for each time point for use list of time points */
	%DO i = 1 %TO &maxobs;
  		DATA _NULL_;  SET timeout2;
   			WHERE numobs=&i;	   
   			CALL SYMPUT("At&i",'_'||left(COMPRESS(timeweeks)));
  		RUN;
	%END;

	/* Setup define statements for each time point with labels */
	%LET time_list= ;
	%DO j=1 %TO &maxobs; 
  		%LET time_list= &time_list &&At&j  ;
  		DATA _NULL_;
  			time=compress("&&At&j",'_');
			IF time=0 THEN CALL SYMPUT('LABEL','Initial');
			ELSE IF time=4 THEN CALL SYMPUT('LABEL','1 Month');
  			ELSE CALL SYMPUT('LABEL', compress(time/4)||' Months');
  		RUN;
		%GLOBAL DEFINE&j;  
  		%LET DEFINE&j= DEFINE &&At&j /"&LABEL" CENTER STYLE=[FONT_SIZE=2 cellwidth=125 ] &STYLEheader;
	%END;
	
	/* Keep only variables needed */
	DATA STABILITY3; SET STABILITY3;
 		keep product test stage peak storage  study timeweeks result;
	RUN;

	/* Calculate summary statistics by time point */
	PROC SORT DATA=STABILITY3; BY product test stage peak storage study timeweeks; RUN;

	PROC SUMMARY DATA=STABILITY3;
  		VAR result;
   		BY product test stage peak storage study timeweeks;
   		OUTPUT OUT=stats(DROP=_TYPE_ _freq_) n=n mean=mean std=std cv=rsd min=min max=max;
	RUN;

	DATA stats; SET stats; BY product test stage peak storage study timeweeks;
   		obs=-1; /* Create obs variable for use in later merging */ 
   		/* Added V2 */  If std=. then std=0;
   		If rsd=. then rsd=0;
   		KEEP product test stage peak storage study obs timeweeks n mean std rsd min max;
	RUN;

	DATA ALLDATA_WITH_STATS; SET STABILITY3; BY product test stage peak storage study timeweeks; 
		RETAIN obs 0;  /* Create obs variable for use in later merging */
		IF first.timeweeks THEN DO; obs=1; OUTPUT; END;
		ELSE DO; obs=obs+1; OUTPUT; END;
	RUN;

	DATA stabsum0;  LENGTH resultc $150; SET ALLDATA_WITH_STATS; BY product test stage peak storage study timeweeks;
  		RETAIN resultc;  /* Create comma delimited list of individual results */
  		IF obs=1 THEN resultc=PUT(result,6.2);
  		ELSE resultc=TRIM(resultc)||', '||left(PUT(result,6.2));
  		IF last.timeweeks THEN OUTPUT; 
  		
		KEEP product test stage peak storage study obs timeweeks resultc;
	RUN;

	PROC SORT DATA=stabsum0; 	BY product test stage peak storage study timeweeks; RUN;
	PROC SORT DATA=stats; 		BY product test stage peak storage study timeweeks; RUN;

	/* Merge individual results with summary statistics */
	DATA alldata0; MERGE stabsum0 stats; 
		BY product test stage peak storage study timeweeks; 
	RUN;

	PROC SORT DATA=alldata0; BY product test stage peak storage study obs timeweeks; RUN;

	/* Transpose the data */
	DATA _NULL_;
		VALUE="&rptvalue";
		IF VALUE='INDIVIDUAL' THEN DO;
  			CALL SYMPUT('var','resultc');
  			CALL SYMPUT('format','*');
		END;
		ELSE IF VALUE^='' and VALUE NOT IN ('SLOPES','N') THEN DO;
  			CALL SYMPUT('var',VALUE);
  			CALL SYMPUT('format','format &time_list 6.2');
		END;
		ELSE IF VALUE='N' THEN DO;
  			CALL SYMPUT('var',VALUE);
  			CALL SYMPUT('format','format &time_list 6.');
		END;
		ELSE DO;
  			CALL SYMPUT('var','MEAN');
  			CALL SYMPUT('format','format &time_list 6.2');
		END;
	RUN;

	PROC TRANSPOSE DATA=alldata0 OUT=alldata1;
   		VAR &var;
   		BY product test stage peak storage study obs ;
   		ID timeweeks;
	RUN;

	DATA allstab; SET alldata1; 
  		BY product test stage peak storage study obs;
  		_NAME_=upcase(_NAME_);
  		&format;
	RUN;  

	PROC SORT DATA=allstab; BY product test study; RUN;

	DATA slopes; LENGTH PROBTC $15; SET SUMSlopes;	/* Format slope statistics */
		slope=estimate;
		WHERE UPCASE(effect)='TIME';
		IF PROBT^=. THEN DO;
			PROBTC=PUT(PROBT,6.3);
			cislope=PUT(lower,6.3)||', '||left(PUT(upper,6.3));
		END;
		ELSE DO;
			PROBTC='-';
			CISLOPE='-';
		END;
		KEEP product test stage peak study slope probtC cislope;
		FORMAT slope 6.3;
	RUN;

	PROC SORT DATA=allstab; BY product test stage peak study ; RUN;

	/* Merge slope information with all other data */
	DATA allstab1; MERGE allstab slopes; BY product test stage peak study ; RUN;

	DATA _NULL_;  /* Setup where statement depending on report type */
    	VALUE=upcase("&rptvalue");
		IF VALUE IN ('MEAN','STD','N','RSD','MIN','MAX') THEN
      		CALL SYMPUT('typesub',"WHERE _NAME_='"||TRIM(left(VALUE))||"'");
		ELSE IF VALUE IN ('INDIVIDUAL') THEN
      		CALL SYMPUT('typesub',"WHERE _NAME_='RESULTC'");
    	ELSE CALL SYMPUT('typesub',' ');
	RUN;

	DATA ALLSTAB2; LENGTH REPORT $12; SET ALLSTAB1;
		&typesub;	/* Subset the data */
		VALUE=upcase("&rptvalue");  storage2="&storage"; 
		
		IF VALUE IN ('SLOPES') THEN DO;  /* Setup slope table definitions */
			CALL SYMPUT('TIME_LIST','slope probtC cislope');
			CALL SYMPUT('defineslope','DEFINE slope/"Estimated Linear Slope" CENTER format=6.3 STYLE=[FONT_SIZE=2 cellwidth=125 ] &STYLEheader');
			CALL SYMPUT('defineprobt','DEFINE probtC/"P-Value" CENTER STYLE=[FONT_SIZE=2 cellwidth=125 ] &STYLEheader');
			CALL SYMPUT('defineCI','DEFINE CISLope/"95% Confidence Interval on Slope" CENTER STYLE=[FONT_SIZE=2 cellwidth=125 ] &STYLEheader');
		END;
		ELSE DO; 
 			CALL SYMPUT('defineslope','*');
			CALL SYMPUT('defineprobt','*');
			CALL SYMPUT('defineCI','*');
		END;
		/* Setup table statistic */
		IF VALUE='STD' 				THEN CALL SYMPUT('REPORT', 'Standard Deviation');
		ELSE IF VALUE='MIN' 			THEN CALL SYMPUT('REPORT', 'Minimum');
		ELSE IF VALUE='MAX' 			THEN CALL SYMPUT('REPORT', 'Maximum');
		ELSE IF VALUE='INDIVIDUAL' 		THEN CALL SYMPUT('REPORT', 'Individual Results');
		ELSE IF VALUE='MEAN' 			THEN CALL SYMPUT('REPORT', 'Mean');
		ELSE IF VALUE='N' 			THEN CALL SYMPUT('REPORT', 'Sample Size');
		ELSE CALL SYMPUT('REPORT', VALUE);
		LABEL 	test    = 'Test'
			storage2= 'Condition'
	  		study   = 'Study'
			product = 'Product'
			storage = 'Storage Condition';
	RUN;

	/* Remove duplicate studies */
	%IF %SUPERQ(VALUE)^=INDIVIDUAL %THEN %DO;
		PROC SORT DATA=allstab2 OUT=allstab2 NODUPKEY; BY test storage product study; RUN;
	%END;

	/* Set specification to N/A if no specification exists */
	%IF %SUPERQ(SPECLABEL)= %THEN %LET SPECLABEL=N/A;

	/* Setup titles and footnotes */
	TITLE h=2 F=ARIAL "&TITLE_product &TITLE_test &TITLE_PEAKA ";
	TITLE2 H=2 F=ARIAL "&TITLE_storage Storage Condition, Summary Statistic: &report";
	FOOTNOTE H=1 F=ARIAL "Generated by the LINKS System on &today at &rpttime";
	FOOTNOTE2 F=ARIAL h=.95 "Data last updated: &Save_Last_Update_Date at &Save_Last_Update_Time";

	/* If sending output to screen setup HTML */ 
  	DATA _NULL_; FILE _WEBOUT;
		print="&print";
  		IF print ^='ON' THEN DO;
  			PUT '<TABLE WIDTH="95%" ALIGN=CENTER><TR><TD>';
		END;
  	RUN;
  	
  	
  	/* Added V2 */
  	%IF %SUPERQ(speclabel1)^=  %THEN %DO;
	  	%LET SPECLABEL= ;
  		%DO I = 1 %TO &NUMSPECS;
  			%LET SPECLABEL=&SPECLABEL &&SPECLABEL&I;
  			%IF &I < &NUMSPECS %THEN %LET SPECLABEL=&SPECLABEL ,;
  		%END;
  	%END;
  	%ELSE %LET SPECLABEL=Specification: N/A;

	/* Setup report style characteristics */
	%LET stylereport= STYLE(column) = {background = white} STYLE(LINES)=[FONT_SIZE=2 FOREGROUND=BLACK] STYLE(report) = [background=white outputwidth=100%] ;
	/* Generate report */
	PROC REPORT DATA=allstab2 nowd box CENTER split='*' &stylereport;
 		COLUMNS  study &time_list ;
 		DEFINE Study/"Study*Number" id CENTER GROUP ORDER=DATA WIDTH=20 STYLE=[FONT_SIZE=2 cellwidth=125 ] &STYLEheader;
 		%DO j=1 %TO &maxobs;
   			&&DEFINE&j;
 		%END;

 		&defineslope;
 		&defineprobt;
 		&defineci;
 
 		COMPUTE AFTER; LINE "&SpecLabel"; ENDCOMP;
	RUN;

	/* If output is sent to the screen, setup HTML */
	DATA _NULL_; FILE _WEBOUT;
  		print="&print";
  		IF print ^='ON' THEN DO;
  			PUT '</TR></TD></TABLE>';
		END;
  	RUN;
%MEND SumStats;

****************************************************************************************************;
*                                      MODULE HEADER                                               *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;
*	REQUIREMENT     : See LINKS Report SOP                                                     *;
*       INPUT           : DATASET: ALLDATA_WITH_STATS, STABILITY3, PLOTSETUP,                      *;
*			  save.LRQUERYRES_PARAMETERS. MACRO VARIABLES: TESTBCHK,                   *;
*			  STAGEBCHK, PEAKBCHK, VALUE, HAXISCHK, INVALIDHAXIS, TESTB,               *;
*			  TIME, RHTEMPFLG, IMPFLAG, TESTACHK, STAGEACHK, PEAKACHK,                 *;
*			  USERHLOWAXIS, USERHUPAXIS, USERHAXISBY, CORRTYPE,                        *;
*			  NUMSTAGEA, NUMPEAKA, NUMSTAGEB, NUMPEAKB, PRINT, WARNING, GROUPVAR.      *;
*			                                                                           *;
*       PROCESSING      : Setup specifications and reference lines for test B. If test B is a      *;
*		          parameter or TestDate, merge parameter dataset with test A data.         *;
*		          Select only data for specified time point.  If the user choses a         *;
*		          correlation plot, generate plot of user specified value (mean or         *;
*		          individual) where test A is on the Y axis and test B is on the X axis.   *;
*		          Stratify plot points by user selected group variable (i.e. study).       *;
*			                                                                           *;
*		          If the user choses a correlation table, generate an overall correlation  *;
*		          table of test A vs test B, as well as individual correlation table for   *;
*		          each level of the grouping variable.   Include summary statistics: N,    *;
*		          mean, standard deviation, min and max as well as the correlation         *;
*		          statistic with a corresponding p-value.                                  *;
*       OUTPUT          : Either 1 correlation plot to web browser or RTF file, or 2 or more       *;
*			  correlation tables to web browser or RTF file.                           *;
****************************************************************************************************;

%MACRO CORR;
	%WARNINGS;

	%GLOBAL time HAXISCORR HLOWAXIS HUPAXIS HAXISBY SPECLISTB;

	DATA _NULL_;
		TESTBCHK2="&TESTBCHK";	/* Setup flag for impurity test method */
		IF COMPRESS(testBchk2) IN ('HPLCRelatedImp.inAdvairMDPI') THEN CALL SYMPUT('IMPFLAGB','YES');  
		ELSE CALL SYMPUT('IMPFLAGB',' ');
	RUN;

	%IF %SUPERQ(RHTEMPFLG)= AND %SUPERQ(TESTB)^=TESTDATE2 %THEN %DO;

	   %IF %SUPERQ(SPECCHKB)=YES %THEN %DO;/* Create list of specs for testB. Setup reference lines. */
		DATA test2only; SET SPECS2;  
			%IF %SUPERQ(IMPFLAGB)=YES %THEN %DO;
				WHERE TRIM(test)="&testBchk" AND COMPRESS(stage,'- ')=COMPRESS("&stagebchk",'- ');
			%END;
			%ELSE %DO;
				WHERE TRIM(test)="&testBchk" AND COMPRESS(stage,'- ')=COMPRESS("&stagebchk",'- ') AND UPCASE(COMPRESS(peak))=UPCASE("&peakbchk");
			%END;
		RUN;

		PROC SORT DATA=test2only NODUPKEY OUT=PRODSPECS0; BY PRODUCT SPEC_TYPE ; RUN;

		DATA PRODSPECLIST; LENGTH SPECLISTm speclisti $1000 LOWERIC UPPERIC LOWERMC UPPERMC $15; SET PRODSPECS0 NOBS=NUMSPECS; BY PRODUCT SPEC_TYPE ;
  			RETAIN  OBS OBSALL 0 speclistM SPECLISTI;
			IF FIRST.SPEC_TYPE THEN OBS=1;
			ELSE OBS=OBS+1;
			OBSALL=OBSALL+1;
			IF LOWERI=. OR LOWERI=0 THEN LOWERIC=''; ELSE LOWERIC=LOWERI;
			IF UPPERI=.             THEN UPPERIC=''; ELSE UPPERIC=UPPERI;
			IF LOWERM=. OR LOWERM=0 THEN LOWERMC=''; ELSE LOWERMC=LOWERM;
			IF UPPERM=.             THEN UPPERMC=''; ELSE UPPERMC=UPPERM;
	
			IF OBS=1 AND UPCASE(SPEC_TYPE)='MEAN' THEN SPECLISTM=TRIM(LOWERMC)||' '||TRIM(UPPERMC);
			ELSE IF UPCASE(SPEC_TYPE)='MEAN' AND OBS > 1 THEN SPECLISTM=TRIM(SPECLISTM)||' '||TRIM(LOWERMC)||' '||TRIM(UPPERMC);
			
			IF OBS=1 AND UPCASE(SPEC_TYPE)='INDIVIDUAL' THEN SPECLISTI=TRIM(LOWERIC)||' '||TRIM(UPPERIC);
			ELSE IF UPCASE(SPEC_TYPE)='INDIVIDUAL' AND OBS > 1 THEN SPECLISTI=TRIM(SPECLISTI)||' '||TRIM(LOWERIC)||' '||TRIM(UPPERIC);
			
			IF OBSALL=NUMSPECS THEN DO;
				CALL SYMPUT('NUMSPECS',NUMSPECS);
				OUTPUT;
			END;
  		RUN;

		DATA _NULL_; SET PRODSPECLIST; /* Create SpecListB macro variable */
			value=UPCASE("&value"); 
	    		IF VALUE='MEAN' THEN CALL SYMPUT("SpecListB", TRIM(SPECLISTM));
			ELSE CALL SYMPUT("SpecListB", TRIM(SPECLISTI));
  		RUN;

		%LET SPECLABELB=N/A;
			
		PROC SORT DATA=SPECS2 NODUPKEY OUT=SPEC_TYPE; BY SPEC_TYPE TXT_LIMIT_A TXT_LIMIT_B TXT_LIMIT_C;
		RUN;
		
		DATA SPEC_TYPE; LENGTH SPEC $750; SET SPEC_TYPE; BY SPEC_TYPE;
			value="&VALUE";
			RETAIN SPEC;
			WHERE UPCASE(SPEC_TYPE)=UPCASE(SYMGET('VALUE'));
			IF FIRST.SPEC_TYPE THEN SPEC=TXT_LIMIT_A||TXT_LIMIT_B||TXT_LIMIT_C;
			ELSE SPEC=TRIM(SPEC)||'; '||TXT_LIMIT_A||TXT_LIMIT_B||TXT_LIMIT_C;

			IF LAST.SPEC_TYPE THEN 
			CALL SYMPUT('SPECBLABEL',TRIM(SPEC));/* Create specification label */
			CALL SYMPUT('SPECBCHK2','YES'); /* Create flag for test B specification */
		RUN;
  		
		DATA _NULL_; /*** Setup Reference Lines ***/ SET SPEC_TYPE;
			VALUE=UPCASE("&VALUE");
  			speclist="&speclistB";
			IF speclist^='' THEN CALL SYMPUT("Href","Href = &speclistB"); 
		RUN;
	   %END;
				
		DATA _NULL_; LENGTH HLOWAXISCHKC HUPAXISCHKC HAXISBYCHKC $25 HLOWAXISCHK HUPAXISCHK HAXISBYCHK 3;  
			SET plotsetup; /**  Setup horizontal Axis Range **/
			%IF %SUPERQ(IMPFLAGB)=YES %THEN %DO;
				WHERE test="&testb" AND COMPRESS(stage2,'- ')=COMPRESS("&stagebchk",'- ');
			%END;
			%ELSE %DO;
				WHERE test="&testB" AND COMPRESS(stage,'- ')=COMPRESS("&stagebchk",'- ') AND UPCASE(peak)=UPCASE("&peakB");
			%END;

			HAXISCHK="&HAXISCHK";
			INVALIDAXIS="&INVALIDHAXIS";
			IF INVALIDAXIS='YES' OR (HAXISCHK^='USER')  THEN CALL SYMPUT("Hlowaxis",put(lowaxis,7.3));  ELSE CALL SYMPUT("HLOWAXIS","&USERHLOWAXIS");	  
			IF INVALIDAXIS='YES' OR (HAXISCHK^='USER')  THEN CALL SYMPUT("Hupaxis", put(upaxis,7.3));   ELSE CALL SYMPUT("HUPAXIS","&USERHUPAXIS");		  
  			IF INVALIDAXIS='YES' OR (HAXISCHK^='USER')  THEN CALL SYMPUT("Haxisby", put((upaxis-lowaxis)/5,7.3)); ELSE CALL SYMPUT("HAXISBY","&USERHAXISBY");	
		RUN;

	    	DATA _NULL_; LENGTH HLOWAXISCHK HUPAXISCHK HAXISBYCHK 3;  /** Setup horizontal axis statement **/
			HLOWAXISCHK="&HLOWAXIS"; HUPAXISCHK="&HUPAXIS"; HAXISBYCHK="&HAXISBY";
			IF HLOWAXISCHK^=HUPAXISCHK AND HAXISBYCHK>0 THEN 
			CALL SYMPUT("HAXISCORR","ORDER= (&hlowaxis TO &hupaxis BY &haxisby)");
			ELSE CALL SYMPUT('HAXISCORR',' ');
		RUN;

	%END;
	%ELSE %DO;
		/* Setup data for RH, CINUM, Temperature and Testdate */
		DATA _NULL_;
			TESTB="&TESTB";  /* Reformat testB name */
			IF TESTB = 'RH' 		THEN CALL SYMPUT('TESTB2','% Relative Humidity');
			IF TESTB = 'CINUM' 		THEN CALL SYMPUT('TESTB2','Cascade Impactor #');
			IF TESTB = 'TEMPERATURE' 	THEN CALL SYMPUT('TESTB2','Temperature');
			IF TESTB = 'TESTDATE2' 		THEN CALL SYMPUT('TESTB2','TESTDATE2');
		RUN;

		PROC SORT DATA=STABILITY3; 			BY SAMP_ID INDVL_TST_RSLT_DEVICE; RUN;
		PROC SORT DATA=SAVE.LRQUERYRES_PARAMETERS; 	BY SAMP_ID INDVL_TST_RSLT_DEVICE; RUN;

		/* Merge parameter data with individual results */
		DATA PARMDATA0; MERGE STABILITY3(IN=A) SAVE.LRQUERYRES_PARAMETERS; BY SAMP_ID INDVL_TST_RSLT_DEVICE; IF A;
		RUN;

		/* Take out */
        %ds2csv(data=PARMDATA0, labels=Y, formats=Y, colhead=Y,conttype=y,contdisp=y,savefile=LINKSXLSData.csv,
		csvfref=_webout, runmode=s, openmode=replace);

		DATA PARMDATA; SET PARMDATA0;  /* Subset data for requested test parameter */
			%IF %SUPERQ(TESTB)^=TESTDATE2 %THEN %DO;
				WHERE UPCASE(TST_PARM_NM)=UPCASE("&TESTB2");
			%END;
			TESTBCHK="&TESTB";
			IF TESTBCHK IN ('RH','TEMPERATURE') THEN TESTB=TST_PARM_VAL_NUM;
			IF TESTBCHK IN ('CINUM') THEN TESTB=TST_PARM_VAL_CHAR;
			IF TESTBCHK IN ('TESTDATE2') THEN TESTB=TESTDATE2;
		RUN;

		PROC SORT DATA=PARMDATA; BY PRODUCT STUDY TIME; RUN;
		/* Calculate means by time point for each study */
		PROC SUMMARY DATA=PARMDATA;
			VAR TESTB;
			BY PRODUCT STUDY TIME;
			OUTPUT OUT=PARMDATESUM MEAN=MEAN;
		RUN;

		DATA PARMDATESUM1; SET PARMDATESUM;
	  		TESTB=mean;
	  		DROP mean;
		RUN; 

		/* Merge Test A Means dataset from SETUP macro with Test B means */ 
		DATA means; MERGE means PARMDATESUM1; BY product study time; RUN; 
		
	%END;

	DATA _NULL_;  /* Setup titles, dataset variables */
		resulttype="&VALUE";
		IF resulttype IN ('INDIVIDUAL') THEN DO;
	           	CALL SYMPUT('Grptitle', 'Correlation of Individual Results');
			%IF %SUPERQ(RHTEMPFLG)= AND %SUPERQ(TESTB)^=TESTDATE2 %THEN %DO;
				CALL SYMPUT('DATASET2','STABILITY3'); 
			%END;
			%ELSE %DO;
		   		CALL SYMPUT('dataset2','PARMDATA'); 
			%END;
			CALL SYMPUT('vartype','result');
		END;
		IF resulttype IN ('MEAN','') THEN DO;
			CALL SYMPUT('Grptitle', 'Correlation of Time Point Means');
			CALL SYMPUT('dataset2','means');
			CALL SYMPUT('vartype','mean');
		END;
	RUN;

	DATA _NULL_; LENGTH time1 $5; /* Setup time where statements and titles */
  		time0="&time";
   		IF time0='' THEN time1="&time1";
   		ELSE time1="&time";
   		IF time0 IN ('ALL') THEN CALL SYMPUT('wheretime','*');
   		ELSE IF time0='' THEN DO;
     			CALL SYMPUT('wheretime',"WHERE time="||"&time1");
	 		CALL SYMPUT('time',"&time1");
   		END;
   		ELSE CALL SYMPUT('wheretime',"WHERE time="||"&time");
   		IF time1='0'        THEN CALL SYMPUT("timetitle",'Initial');
		ELSE IF time1='ALL' THEN CALL SYMPUT("timetitle",'All');
    		ELSE                     CALL SYMPUT("timetitle",TRIM(time1)||' Month');
	RUN;

	%IF %SUPERQ(RHTEMPFLG)= AND %SUPERQ(TESTB)^=TESTDATE2 %THEN %DO;

		DATA testA testB; SET &dataset2;  /* Divide appropriate dataset into TestA and TestB datasets */
			%IF %SUPERQ(IMPFLAG)= %THEN %DO;
   				IF TRIM(test) IN ("&testAchk") and COMPRESS(stage2,'- ') = COMPRESS("&stageachk",'- ') and UPCASE(COMPRESS(peak)) = UPCASE(COMPRESS("&peakachk")) THEN OUTPUT testA;
			%END;
			%ELSE %DO;
				IF TRIM(test) IN ("&testAchk") and COMPRESS(stage2,'- ') = COMPRESS("&stageachk",'- ') THEN OUTPUT testA;
			%END;
			%IF %SUPERQ(IMPFLAGB)= %THEN %DO;
   				IF TRIM(test) IN ("&testBchk") and COMPRESS(stage2,'- ') = COMPRESS("&stagebchk",'- ') and UPCASE(COMPRESS(peak)) = UPCASE(COMPRESS("&peakbchk")) THEN OUTPUT testB;
			%END;
			%ELSE %DO;
				IF TRIM(test) IN ("&testBchk") and COMPRESS(stage2,'- ') = COMPRESS("&stagebchk",'- ') THEN OUTPUT testB;
			%END;
  		RUN;

  		DATA testA; SET testA;
    		testA=&vartype;  /* Create testA variable */
			DROP &vartype;
  		RUN;

  		DATA testB; SET testB;
    		testB=&vartype; /* Create testB variable */
			DROP &vartype;
  		RUN;

		PROC SORT DATA=TESTA; BY PRODUCT STUDY TIME; RUN;
		PROC SORT DATA=TESTB; BY PRODUCT STUDY TIME; RUN;

		DATA bothtests; MERGE testA testB;  /* Merge data back together */
    		BY product study time;
  			&wheretime;
  		RUN;
	%END;
	%ELSE %DO;
		DATA BOTHTESTS0; SET &dataset2;  /* Keep only test A and parameter/date information */
   			%IF %SUPERQ(IMPFLAG)=YES %THEN %DO;
				WHERE TRIM(test)="&testAchk" AND COMPRESS(stage2,'- ')=COMPRESS("&stageachk",'- ');
			%END;
			%ELSE %DO;
				WHERE TRIM(test)="&testachk" AND COMPRESS(stage2,'- ')=COMPRESS("&stageachk",'- ') AND UPCASE(COMPRESS(peak))=UPCASE(COMPRESS("&peakachk"));
			%END;
   		RUN;
   		

		%GLOBAL FORMAT;  /* Setup date format */
		%IF %SUPERQ(TESTB)=TESTDATE2 %THEN 	%LET FORMAT=format testb date9.;
		
  		DATA BOTHTESTS; SET BOTHTESTS0;
    		testA=&vartype;  /* Create test A variable */
		
			DROP &vartype ;
			&wheretime; /* Subset for selected time point */
			&FORMAT;
		RUN;

		PROC SUMMARY DATA=BOTHTESTS;   /* Calculate MIN and MAX values of Test B for axis statement */
			VAR TESTB;
			OUTPUT OUT=MAXRHTEMP MIN=MIN MAX=MAX;
		RUN;
		%GLOBAL HLOWAXIS HUPAXIS HAXISBY; 
		DATA _NULL_; SET MAXRHTEMP;
			INVALIDAXIS="&INVALIDHAXIS";
			HLOWAXISCHK="&USERHLOWAXIS";
			HUpaxischk="&USERHUpAxis";
			HAxisby="&USERhaxisby";
			TESTB="&TESTB";
			/* Create horizontal axis statement */
			IF testb NOT IN ('TESTDATE2','CINUM') THEN DO;
  				IF HLOWAXISCHK='' OR INVALIDAXIS='YES' THEN lowaxis=min*.9; 		ELSE LOWAXIS=HLOWAXISCHK;
  				IF HUPAXISCHK=''  OR INVALIDAXIS='YES' THEN upaxis=max*1.1; 		ELSE UPAXIS=HUPAXISCHK;
  				IF HAXISBY=''     OR INVALIDAXIS='YES' THEN axisby=(upaxis-lowaxis)/10; ELSE AXISBY=HAXISBY;
				PUT LOWAXIS UPAXIS AXISBY;
			END;

			IF testb NOT IN ('TESTDATE2', 'CINUM') AND LOWAXIS^=UPAXIS AND AXISBY > 0 THEN DO;
				CALL SYMPUT('haxiscorr','ORDER=('||lowaxis||' TO '||upaxis||' BY '||axisby||')');
				CALL SYMPUT('HLOWAXIS',PUT(LOWAXIS, 6.3));
				CALL SYMPUT('HUPAXIS', PUT(UPAXIS,6.3));
				CALL SYMPUT('HAXISBY', PUT(AXISBY, 6.3));
			END;
			ELSE CALL SYMPUT('HAXISCORR','');
			
		RUN;
 
	%END;

	/* Generate Correlation Plot */
	%IF %SUPERQ(corrtype)=PLOT %THEN %DO;
		%IF %SUPERQ(print)=ON %THEN %DO;%PRINT;%END;
		/* Setup footnote macro variables */
		%IF %SUPERQ(numstageA)>1 %THEN %DO;
			%IF %SUPERQ(numpeakA)>1 %THEN %LET footnote1= "   Test 1 = &TestA - &stageA - &peakA "; 
			%ELSE %LET footnote1= "   Test 1 = &TestA - &stageA "; ;
		%END;
		%ELSE %DO;
			%IF %SUPERQ(numpeakA)>1 %THEN %LET footnote1= "   Test 1 = &TestA - &peakA "; 
			%ELSE %LET footnote1="   Test 1 = &TestA "; ;
		%END;

		%IF %SUPERQ(numstageB)>1 %THEN %DO;
			%IF %SUPERQ(numpeakB)>1 %THEN %LET footnote2="   Test 2 = &TestB - &stageB - &peakB "; 
			%ELSE %LET footnote2="   Test 2 = &TestB - &stageB "; 
		%END;
		%ELSE %DO;
			%IF %SUPERQ(numpeakB)>1 %THEN %LET footnote2="   Test 2 = &TestB - &peakB ";
			%ELSE %LET footnote2="   Test 2 = &TestB ";   /* Added V2 */
		%END;
				
		%IF %SUPERQ(TESTB)=RH %THEN %DO;
			%LET footnote2="   Test 2 =% Relative Humidity";
		%END;
		%ELSE %IF %SUPERQ(TESTB)=TEMPERATURE %THEN %DO;
			%LET footnote2="   Test 2 =Temperature (Celsius)";
		%END;
		%ELSE %IF %SUPERQ(TESTB)=CINUM %THEN %DO;
			%LET footnote2="   Test 2 = CI Stack Number";
		%END;
		%ELSE %IF %SUPERQ(TESTB)=TESTDATE2 %THEN %DO;
			%LET footnote2="   Test 2 = Test Date";
		%END;
			
		DATA _NULL_;  /* Create null horizontal reference line statement if no specifications exist */
			HREF=TRIM("&HREF");
			IF HREF='HREF=' THEN CALL SYMPUT('HREF',' ');
		RUN;

		GOPTIONS reset=all;  /* Setup plot options */
		GOPTIONS device=&device display;
		GOPTIONS &xpixels ypixels=500  gsfmode=replace BORDER;

		/* Create titles and footnotes */
		TITLE H=1 F=SWISSB "&TITLE_product &Grptitle";
		TITLE2 H=1 F=SWISSB "&TITLE_storage Storage Condition, Time Point: &timetitle";
 		
		DATA _NULL_; FILE _WEBOUT;	/**  Print warning if applicable if data exists outside axis range **/
    			&warning;
		RUN;

		%IF %SUPERQ(WARNING)= %THEN %DO;
			FOOTNOTE1 j=l H=1.2 F=ARIAL &FOOTNOTE1;
  			FOOTNOTE2 j=l H=1.2 F=ARIAL &FOOTNOTE2;
			FOOTNOTE3 H=.2 ' ';
			FOOTNOTE4 F=ARIAL j=l h=.95 "Generated by the LINKS System on &today at &rpttime" j=r "Data last updated: &Save_Last_Update_Date at &Save_Last_Update_Time";
  			FOOTNOTE5 H=.2 ' ';
		%END;
		%ELSE %DO;
			FOOTNOTE2 H=.2 ' ';
			FOOTNOTE3 j=l H=1.2 F=ARIAL &FOOTNOTE1;
  			FOOTNOTE4 j=l H=1.2 F=ARIAL &FOOTNOTE2;
			FOOTNOTE5 H=.2 ' ';
			FOOTNOTE6 F=ARIAL j=l h=.95 "Generated by the LINKS System on &today at &rpttime" j=r "Data last updated: &Save_Last_Update_Date at &Save_Last_Update_Time";
  			FOOTNOTE7 H=.2 ' ';
		%END;

		%IF %SUPERQ(GROUPVAR)=NONE %THEN %DO;
			symbol1  i=NONE c=black   	v=STAR;
		%END;
		%ELSE %DO;	
			symbol1  i=NONE c=black   	v="A";	
		%END;
 			symbol2  i=NONE c=red     	v="B";
  			symbol3  i=NONE c=blue    	v="C";
  			symbol4  i=NONE c=green   	v="D";
  			symbol5  i=NONE c=orange  	v="E";
  			symbol6  i=NONE c=brown   	v="F";
  			symbol7  i=NONE c=cyan    	v="G";
  			symbol8  i=NONE c=magenta 	v="H";
  			symbol9  i=NONE c=yellow  	v="I";
  			symbol10 i=NONE c=gray    	v="J";
  			symbol11 i=NONE c=navy    	v="K";
  			symbol12 i=NONE c=purple  	v="L";
  			symbol13 i=NONE c=red 		v="M";
  			symbol14 i=NONE c=blue 		v="N";
  			symbol15 i=NONE c=green 	v="O";
  			symbol16 i=NONE c=orange 	v="P";
  			symbol17 i=NONE c=brown 	v="Q";
  			symbol18 i=NONE c=cyan 		v="R";
  			symbol19 i=NONE c=magenta 	v="S";
  			symbol20 i=NONE c=yellow 	v="T";
  			symbol21 i=NONE c=gray 		v="U";
  			symbol22 i=NONE c=navy 		v="V";
  			symbol23 i=NONE c=purple 	v="W";
  			symbol23 i=NONE c=red 		v="X";
  			symbol25 i=NONE c=black 	v="Y";
  			symbol26 i=NONE c=blue 		v="Z";

			axis1 OFFSET=(2,2) LABEL=(a=90 FONT=simplex "Test 1" ) &VAXIS;
  			axis2 OFFSET=(2,2) LABEL=(FONT=simplex "Test 2" ) &HAXISCORR;

		DATA _NULL_;
			GROUPVAR="&GROUPVAR";
			IF GROUPVAR='NONE' THEN CALL SYMPUT('GROUPVAR2','');
			ELSE CALL SYMPUT('GROUPVAR2', '='||"&GROUPVAR");
		RUN;

		/* Generate plot */
		PROC GPLOT DATA=bothtests;
			PLOT testA*TESTB&groupvar2/VAXIS=axis1 HAXIS=axis2 &href &vref ;
			LABEL study='Study';
		RUN;
	%END;

	%ELSE %IF %SUPERQ(corrtype)=TABLE %THEN %DO;  /* Generate correlation tables */
   			
		%MACRO CorrStats;

			%IF %SUPERQ(byvar)^= %THEN %DO; PROC SORT DATA=bothtests; &byvar; RUN; %END;
				/* Generate correlation statistics */
    			ODS LISTING CLOSE;
    			PROC GLM DATA=bothtests OUTSTAT=corr NOPRINT;
				MODEL testa=testb;
				&byvar;
			RUN;

			%IF %SUPERQ(print)^=ON %THEN %DO;ods html close;%END;

			/* Determine the sign of the slope */
			PROC MIXED DATA=BOTHTESTS METHOD=reml ;
			MODEL TESTA=TESTB/ cl  htype=1;
			MAKE 'solutionf' OUT=SLOPES;
			&BYVAR;
			RUN;

			%IF %SUPERQ(print)^=ON %THEN %DO;ODS HTML BODY=_WEBOUT RS=NONE PATH=&_TMPCAT (URL=&_REPLAY2);%END;
			%IF %SUPERQ(print)=ON %THEN %DO;%PRINT;%END;

			%LET SIGN=;
			DATA _NULL_; SET slopes; WHERE UPCASE(effect)='TESTB'; 
			IF ESTIMATE < 0 THEN CALL SYMPUT('SIGN','-');
			RUN;

			DATA corr; SET corr;
   				WHERE _TYPE_ IN ('ERROR', 'SS1');
    			RUN;

    			DATA corr;  SET corr nobs=maxobs; &byvar;
	    			RETAIN totalss obs 0;
				obs=obs+1;
				IF first.&groupvar2 THEN totalss=ss;
        			ELSE totalss=totalss+ss;
				corr=sqrt(ss/totalss);
				temp="&groupvar2";
				IF obs=maxobs or last.&groupvar2 THEN output;
				KEEP temp &groupvar2 corr prob;
   			RUN;

			/* Calculate summary statistics for test A */
			PROC SUMMARY DATA=bothtests;
				VAR testa;
				&byvar;
				OUTPUT OUT=testasum n=n1 mean=mean1 std=std1 min=min1 max=max1;
			RUN;

			DATA testasum;  SET testasum;
   				temp="&groupvar2";
   				test="&TITLE_test &TITLE_PEAKA"; /* Setup test variable */
			RUN;
	
			/* Calculate summary statistics for test B */
			PROC SUMMARY DATA=bothtests;
				VAR testb;
				&byvar;
				OUTPUT OUT=testbsum n=n1 mean=mean1 std=std1 min=min1 max=max1;
				RUN;

				DATA testbsum; SET testbsum;
	      			temp="&groupvar2";  /* Setup test variable */
				%IF %SUPERQ(RHTEMPFLG)= AND %SUPERQ(TESTB)^=TESTDATE2 %THEN %DO;
		  			test="&TITLE_testb &TITLE_PEAKb";
				%END;
				%ELSE %IF %SUPERQ(TESTB)=RH %THEN %DO;
					TEST='% Relative Humidity';
				%END;
				%ELSE %IF %SUPERQ(TESTB)=TEMPERATURE %THEN %DO;
					TEST='Temperature (Celsius)';
				%END;
				%ELSE %IF %SUPERQ(TESTB)=CINUM %THEN %DO;
					TEST='CI Stack Number';
				%END;
				%ELSE %IF %SUPERQ(TESTB)=TESTDATE2 %THEN %DO;
					TEST='Test Date';
				%END;
			RUN;

			/* Combine testa and testb summary statistics */
			DATA testsum; LENGTH test $100; SET testasum testbsum;  DROP _TYPE_ _freq_; RUN;

			PROC SORT DATA=testsum; BY &groupvar2; RUN;
			PROC SORT DATA=corr; BY  &groupvar2; RUN;

			%GLOBAL FORMAT LABEL;  /* Setup formats and labels */
			%IF %SUPERQ(TESTB)=TESTDATE2 %THEN %DO;
				%LET FORMAT= DATE9.;
				%LET LABEL = LABEL TESTB='Test Date';
			%END;
			%ELSE %LET FORMAT=8.3;

			/* Merge summary statistics with correlation statistics */
			DATA allcorr; LENGTH meanc stdc minc maxc $25; MERGE testsum corr; 
				IF corr=. THEN corr=0;
				IF prob=. THEN prob=1;
										
				if UPCASE(test) = 'TEST DATE' then do;
					TEST    = 'Test Date';
					meanc	= 'N/A';
					minc	= PUT(min1,DATE9.);
					maxc	= PUT(max1,DATE9.);
					STDC	= 'N/A';
				END;
				ELSE DO;
					meanc	= put(mean1,8.3);
					minc	= put(min1,8.3);
					maxc	= put(max1,8.3);
				IF      std1    = . 
					THEN stdc = '0';
					ELSE STDC = PUT(std1,8.3);
				END;
				
				BY &groupvar2 ;
				&LABEL;
			RUN;

			/* Setup title, footnotes and report characteristic variables */
  			TITLE h=2 "&TITLE";
			title2 h=1.5 "&TITLE_product (&TITLE_storage Storage Condition), Time Point: &timetitle";
  
			ODS noproctitle ;

			%LET stylereport=STYLE(column) = {background = white} STYLE(report) = [background=white outputwidth=90%]
			STYLE(lines)=[FONT_weight=bold FONT_SIZE=2] ;

			%LET styleheader=STYLE(header)=[FONT_SIZE=2 background=#C0C0C0 foreground=black];

			FOOTNOTE h=.95 FONT=ARIAL "Generated by the LINKS System on &today at &rpttime";
			FOOTNOTE2 F=ARIAL h=.95 "Data last updated: &Save_Last_Update_Date at &Save_Last_Update_Time";
  		  	
			/* Generate table */
			PROC REPORT DATA=allcorr SPLIT='*' &stylereport ; 
				COLUMNS &column test n1 meanc stdc minc maxc corr=corr2 prob=pcorr2; 
				&DEFINE;
				DEFINE test  / "Test"                      STYLE=[FONT_SIZE=2 cellwidth=350 ] &STYLEHeader;
				DEFINE n1    / "Sample*Size"        CENTER STYLE=[FONT_SIZE=2 cellwidth=100 ] &StyleHeader;
				DEFINE meanC / "Mean"               CENTER STYLE=[FONT_SIZE=2 cellwidth=100 ] &STYLEheader;
				DEFINE stdC  / "Standard*Deviation" CENTER STYLE=[FONT_SIZE=2 cellwidth=100 ] &STYLEheader;
				DEFINE minC  / "Minimum"            CENTER STYLE=[FONT_SIZE=2 cellwidth=100 ] &STYLEheader;
				DEFINE maxC  / "Maximum"            CENTER STYLE=[FONT_SIZE=2 cellwidth=100 ] &STYLEheader;
				DEFINE corr2 / analysis mean noprint;
				DEFINE pcorr2/ analysis mean noprint;
				COMPUTE AFTER &column;
				LINE "Correlation Statistic (r): &SIGN" corr2 6.3 "      P-Value:"  pcorr2 6.3; 
			ENDCOMP;
			RUN;
  		%MEND CorrStats;

  		%LET byvar=; 			/* Generate Overall correlation table */
  		%LET groupvar2=temp;
  		%LET column=;
  		%LET DEFINE=;
  		%LET TITLE = Overall &grptitle;
  		%corrstats;

		%IF %SUPERQ(GROUPVAR) ^= NONE %THEN %DO;
  			%LET byvar=BY &groupvar;  /* Generate correlation table for each level of GroupVar classification variable */
  			%LET groupvar2=&groupvar;
  			%LET column=&groupvar;
  			%LET DEFINE=DEFINE &groupvar/"&groupvar"  GROUP STYLE=[FONT_SIZE=2 cellwidth=150 ] &STYLEheader;
   			%LET TITLE=&grptitle BY &groupvar;
  			%corrstats;
		%END;
	%END;
%MEND CORR;

****************************************************************************************************;
*                                      MODULE HEADER                                               *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;
*	REQUIREMENT     : See LINKS Report SOP                                                     *;
*       INPUT           : MACRO VARIABLES: STUDY0, XPIXELS, YPIXELS, RPTTIME, TODAY,               *; 
*  			  INVALIDVAXIS, LOWAXIS, UPAXIS, AXISBY, VALUE.  DATASETS:                 *;
*  			  MEANSTAGES, CIDATA.                                                      *;
*       PROCESSING      : If only one study, generate profile plot of cascade                      *;
*  			  impaction individual data.  If more than one study, generate             *;
*                         profile plot of cascade impaction mean data.  Plot individual            *;
*  			  CI stages along the horizontal axis and results along vertical           *;
*  			  axis.  Connect each stage with a solid line for each study.  		   *;	          
*       OUTPUT          : 1 plot to web browser or RTF file.                                       *;
****************************************************************************************************;

%MACRO CIPROFILES;
	%WARNINGS;

	%IF %SUPERQ(study0)= %THEN %LET study0=&NUMALLSTUDY;
	/* If more than one study, setup variables to plot means. Otherwise, setup variables to plot individuals */
  	%IF %SUPERQ(study0)>1 %THEN %DO;
	     	%LET cidata=Meanstages;
	 	%LET VALUE=CIMean;
	 	%LET symbol1 = symbol1  c=black  v="A" i=std3tmj;
	%END;
  	%ELSE %IF %SUPERQ(study0)=1 %THEN %DO;
	 	%LET cidata=CIData;
	 	%LET VALUE=Result;
		%LET symbol1 = symbol1  c=black  v=star i=std3tmj;
	%END;

	GOPTIONS reset=all;  /* Setup plot options */
  	GOPTIONS device=&device display;
  	GOPTIONS &xpixels &ypixels  gsfmode=replace BORDER;

	/* Setup titles */
	TITLE H=1 F=SWISSB "&TITLE_product Cascade Impaction Profile";
  	TITLE2 H=1 F=SWISSB "(&peakA Drug Substance, &TITLE_storage Storage Condition, &timetitle)";

	%IF %SUPERQ(CIWARNING)=YES %THEN %DO;  /* Setup footnotes. Plot warning if data exists outside user defined axis range */
		FOOTNOTE1 F=ARIAL H=1.2 C=RED "Data points exist outside user defined axis range";
		FOOTNOTE2 H=.2 ' ';
		FOOTNOTE3 F=ARIAL j=l h=.95 "Generated by the LINKS System on &today at &rpttime" j=r "Data last updated: &Save_Last_Update_Date at &Save_Last_Update_Time";
  		FOOTNOTE4 H=.2 ' ';
	%END;
	%ELSE %DO;	
		FOOTNOTE1 F=ARIAL j=l h=.95 "Generated by the LINKS System on &today at &rpttime" j=r "Data last updated: &Save_Last_Update_Date at &Save_Last_Update_Time";
  		FOOTNOTE2 H=.2 ' ';
	%END;

	&symbol1 ;
  	symbol2 i=std3tmj c=red      v="B";
  	symbol3 i=std3tmj c=blue     v="C";
  	symbol4 i=std3tmj c=green    v="D";
  	symbol5 i=std3tmj c=orange   v="E";
  	symbol6 i=std3tmj c=brown    v="F";
  	symbol7 i=std3tmj c=cyan     v="G";
  	symbol8 i=std3tmj c=magenta  v="H";
  	symbol9 i=std3tmj c=yellow   v="I";
  	symbol10 i=std3tmj c=gray    v="J";
  	symbol11 i=std3tmj c=navy    v="K";
  	symbol12 i=std3tmj c=purple  v="L";
  	symbol13 i=std3tmj c=red     v="M";
  	symbol14 i=std3tmj c=blue    v="N";
  	symbol15 i=std3tmj c=green   v="O";
  	symbol16 i=std3tmj c=orange  v="P";
  	symbol17 i=std3tmj c=brown   v="Q";
  	symbol18 i=std3tmj c=cyan    v="R";
  	symbol19 i=std3tmj c=magenta v="S";
  	symbol20 i=std3tmj c=yellow  v="T";
  	symbol21 i=std3tmj c=gray    v="U";
  	symbol22 i=std3tmj c=navy    v="V";
  	symbol23 i=std3tmj c=purple  v="W";
  	symbol23 i=std3tmj c=red     v="X";
  	symbol25 i=std3tmj c=black   v="Y";
  	symbol26 i=std3tmj c=blue    v="Z";
	%IF %SUPERQ(CIType)=NONPOOLED %THEN %DO;
		AXIS1 OFFSET=(5,5) LABEL=(FONT=simplex 'Stage') ORDER=('T' 'P' '0' '1' '2' '3' '4' '5' '6,7&F');
	%END;
	%IF %SUPERQ(CIType)=POOLED %THEN %DO;
		AXIS1 OFFSET=(5,5) LABEL=(FONT=simplex 'Stage') ORDER=('TP0' '12' '34' '5' '6,7&F');
	%END;
	%IF %SUPERQ(CIType)=FULL %THEN %DO;
		AXIS1 OFFSET=(5,5) LABEL=(FONT=simplex 'Stage') ORDER=('T' 'P' '0' '1' '2' '3' '4' '5' '6' '7' 'F');
	%END;
	AXIS2 LABEL=(A=90 FONT=simplex 'Mean Cascade Impaction') ORDER=(&LOWAXIS TO &UPAXIS BY &AXISBY);
	/* Generate plot */
  	PROC GPLOT DATA=&cidata;
  		PLOT &VALUE*stage=study/HAXIS=axis1 VAXIS=AXIS2;
  	RUN;

%MEND CIPROFILES;

****************************************************************************************************;
*                                       MODULE HEADER                                              *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;
*	REQUIREMENT     : See LINKS Report SOP                                                     *;
*       INPUT           : DATASET: STABILITY2, SAVE.LRQUERY01A. MACRO VARIABLES:                   *; 
*		          STUDY.                                                                   *;
*       PROCESSING      : This code will be executed when user clicks on study                     *;
*		          hyperlinks from HTML menu.  The code produces a summary table containing *;
*		          study information including blend lot, fill lot and asssembled lot,      *;
*		          assembled lot description, study purpose, product.                       *;
*       OUTPUT          : 1 table to web browser or RTF file.                                      *;
****************************************************************************************************;

%MACRO StudyDesc;
	%WARNINGS;

	/* Added V2 */
	DATA _NULL_;  /* Create macros for date and time for use in footnotes */
   		CALL SYMPUT('today',	TRIM(left(put(today(),worddate.))));
   		CALL SYMPUT('rpttime', 	TRIM(left(put(time(),timeampm9.))));
	RUN;
	
	/* Merge lot relationship data into study dataset by blend lot */
	DATA STUDYINFO; SET SAVE.LRQUERYRES_Database; WHERE STABILITY_STUDY_NBR_CD="&STUDY"; 
	CALL SYMPUT('PROD_GRP',PROD_GRP);
	RUN;

	PROC SORT DATA=STUDYINFO NODUPKEY; BY STABILITY_STUDY_NBR_CD; RUN;

	%IF %SUPERQ(PRINT)^=ON %THEN %DO;
	/* If output is going to browser, set up LINKS banner HTML */
		DATA _NULL_; LENGTH LINE anchor $1000;  
  			FILE _WEBOUT;

  			/* Set up LINKS banner */    /* Added V3 */
   			PUT '<BODY BGCOLOR="#808080"><TITLE>LINKS Stability Analysis Tools - Unofficial Report If Printed From Web Browser</TITLE></BODY>';
  			PUT '<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" BORDER="1" BORDERCOLOR="#003366" CELLPADDING="0" CELLSPACING="0">';
  			PUT '<TR ALIGN="LEFT" ><TD COLSPAN=2 BGCOLOR="#003366">';
  			PUT '<TABLE ALIGN=left VALIGN=top HEIGHT="100%" WIDTH="100%"><TR><TD ALIGN=left><BIG><BIG><BIG>';
			LINE= '<IMG SRC="//'||"&_server"||'/links/images/gsklogo1.gif" WIDTH="141" HEIGHT="62">'; PUT LINE;
  			PUT '<FONT FACE=ARIAL COLOR="#FFFFFF"><EM> LINKS </EM> Stability Module</FONT></BIG></BIG></BIG></TD>';

  			anchor= '<TD ALIGN=right><A HREF="'|| "%superq(_THISSESSION)" ||
			'&_program='||"links.LRReport.sas"||'"><FONT FACE=ARIAL COLOR="#FFFFFF">Back to Stability Menu</FONT></A></TD>'; 
	    		PUT anchor; 

  			anchor= '<TD ALIGN=right><A HREF="'|| "%superq(_THISSESSION)" ||'&reportype2=STUDYDESC&print=ON'||
			'&_program='		||"links.LRSTAnalysis.sas"	||
			'&study='		||"&study"						||
			'"><FONT FACE=ARIAL COLOR="#FFFFFF">Print or Save Analysis</FONT></A></TD></TR></TABLE>'; 
	    		PUT anchor; 

  			PUT '</TD></TR>';
			PUT '<TR HEIGHT="87%"><TD BGCOLOR="#ffffdd" nowrap VALIGN="CENTER">';
  		RUN;

		%LET CLOSE=ODS HTML CLOSE;  /* Setup ODS HTML statements */
		ODS HTML BODY=_WEBOUT;
	%END;

	%ELSE %DO; 	/* Setup ODS RTF file statements */
		DATA _NULL_;
 			rc=appsrv_header('Content-disposition',"attachment; FILEname=LINKSSTUDYDETAILS&save_uid..rtf");
		RUN;

		OPTIONS ORIENTATION=LANDSCAPE;
		ODS LISTING CLOSE;
		ODS RTF BODY=_WEBOUT ;
		ODS NOPROCTITLE;
		
		%LET close=ODS RTF CLOSE;
	%END;

	DATA STUDYINFO; SET STUDYINFO;  /*Modified V8 */
	IF ASSY_BATCH='' THEN ASSY_BATCH='Not Available';
	IF fill_BATCH='' THEN fill_BATCH='Not Available';
	IF blend_BATCH='' THEN blend_BATCH='Not Available';
	IF ASSY_desc='' THEN ASSY_desc='Not Available';
	IF fill_desc='' THEN fill_desc='Not Available';
	IF blend_desc='' THEN blend_desc='Not Available';
	RUN;


	/* Setup footnotes and report characteristics */
	FOOTNOTE f=arial h=.95 "Generated by the LINKS System on &today at &rpttime";
	FOOTNOTE2 F=ARIAL h=.95 "Data last updated: &Save_Last_Update_Date at &Save_Last_Update_Time";

	%LET stylereport=STYLE(column) = {background = white} STYLE(report) = [background=white outputwidth=90%]
				STYLE(lines)=[FONT_weight=bold FONT_SIZE=2] ;

	%LET styleheader=STYLE(header)=[FONT_SIZE=2 background=#C0C0C0 foreground=black];

	%IF %SUPERQ(PROD_GRP)=MDPI %THEN %DO;  /* Modified V7 */
	/* Changed lot variable names V5 */
  	/* Generate table */
	PROC REPORT DATA=STUDYINFO SPLIT='*' &stylereport ; 
		COLUMNS STABILITY_STUDY_NBR_CD STABILITY_STUDY_PURPOSE_TXT 
		BLEND_BATCH BLEND_DESC FILL_BATCH FILL_DESC ASSY_BATCH ASSY_DESC; 
		DEFINE STABILITY_STUDY_NBR_CD     / "Study Number"                  ID STYLE=[FONT_SIZE=2 cellwidth=85 ] &STYLEHeader;
		DEFINE STABILITY_STUDY_PURPOSE_TXT/ "Study Description"         CENTER STYLE=[FONT_SIZE=2 cellwidth=250] &STYLEheader;
		DEFINE BLEND_BATCH                  / "Blend Number"              CENTER STYLE=[FONT_SIZE=2 cellwidth=75 ] &STYLEheader;
		DEFINE BLEND_DESC             / "Blend Nbr Description"     CENTER STYLE=[FONT_SIZE=2 cellwidth=150] &STYLEheader;
		DEFINE FILL_BATCH                   / "Filled Number"             CENTER STYLE=[FONT_SIZE=2 cellwidth=75 ] &STYLEheader;
		DEFINE FILL_DESC              / "Filled Nbr Description"    CENTER STYLE=[FONT_SIZE=2 cellwidth=150] &STYLEheader;
		DEFINE ASSY_BATCH              / "Assembled Number"          CENTER STYLE=[FONT_SIZE=2 cellwidth=75 ] &STYLEheader;
		DEFINE ASSY_DESC         / "Assembled Nbr Description" CENTER STYLE=[FONT_SIZE=2 cellwidth=150] &STYLEheader;
	RUN;
	%END;

	%ELSE %DO;
	PROC REPORT DATA=STUDYINFO SPLIT='*' &stylereport ; 
		COLUMNS STABILITY_STUDY_NBR_CD STABILITY_STUDY_PURPOSE_TXT 
		FILL_BATCH FILL_DESC ASSY_BATCH ASSY_DESC; 
		DEFINE STABILITY_STUDY_NBR_CD     / "Study Number"                  ID STYLE=[FONT_SIZE=2 cellwidth=85 ] &STYLEHeader;
		DEFINE STABILITY_STUDY_PURPOSE_TXT/ "Study Description"         CENTER STYLE=[FONT_SIZE=2 cellwidth=250] &STYLEheader;
		DEFINE FILL_BATCH                   / "Manufactured Batch Number"             CENTER STYLE=[FONT_SIZE=2 cellwidth=75 ] &STYLEheader;
		DEFINE FILL_DESC              / "Manufactured Batch Description"    CENTER STYLE=[FONT_SIZE=2 cellwidth=150] &STYLEheader;
		DEFINE ASSY_BATCH              / "Packaged Batch Number"          CENTER STYLE=[FONT_SIZE=2 cellwidth=75 ] &STYLEheader;
		DEFINE ASSY_DESC         / "Packaged Batch Description" CENTER STYLE=[FONT_SIZE=2 cellwidth=150] &STYLEheader;
	RUN;
	%END;

	&CLOSE;

	%IF %SUPERQ(PRINT)^=ON %THEN %DO;  /* Complete HTML statements for browser output only */
		DATA _NULL_; FILE _WEBOUT;
			PUT '</TD></TR><TR  ALIGN="right" HEIGHT="8%"><TD COLSPAN=2 BGCOLOR="#003366">';
		 	LINE = '<A HREF="//'||SYMGET('_server')||'/links/'||"&SAVE_linkshome"||'.ASP?UserRole='|| "%SUPERQ(Save_UserRole)" ||'">
			<FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Home</FONT></a>&nbsp&nbsp'; PUT line;

			anchor= '<A HREF="'|| "%superq(_THISSESSION)" ||
				'&_program='||"LINKS.LRLogoff.sas"||
				'"><FONT FACE=ARIAL COLOR="#FFFFFF">Log off</FONT></A>'; 
			PUT anchor; 
			PUT '</TD></TR></TABLE><BIG><BIG>';
		RUN;
	%END;

%MEND StudyDesc;

****************************************************************************************************;
*                                      MODULE HEADER                                               *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;
*	REQUIREMENT     : See LINKS Report SOP                                                     *;
*       INPUT           : DATASET: SAVE.LRQUERY01A. MACRO VARIABLES:WHERESTUDY.		           *;
*       PROCESSING      : Detemine if each batch was used as stability study. If                   *;
*		  	  so, set studyflag.  Determine mean of each batch.  Check to ensure       *; 
*			  all datapoints are not equal (cannot generate chart), if so              *;
*			  print warning for insufficient data.  Otherwise create x bar chart       *;
*			  stratifying by studyflag.  Plot batch on horizontal axis.  Connect       *;
*			  points with a solid line.  Plot specifications as reference lines.       *;
*       OUTPUT          : 1 PLOT to web browser or RTF file.                                       *;
****************************************************************************************************;

%MACRO PRODRELEASE;
	%WARNINGS;

	

	/* Generate 3 comma delimited lists of all blend lots, fill lots and assembled lots */
	/* Combine into one list */
	/* Changed variable names V5 
	DATA BATCHLIST; LENGTH BLENDLIST FILLLIST ASSEMBLEDLIST $1000; SET SAVE.LEMETADATA_&PRODUCTDATA NOBS=NUMOBS;
		RETAIN OBS 0 BLENDLIST FILLLIST ASSEMBLEDLIST;
		OBS=OBS+1;
		IF OBS=1 THEN DO;
			BLENDLIST	='"'||TRIM(BLEND_NBR)		||'"';
			FILLLIST	='"'||TRIM(FILL_NBR)		||'"';
			ASSEMBLEDLIST	='"'||TRIM(ASSEMBLED_NBR)	||'"';
		END;
		ELSE DO;
			BLENDLIST=TRIM(BLENDLIST)||', "'||TRIM(BLEND_NBR)||'"';
			FILLLIST=TRIM(FILLLIST)||', "'||TRIM(FILL_NBR)||'"';
			ASSEMBLEDLIST=TRIM(ASSEMBLEDLIST)||', "'||TRIM(ASSEMBLED_NBR)||'"';
		END;
		IF OBS=NUMOBS THEN CALL SYMPUT('ALLBATCHES',TRIM(BLENDLIST)||', '||TRIM(FILLLIST)||', '||TRIM(ASSEMBLEDLIST));
	
	RUN;
    
	DATA BATCHES1; SET BATCHES1; 
	   BATCH_NBR2=TRIM(MATL_NBR)||'-'||TRIM(LEFT(BATCH_NBR));
	RUN;  */

	DATA BATCHES1; SET BATCHES1;
		BATCH_NBR2=TRIM(MATL_NBR)||'-'||TRIM(LEFT(BATCH_NBR));
	RUN;

	PROC SORT DATA=BATCHES1; BY Batch_Nbr2; RUN;
	/* Calculate means by lot */
	PROC SUMMARY DATA=BATCHES1;
		VAR RESULT;
		BY Batch_Nbr2;
		ID BATCH_NBR MATL_MFG_DT STUDYFLAG;
		OUTPUT OUT=BATCHSUM0 MEAN=PRMEAN;
	RUN;

	/* Create format for study flag */
	PROC FORMAT;
		VALUE STUDY 0='YES' 1='NO';
	RUN; 

	/* If lot number is contained in list of all batches than set studyflag to 0, otherwise set to 1 */
	DATA BATCHSUM; SET BATCHSUM0;
		
		FORMAT STUDYFLAG STUDY.;
		*IF _N_=1 THEN PUT _ALL_;PUT _ALL_;
	RUN;

	/* Creates the Spec Footnotes */	
/****
	PROC SORT DATA=BATCHSUM;
	PROC SORT DATA=SEPCTYPE1;
	DATA SPECSUM;
	MERGE BATCHSUM(IN=IN1)
	      SPEC_TYPE1(IN=IN2);
	BY TEST PROD 
	RUN;
	
	PROC SORT DATA=SPECSUM NODUPKEY;BY TXT_LIMIT_A TXT_LIMIT_B TXT_LIMIT_C ;RUN;
	
	DATA _NULL;SET SPECSUM  NOBS=maxobs; 
		RETAIN OBS SPEC ;
		OBS=OBS+1;
		SPEC=TRIM(TXT_LIMIT_A)||TRIM(TXT_LIMIT_B)||TRIM(TXT_LIMIT_C);
		IF OBS=1 THEN DO;
			CALL SYMPUT('SPECLABEL1', 'Specification: '||TRIM(LEFT(SPEC)));
			CALL SYMPUT('FOOTNOTE1', 'FOOTNOTE&K F=ARIAL h=1 "Specification: '||TRIM(LEFT(SPEC))||'"');
		END;
		ELSE DO;
			CALL SYMPUT('SPECLABEL'||TRIM(LEFT(OBS)),TRIM(SPEC)); 
			CALL SYMPUT('FOOTNOTE'||TRIM(LEFT(OBS)), 'FOOTNOTE&K F=ARIAL h=1 "'||TRIM(LEFT(SPEC))||'"');
		END;
		IF OBS=MAXOBS THEN CALL SYMPUT('NUMSPECS',MAXOBS);
	RUN;
******/

	%LET DATACHKFLAG=GO;

	/* Check to see if all results are the same if so set flag to STOP */
	DATA _NULL_; SET BATCHSUM NOBS=MAXOBS;
		RETAIN DATACHK OBS 0;
		OBS=OBS+1;
		DATACHK=PRMEAN-DATACHK;
		IF OBS=MAXOBS AND DATACHK =0 THEN CALL SYMPUT('DATACHKFLAG','STOP');
	RUN;

	%IF %SUPERQ(DATACHKFLAG)^=STOP %THEN %DO;  /* If datachkflag is not STOP then proceed */
		GOPTIONS reset=all;  /**  Setup goptions **/
		GOPTIONS device=&device display;
		GOPTIONS &xpixels &ypixels  gsfmode=replace  BORDER;

		/* Setup titles and footnotes */
		TITLE h=1 F=SWISSB "&TITLE_product &TITLE_test &TITLE_PEAKA"; /**  Setup titles, legend and axis **/
		title2 h=1 F=SWISSB "Plot of Initial Stability Time Point Data and Product Release Data";

		%IF %SUPERQ(NUMSPECS)>8 %THEN %LET NUMSPECS=8;

		%DO I = 1 %TO &NUMSPECS;
			%LET K=%EVAL(&I);
			&&FOOTNOTE&I;
		%END;
		%LET J = %EVAL(&NUMSPECS+1);
		FOOTNOTE&J H=.2 ' ';
		%LET J = %EVAL(&NUMSPECS+2);
		FOOTNOTE&J F=ARIAL j=l h=.95 "Generated by the LINKS System on &today at &rpttime" j=r "Data last updated: &Save_Last_Update_Date at &Save_Last_Update_Time";
  	
		%GLOBAL VREF2;
		%IF %SUPERQ(SPECCHK)=YES %THEN %DO;  /* Setup specification dataset */

			data _null_;set prodspecs0;put _all_;run;
			PROC SORT DATA=PRODSPECS0 NODUPKEY; BY LOWERM UPPERM LOWERI UPPERI; RUN;
			DATA VREF (KEEP= _var_ _ref_ _reflab_); LENGTH _REFLAB_ $20; SET PRODSPECS0; 
				IF LOWERM^=. OR UPPERM ^=. THEN DO;
				if low_limit>0 then do;_var_='PRMean'; _ref_=lowerm;  OUTPUT;end; 
				IF UPR_LIMIT>0 THEN DO; _var_='PRMean'; _ref_=upperm;  OUTPUT; END;
				end;
				/*IF LOWERM=. AND UPPERM=. THEN DO;
					if low_limit>0 then do;_var_='PRMean'; _ref_=loweri;  OUTPUT;end;
					_var_='PRMean'; _ref_=upperi;  OUTPUT;
				END;*/
				
			RUN;

			data _null_; set vref; put _all_; CALL SYMPUT('PRDATACHK', 'GO'); run;

			%IF %SUPERQ(PRDATACHK)=GO %THEN %LET VREF2= vref=vref;
			%ELSE %LET VREF2=;
		%END;

		PROC FREQ DATA=BATCHSUM NOPRINT; TABLE STUDYFLAG/OUT=OUTFLAG; RUN;
		/* If batch is used as stability study set symbol as red dot, otherwise set to black star */
		DATA _NULL_; SET OUTFLAG NOBS=MAXOBS;
			IF MAXOBS=1 AND STUDYFLAG=0 THEN CALL SYMPUT('SYMBOL1', 'symbol1 v=DOT w=.75 c=red');
			ELSE CALL SYMPUT('SYMBOL1', 'symbol1 v=star w=.75 c=black');
		RUN;

		AXIS1 LABEL=(a=90 FONT=SIMPLEX "Mean Result") &VAXIS;
		&Symbol1;
		SYMBOL2 v=DOT w=.75 c=red;
		LEGEND1 ORDER=(0,1);

		PROC SORT DATA=BATCHSUM; BY MATL_MFG_DT Batch_Nbr; RUN;

		DATA _NULL;SET BATCHSUM; PUT _ALL_;RUN;

		/* Create chart */
		PROC SHEWHART DATA=BATCHSUM;FORMAT PRMEAN 7.3;
 			XCHART PRMEAN*Batch_Nbr=STUDYFLAG / NPANELPOS=1000
 					  VAXIS=axis1	
                			  NOLCL
					  NOUCL
					  &VREF2
					  LVREF=1
					  BLOCKPOS=1
					  BLOCKLABTYPE=truncated
					  CCONNECT=black
					  NOLEGEND
					  NOLIMITLABEL
					  SYMBOLLEGEND=LEGEND1
					  TABLEALL(noprint exceptions);
					  LABEL 	Batch_Nbr='Batch Number'
					  STUDYFLAG='Batch Used as Stability Study?';
		RUN;
	%END;
	%ELSE %DO;
		/* Pring warning in HTML for insufficient data */
		DATA _NULL_; FILE _WEBOUT;
			PUT '<TABLE WIDTH="50%" ALIGN=CENTER VALIGN=CENTER><TR><TD>';
			PUT '<FONT FACE="Arial" ></BR></BR></BR>Insufficient data to create chart.</FONT></TD></TR></TABLE>';
		RUN;
	%END;

%MEND PRODRELEASE;

****************************************************************************************************;
*                                      MODULE HEADER                                               *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;
*	REQUIREMENT     : See LINKS Report SOP                                                     *;
*       DESIGN COMPONENT: See SDS        REQUIREMENT: See FRS                                      *;
*       INPUT           : MACRO VARIABLES: PRODUCT, STORAGE, TESTA, STAGEA, PEAKA,                 *;
*		          TESTB, STAGEB, PEAKB, REPORTYPE, VALUE, ANALYST, TIME, OBSMAXPCT,        *;
*		          GROUPVAR, STUDY0, STUDY1,...,STUDY#, LOWAXIS, UPAXIS, AXISBY,            *;
*		          USERLOWAXIS, USERUPAXIS, USERAXISBY, HLOWAXIS, HUPAXIS, HAXISBY,         *; 
*		          USERHLOWAXIS, USERHUPAXIS, USERHAXISBY, XPIXELS0, YPIXELS0, REG0,        *;
*		          REG2.                                                                    *;
*       PROCESSING      : Create html forms to edit plots.  For report type =                      *;
*		          SCATTER include text fields for changing the horizontal and vertical     *;
*		          axis, drop down boxes for changing the plot size, and drop down boxes    *;
*		          for changing regression line and confidence bounds. For report type =    *;
*		          CORR include text fields for changing the horizontal and vertical        *;
*		          axis and drop down boxes for changing the plot size, For report type =   *; 
*		          HISTIND include text fields for changing histogram midpoints, changing   *;
*		          vertical axis value, and drop down boxes for changing the plot size.     *;
*		          For report type=CIPROFILES and PRODRELEASE, include text fields for      *;
*		          changing vertical axis and drop down boxes for changing plot size.       *;              
*       OUTPUT          : 1 of 5 different HTML forms depending on report type.                    *;
****************************************************************************************************;

%MACRO Webout2;
	/* Setup HTML form for report editing menus */ 
	DATA _NULL_; LENGTH LINE $500; FILE _WEBOUT;
	 	LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

  		%THISSESSION;

		LINE= '<INPUT TYPE="hidden" NAME=product      	VALUE="' ||TRIM("&product")	       	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=storage      	VALUE="' ||TRIM("&storage")	       	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=testA      	VALUE="' ||TRIM("&testA")		||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=stageA      	VALUE="' ||TRIM("&stageA")	       	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=peakA      	VALUE="' ||TRIM("&peakA")	       	||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=testB      	VALUE="' ||TRIM("&testB")		||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=stageB      	VALUE="' ||TRIM("&stageB")	       	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=peakB      	VALUE="' ||TRIM("&peakB")	       	||'">'; PUT LINE;  
  		LINE= '<INPUT TYPE="hidden" NAME=reportype  	VALUE="' ||TRIM("&reportype")	    	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=VALUE      	VALUE="' ||TRIM("&VALUE")       	||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=class  	VALUE="' ||TRIM("&class")     		||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=analyst  	VALUE="' ||TRIM("&analyst")     	||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=TIME  		VALUE="' ||TRIM("&time")     		||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=ObsMaxPct 	VALUE="' ||TRIM("&ObsMaxPct")		||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=GROUPVAR     	VALUE="' ||TRIM("&GROUPVAR")	    	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=CORRTYPE     	VALUE="' ||TRIM("&CORRTYPE")	    	||'">'; PUT LINE; 
  		
		%Studies;

		/* Setup Plot edit fields for report type of SCATTER and CORR */
		%IF %SUPERQ(reportype) = SCATTER OR (%SUPERQ(reportype) = CORR AND %SUPERQ(CORRTYPE)=PLOT) %THEN %DO;
		    	PUT '<TABLE BGCOLOR="#ffffdd" ALIGN=CENTER WIDTH="100%" >';
		    	PUT '<TR><TD COLSPAN=3 ALIGN=left BGCOLOR="#003366"><STRONG><FONT FACE="Arial" COLOR="#FFFFFF">Edit Plot</FONT></STRONG></TD></TR>';
		    	PUT '<TR ><TD  halign=right VALIGN=CENTER>';

			/* Create text entry fields to change vertical axis values */
			PUT '<SMALL><FONT FACE="Arial">Vertical Axis:</FONT></SMALL></TD>';
		    	LINE= '<TD VALIGN=CENTER HALIGN=LEFT><SMALL><FONT FACE="Arial" >Min: </SMALL><INPUT TYPE="text" NAME="USERlowaxis" VALUE="'||
				COMPRESS("&lowaxis")||'" SIZE="6">'; PUT LINE;
		    	LINE= '<SMALL>Max: </SMALL><INPUT TYPE="text" NAME="USERupaxis" VALUE="'||COMPRESS("&upaxis")||'" SIZE="6">'; PUT LINE;
		    	LINE= '<SMALL>By: </SMALL><INPUT TYPE="text" NAME="USERaxisby" VALUE="'||COMPRESS("&axisby")||'"  SIZE="6">'; PUT LINE;
		    	LINE= '</TD><TD><SMALL><FONT FACE=ARIAL>Pixel Size: </FONT></SMALL>'; PUT LINE;
			LINE= '<SELECT NAME="Ypixels0" SIZE=1>'; PUT LINE;

			/* Create drop down boxes for changing vertical plot size (in pixels) */
			%IF %SUPERQ(YPIXELS0)=400 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		        LINE = '<OPTION '||"&SELECT"||' VALUE="400" SIZE="1">400</OPTION>'; PUT LINE;
			%IF %SUPERQ(YPIXELS0)=500 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
			LINE = '<OPTION '||"&SELECT"||' VALUE="500" SIZE="1">500</OPTION>'; PUT LINE;
			%IF %SUPERQ(YPIXELS0)=600 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
			LINE = '<OPTION '||"&SELECT"||' VALUE="600" SIZE="1">600</OPTION>'; PUT LINE;
			%IF %SUPERQ(YPIXELS0)=700 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
			LINE = '<OPTION '||"&SELECT"||' VALUE="700" SIZE="1">700</OPTION>'; PUT LINE;
			%IF %SUPERQ(YPIXELS0)=800 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
			LINE = '<OPTION '||"&SELECT"||' VALUE="800" SIZE="1">800</OPTION>'; PUT LINE;
			%IF %SUPERQ(YPIXELS0)=900 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
			LINE = '<OPTION '||"&SELECT"||' VALUE="900" SIZE="1">900</OPTION>'; PUT LINE;
			%IF %SUPERQ(YPIXELS0)=1000 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
			LINE = '<OPTION '||"&SELECT"||' VALUE="1000" SIZE="1">1000</OPTION>'; PUT LINE;
	 		LINE= '</SELECT> '; PUT LINE;
			LINE= '</TD></TR>'; PUT LINE;
     
		    	PUT '<TR><TD WIDTH="20%" halign=right VALIGN=CENTER >';
			/* Create text entry fields to change horizontal axis values */

			%IF %SUPERQ(TESTB)^=TESTDATE2 AND %SUPERQ(TESTB)^=CINUM %THEN %DO;
				PUT '<SMALL><FONT FACE="Arial" >Horizontal Axis:</FONT></SMALL></TD>';
		    		LINE= '<TD VALIGN=CENTER><SMALL><FONT FACE="Arial" >Min: </SMALL><INPUT TYPE="text" NAME="USERhlowaxis" VALUE="'||COMPRESS("&hlowaxis")||'" SIZE="6">'; PUT LINE;
		    		LINE= '<SMALL>Max: </SMALL><INPUT TYPE="text" NAME="USERhupaxis" VALUE="'||COMPRESS("&hupaxis")||'" SIZE="6">'; PUT LINE;
		    		LINE= '<SMALL>By: </SMALL><INPUT TYPE="text" NAME="USERhaxisby" VALUE="'||COMPRESS("&haxisby")||'"  SIZE="6"></TD>'; PUT LINE;
			%END;
			%ELSE %DO;	
				LINE= '</TD><TD>&nbsp;</TD>'; PUT LINE; 
			%END;

			LINE= '<TD VALIGN=CENTER><FONT FACE=ARIAL><SMALL>Pixel Size: </FONT></SMALL>'; PUT LINE;
			LINE= '<SELECT NAME="xpixels0" SIZE=1>'; PUT LINE;

			/* Create drop down boxes for changing horizontal plot size (in pixels) */
			%IF %SUPERQ(xPIXELS0)=700 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		        LINE = '<OPTION '||"&SELECT"||' VALUE="700" SIZE="1">700</OPTION>'; PUT LINE;
			%IF %SUPERQ(xPIXELS0)=800 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
			LINE = '<OPTION '||"&SELECT"||' VALUE="800" SIZE="1">800</OPTION>'; PUT LINE;
			%IF %SUPERQ(xPIXELS0)=900 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
			LINE = '<OPTION '||"&SELECT"||' VALUE="900" SIZE="1">900</OPTION>'; PUT LINE;
			%IF %SUPERQ(xPIXELS0)=1000 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
			LINE = '<OPTION '||"&SELECT"||' VALUE="1000" SIZE="1">1000</OPTION>'; PUT LINE;
 			LINE= '</SELECT> ';
			LINE= '</TD></TR>'; PUT LINE;

		    	VALUE=upcase("&VALUE");

			%GLOBAL DISABLE;
			%IF %SUPERQ(MAXTIMECHK)=0 %THEN %LET DISABLE=DISABLED=DISABLED;
		
			/* For Report type of SCATTER, add drop down fields to add regression lines and confidence bounds */
			%IF %SUPERQ(reportype)=SCATTER %THEN %DO;
		    		%IF %SUPERQ(VALUE)=MEAN OR %SUPERQ(VALUE)=INDIVIDUAL %THEN %DO;
					/* Setup regression line options, select current selection.  If only initial data, disable field. */
		        		PUT '<TR><TD COLSPAN=3 VALIGN=CENTER ALIGN=CENTER><SMALL><FONT FACE="Arial" >Regression:</FONT></SMALL>';
		        		LINE= '<SELECT NAME=reg0 SIZE=1 '||"&DISABLE"||'>'; PUT LINE;

		        		%IF %SUPERQ(reg0)=rl OR %SUPERQ(reg0)= %THEN %LET SELECT=selected; %ELSE %LET SELECT= ;	
		        		LINE= '<OPTION '||"&SELECT"||' VALUE="rl">Linear</OPTION>'; PUT LINE;

		        		%IF %SUPERQ(reg0)=rq %THEN %LET SELECT=selected; %ELSE %LET SELECT= ;
		        		LINE= '<OPTION '||"&SELECT"||' VALUE="rq">Quadratic</OPTION>'; PUT LINE;
	
		        		%IF %SUPERQ(reg0)=rc %THEN %LET SELECT=selected; %ELSE %LET SELECT= ;
	        			LINE= '<OPTION '||"&SELECT"||' VALUE="rc">Cubic</OPTION>'; PUT LINE;
	
		        		%IF %SUPERQ(reg0)=NONE %THEN %LET SELECT=selected; %ELSE %LET SELECT= ;
	        			LINE= '<OPTION '||"&SELECT"||' VALUE="NONE">None</OPTION>'; PUT LINE;	

		        		PUT '</SELECT>';

					/* Setup regression confidence bound options, select current selection.  If only initial data, disable field. */
					PUT '<SMALL><FONT FACE="Arial" >Confidence Bounds:</FONT></SMALL>';
	        			LINE= '<SELECT NAME=reg2 SIZE=1 '||"&DISABLE"||'>'; PUT LINE;
				
	        			%IF %SUPERQ(VALUE)=MEAN %THEN %DO; /* If plot is on mean, allow only mean confidence bounds */
	          				%IF %SUPERQ(reg2)=clm95 %THEN %LET SELECT=selected; %ELSE %LET SELECT= ;
	          				LINE= '<OPTION '||"&SELECT"||' VALUE="clm95">95% Mean Confidence Bounds</OPTION>'; PUT LINE;
	
						%IF %SUPERQ(reg2)=clm99 %THEN %LET SELECT=selected; %ELSE %LET SELECT= ;
		          			LINE= '<OPTION '||"&SELECT"||' VALUE="clm99">99% Mean Confidence Bounds</OPTION>'; PUT LINE;
        
		          			%IF %SUPERQ(reg2)=NONE or %SUPERQ(reg2)= %THEN %LET SELECT=selected; %ELSE %LET SELECT= ;
		         			LINE= '<OPTION '||"&SELECT"||' VALUE="NONE">None</OPTION>'; PUT LINE;	
		        		%END;

			        	%IF %SUPERQ(VALUE)=INDIVIDUAL %THEN %DO; /* If plot is on individuals, allow mean and prediction confidence bounds */
		        	  		%IF %SUPERQ(reg2)=clm95 %THEN %LET SELECT=selected; %ELSE %LET SELECT= ;	
		       		   		LINE= '<OPTION '||"&SELECT"||' VALUE="clm95">95% Mean Confidence Bounds</OPTION>'; PUT LINE;

			          		%IF %SUPERQ(reg2)=clm99 %THEN %LET SELECT=selected; %ELSE %LET SELECT= ;
			          		LINE= '<OPTION '||"&SELECT"||' VALUE="clm99">99% Mean Confidence Bounds</OPTION>'; PUT LINE;

			          		%IF %SUPERQ(reg2)=cli95 %THEN %LET SELECT=selected; %ELSE %LET SELECT= ;
			          		LINE= '<OPTION '||"&SELECT"||' VALUE="cli95">95% Individual Prediction Bounds</OPTION>'; PUT LINE;

			          		%IF %SUPERQ(reg2)=cli99 %THEN %LET SELECT=selected; %ELSE %LET SELECT= ;
			          		LINE= '<OPTION '||"&SELECT"||' VALUE="cli99">99% Individual Prediction Bounds</OPTION>'; PUT LINE;

			          		%IF %SUPERQ(reg2)=NONE or %SUPERQ(reg2)= %THEN %LET SELECT=selected; %ELSE %LET SELECT= ;
			          		LINE= '<OPTION '||"&SELECT"||' VALUE="NONE">None</OPTION>'; PUT LINE;	
		        		%END;
				
			        	PUT '</SELECT></TD>';
				       	PUT '</TR></TABLE>';
	      			%END; 
			%END;
	RUN;

	/* Create submit button and form to reset to plot default values */
    	DATA _NULL_; LENGTH LINE $1000; FILE _WEBOUT;
		PUT '<TABLE ALIGN=CENTER WIDTH="100%" BGCOLOR="#ffffdd"><TR><TD VALIGN=top ALIGN=right><INPUT TYPE="submit" VALUE="Update Plot" NAME="B1"></TD>';
  		PUT '</FORM><TD VALIGN=top ALIGN=left>';
		LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

		%THISSESSION;

		LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="' ||TRIM("&product")	       ||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=storage    VALUE="' ||TRIM("&storage")	       ||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="' ||TRIM(symget("testA"))   ||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="' ||TRIM("&stageA")	       ||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="' ||TRIM("&peakA")	       ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=testB      VALUE="' ||TRIM(symget("testB"))   ||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=stageB     VALUE="' ||TRIM("&stageB")	       ||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=peakB      VALUE="' ||TRIM("&peakB")	       ||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="' ||TRIM("&reportype")      ||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=VALUE      VALUE="' ||TRIM("&VALUE")          ||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="' ||TRIM("&reportype")      ||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=TIME  	    VALUE="' ||TRIM("&time")           ||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=GROUPVAR   VALUE="' ||TRIM("&GROUPVAR")       ||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=CORRTYPE   VALUE="' ||TRIM("&CORRTYPE")       ||'">'; PUT LINE; 

	    	%Studies;

 		PUT '<INPUT TYPE="submit" VALUE="Reset to Default" NAME="B1">';
  		PUT '</FORM></TD></TR></TABLE>';
	%END;

	%ELSE %IF %SUPERQ(reportype)=HISTIND %THEN %DO; /* Setup fields to edit histograms */
  		PUT   '<TABLE ALIGN=CENTER WIDTH="100%" BORDER="0"  BGCOLOR="#ffffdd">';
		/* Create fields for histogram midpoints, maximum percentage (display minimum possible percentage) */
  		PUT   '<TR ><TD COLSPAN=3 BGCOLOR="#003366"><STRONG><SMALL><FONT COLOR="FFFFFF" FACE="Arial">Histogram Midpoints:</FONT></SMALL></STRONG></TD>'; 
  		PUT   '<TD  BGCOLOR="#003366"><STRONG><SMALL><FONT COLOR="FFFFFF"  FACE="Arial">Max Percent:</FONT></SMALL></STRONG></TD>';
		PUT   '<TD COLSPAN=2 BGCOLOR="#003366"><STRONG><SMALL><FONT COLOR="FFFFFF"  FACE="Arial">Size (In Pixels):</FONT></SMALL></STRONG></TD>';
  		LINE= '<TR ><TD VALIGN=CENTER halign=left ><SMALL><FONT FACE="Arial">Min: </FONT></SMALL><INPUT TYPE="text" NAME="userlowaxis" VALUE="'||put(&lowaxis,6.2)||'" SIZE="6"></TD>'; PUT LINE;
  		LINE= '<TD VALIGN=CENTER halign=left><SMALL><FONT FACE="Arial">Max: </FONT></SMALL><INPUT TYPE="text" NAME="userupaxis" VALUE="'||put(&upaxis,6.2)||'" SIZE="6"></TD>'; PUT LINE;
  		LINE= '<TD VALIGN=CENTER halign=left><SMALL><FONT FACE="Arial">By: </FONT></SMALL><INPUT TYPE="text" NAME="useraxisby" VALUE="'||put(&axisby,6.2)||'"  SIZE="6"></TD>'; PUT LINE;
  		LINE= '<TD VALIGN=CENTER halign=left><INPUT TYPE="text" NAME="maxpercent" VALUE="'||COMPRESS("&maxpercent")||'" SIZE="3"><FONT FACE=ARIAL SIZE=2> *Must be at least '||TRIM("&obsmaxpct")||'</FONT></TD>'; PUT LINE;
  		
  		LINE= '<TD VALIGN=CENTER halign=left><SMALL><FONT FACE=ARIAL>X: </FONT></SMALL>'; PUT LINE;
		LINE= '<SELECT NAME="xpixels0" SIZE=1>'; PUT LINE;
		/* Create drop down boxes for plot size in pixels */
		%IF %SUPERQ(xPIXELS0)=700 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
	       	LINE = '<OPTION '||"&SELECT"||' VALUE="700" SIZE="1">700</OPTION>'; PUT LINE;
		%IF %SUPERQ(xPIXELS0)=800 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="800" SIZE="1">800</OPTION>'; PUT LINE;
		%IF %SUPERQ(xPIXELS0)=900 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="900" SIZE="1">900</OPTION>'; PUT LINE;
		%IF %SUPERQ(xPIXELS0)=1000 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="1000" SIZE="1">1000</OPTION>'; PUT LINE;
 		LINE= '</SELECT></TD>'; PUT LINE;
  		LINE= '<TD VALIGN=CENTER><SMALL><FONT FACE=ARIAL>Y: </FONT></SMALL>'; PUT LINE;
		LINE= '<SELECT NAME="Ypixels0" SIZE=1>'; PUT LINE;
		
		%IF %SUPERQ(YPIXELS0)=400 AND %SUPERQ(NUMROWS)<= 5 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="400" SIZE="1">400</OPTION>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=500 AND %SUPERQ(NUMROWS)<= 5 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="500" SIZE="1">500</OPTION>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=600 AND %SUPERQ(NUMROWS)<= 5 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="600" SIZE="1">600</OPTION>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=700 AND %SUPERQ(NUMROWS)<= 5 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="700" SIZE="1">700</OPTION>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=800 AND %SUPERQ(NUMROWS)<= 7 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="800" SIZE="1">800</OPTION>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=900 AND %SUPERQ(NUMROWS)<= 10 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="900" SIZE="1">900</OPTION>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=1000  %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="1000" SIZE="1">1000</OPTION>'; PUT LINE;
 		LINE= '</SELECT> '; PUT LINE;
		PUT '</TD></TR>';
		LINE='</TD></TR></TABLE>'; PUT LINE;
		/* Create submit button */
		PUT '<TABLE WIDTH="100%" BGCOLOR="#FFFFDD"><TR ><TD COLSPAN=3 VALIGN=top ALIGN=right><INPUT TYPE="submit" VALUE="Update Histogram" NAME="B1"></TD>';
		/* Create button to reset to default plot values */
		PUT '</FORM><TD COLSPAN=3 VALIGN=top ALIGN=left>';
		LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

		%THISSESSION;   		

		LINE= '<INPUT TYPE="hidden" NAME=product     VALUE="' ||TRIM("&product")       ||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=storage     VALUE="' ||TRIM("&storage")       ||'">'; PUT LINE; 
 		LINE= '<INPUT TYPE="hidden" NAME=testA       VALUE="' ||TRIM("&testA")	       ||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=stageA      VALUE="' ||TRIM("&stageA")	       ||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=peakA       VALUE="' ||TRIM("&peakA")	       ||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=reportype   VALUE="' ||TRIM("&reportype")     ||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=class       VALUE="' ||TRIM("&class")         ||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=analyst     VALUE="' ||TRIM("&analyst")       ||'">'; PUT LINE;
		LINE='<INPUT TYPE="hidden" NAME=TIME  	     VALUE="' ||TRIM("&time")          ||'">'; PUT LINE;

		%Studies;

		PUT   '<INPUT TYPE="submit" VALUE="Reset to Default" NAME="B1">';
  		PUT   '</FORM></TD></TR></TABLE>';
	%END;
	
	%IF %SUPERQ(reportype)=CIPROFILES %THEN %DO;   /* Setup fields to edit CI Profiles */
		/* Setup vertical axis text fields */
    		PUT '<TABLE BGCOLOR="#ffffdd" ALIGN=CENTER WIDTH="100%" >';
    		PUT '<TR><TD COLSPAN=2 ALIGN=left BGCOLOR="#003366"><STRONG><FONT FACE="Arial" COLOR="#FFFFFF">Edit Plot</FONT></STRONG></TD></TR>';
    		PUT '<TR ><TD WIDTH="20%" halign=right VALIGN=CENTER>';
	    	PUT '<SMALL><FONT FACE="Arial">Vertical Axis:</FONT></SMALL></TD>';
		
	    	LINE= '<TD VALIGN=CENTER><SMALL><FONT FACE="Arial" >Min: </SMALL><INPUT TYPE="text" NAME="USERlowaxis" VALUE="'||COMPRESS("&lowaxis")||'" SIZE="6">'; PUT LINE;
	    	LINE= '<SMALL>Max: </SMALL><INPUT TYPE="text" NAME="USERupaxis" VALUE="'||COMPRESS("&upaxis")||'" SIZE="6">'; PUT LINE;
	    	LINE= '<SMALL>By: </SMALL><INPUT TYPE="text" NAME="USERaxisby" VALUE="'||COMPRESS("&axisby")||'"  SIZE="6">'; PUT LINE;
    	
		LINE= '</TD></TR>'; PUT LINE;

	     	/* Setup drop down boxes to change plot size */
	    	PUT '<TR><TD WIDTH="20%" halign=right VALIGN=CENTER ><FONT FACE=ARIAL SIZE=2>Plot Size (in Pixels): </FONT></TD>';
	    	LINE= '<TD VALIGN=CENTER>'; PUT LINE;
	    	LINE= '<FONT FACE=ARIAL SIZE=2>X: </FONT>'; PUT LINE;
		LINE= '<SELECT NAME="xpixels0" SIZE=1>'; PUT LINE;
		
		%IF %SUPERQ(xPIXELS0)=700 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
	        LINE = '<OPTION '||"&SELECT"||' VALUE="700" SIZE="1">700</OPTION>'; PUT LINE;
		%IF %SUPERQ(xPIXELS0)=800 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="800" SIZE="1">800</OPTION>'; PUT LINE;
		%IF %SUPERQ(xPIXELS0)=900 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="900" SIZE="1">900</OPTION>'; PUT LINE;
		%IF %SUPERQ(xPIXELS0)=1000 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="1000" SIZE="1">1000</OPTION>'; PUT LINE;
 		LINE= '</SELECT> '; PUT LINE;
		LINE= '<FONT FACE=ARIAL SIZE=2>Y: </FONT>'; PUT LINE;
		LINE= '<SELECT NAME="Ypixels0" SIZE=1>'; PUT LINE;
		
		%IF %SUPERQ(YPIXELS0)=400 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
	        LINE = '<OPTION '||"&SELECT"||' VALUE="400" SIZE="1">400</OPTION>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=500 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="500" SIZE="1">500</OPTION>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=600 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="600" SIZE="1">600</OPTION>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=700 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="700" SIZE="1">700</OPTION>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=800 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="800" SIZE="1">800</OPTION>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=900 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="900" SIZE="1">900</OPTION>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=1000 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="1000" SIZE="1">1000</OPTION>'; PUT LINE;
 		LINE= '</SELECT> '; PUT LINE;
		LINE= '</TD></TR></TABLE>'; PUT LINE;

		/* Create submit button and form to reset to default */
		DATA _NULL_; LENGTH LINE $1000; FILE _WEBOUT;
		PUT '<TABLE ALIGN=CENTER WIDTH="100%" BGCOLOR="#ffffdd"><TR><TD VALIGN=top ALIGN=right><INPUT TYPE="submit" VALUE="Update Plot" NAME="B1"></TD>';
  		PUT '</FORM><TD VALIGN=top ALIGN=left>';
		LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

		%THISSESSION;  		

		LINE= '<INPUT TYPE="hidden" NAME=product      	VALUE="' ||TRIM("&product")	   ||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=storage      	VALUE="' ||TRIM("&storage")	   ||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=testA      	VALUE="' ||TRIM(symget("testA"))   ||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=stageA      	VALUE="' ||TRIM("&stageA")	   ||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=peakA      	VALUE="' ||TRIM("&peakA")	   ||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=reportype     	VALUE="' ||TRIM("&reportype")	   ||'">'; PUT LINE; 
  		LINE='<INPUT TYPE="hidden"  NAME=TIME  		VALUE="' ||COMPRESS("&time")       ||'">'; PUT LINE;

	    	%Studies;

 		PUT '<INPUT TYPE="submit" VALUE="Reset to Default" NAME="B1">';
  		PUT '</FORM></TD></TR></TABLE>';
	%END;

	%IF %SUPERQ(REPORTYPE)=PRODRELEASE AND %SUPERQ(DATACHKFLAG)^=STOP %THEN %DO;  /* Setup fields to edit product release run charts */
		PUT '<TABLE BGCOLOR="#ffffdd" ALIGN=CENTER WIDTH="100%" >';
	    	PUT '<TR><TD COLSPAN=4 ALIGN=left BGCOLOR="#003366"><STRONG><FONT FACE="Arial" COLOR="#FFFFFF">Edit Plot</FONT></STRONG></TD></TR>';
	    	PUT '<TR ><TD  halign=right VALIGN=CENTER>';
	    	PUT '<SMALL><FONT FACE="Arial">Vertical Axis:</FONT></SMALL></TD>';

		/* Create text fields to change vertical axis values */
	    	LINE= '<TD VALIGN=CENTER HALIGN=LEFT><SMALL><FONT FACE="Arial" >Min: </SMALL><INPUT TYPE="text" NAME="USERlowaxis" VALUE="'||COMPRESS("&lowaxis")||'" SIZE="6">'; PUT LINE;
	    	LINE= '<SMALL>Max: </SMALL><INPUT TYPE="text" NAME="USERupaxis" VALUE="'||COMPRESS("&upaxis")||'" SIZE="6">'; PUT LINE;
	    	LINE= '<SMALL>By: </SMALL><INPUT TYPE="text" NAME="USERaxisby" VALUE="' ||COMPRESS("&axisby")||'"  SIZE="6">'; PUT LINE;
	    	LINE= '</TD><TD><SMALL><FONT FACE=ARIAL>X Pixel Size: </FONT></SMALL>'; PUT LINE;
		LINE= '<SELECT NAME="Xpixels0" SIZE=1>'; PUT LINE;

		/* Create drop down boxes to change plot size */
		%IF %SUPERQ(XPIXELS0)=400 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
	        LINE = '<OPTION '||"&SELECT"||' VALUE="400" SIZE="1">400</OPTION>'; PUT LINE;
		%IF %SUPERQ(XPIXELS0)=500 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="500" SIZE="1">500</OPTION>'; PUT LINE;
		%IF %SUPERQ(XPIXELS0)=600 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="600" SIZE="1">600</OPTION>'; PUT LINE;
		%IF %SUPERQ(XPIXELS0)=700 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="700" SIZE="1">700</OPTION>'; PUT LINE;
		%IF %SUPERQ(XPIXELS0)=800 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="800" SIZE="1">800</OPTION>'; PUT LINE;
		%IF %SUPERQ(XPIXELS0)=900 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="900" SIZE="1">900</OPTION>'; PUT LINE;
		%IF %SUPERQ(XPIXELS0)=1000 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="1000" SIZE="1">1000</OPTION>'; PUT LINE;
 		LINE= '</SELECT> '; PUT LINE;
		LINE= '</TD><TD><SMALL><FONT FACE=ARIAL>Y Pixel Size: </FONT></SMALL>'; PUT LINE;
		LINE= '<SELECT NAME="Ypixels0" SIZE=1>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=400 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
	        LINE = '<OPTION '||"&SELECT"||' VALUE="400" SIZE="1">400</OPTION>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=500 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="500" SIZE="1">500</OPTION>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=600 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="600" SIZE="1">600</OPTION>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=700 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="700" SIZE="1">700</OPTION>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=800 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="800" SIZE="1">800</OPTION>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=900 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="900" SIZE="1">900</OPTION>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=1000 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="1000" SIZE="1">1000</OPTION>'; PUT LINE;
 		LINE= '</SELECT></td> '; PUT LINE;
		PUT '</TR>'; PUT LINE;

		/* Create submit buttons and a form to reset plot to default */
		PUT '<TABLE ALIGN=CENTER WIDTH="100%" BGCOLOR="#ffffdd"><TR><TD VALIGN=top ALIGN=right><INPUT TYPE="submit" VALUE="Update Plot" NAME="B1"></TD>';
  		PUT '</FORM><TD VALIGN=top ALIGN=left>';
		LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

		%THISSESSION;

		LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="' ||TRIM("&product")	       	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=storage    VALUE="' ||TRIM("&storage")	       	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="' ||TRIM("&testA")	       	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="' ||TRIM("&stageA")	       	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="' ||TRIM("&peakA")	       	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="' ||TRIM("&reportype")	||'">'; PUT LINE; 

  		%Studies;

 		PUT '<INPUT TYPE="submit" VALUE="Reset to Default" NAME="B1">';
  		PUT '</FORM></TD></TR></TABLE>';
	%END;
		 	
		/* Create HTML to make footer banner */
		PUT '</TD></TR><TR  ALIGN="right" HEIGHT="8%"><TD COLSPAN=2 BGCOLOR="#003366">';
	 	LINE = '<A HREF="//'||SYMGET('_server')||'/links/'||"&SAVE_linkshome"||'.ASP?UserRole='|| "%SUPERQ(Save_UserRole)" ||'">
		<FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Home</FONT></a>&nbsp&nbsp'; PUT line;

		anchor= '<A HREF="'|| "%superq(_THISSESSION)" || 
			'&_program='||"LINKS.LRLogoff.sas"||
			'"><FONT FACE=ARIAL COLOR="#FFFFFF">Log off</FONT></A>'; 
		PUT anchor; 
		PUT '</TD></TR></TABLE><BIG><BIG>';
	
	RUN;
%MEND Webout2;

****************************************************************************************************;
*                                      MODULE HEADER                                               *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;
*	REQUIREMENT     : See LINKS Report SOP                                                     *;
*       INPUT           : MACRO VARIABLES: REPORTYPE2, DATACHECK1A, DATACHECK1B,                   *; 
*		          DATACHECK2A, DATACHECK2B, DATACHECK3, PRINT, REPORTYPE                   *;
*       PROCESSING      : This macro decides on the program flow depending on                      *;
*		          the values of certain parameters.                                        *;
*       OUTPUT          : Report to screen or RTF file.                                            *;
****************************************************************************************************;

%MACRO LRSTANALYSIS;
%Put _All_;	

	%IF %SUPERQ(REPORTYPE2)=STUDYDESC %THEN %STUDYDESC;  /* If report = STUDYDESC then execute STUDYDESC macro */
	%ELSE %DO;  /* Otherwise do the following */
		%INIT;  /* Execute INIT macro */
		%IF %SUPERQ(datacheck0)^=GO %THEN %DO;
			DATA _NULL_; LENGTH LINE $500; FILE _WEBOUT;										/* Print warning */
				LINE='<BODY BGCOLOR="#C0C0C0"></BR></BR></BR><TABLE VALIGN=CENTER ALIGN=CENTER WIDTH="75%"><TR ><TD ROWSPAN=2 ALIGN=CENTER >'; PUT LINE;
				LINE='<IMG SRC="//'||"&_server"||'/links/images/j02702421.wmf" WIDTH="175" HEIGHT="200"></TD>'; PUT LINE;
    				LINE='<TD ><TABLE><TR><TD BGCOLOR="#FF0000"><FONT FACE=ARIAL SIZE=10 COLOR=WHITE><STRONG>No valid data exists.</STRONG><FONT></TD></TR>'; PUT LINE;
				LINE='<TR><TD ALIGN=CENTER><FONT FACE=ARIAL SIZE=5 COLOR=BLACK><STRONG>Please contact a LINKS Administrator.</STRONG><FONT></TD></TR></TABLE></TD></TR></TABLE>'; PUT LINE;
    			RUN;
		%END;  
		%ELSE %DO;  
			%SUBSET1;  /* Execute Subset1 macro */
			%IF %SUPERQ(datacheck1A)^=GO OR %SUPERQ(DATACHECK1B)^=GO %THEN %DO;
				DATA _NULL_; LENGTH LINE $500; FILE _WEBOUT;								
					LINE='<BODY BGCOLOR="#C0C0C0"></BR></BR></BR><TABLE VALIGN=CENTER ALIGN=CENTER WIDTH="75%"><TR ><TD ROWSPAN=2 ALIGN=CENTER >'; PUT LINE;
					LINE='<IMG SRC="//'||"&_server"||'/links/images/j02702421.wmf" WIDTH="175" HEIGHT="200"></TD>'; PUT LINE;
    					LINE='<TD ><TABLE><TR><TD BGCOLOR="#FF0000"><FONT FACE=ARIAL SIZE=10 COLOR=WHITE><STRONG>No valid data exists for the query selections.</STRONG><FONT></TD></TR>'; PUT LINE;
					LINE='<TR><TD ALIGN=CENTER><FONT FACE=ARIAL SIZE=5 COLOR=BLACK><STRONG>Please use the back button to change your selection.</STRONG><FONT></TD></TR></TABLE></TD></TR></TABLE>'; PUT LINE;
	    			RUN;
			%END;
			%ELSE %DO;
				%SUBSET2;  /* If data does exist from Subset1, execute Subset2 */
				%IF %SUPERQ(datacheck2A)^=GO OR %SUPERQ(DATACHECK2B)^=GO %THEN %DO;
					DATA _NULL_; LENGTH LINE $500; FILE _WEBOUT;									
						LINE='<BODY BGCOLOR="#C0C0C0"></BR></BR></BR><TABLE VALIGN=CENTER ALIGN=CENTER WIDTH="75%"><TR ><TD ROWSPAN=2 ALIGN=CENTER >'; PUT LINE;
						LINE='<IMG SRC="//'||"&_server"||'/links/images/j02702421.wmf" WIDTH="175" HEIGHT="200"></TD>'; PUT LINE;
    						LINE='<TD ><TABLE><TR><TD BGCOLOR="#FF0000"><FONT FACE=ARIAL SIZE=10 COLOR=WHITE><STRONG>No valid data exists for the query selections.</STRONG><FONT></TD></TR>'; PUT LINE;
						LINE='<TR><TD ALIGN=CENTER><FONT FACE=ARIAL SIZE=5 COLOR=BLACK><STRONG>Please use the back button to change your selection.</STRONG><FONT></TD></TR></TABLE></TD></TR></TABLE>'; PUT LINE;
    					RUN;
				%END;
				%ELSE %DO;
					%SUBSET3;   /* If data does exist from Subset2, execute Subset3 */
					%IF %SUPERQ(datacheck3)^=GO %THEN %DO;	
						DATA _NULL_; LENGTH LINE $500; FILE _WEBOUT;									
							LINE='<BODY BGCOLOR="#C0C0C0"></BR></BR></BR><TABLE VALIGN=CENTER ALIGN=CENTER WIDTH="75%"><TR ><TD ROWSPAN=2 ALIGN=CENTER >'; PUT LINE;
							LINE='<IMG SRC="//'||"&_server"||'/links/images/j02702421.wmf" WIDTH="175" HEIGHT="200"></TD>'; PUT LINE;
    							LINE='<TD ><TABLE><TR><TD BGCOLOR="#FF0000"><FONT FACE=ARIAL SIZE=10 COLOR=WHITE><STRONG>No data exists for the query selections.</STRONG><FONT></TD></TR>'; PUT LINE;
							LINE='<TR><TD ALIGN=CENTER><FONT FACE=ARIAL SIZE=5 COLOR=BLACK><STRONG>Please use the back button to change your selection.</STRONG><FONT></TD></TR></TABLE></TD></TR></TABLE>'; PUT LINE;
    						RUN;
					%END;
					%ELSE %DO;
						%SETUP;  /* If data does exist from Subset3, execute Setup */
			
						/* If user has chosen to print, execute Print macro, Otherwise execute Webout macro */
						%IF %SUPERQ(print)=ON AND %SUPERQ(reportype)^=CORR %THEN %PRINT;  
						%ELSE %IF %SUPERQ(print)^=ON %THEN %WEBOUT;	
     
						/* Execute corresponding macro depending on value of reportype */
						%IF %SUPERQ(reportype)=HISTIND %THEN %HIST;		
   				 		%ELSE %IF %SUPERQ(reportype)=SUMSTATS %THEN %SUMSTATS;       
   						%ELSE %IF %SUPERQ(reportype)=SCATTER %THEN %SCATTERPLOT;
   						%ELSE %IF %SUPERQ(reportype)=CORR %THEN %CORR;
   						%ELSE %IF %SUPERQ(reportype)=CIPROFILES %THEN %CIPROFILES;
						%ELSE %IF %SUPERQ(reportype)=PRODRELEASE %THEN %PRODRELEASE;

						&close;  /* Close ODS statement */

						%IF %SUPERQ(print)^=ON %THEN %Webout2;  /* If output is going to web browser, execute Webout2 */
					%END;
				%END;
			%END;
		%END;
		/* Save variables from current run for comparison to future runs */
		%LET save_prodinit=&product;
		%LET save_condinit=&storage;
		%LET save_testinit=&testA;
		%LET save_staginit=&stageA;
		%LET save_peakinit=&PeakA;
		
	%END;

%MEND LRSTANALYSIS;

%LRSTANALYSIS;

