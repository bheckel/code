****************************************************************************************************;
*                     PROGRAM HEADER                                                               *;
*--------------------------------------------------------------------------------------------------*;
*  PROJECT NUMBER:  LINKS POT0301                                                                  *;
*  PROGRAM NAME: LRBatchAnalysis.SAS               SAS VERSION: 8.2                                *;
*  DEVELOPED BY: Carol Hiser                       DATE: 11/21/2002                                *;
*  PROJECT REPRESENTATIVE: Carol Hiser                                                             *;
*  PURPOSE: Prompts the user to select study analysis, then generates report(s)                    *;
*  SINGLE USE OR MULTIPLE USE? (SU OR MU) MU                                                       *;
*  PROGRAM ASSUMPTIONS OR RESTRICTIONS: All documentation for this program                         *;
*	is covered under the LINKS report SOP.                                                     *;
*--------------------------------------------------------------------------------------------------*;
*  OTHER SAS PROGRAMS, MACROS OR MACRO VARIABLES USED IN THIS                                      *;
*  PROGRAM:   None.                                                                                *;
*--------------------------------------------------------------------------------------------------*;
*  DESCRIPTION OF OUTPUT:  Output can consist of 7 report types:	                           *;	
*	Scatterplot over Time, Histogram of Individual Results, Summary Statistics                 *; 
*	Table, Initial Data vs. Product Release Run Chart, Cascade Impaction 	                   *;	
*	Profiles, Study Details.                                                                   *;
*   Report can be printed to the screen or as an RTF file.	                                   *;
*--------------------------------------------------------------------------------------------------*;
****************************************************************************************************;
*                      HISTORY OF CHANGE                                                           *;
*-------------+---------+---------------+----------------------------------------------------------*;
*     DATE    | VERSION | NAME         	| Description                                              *;
*-------------+---------+---------------+----------------------------------------------------------*;
*  11/10/2003 |   1.0   | James Becker 	| Original                                                 *;
*--------------------------------------------------------------------------------------------------*;
*  13JUN2006  |   2.0   | Carol Hiser   | VCC45936 - Revised to reflect new dataset structure from *;
*             |         |               |            LRQuery.                                      *;
*             |         |               |          - Removed LRQueryRes_SPECS and                  *;
*             |         |               |            LRQueryRes_Relationship dataset files.        *;
*             |         |               |          - Removed RSD Data                              *;
*             |         |               |          - Change Test if user changes Product           *;
*             |         |               |          - Revised Axis for graphs                       *;
*             |         |               |          - Change Option to Landscape for PRODSTATS      *;
*--------------------------------------------------------------------------------------------------*;
*  18Jun2006  |  3.0    | Carol Hiser   | VCC45936 - Modified Batch Summary Table to fix missing   *;
*             |         |               |            header when batch genealogy is missing.       *; 
*--------------------------------------------------------------------------------------------------*;
*  30Oct2006  |  4.0    | Carol Hiser   | VCC55049 -Modified tables to be labeled as Ppk           *;
*             |         |               |          -Fixed specification issue                      *;
*             |         |               |          -Changed default to data defined 3 sigma limits *; 
*--------------------------------------------------------------------------------------------------*;
*  22JAN2007  |  5.0    | James Becker  |  VCC53434 %Reports                                       *;
*             |         |               |   - Modified Reading in new Spec File                    *;
*--------------------------------------------------------------------------------------------------*;
*  08FEB2007  |  6.0    | James Becker  |  VCC53434                                                *;
*             |         |               |   - %XBAR Added code to produce missing footnotes        *;
*             |         |               |   - %BATCHSTATS modified code to produce missing         *;
*             |         |               |     footnotes                                            *;
*--------------------------------------------------------------------------------------------------*;
*  13FEB2007  |  7.0    | James Becker  |  VCC53434                                                *;
*             |         |               |   - %SBAR       - fixed code to produce missing report   *;
*             |         |               |   - %SUBSET2    - UPCASED Stage variable for %CIPROFILES *;
*             |         |               |   - %BATCHSTATS - fixed code to set to 4 decimal places  *;
*--------------------------------------------------------------------------------------------------*;
*  20FEB2007  |  8.0    | James Becker  |  VCC57135                                                *;
*             |         |               |   - %INIT       - added PEAKACHK='NONE' to fix peaks     *;
*--------------------------------------------------------------------------------------------------*;
*  21APR2007  |  9.0    | James Becker  |  VCC57535                                                *;
*             |         |               |   - %Init       - modified string used to determine      *;
*             |         |               |                   which methods need Impaction Profile   *;
*             |         |               |   - %Setup      - added error trap for single batches    *;
*             |         |               |                 - modified CIPROFILES to handle other    *;
*             |         |               |                   MDI/MDPI products                      *;
*             |         |               |                 - Added SORT to delete duplicates for    *;
*             |         |               |                   Relenza Cascade Methods                *;
*             |         |               |   - %CIProfiles - modified GPLOT parms to handle other   *;
*             |         |               |                   MDI/MDPI products                      *;
****************************************************************************************************;
* 		Setup Module	 		      		     	                           *;
****************************************************************************************************;
%LET METHOD=GET;
OPTIONS spool number nodate mlogic mprint symbolgen mautosource source source2 pageno=1 compress=yes; 

%GLOBAL DATATYPE vref href print warning warning2 study product test values vaxis0 haxis0 NUMALLSTUDY
	reg study0 byvar check save_product save_testA save_storage save_studysub2 save_reportype 
	lowaxis upaxis axisby hlowaxis hupaxis haxisby xpixels0 ypixels0 xpixels ypixels reg0 reg2 reportype VALUE time 
	RPTVALUE stageA stageB peakA PeakB numanalyst numtimes save_stageinit save_peakinit maxpercent save_rptinit
        datacheck DATACHECK0 cirptvalue testa testb storage save_testinitb save_testinit groupvar corrtype NUMSTAGEA
	TESTRPT SAVE_TESTRPTINIT OBSMAXPCT CILOWAXIS CIUPAXIS CIAXISBY INSETN INSETMEAN INSETSTD INSETMIN INSETMAX 
	INSETPNORMAL INSETCPK INSETPOS NORMAL USERLOWAXIS USERUPAXIS USERAXISBY USERHLOWAXIS USERHUPAXIS USERHAXISBY
	save_prodinit save_staginit save_peakinit INVALIDLIMITS SPECCHKI SPECCHKM METHOD
	HAXISCHK VAXISCHK BATCH SORTVALUE CTLLIMITS USERLCL USERUCL USERBAR STARTMONTH STARTDAY STARTYEAR
	ENDMONTH ENDDAY ENDYEAR DATECHECK reportype2 resulttype datachkflg NOSAMPDT SAVE_USERROLE SAVE_LINKSHOME
	ucl lcl bar  NORECORDS UNAPPFLAG Low_error Upr_Error Err_Axis LowRefLine UprRefLine SpecVal RefWarning
	;

****************************************************************************************************;
*                                      MODULE HEADER                                               *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;
*	     REQUIREMENT: See LINKS Report SOP                                                     *;
*       INPUT           : DATASET save.LRQueryRes_Database                                         *;
*       PROCESSING      : Setup initial macro variables. Create a macro Varlist                    *;
*		          to create lists of macro variables for a given dataset and variable.     *;  
*		          Generate a list of all products, storage conditions and test methods.    *; 
*       OUTPUT          : Initial macro variables.  Dataset LRQueryRes.                            *;
****************************************************************************************************;
	
%MACRO INIT;
	PROC FORMAT;
		PICTURE trnc4D  0-high=" 0009.9999" 
				low-<0=" 0009.9999" (PREFIX='-');
   		PICTURE trnc3D  0-high=" 0009.999" 
				low-<0=" 0009.999" (PREFIX='-');
   		PICTURE trnc2D  0-high=" 0009.99"
				low-<0=" 0009.99"  (PREFIX='-');
   		PICTURE trnc1D  0-high=" 0009.9" 
				low-<0=" 0009.9"   (PREFIX='-');
	RUN;

	%LET SAVE_LINKSHOME=User_HomePage;
	
/*
	PROC SORT DATA=SAVE.LRQUERYRES_BATCHES(WHERE=(STABILITY_STUDY_NBR_CD = '')) OUT=TEST NODUPKEY;BY SAMP_STATUS;RUN;
*/
	DATA LRQUERYRES; SET SAVE.LRQUERYRES_BATCHES(WHERE=(STABILITY_STUDY_NBR_CD = ''));
		/*IF UPCASE(COMPRESS(Lab_Tst_Meth_Spec_Desc)) IN ('HPLCASSAYADVAIRMDPIBLENDS','ADVAIRCONTENTPERBLISTER','CUOFEMITTEDDOSEINADVAIRMDPI')
			THEN RESULT=INDVL_TST_RSLT_VAL_UNIT;
			ELSE RESULT=INDVL_TST_RSLT_VAL_NUM;*/
		IF UPCASE(COMPRESS(Lab_Tst_Meth_Spec_Desc)) IN ('HPLCASSAYADVAIRMDPIBLENDS','CUOFEMITTEDDOSEINADVAIRMDPI')
			THEN RESULT=INDVL_TST_RSLT_VAL_UNIT;
			ELSE RESULT=INDVL_TST_RSLT_VAL_NUM;

		IF UPCASE(LAB_TST_METH_SPEC_DESC) IN ('HPLC RELATED IMP.') THEN LAB_TST_METH_SPEC_DESC='HPLC Related Impurities';

		IF INDEXW(LAB_TST_DESC, 'RSD')>0 THEN DELETE;

		LAB_TST_DESC2=UPCASE(LAB_TST_DESC);
		*IF INDEXW(LAB_TST_DESC2, 'RSD')>0 THEN DELETE;  /* V2 - REMOVED RSD DATA */
		
		/*** Delete individual missing results ***/
		IF RESULT = . THEN DELETE;
		/*** If product is missing then delete ***/
		IF UPCASE(STABILITY_SAMP_PRODUCT) = 'ADVAIR DISKUS' THEN DELETE;

		/*** Delete non-numeric test methods   ***/
		IF COMPRESS(UPCASE(LAB_TST_METH_SPEC_DESC)) IN 
		('MLTFORMDPISTRIPS', 'ADVAIRDISKUSAPPEARANCE', 'MDPIMICROSCOPICEVALUATION', 'ADVAIRMDPIIDBYUV','SIOMDPIBLENDS', 'APPEARANCE') THEN DELETE;
		/*** Include only approved data ***/
		%IF %SUPERQ(DATATYPE)=APP %THEN %DO;  
			IF SAMP_STATUS = '17';  /* Modified V ? */
		%END;

		
	RUN;
/**
	PROC SORT DATA=SAVE.LRQUERYRES_BATCHES OUT=OUTRES NODUPKEY;BY STABILITY_STUDY_NBR_CD Samp_Status;RUN;
**/
	DATA _NULL_; SET LRQueryRes; 
		RETAIN obs 0;			/*** Check to see if this is the first execution of the program, if so setup initial ***/
		INITCHK0="&PRODUCT";  	/*** product, condition and test method macro variables  ***/
		
		INITCHK1="&SAVE_STAGINIT";
		INITCHK2="&SAVE_PEAKINIT";
		INITCHK3="&SAVE_TESTINIT";

		obs=obs+1; 
		IF obs=1 AND INITCHK0 ='' THEN DO;
			CALL SYMPUT('save_prodinit', TRIM(STABILITY_SAMP_PRODUCT));
			CALL SYMPUT('PRODUCT', TRIM(STABILITY_SAMP_PRODUCT));
			PUT STABILITY_SAMP_PRODUCT lab_tst_meth_spec_desc indvl_meth_stage_nm meth_peak_nm;
			END;
		IF obs=1 AND INITCHK1 ='' THEN CALL SYMPUT('save_staginit', TRIM(INDVL_METH_STAGE_NM));
		IF obs=1 AND INITCHK2 ='' THEN CALL SYMPUT('save_peakinit', TRIM(METH_PEAK_NM));
  		IF obs=1 AND INITCHK3 ='' THEN CALL SYMPUT('save_testinit', TRIM(LAB_TST_METH_SPEC_DESC));
		
		IF OBS=1 THEN CALL SYMPUT('TESTINIT',TRIM(LAB_TST_METH_SPEC_DESC));
		CALL SYMPUT('DATACHECK0','GO');  /*** Check for valid data ***/
	RUN;
	
	%IF %SUPERQ(DATACHECK0)=GO %THEN %DO;
		%GLOBAL today rpttime IMPFLAG CIFLAG;  
		/*** Create macros for date and time for use in footnotes ***/
		DATA _NULL_;  
	   		CALL SYMPUT('today',	TRIM(left(put(today(),worddate.))));
	   		CALL SYMPUT('rpttime', 	TRIM(left(put(time(),timeampm9.))));
		RUN;

		DATA _NULL_; /***  Setup initial macro values ***/
                ****************************************************************************************************;
		*** If first execution of the program, set variable product, storage and testa to init variables ***;
		*** and set report to XBAR		                                                         ***;
                ****************************************************************************************************;
			*product="&product";		*IF product='' 	     THEN CALL SYMPUT("PRODUCT","&save_prodinit");
			testA="&testa";  		IF testA='' 	     THEN CALL SYMPUT("testA",symget('save_testinit'));
			report="&reportype";		IF report='' 	     THEN CALL SYMPUT('reportype','XBAR');
			IF TESTA = 'ALL' AND REPORT NOT IN ('PRODSTATS','BATCHSTATS', 'XBAR') THEN CALL SYMPUT('TESTA',"&TESTINIT");
		/*** Set Scatterplot variable VALUE to MEAN if not specified                                      ***/
			IF REPORT = 'BATCHSTATS' THEN DO;
			   VALUE="&VALUE";		IF VALUE='' 	     THEN CALL SYMPUT('VALUE','SUMMARY');
			   						IF VALUE='ALLTESTS'  THEN CALL SYMPUT('BATCH', ''); /* ADDED V3 */
			END;
			ELSE DO;
			   VALUE="&VALUE";		IF VALUE='' 	     THEN CALL SYMPUT('VALUE','MEAN');
			END;

		/*** If no report value is specified, set it to MEAN                                              ***/
			rptvalue="&RPTVALUE";		IF RPTVALUE=''       THEN CALL SYMPUT('rptvalue','MEAN');

		/*** Setup Correlation variables to default if not specified                                      ***/
			corrtype="&corrtype";		IF corrtype='' 	     THEN CALL SYMPUT('corrtype','PLOT');
			groupvar="&groupvar";		IF groupvar='' 	     THEN CALL SYMPUT('groupvar','NONE');

		/*** Set horizontal and vertical axis flags if user has entered custom axis values                ***/
			USERHLOWAXIS="&USERHLOWAXIS";  	IF USERHLOWAXIS^=''  THEN CALL SYMPUT('HAXISCHK','USER');
			USERHUPAXIS ="&USERHUPAXIS";   	IF USERHUPAXIS^=''   THEN CALL SYMPUT('HAXISCHK','USER');
			USERHAXISBY ="&USERHAXISBY";   	IF USERHAXISBY^=''   THEN CALL SYMPUT('HAXISCHK','USER');
		
			USERLOWAXIS="&USERLOWAXIS";  	IF USERLOWAXIS^=''   THEN CALL SYMPUT('VAXISCHK','USER');
			USERUPAXIS ="&USERUPAXIS";   	IF USERUPAXIS^=''    THEN CALL SYMPUT('VAXISCHK','USER');
			USERAXISBY ="&USERAXISBY";   	IF USERAXISBY^=''    THEN CALL SYMPUT('VAXISCHK','USER'); 

			SORTVALUE="&SORTVALUE";		IF SORTVALUE=''      THEN CALL SYMPUT('SORTVALUE','MATL_MFG_DT');
			CTLLIMITS="&CTLLIMITS";		IF CTLLIMITS=''	     THEN CALL SYMPUT('CTLLIMITS','DEFAULT');  /* Modified V4 */
		RUN;

		DATA _NULL_; 
		/*** Added V2 - If the user has changed the product, change test                                ***/
			productchk1=COMPRESS("&save_prodinit");		productchk2=COMPRESS("&product");  

			IF (productchk1 ^= productchk2) THEN DO;  
					CALL SYMPUT('BATCH',' ');  *Clears out batch parameter if user changes product;
	    			CALL SYMPUT('testA',' ');	
					CALL SYMPUT('stageA',' ');	
					CALL SYMPUT('peakA',' ');
					END;
		RUN;

		DATA _NULL_;
			PEAKACHK=UPCASE(COMPRESS("&PEAKA"));  		PEAKBCHK=UPCASE(COMPRESS("&PEAKB"));
			STAGEACHK=UPCASE(COMPRESS("&STAGEA"));  		STAGEBCHK=UPCASE(COMPRESS("&STAGEB"));
			STAGEACHK2=UPCASE(COMPRESS("&SAVE_STAGEINIT"));
	 	 	valuechk=UPCASE(COMPRESS("&VALUE"));		
			test1chk1=COMPRESS("&save_testinit");	  	test1chk2=COMPRESS("&testA");  test2chk2=COMPRESS("&testb");
			/*** Setup flag of CI test method                         ***/
/***			IF test1chk2 IN ("HPLCAdvairMDPlCas.Impaction") THEN CALL SYMPUT('CIFLAG','YES'); 	***/
                        /* v9 */
			IF index(test1chk2, "Impaction") THEN CALL SYMPUT('CIFLAG','YES'); 	
                        /*** If user changes test, reset stage and peak variables ***/
			IF (test1chk1 ^= test1chk2) OR (test1chk1='ALL' AND valuechk='ALLTESTS') THEN DO;  
	    			CALL SYMPUT('stageA',' ');	
				CALL SYMPUT('peakA',' ');
			END; 
       		 	***********************************************************************************;
			*** V8 - Added PEAKACHK='NONE' to prevent graph from not switching peaks        ***;
		        ***********************************************************************************;
			IF TEST1CHK2 = 'Content' THEN DO;
				IF STAGEACHK IN ('WT','WEIGHT') then CALL SYMPUT('peakA',' ');
				IF STAGEACHK2 IN ('WT','WEIGHT','') AND STAGEACHK NOT IN ('WT','WEIGHT') AND PEAKACHK='NONE' THEN CALL SYMPUT('peakA',' ');
			END;
			********************************************;
			*** Setup flag for impurity test method  ***;
			*** Set peak variables to null           ***;
			********************************************;
			IF test1chk2 IN ('HPLCRelatedImp.InAdvairMDPI') THEN DO;
				CALL SYMPUT('IMPFLAG','YES');  		
		         	CALL SYMPUT('PEAKA','');	
				CALL SYMPUT('PEAKB','');  		
			END;

			CALL SYMPUT('INVALIDMAXAXIS','');
			IF test1chk2 IN ('ForeignParticulateMatter') AND PEAKACHK = 'TOTALNUMBEROFPARTICLES' THEN CALL SYMPUT('STAGEA','Totals');
			IF test2chk2 IN ('ForeignParticulateMatter') AND PEAKBCHK = 'TOTALNUMBEROFPARTICLES' THEN CALL SYMPUT('STAGEB','Totals');
		RUN;

		/*** If testb is not specified, set testb, stageb and peakb variables to testa, stagea and peaka          ***/
		DATA _NULL_;  
			testB="&testB";		TESTA="&TESTA";		REPORTYPE="&REPORTYPE";
			IF testB='' 		THEN DO;
				CALL SYMPUT("testB",TRIM("&testA")); 
				CALL SYMPUT("stageB","&stageA");
				CALL SYMPUT("peakB","&peakA");
			END;
			IF TESTA ^= TESTB THEN DO;
				  	IF REPORTYPE= 'CORR' THEN CALL SYMPUT('VALUE','MEAN');
	    		END;
		RUN;

		%GLOBAL RHTEMPFLG ;
		DATA _NULL_;   
	  		CIFLAG="&CIFLAG"; 	TEST2=UPCASE("&TESTB"); 
                        *************************************************************************************************************;
			*** Reset testb, stageb and peakb variables if testa is not CI and testb is temp or RH since temp and RH  ***;
			*** data is only available for the Cascade Impaction test                                                 ***;
                        *************************************************************************************************************;
			/*** Set flag if testa is CI and testb is temperature or humidity                                ***/
			IF  CIFLAG^='YES' AND TEST2 IN ('TEMPERATURE', 'RH') THEN DO;
				CALL SYMPUT('TESTB', TRIM("&TESTA"));
				CALL SYMPUT("stageB",TRIM("&stageA"));
				CALL SYMPUT("peakB", TRIM("&peakA"));
			END;                                   
			ELSE IF CIFLAG='YES' AND TEST2 IN ('TEMPERATURE','RH','CINUM') THEN DO;  
				CALL SYMPUT('RHTEMPFLG','YES');
			END;
		RUN;

		/***  Setup macro values for use in where statements                                                     ***/
		DATA _NULL_;   
		   	CALL SYMPUT('TestAnew',	COMPRESS("&testA"));
		 	CALL SYMPUT('TestBnew',	COMPRESS("&testB"));
		  	CALL SYMPUT('StageAnew',COMPRESS("&stageA", '- '));
		  	CALL SYMPUT('StageBnew',COMPRESS("&stageB", '- '));
		  	CALL SYMPUT('PeakAnew',	COMPRESS("&peakA"));
	 	 	CALL SYMPUT('PeakBnew',	COMPRESS("&peakB"));
		RUN;
		%global whereprod;
		/***  Create macro for creating a macro list of a given variable                                         ***/
		%MACRO VarList;   
			%GLOBAL NUM&var2 ;

			PROC SORT DATA=&DATA NODUPKEY OUT=varlist1; BY &byvar; RUN;     /*** Generate unique list          ***/

			DATA VARLIST2; SET VARLIST1 &whereprod; RUN;

			DATA varlist2; SET varlist2  NOBS=num&var2 ; BY &byvar ;   /* added V2 */
	    		RETAIN obs 0;
				obs=obs+1; OUTPUT;			
				CALL SYMPUT("num&var2",num&var2);
			RUN;

			/*** Create macro variable for each value in unique list                                         ***/
			%DO i = 1 %TO &&num&var2;  
			%GLOBAL &var2&i ;
				DATA _NULL_; SET varlist2;
					WHERE obs=&i ;
					CALL SYMPUT("&var2&i",TRIM(&var));
				RUN;
			%END;
		
		%MEND VARLIST;

		%LET byvar= STABILITY_SAMP_PRODUCT; %LET var=STABILITY_SAMP_PRODUCT;	%LET var2=PRODUCT;	%LET DATA=LRQueryRes; 	%varlist;  /*** Create list of products ***/
		%LET byvar=STABILITY_SAMP_PRODUCT lab_tst_meth_spec_desc;	%LET var=lab_tst_meth_spec_desc; %LET var2= test;		%let whereprod= (where= (STABILITY_SAMP_PRODUCT="&product")); /*added V2 */ %LET DATA=LRQueryRes; 	%varlist;  /*** Create list of tests    ***/

		%IF %SUPERQ(TESTA)= %THEN %DO;

			DATA _NULL_;  
				CALL SYMPUT('TESTA', "&TEST1");  /* Modified V4 (removed compress) */
				CALL SYMPUT('TESTANEW', COMPRESS("&TEST1"));
             	                CALL SYMPUT('TESTB', "&TEST1");/* Modified V4 (removed compress) */
				CALL SYMPUT('TESTBNEW', COMPRESS("&TEST1"));
			 %END;

		%GLOBAL INVALIDHAXIS INVALIDVAXIS;	/***  Check to see if user entered valid vertical and horizontal axis values ***/
		%LET INVALIDHAXIS=;
		%LET INVALIDVAXIS=;
		/*** If not, set invalid axis flag ***/
		DATA _NULL_; LENGTH HINVALIDNUM1 HINVALIDNUM2 HINVALIDNUM3 HLOWAXISCHK HUPAXISCHK HAXISBYCHK 3 
				    VINVALIDNUM1 VINVALIDNUM2 VINVALIDNUM3 VLOWAXISCHK VUPAXISCHK VAXISBYCHK 3
			            HLOWAXISCHKC HUPAXISCHKC HAXISBYCHKC $10  
			            VLOWAXISCHKC VUPAXISCHKC VAXISBYCHKC $10; 
				    HINVALIDNUM1=.;HINVALIDNUM2=.;HINVALIDNUM3=.;HLOWAXISCHK=.;HUPAXISCHK=.;HAXISBYCHK=.;
				    VINVALIDNUM1=.;VINVALIDNUM2=.;VINVALIDNUM3=.;VLOWAXISCHK=.;VUPAXISCHK=.;VAXISBYCHK=.;
			            HLOWAXISCHKC='';HUPAXISCHKC='';HAXISBYCHKC='';  
			            VLOWAXISCHKC='';VUPAXISCHKC='';VAXISBYCHKC='';

			HAXISCHK="&HAXISCHK";		
			%IF %SUPERQ(HAXISCHK)=USER %THEN %DO;
	  			Hlowaxischk  = "&USERHlowaxis";	Hupaxischk="&USERHupaxis";  	Haxisbychk   = "&USERHaxisby";	
				HlowaxischkC = "&USERHlowaxis";	HupaxischkC="&USERHupaxis";	HaxisbychkC  = "&USERHaxisby";

				HINVALIDNUM1=HlowaxischkC*1;
				HINVALIDNUM2=HupaxischkC*1;
				HINVALIDNUM3=HAXISBYCHKC*1;
	
				IF (HINVALIDNUM1=. OR HINVALIDNUM2=. OR HINVALIDNUM3=.)  	
				THEN CALL SYMPUT('INVALIDHAXIS','YES'); 
				ELSE DO;
					HAXISrange=Hupaxischk-Hlowaxischk; 
		  			IF HAXISRANGE^=. AND HAXISrange <= HAXISbyCHK 	   	THEN CALL SYMPUT('INVALIDHAXIS','YES'); 
		  			IF (Hupaxischk^=. AND Hlowaxischk^=.) AND Hupaxischk <= Hlowaxischk 	THEN CALL SYMPUT('INVALIDHAXIS','YES'); 
				END;
			%END;

			VAXISCHK="&VAXISCHK";
			%IF %SUPERQ(VAXISCHK)=USER %THEN %DO;
	  			Vlcl         = "&USERLCL";	Vucl         = "&USERUCL";	

	  			Vlowaxischk  = "&USERlowaxis";	Vupaxischk="&USERupaxis";  	Vaxisbychk   = "&USERaxisby";	
				VlowaxischkC = "&USERlowaxis";	VupaxischkC="&USERupaxis";	VaxisbychkC  = "&USERaxisby";
		  		
				VINVALIDNUM1=VLOWAXISCHKC*1;
				VINVALIDNUM2=VUPAXISCHKC*1;
				VINVALIDNUM3=VAXISBYCHKC*1;

				/*** Check for invalid numeric values ***/
				IF (VINVALIDNUM1=. OR VINVALIDNUM2=. OR VINVALIDNUM3=.)  		  
				   THEN CALL SYMPUT('INVALIDVAXIS','YES'); 
				   ELSE DO;  /*** Check for valid axisrange, lowaxis and upaxis values ***/
					Vaxisrange=Vupaxischk-Vlowaxischk; 
			    		IF Vaxisrange^=. and (Vaxisrange <= Vaxisbychk OR Vaxisbychk <=0)  	  THEN CALL SYMPUT('INVALIDVAXIS','YES'); 
					IF Vaxisrange^=. and (Vupaxischk <= Vlowaxischk) 		  	  THEN CALL SYMPUT('INVALIDVAXIS','YES'); 
					IF "&CTLLIMITS"='USER' AND (Vupaxischk < Vucl OR Vlcl < Vlowaxischk)	  THEN CALL SYMPUT('INVALIDVAXIS','YES'); 
	 			   END;
			%END;
		RUN;
	%END;
%PUT _ALL_;
%MEND INIT;

****************************************************************************************************;
*                                  MODULE HEADER                                                   *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;
*	     REQUIREMENT: See LINKS Report SOP                                                     *;
*       INPUT DATASETS  : SAVE.LRQUERYRES_DATABASE, SAVE.LRQUERYRES_BATCHES,                       *;
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

	/*** Create where statements for product, storage condition and test.  Where1A is used for stability data, Where1B is used for product release data ***/
	DATA _NULL_;  
		product=COMPRESS("&product"); BATCH="&BATCH";  reportype="&reportype"; TESTA=UPCASE("&TESTA"); TESTB=UPCASE("&TESTB");
		****************************************************************************************;
		*** Select testa and testb for correlation plots                                     ***;
		*** Select specified products, testa and testb, and storage condition (where1a only) ***;
		*** Select specified products, testa only, and storage condition (where1a only)      ***;
		****************************************************************************************;
		IF reportype='CORR' AND TESTB NOT IN ('TEMPERATURE','RH','TESTDATE2') THEN DO;   	
			CALL SYMPUT('where1','WHERE=(compress(lab_tst_meth_spec_desc) IN ("&testanew","&testBnew") and compress(STABILITY_SAMP_PRODUCT)=COMPRESS("&product"))');
		END;
		ELSE IF BATCH ^= '' OR (REPORTYPE IN ('PRODSTATS','BATCHSTATS', 'XBAR') AND TESTA IN ('ALL')) THEN DO;
			CALL SYMPUT('where1','WHERE=(STABILITY_SAMP_PRODUCT="&product")');
		END;
		ELSE DO;  
			CALL SYMPUT('where1','WHERE=(compress(lab_tst_meth_spec_desc)=compress("&testanew") and STABILITY_SAMP_PRODUCT="&product")');
			END;
    IF BATCH ^='' AND REPORTYPE ^= 'BATCHSTATS' THEN CALL SYMPUT('BATCH','');
	%if %superq(testa) ^=ALL %THEN %DO;
	CALL SYMPUT('wherespec','WHERE=(compress(lab_tst_meth_spec_desc)=compress("&testanew") and compress(indvl_meth_stage_nm)=compress("&stageanew") and compress(meth_peak_nm)=compress("&peakanew") and compress(STABILITY_SAMP_PRODUCT)=compress("&product"))');
	%END;

	%ELSE %DO;
	CALL SYMPUT('wherespec','WHERE=(compress(STABILITY_SAMP_PRODUCT)=compress("&product"))');
	%END;

	RUN;

	%GLOBAL DATACHECK1;
	/*** Create dataset for Product Release data ***/
	
		 /*** Select test, condition and product using above created WHERE clause ***/
	
	
	%global where1;
	DATA BATCHES1 ; LENGTH ANALYST $30 STAGE PEAK $50; SET LRQueryRes(&where1);	
		CALL SYMPUT('DataCheck1','GO');                            /***  Set flag if data exists    ***/
		
		Product	= UPCASE(STABILITY_SAMP_PRODUCT);		           /***  Rename/Reformat variables  ***/
		Test	= LAB_TST_METH_SPEC_DESC;  
		Peak	= METH_PEAK_NM;
		*IF Peak = 'FLUTICASONE' THEN Peak ='Fluticasone';
		*IF Peak = 'SALMETEROL'  THEN Peak ='Salmeterol';
		IF COMPRESS(UPCASE(TEST)) = 'FOREIGNPARTICULATEMATTER' AND COMPRESS(UPCASE(PEAK))='TOTAL' 
			THEN PEAK='Total Number of Particles'; 
		/*** Setup Stage variable depending on test ***/
		IF COMPRESS(TEST) = 'HPLCAdvairMDPlCas.Impaction'  THEN Stage='Stage: '||TRIM(LEFT(INDVL_METH_STAGE_NM)); 
		ELSE IF UPCASE(COMPRESS(TEST))='HPLCRELATEDIMP.INADVAIRMDPI' THEN DO;
			IF INDVL_METH_STAGE_NM='UNSPECIFIED' THEN DO;
				IF INDVL_TST_RSLT_NM^='' THEN STAGE=TRIM(PEAK)||'-'||TRIM(LEFT(INDVL_TST_RSLT_NM));
				ELSE STAGE='Any Unspec. Degradant-'||TRIM(LEFT(PEAK));
			END;
			ELSE IF INDVL_METH_STAGE_NM='TOTAL' THEN STAGE='Total Degradants';
			ELSE IF PEAK ^='NONE' THEN Stage=TRIM(INDVL_METH_STAGE_NM)||'-'||TRIM(PEAK); 
			ELSE Stage=TRIM(INDVL_METH_STAGE_NM);
		END;
		ELSE IF COMPRESS(UPCASE(TEST)) = 'FOREIGNPARTICULATEMATTER' AND
				COMPRESS(UPCASE(INDVL_METH_STAGE_NM)) IN ('NONE','') THEN STAGE='Totals'; 
		ELSE Stage=INDVL_METH_STAGE_NM; 

		STAGE=UPCASE(STAGE);

/** ??? ***/	IF MATL_MFG_DT='' THEN MATL_MFG_DT=DATETIME();
		Analyst   = UPCASE(CHECKED_BY_USER_ID);		IF Analyst IN ('','N/A','NA') THEN Analyst = 'No Analyst Data';	
		Time      = STABILITY_SAMP_TIME_VAL;
		Timeweeks = STABILITY_SAMP_TIME_WEEKS;
		TESTDATE2 = DATEPART(SAMP_TST_DT); 

		Test2    = COMPRESS(tranwrd(LAB_TST_METH_SPEC_DESC,'&','and'));  /*** Compress dataset variables for use in where statement ***/
		Product2 = COMPRESS(PRODUCT);
		Stage2   = COMPRESS(STAGE,'- ');
  		Peak2    = COMPRESS(METH_PEAK_NM);
		IF PROD_GRP='MDPI' THEN
		BATCHLIST=TRIM(BLEND_BATCH)||'-'||TRIM(FILL_BATCH)||'-'||TRIM(ASSY_BATCH);
		ELSE BATCHLIST=TRIM(BLEND_BATCH)||'-'||TRIM(FILL_BATCH);
		FORMAT TESTDATE2 DATE9.;
	RUN;


        ***********************************************************************************;
	*** V2 - Removed LRQueryRes_SPECS and LRQueryRes_Relationship dataset files.    ***;
        ***********************************************************************************;
	/*
	PROC COPY IN = SAVE OUT=WORK;
		SELECT LRQUERYRES_RELATIONSHIPS / memtype = data;		
	RUN;

	PROC SQL;CREATE INDEX INDEX2 ON BATCHES1A (BATCH_NBR, MATL_NBR);QUIT;
	PROC SORT DATA=LRQUERYRES_RELATIONSHIPS NODUPKEY;BY BATCH_NBR MATL_NBR;QUIT;

	DATA BATCHES1; MERGE BATCHES1A(IN=INA) LRQUERYRES_RELATIONSHIPS(IN=INB); BY BATCH_NBR MATL_NBR; IF INA;
		BATCHLIST=TRIM(BLEND_NBR)||'-'||TRIM(FILL_NBR)||'-'||TRIM(ASSEMBLED_NBR);
	RUN; */

	proc freq data=BATCHES1 noprint; table stability_samp_product*test*stage*peak/out=check; run;
/*	proc freq data=save.lrqueryres_specs noprint; table stability_samp_product*lab_tst_meth_spec_desc*lab_tst_desc*low_limit*upr_limit/out=check; run;*/

	data _null_; set check; put stability_samp_product test stage peak; run;

	**************************************************************;
	*** Create specification dataset                           ***;
	*** Subset for selected tests and product(s)               ***;
	**************************************************************;
        ***********************************************************************************;
	*** V2 - Revised SPECS Dataset to reflect new dataset structure from LRQuery.   ***;
        ***********************************************************************************;
	LIBNAME META 'D:\SQL_LOADER\METADATA';

/**	DATA SPECS0; LENGTH SPECTYPE $25 LOWERI UPPERI LOWERM UPPERM 8 STAGE $50; SET SAVE.LRQUERYRES_SPECS(&where1);   **/
	DATA SPECS0; LENGTH SPEC_TYPE $25 LOWERI UPPERI LOWERM UPPERM 8 STAGE $50 Product $40; 
    SET META.LINKS_SPec_File(&where1);
		
IF stability_samp_product='Advair Diskus 250/50' then put _all_;
&where1;
		reportype="&reportype";
		
		/***  Setup specification type                              ***/
		
		
		 *IF SPEC_TYPE='' THEN DELETE;

		/*IF MEANCHECK = 0 AND INDCHECK=0 THEN DELETE;   Temporarily remove specs until I can fix them */
		/***  Setup Mean specifications                             ***/
		IF SPEC_TYPE='MEAN' THEN DO;
			LOWERM=PUT(LOW_LIMIT,8.2);
			UPPERM=PUT(UPR_LIMIT,8.2);
		END;
		/***  Setup Individual specifications                       ***/
		IF  SPEC_TYPE='INDIVIDUAL' THEN DO;
			LOWERI=PUT(LOW_LIMIT,8.2);
			UPPERI=PUT(UPR_LIMIT,8.2);
		END;

		
		/***  Rename/Reformat variables                             ***/
		Product	=	upcase(STABILITY_SAMP_PRODUCT);       
		Test	=	LAB_TST_METH_SPEC_DESC;  
		Peak	=	METH_PEAK_NM;
		

		/*** Setup Stage variable depending on test ***/

		IF INDVL_METH_STAGE_NM='34' THEN SUMMARY_METH_STAGE_NM='3-4';
		IF INDVL_METH_STAGE_NM='6F' THEN SUMMARY_METH_STAGE_NM='6-F';

		IF COMPRESS(TEST) = 'HPLCAdvairMDPlCas.Impaction'  THEN Stage='Stage: '||TRIM(LEFT(INDVL_METH_STAGE_NM)); 
		ELSE IF UPCASE(COMPRESS(TEST))='HPLCRELATEDIMP.INADVAIRMDPI' THEN DO;
			IF UPCASE(INDVL_METH_STAGE_NM)='TOTAL' THEN STAGE='Total Degradants';
			ELSE IF UPCASE(INDVL_METH_STAGE_NM)='UNSPECIFIED' THEN STAGE='Any Unspec. Degradant-'||TRIM(LEFT(PEAK)); 
			ELSE IF PEAK ^='NONE' THEN Stage=TRIM(INDVL_METH_STAGE_NM)||'-'||TRIM(PEAK); 
			ELSE Stage=TRIM(INDVL_METH_STAGE_NM);
		END;
	    ELSE IF COMPRESS(UPCASE(TEST)) = 'FOREIGNPARTICULATEMATTER' THEN DO; 
			IF COMPRESS(UPCASE(INDVL_METH_STAGE_NM))='NONE' THEN STAGE='Totals'; 
			ELSE Stage=INDVL_METH_STAGE_NM; 
		END;
		ELSE Stage=INDVL_METH_STAGE_NM;			

		Stage2=COMPRESS(STAGE, '- ');

		
		IF SPEC_TYPE='MEAN' THEN CALL SYMPUT('SpecVal','MEAN');
		IF SPEC_TYPE='INDIVIDUAL' THEN CALL SYMPUT('SpecVal','INDIVIDUAL');
		IF (REPORTYPE in ('BATCHSTATS','PRODSTATS') AND SPEC_TYPE='INDIVIDUAL')
			THEN CALL SYMPUT('SPECCHKI','YES');        /*** Create flag to add/remove spec from table ***/
			
		IF (REPORTYPE in ('BATCHSTATS','PRODSTATS')  AND SPEC_TYPE='MEAN') 
			THEN CALL SYMPUT('SPECCHKM','YES');        /*** Create flag to add/remove spec from table ***/
			
			
 /* debug */   put product stability_samp_product test peak spec_type LOW_LIMIT UPR_LIMIT lowerm upperm loweri upperi;
	
	RUN;
         
	/*** Select PRODUCT RELEASE specifications ***/
		DATA SPECS1; SET SPECS0(WHERE=(SPEC_GROUP = 'RELEASE'));PUT TEST STAGE PEAK PRODUCT ; 	IF upcase(Product)=upcase("&Product"); RUN;
		
	%IF %SUPERQ(DATACHECK1)=GO AND %SUPERQ(TESTA)=ALL %THEN %DO;	
		DATA stageA1; SET BATCHES1; *put test2; RUN;

		%let byvar=stage; %LET var=stage; %LET var2=stageA; %LET DATA=stageA1; %varlist;  
	%END; 
	%IF %SUPERQ(DATACHECK1)=GO  AND %SUPERQ(TESTA)^=ALL  %THEN %DO;	
		************************************************************************************;
		*** If product release data exists, generate list of stages and peaks for test A ***;
		*** for use in drop down boxes                                                   ***;
		************************************************************************************;

		DATA stageA1; SET BATCHES1(WHERE=(test2="&testAnew"));       		     
		RUN;

		%let byvar=stage;  %LET var=stage; %LET var2=stageA; %LET DATA=stageA1; %varlist;  

		%GLOBAL STAGE1NEW PEAK1NEW;
		DATA _NULL_;  
			stageA="&stageA";
			/*** If stageA is null, set it to the first stage in the list ***/
	    	IF stageA='' THEN DO;               
	       			CALL SYMPUT('stageA',"&stageA1");
				CALL SYMPUT('stageAnew',COMPRESS("&stageA1", '- '));
			END;
		RUN;  

		DATA PEAKA1; SET STAGEA1(WHERE=(STAGE="&STAGEA")); RUN; 

		%let byvar=peak; %LET var=peak;  %LET var2=peakA;  %LET DATA=PEAKA1; %varlist;
    		
		DATA _NULL_;  
			peakA="&peakA";  
				
			/*** If peakA is null, set it to the first peak in the list   ***/
			IF peakA='' THEN DO;                
	    			CALL SYMPUT('peakA',"&peakA1");
				CALL SYMPUT('peakAnew',COMPRESS("&peakA1"));
			END;
			
		RUN;    	  

		/*** Execute this code only if report type is CORR and testb is not ***/
		%IF %SUPERQ(reportype)=CORR %THEN %DO;  
			/*** TEMPERATURE, RH or TESTDATE2 ***/
			%IF %SUPERQ(RHTEMPFLG)= AND %SUPERQ(TESTBNEW)^=TESTDATE2 %THEN %DO;    
				/*** Generate list of stages and peaks for test B for use in drop down boxes ***/
				DATA stageB1; SET BATCHES1;  
					WHERE test2="&testBnew";
				RUN;

				%let byvar=stage; %LET var=stage; %LET var2=StageB; %LET DATA=stageB1; %varlist;
				%let byvar=peak; %LET var=peak;  %LET var2=PeakB;  %LET DATA=stageB1; %varlist;
	
				%GLOBAL PEAKBNEW STAGEBNEW;
				DATA _NULL_; 
					StageB="&StageB";  PeakB="&PeakB";
					/*** If stageB is null, set it to the first stage in the list ***/
		    			IF StageB='' THEN DO;   
						CALL SYMPUT('StageB',"&StageB1");
						CALL SYMPUT('StageBnew',COMPRESS("&StageB1", '- '));
					END;
					/*** If peakB is null, set it to the first peak in the list   ***/
					IF PeakB='' THEN DO;    
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
*	     REQUIREMENT: See LINKS Report SOP                                                     *;
*       INPUT DATASET   : STABILITY2, BATCHES2, SPECS2.                                            *;
*       PROCESSING      : Create where statement for subsetting by stage and peak.                 *;
*		          Create datasets Stability2, Batches2 and Specs2, using where statement.  *;               
*       OUTPUT DATASETS : STABILITY2, BATCHES2, SPECS2. MACRO VARIABLES:                           *; 
*		          ALLSTUDY1,..ALLSTUDY#, NUMALLSTUDY, ANALYST1,...ANALYST#, NUMANALYST,    *; 
*		          DATACHECK2A, DATACHECK2B.                                                *;
****************************************************************************************************;
%MACRO SUBSET2;
	%GLOBAL DATACHECK2 DATACHECK2 SPECCHK SPECCHKB WHERE2 CHANGES;
	DATA _NULL_;
		testA="&testA";  reportype="&reportype"; BATCH="&BATCH";value="&value";
		****************************************************************************;
		*** Generate where clause for stage A and peak A only for CORR reports   ***;
		*** Generate where clause for stage and peak for all other reports       ***;
		****************************************************************************;
		IF reportype = 'CORR' THEN DO;  
			IF UPCASE(COMPRESS(testa)) NOT IN ('HPLCRELATEDIMP.INADVAIRMDPI') 
			THEN CALL SYMPUT('where2','WHERE (COMPRESS(test) = "&testanew" and COMPRESS(Stage,"- ")="&stageAnew" and COMPRESS(peak)="&peakAnew") or 
 				(COMPRESS(test) = "&testBnew" and COMPRESS(Stage, "- ")="&stageBnew" and COMPRESS(peak)="&peakBnew")') ;
			ELSE CALL SYMPUT('where2','WHERE (COMPRESS(test) = "&testanew" and COMPRESS(Stage,"- ")="&stageAnew" ) or (COMPRESS(test) = "&testBnew" and COMPRESS(Stage, "- ")="&stageBnew" )') ;
		END;

/*		ELSE IF (REPORTYPE IN ('PRODSTATS','BATCHSTATS') AND TESTA IN ('ALL') AND VALUE='INDIVIDUAL' THEN CALL SYMPUT('WHERE2', '*;');*/
		ELSE IF (REPORTYPE IN ('PRODSTATS','BATCHSTATS', 'XBAR') AND TESTA IN ('ALL')) OR BATCH ^='' THEN CALL SYMPUT('WHERE2', '*;');
		ELSE DO;                              
			IF reportype ^="CIPROFILES" AND UPCASE(COMPRESS(testa)) NOT IN ('HPLCRELATEDIMP.INADVAIRMDPI', 'IMPURITIES') 
				THEN CALL SYMPUT('where2','WHERE UPCASE(COMPRESS(Stage, "- ")) = UPCASE("&stageAnew") and UPCASE(COMPRESS(Peak)) IN ("'||UPCASE(TRIM("&peakAnew"))||'")');
			ELSE IF REPORTYPE='CIPROFILES' 
				THEN CALL SYMPUT('where2','WHERE COMPRESS(Peak) IN ("'||TRIM("&peakAnew")||'")');
			ELSE IF UPCASE(COMPRESS(TESTA))='HPLCRELATEDIMP.INADVAIRMDPI' 
				THEN CALL SYMPUT('where2','WHERE COMPRESS(Stage, "- ") IN ("'||TRIM("&stageAnew")||'")');
			ELSE IF UPCASE(COMPRESS(TESTA))='IMPURITIES' THEN
				CALL SYMPUT('where2','WHERE COMPRESS(Peak) IN ("'||TRIM("&peakAnew")||'")');
			END;
	RUN;

	PROC SUMMARY DATA=stageA1 NWAY;&where2; 
	CLASS Product stage;
	OUTPUT OUT=CIOUT
	n(Indvl_Tst_Rslt_Val_Num)=numcnt;
	RUN;

	DATA _NULL_; SET CIOUT;
		put product stage;
	RUN;

	/*** V7 - UPCASED Stage variable ***/

	DATA _NULL_; SET CIOUT;
		WHERE upcase(Product) = upcase("&Product") AND upcase(stage)=upcase("&StageA");
		CALL SYMPUT('StagePresent',1);
		put product stage;
	RUN;
 
	%IF %SUPERQ(StagePresent)=0 %THEN %DO;
		DATA _NULL_; SET CIOUT;
			WHERE upcase(Product) = upcase("&Product");
			PUT product Stage numcnt;
			Obs+1;
			IF _N_ = 1 THEN DO;
				CALL SYMPUT('STAGEANEW',stage);
				CALL SYMPUT('STAGEA',stage);
			END;
		RUN;
	%END;

	DATA _NULL_; SET CIOUT;
		WHERE upcase(Product) = upcase("&Product");
		PUT product Stage numcnt;
		Obs+1;
		IF Obs=06 THEN CALL SYMPUT('CIType','POOLED   ');
		IF Obs=11 THEN CALL SYMPUT('CIType','FULL     ');
		IF Obs=12 THEN CALL SYMPUT('CIType','FULL     ');
		IF Obs=13 THEN CALL SYMPUT('CIType','NONPOOLED');     		
	RUN;

	%IF %SUPERQ(reportype)=CORR AND %SUPERQ(RHTEMPFLG)= AND %SUPERQ(TESTBNEW)^=TESTDATE2 %THEN %DO;
		data stageA1;set stageA1 stageB1;RUN;
	%END;

	PROC SUMMARY DATA=stageA1;&where2; 
		VAR MATL_MFG_DT;
		OUTPUT OUT=DATESUM MIN=MINDATE MAX=MAXDATE;
	RUN;
	%LET NUMMAX=0;
	DATA _NULL_;SET DATESUM nobs=nummax;
		CALL SYMPUT('NEWSTARTDT',MINDATE);
		CALL SYMPUT('NEWENDDT',MAXDATE);
		FORMAT MINDATE MAXDATE datetime20.;
		IF _N_ = 1 THEN PUT MINDATE MAXDATE;
		CALL SYMPUT('NUMMAX',NUMMAX);
	RUN;

	%IF &NUMMAX=0 %THEN %DO;
		%LET NEWSTARTDT=0;
		%LET NEWENDDT  =0;
		%LET NORECORDS =0;
	%END;
	/***  Select stage and peak names  ***/
	%IF %SUPERQ(TESTA) ^=%SUPERQ(save_testinit) OR %SUPERQ(PEAKA)  ^=%SUPERQ(save_peakinit) OR
	    %SUPERQ(STAGEA)^=%SUPERQ(save_staginit) OR %SUPERQ(product)^=%SUPERQ(save_prodinit)
		%THEN %LET CHANGES=YES; 
		%ELSE %LET CHANGES=NO;

	%LET UNAPPFLAG=NO;

	DATA BATCHES2A; LENGTH SMONTH SDAY SYEAR EMONTH EDAY EYEAR 4;SET BATCHES1;
		&where2;    						 	       
		testbchk="&testb";  
		testinit="&save_testinit";
  		if testbchk='TESTDATE2' and testdate2=. THEN DELETE;
		CREATE_DATE2=DATEPART(MATL_MFG_DT);
		MONTH=MONTH(CREATE_DATE2);
		YEAR=YEAR(CREATE_date2);

   		if (month=01 or month=02 or month=03)   then quarter=trim(left(year))||"Q1";
   		if (month=04 or month=05 or month=06)   then quarter=trim(left(year))||"Q2";
   		if (month=07 or month=08 or month=09)   then quarter=trim(left(year))||"Q3";
   		if (month=10 or month=11 or month=12)   then quarter=trim(left(year))||"Q4";
		DateFlag='T';
		%IF %SUPERQ(STARTMONTH)^= %THEN %DO;
			SMONTH="&STARTMONTH";SDAY="&STARTDAY";SYEAR="&STARTYEAR";
			EMONTH="&ENDMONTH";  EDAY="&ENDDAY";  EYEAR="&ENDYEAR";
			IF (SMONTH IN (1,3,5,7,8,10,12) AND SDAY>31) OR
			   (SMONTH IN (2)               AND SDAY>29) OR
			   (SMONTH IN (4,6,9,11) 	AND SDAY>30) THEN DateFlag='F';
			IF (EMONTH IN (1,3,5,7,8,10,12) AND EDAY>31) OR
			   (EMONTH IN (2)               AND EDAY>29) OR
			   (EMONTH IN (4,6,9,11) 	AND EDAY>30) THEN DateFlag='F';
			STARTDATE=MDY(&STARTMONTH, &STARTDAY, &STARTYEAR);
			ENDDATE=MDY(&ENDMONTH, &ENDDAY, &ENDYEAR);
			IF STARTDATE > ENDDATE THEN CALL SYMPUT('DATECHECK','STOP');
		%END;

		IF DateFlag='F' OR "&STARTMONTH"='' THEN DO;
			STARTDATE=DATEPART(&NEWSTARTDT);
			ENDDATE=DATEPART(&NEWENDDT);
			IF STARTDATE > ENDDATE THEN CALL SYMPUT('DATECHECK','STOP');
			SMONTH=MONTH(STARTDATE);CALL SYMPUT('STARTMONTH',SMONTH);
			EMONTH=MONTH(ENDDATE);  CALL SYMPUT('ENDMONTH',EMONTH);
			SDAY  =DAY(STARTDATE);  CALL SYMPUT('STARTDAY',SDAY);
			EDAY  =DAY(ENDDATE);    CALL SYMPUT('ENDDAY',EDAY);
			SYEAR =YEAR(STARTDATE); CALL SYMPUT('STARTYEAR',SYEAR);
			EYEAR =YEAR(ENDDATE);   CALL SYMPUT('ENDYEAR',EYEAR);
		END; 
		IF DateFlag='F' THEN CALL SYMPUT('DATECHECK','STOP');
		%IF %SUPERQ(reportype)=CORR OR %SUPERQ(CHANGES)=YES %THEN %DO;
			STARTDATE=DATEPART(&NEWSTARTDT);
			ENDDATE=DATEPART(&NEWENDDT);
			SMONTH=MONTH(STARTDATE);CALL SYMPUT('STARTMONTH',SMONTH);
			EMONTH=MONTH(ENDDATE);  CALL SYMPUT('ENDMONTH',EMONTH);
			SDAY  =DAY(STARTDATE);  CALL SYMPUT('STARTDAY',SDAY);
			EDAY  =DAY(ENDDATE);    CALL SYMPUT('ENDDAY',EDAY);
			SYEAR =YEAR(STARTDATE); CALL SYMPUT('STARTYEAR',SYEAR);
			EYEAR =YEAR(ENDDATE);   CALL SYMPUT('ENDYEAR',EYEAR);
			IF STARTDATE > ENDDATE THEN CALL SYMPUT('DATECHECK','STOP');
		%END;
		IF SAMP_STATUS < '17' THEN CALL SYMPUT('UNAPPFLAG','YES');
				      
		START_DATE=STARTDATE;END_DATE=ENDDATE;
		FORMAT START_DATE END_DATE MMDDYY8.;
		*IF _N_ = 1 THEN PUT _ALL_;
		put test stage peak;
	RUN;

	PROC SORT DATA=BATCHES2A OUT=BOUT NODUPKEY;BY SAMP_STATUS lab_tst_meth_spec_desc peak;RUN;

	DATA BATCHES2; SET BATCHES2A;
	%IF %SUPERQ(STARTMONTH)^= AND %SUPERQ(DATECHECK)^=STOP %THEN %DO;
	WHERE CREATE_DATE2 >= STARTDATE AND CREATE_DATE2 <= ENDDATE;
	*put batch_Nbr matl_mfg_dt create_date2 startdate enddate;
	%END;
	CALL SYMPUT('datacheck2','GO');   /***  Set flag if data exists             ***/
	put test stage peak;
	RUN;
	
	

	PROC SORT DATA=BATCHES2A OUT=BatchT;BY Meth_Spec_Nm Batch_Nbr Meth_Peak_Nm Stage;RUN;
	
	
	%IF %SUPERQ(DATACHECK2)=GO %THEN %DO;

		data specs1; set specs1; put test stage peak; IF SPEC_TYPE='' THEN DELETE; run;

		DATA SPECS2; SET SPECS1;				       /*** Select stage and peak names          ***/
			&WHERE2;
			*IF upcase(Product)=upcase("&Product");
			%IF %SUPERQ(TESTA)^=ALL %THEN %DO;
			IF compress(TEST)=compress("&TESTA") THEN CALL SYMPUT('SPECCHK','YES');    /***  Set flag if specs exists for Test A ***/
			IF compress(TEST)=compress("&TESTB") THEN CALL SYMPUT('SPECCHKB','YES');   /***  Set flag if specs exists for Test B ***/
			%END;
			%ELSE %DO;
				CALL SYMPUT('SPECCHK','YES');
			%END;
			reportype="&reportype";
			/*spectype="&value";*/
			put reportype SPEC_TYPE meancheck indcheck TEST STAGE PEAK;
		RUN;

		/*** Create macro variables for all ANALYSTS in dataset for Histograms and Corr reports                  ***/
		%let byvar=analyst; %LET var=ANALYST; 	%LET VAR2=ANALYST; 	%LET DATA=BATCHES2; 	%varlist; 
	%END;

%MEND SUBSET2;

****************************************************************************************************;
*                                    MODULE HEADER                                                 *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *; 
*	     REQUIREMENT: See LINKS Report SOP                                                     *;
*       INPUT Datasets  : Batches1, Stability2, Stability3.                                        *;
*       PROCESSING      : Creates general report datasets and macro variables.                     *;
*       OUTPUT          :   General report datasets and macro variables.                           *;
****************************************************************************************************;
%MACRO SETUP;
	%GLOBAL SPECLIST SPECLABEL SPECLABEL1 SPECLABEL2 SPECLABEL3 SPECLABEL4 SPECLABEL5
		FOOTNOTE1 FOOTNOTE2 FOOTNOTE3 FOOTNOTE4 FOOTNOTE5 NUMSPECS CalcLowAxis CalcUpAxis
		DATACHECK3;

	/*** Setup dataset names and by variables depending on report type ***/
	
	%LET DSN1=BATCHES2;
	%LET DSN2=BATCHES2;
	%LET BYVAR=BY PRODUCT TEST STAGE STAGE2 PEAK BATCH_NBR;

	DATA SPECOUT;SET specs1;KEEP PRODUCT TEST STAGE PEAK SPEC_PRECISION;RUN;
	PROC SORT DATA=SPECOUT; BY PRODUCT TEST STAGE PEAK ; RUN;
	PROC SORT DATA=&DSN1; BY PRODUCT TEST STAGE PEAK ; RUN;
	DATA &DSN1; MERGE &DSN1(IN=A) SPECOUT(IN=B); BY PRODUCT TEST STAGE PEAK ;IF A;RUN;
	
       	*********************************************************************;
	*** V9 - Added Sort to delete duplicates for Batch Summary Report ***; 
      	*********************************************************************;
	%IF %SUPERQ(Reportype)=BATCHSTATS %THEN %DO;
			PROC SORT DATA=&DSN1 NODUPKEY;
        		BY    BATCH_nbr MATL_MFG_DT TEST result Indvl_tst_rslt_device 
			      Indvl_tst_rslt_val_char LAB_TST_METH samp_tst_dt; 
			RUN;
	%END;

	PROC SORT DATA=&DSN1; &BYVAR; RUN;

	PROC SUMMARY DATA=&DSN1;                  /***  Calculate summary statistics for designated dataset/by variables  ***/
	  	VAR result;
	   	&BYVAR;
		ID ANALYST PROD_GRP MATL_NBR MATL_MFG_DT SAMP_TST_DT BATCHLIST BLEND_BATCH FILL_BATCH ASSY_BATCH SPEC_PRECISION MATL_DESC;
	  	OUTPUT OUT=Means N=N mean=mean std=std cv=rsd min=min max=max;
	RUN;

/*	PROC SORT DATA=&DSN1; &BYVAR; RUN;*/
	PROC SORT DATA=Means; &BYVAR; RUN;

	DATA ALLDATA_WITH_STATS; MERGE &DSN1(IN=A) means(IN=B); &BYVAR; 
		IF NOT FIRST.BATCH_NBR THEN DO;
			mean=.;std=.;rsd=.;
		END;
	RUN;        /***  Combine individual results with sum stats  ***/

 
	PROC SORT DATA=ALLDATA_WITH_STATS; BY test stage2 peak; RUN;

	DATA _NULL_;SET ALLDATA_WITH_STATS;
		IF TEST=:'Blend As' THEN
		PUT PRODUCT test stage2 peak N mean result std rsd min max;
	RUN;
  	PROC SUMMARY DATA=ALLDATA_WITH_STATS;  			        /***  Calculate min and max summary statistics   ***/
    	VAR N mean result std rsd min max;
		BY PRODUCT test stage2 peak;
		ID STAGE SPEC_PRECISION;
    	OUTPUT OUT=MaxData min=minn  minmean minind minstd minrsd minmin minmax 
                           max=maxn  maxmean maxind maxstd maxrsd maxmin maxmax 
			  MEAN=meann GRMEAN  A      B      C      D      E 
		           STD=F     BETSTD  GRSTD  H      I      J      K 
			     N=G     GRN     L      M      N      O      P;
  	RUN;

	/*************************************************************************/
	/* Added V9 - trap errors caused by single batches (proc summary is not  */
	/*            able to calculate std deviation on them)                   */
	/*************************************************************************/
	proc sql;
		create table batchcnt as
		select count(distinct BATCH_NBR) as cnt
		from ALLDATA_WITH_STATS
		;
	quit;
 
	data _null_; 
		set batchcnt;
		if cnt = 1 then
				CALL SYMPUT('DATACHECK3','STOP');
		else
				CALL SYMPUT('DATACHECK3','GO');
	run;

	%GLOBAL LCL UCL BAR;
	DATA MAXDATA; SET MAXDATA;  				
		IF MINSTD=. THEN MINSTD=0;
		IF MAXSTD=. THEN MAXSTD=0;
		IF MINRSD=. THEN MINRSD=0;
		IF MAXRSD=. THEN MAXRSD=0;

		%IF %SUPERQ(CTLLIMITS) = USER %THEN %DO;
		CALL SYMPUT('LCL', "&USERLCL");
		CALL SYMPUT('UCL', "&USERUCL");
		CALL SYMPUT('BAR', "&USERBAR");
		%END;
		%ELSE %IF %SUPERQ(REPORTYPE)=XBAR %THEN %DO;
		CALL SYMPUT('LCL', PUT(GRMEAN - 3*BETSTD, 6.2));
		CALL SYMPUT('UCL', PUT(GRMEAN + 3*BETSTD, 6.2));
		CALL SYMPUT('BAR', PUT(GRMEAN, 6.2));
		%END;
		DROP A B C D E F  H I J K M N O P;  /** G L **/
  	RUN;

	%GLOBAL LIMITNMIN LIMITNMAX;
	DATA _NULL_; SET MAXDATA;
		IF MINN GT 1 THEN CALL SYMPUT('LIMITNMIN', MINN);
			     ELSE CALL SYMPUT('LIMITNMIN', MINN+1);
		CALL SYMPUT('LIMITNMAX', MAXN);
	RUN;

	%IF %SUPERQ(REPORTYPE)=SBAR %THEN %DO;
	%LET INVALIDLIMITS=;

		PROC SORT DATA=BATCHES2; BY TEST STAGE PEAK; RUN;

		PROC SHEWHART DATA=BATCHES2;
 		SCHART RESULT*BATCH_NBR/ 
				LIMITN=&LIMITNMIN
				NOCHART
 				OUTLIMITS=STDCTL;
		BY TEST STAGE PEAK;
		RUN;

		DATA STDCTL; SET STDCTL;
		_LIMITN_=&LIMITNMIN;
			TEMP_LCLS_=_LCLS_;  TEMP_UCLS_=_UCLS_;  TEMP_S_=_S_;
			%IF %SUPERQ(CTLLIMITS)=USER %THEN %DO;
				_LCLS_="&USERLCL";  _UCLS_="&USERUCL";  _S_="&USERBAR";
			%END;
			%ELSE %DO;
				CALL SYMPUT('LCL', PUT(_LCLS_, 6.2));
				CALL SYMPUT('UCL', PUT(_UCLS_, 6.2));
				CALL SYMPUT('BAR', PUT(_S_, 6.2));
			%END;
		CHARFLAG='N';
		if indexc(COMPRESS(UPCASE(_LCLS_)),'ABCDEFGHIJKLMNOPQRSTUVWXYZ !@#$%^&*()_-+=') > 0 OR
		   indexc(COMPRESS(UPCASE(_UCLS_)),'ABCDEFGHIJKLMNOPQRSTUVWXYZ !@#$%^&*()_-+=') > 0 OR
		   indexc(COMPRESS(UPCASE(_S_)),'ABCDEFGHIJKLMNOPQRSTUVWXYZ !@#$%^&*()_-+=') > 0 
			THEN CHARFLAG='Y';		

			IF _LCLS_ < 0 THEN _LCLS_=0;
			IF _UCLS_ < _LCLS_ OR _UCLS_=. OR _LCLS_=. OR CHARFLAG='Y' THEN DO; 
				CALL SYMPUT('LCL', PUT(TEMP_LCLS_, 6.2));  _LCLS_=TEMP_LCLS_;
				CALL SYMPUT('UCL', PUT(TEMP_UCLS_, 6.2));  _UCLS_=TEMP_UCLS_;
				CALL SYMPUT('BAR', PUT(TEMP_S_, 6.2));     _S_   =TEMP_S_;
				CALL SYMPUT('INVALIDLIMITS','YES');
				CALL SYMPUT('CTLLIMITS','DEFAULT');
			END;
			OUTPUT;	

			PUT   _VAR_ _SUBGRP_ _LCLS_ _S_ _UCLS_ _STDDEV_ _LIMITN_ _TYPE_ _ALPHA_; 
			KEEP  TEST STAGE PEAK _VAR_ _SUBGRP_ _LCLS_ _S_ _UCLS_ _STDDEV_ _LIMITN_ _TYPE_ _ALPHA_;
			
			RUN;
	%END;

	%LET SPECLABEL=N/A;  %LET NUMSPECS=0;
	/***  If specifications exist, then proceed.  ***/
	%IF %SUPERQ(SPECCHK)=YES OR %SUPERQ(SPECCHKB)=YES OR %SUPERQ(SPECCHKI)=YES OR %SUPERQ(SPECCHKM)=YES %THEN %DO;       

		PROC SORT DATA=SPECS2; BY PRODUCT TEST STAGE2 PEAK; WHERE SUBSTR(TXT_LIMIT_A,1,7)^='Stage 2';RUN;

		PROC SUMMARY DATA=specs2;                                  /***  Calculate min and max specifications    ***/
    		VAR LOWERI UPPERI LOWERM UPPERM;
			BY PRODUCT test stage2 peak;
			ID STAGE;
    		OUTPUT OUT=maxSPECS min=minLOWI minUPI MINLOWM MINUPM max=maxLOWI maxUPI MAXLOWM MAXUPM;
  		RUN;

		data _null_; set maxdata; put PRODUCT TEST STAGE2 PEAK; run;
		data _null_; set maxspecs; put PRODUCT TEST STAGE2 PEAK; run;


		DATA MAXDATA; MERGE MAXDATA MAXSPECS; BY PRODUCT TEST STAGE2 PEAK; 
		put PRODUCT TEST STAGE2 PEAK minLOWI minUPI MINLOWM MINUPM maxLOWI maxUPI MAXLOWM MAXUPM ; 

		RUN;

		%LET NUMSPECS=1;
		
		DATA TestASpecs; SET SPECS2;                               /***  Create dataset with specs for only testA  ***/
			%IF %SUPERQ(TESTA)^=ALL %THEN %DO;
				%IF %SUPERQ(IMPFLAG)=YES %THEN %DO;
					WHERE upcase(product)=upcase("&product") and upcase(test)=upcase("&testA") AND upcase(COMPRESS(stage,'- '))=upcase("&stageANEW");  
				%END;
				%ELSE %DO;
					WHERE upcase(product)=upcase("&product") and upcase(test)=upcase("&testA") AND upcase(COMPRESS(stage,'- '))=upcase("&stageANEW") AND upcase(compress(peak))=upcase("&peakA"); 
				%END;
			%END;
			put product test stage peak;
		RUN;

		/*** Create 2 lists of specifications for TestA, one for mean specs and one for individual specs  ***/
		PROC SORT DATA=TestASpecs NODUPKEY OUT=PRODSPECS0; BY PRODUCT TEST STAGE PEAK SPEC_TYPE ; RUN;
	
		DATA PRODSPECLIST; RETAIN LowLine 250 UprLine 0; LENGTH SPECLISTm speclisti $1000 LOWERIC UPPERIC LOWERMC UPPERMC $15; 
			SET PRODSPECS0 NOBS=NUMSPECS;
		BY PRODUCT TEST STAGE PEAK SPEC_TYPE ;
  			RETAIN  OBS OBSALL 0 speclistM SPECLISTI;
			IF FIRST.SPEC_TYPE THEN OBS=1;                      /***  Create counter for each spectype        ***/
			ELSE OBS=OBS+1;
			OBSALL=OBSALL+1;                                   /***  Create counter of overall observations  ***/
			/*** Convert specifications to character ***/
			IF LOWERI=. OR LOWERI=0 THEN LOWERIC=''; ELSE LOWERIC=LOWERI;
			IF UPPERI=. THEN UPPERIC=''; ELSE UPPERIC=UPPERI;
			IF LOWERM=. OR LOWERM=0 THEN LOWERMC=''; ELSE LOWERMC=LOWERM;
			IF UPPERM=. THEN UPPERMC=''; ELSE UPPERMC=UPPERM;
			/*** Create mean spec list               ***/
			IF OBS=1 AND SPEC_TYPE='MEAN' THEN SPECLISTM=TRIM(LOWERMC)||' '||TRIM(UPPERMC);
			ELSE IF SPEC_TYPE='MEAN' AND OBS > 1 THEN SPECLISTM=TRIM(SPECLISTM)||' '||TRIM(LOWERMC)||' '||TRIM(UPPERMC);
			/*** Create individual spec list         ***/
			IF OBS=1 AND SPEC_TYPE='INDIVIDUAL' THEN SPECLISTI=TRIM(LOWERIC)||' '||TRIM(UPPERIC);
			ELSE IF SPEC_TYPE='INDIVIDUAL' AND OBS > 1 THEN SPECLISTI=TRIM(SPECLISTI)||' '||TRIM(LOWERIC)||' '||TRIM(UPPERIC);
			/*** If end of dataset then output       ***/
			IF LAST.PEAK THEN OUTPUT;
			IF SPEC_TYPE='INDIVIDUAL' THEN DO;
				If loweri in ('.','0',' ') then Loweric=0;if upperi=. then upperic=0;
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
				If lowerm in ('.','0',' ') then Lowermc=0;if upperm=. then uppermc=0;
				IF Lowermc LT LowLine THEN DO;
				        CALL SYMPUT('LowRefLine',TRIM(LEFT(Lowermc)));
					 LowLine=Lowermc;
				END;	
			        IF Uppermc GT UprLine THEN DO;
					CALL SYMPUT('UprRefLine',TRIM(LEFT(Uppermc)));
					UprLine=Uppermc;
				END;
			END;
			PUT SPEC_TYPE loweri upperi loweric upperic ' - ' lowerm upperm lowermc uppermc LowLine UprLine;
  		RUN;

		DATA _NULL_; SET PRODSPECLIST;    /***  Setup SpecList macro variable depending on the report statistic  ***/
			value=UPCASE("&value");  reportype="&reportype";
	    		IF (VALUE='MEAN' AND REPORTYPE IN ('HISTIND','CORR')) OR REPORTYPE = 'XBAR' THEN CALL SYMPUT("SpecList", TRIM(SPECLISTM));
			ELSE IF (VALUE='INDIVIDUAL' AND REPORTYPE IN ('HISTIND','CORR')) OR REPORTYPE IN ('INDRUN') THEN CALL SYMPUT("SpecList", TRIM(SPECLISTI));
  		RUN;

		/*** Create macro variable SpecLabel for text version of specification for use in report titles/footnotes ***/
		
		%IF %SUPERQ(REPORTYPE)=XBAR         %THEN %LET CHKVALUE=WHERE UPCASE(SPEC_TYPE)=UPCASE("&VALUE");
		%IF %SUPERQ(REPORTYPE)=SBAR         %THEN %LET CHKVALUE=*;
		%IF %SUPERQ(REPORTYPE)=INDRUN       %THEN %LET CHKVALUE=WHERE UPCASE(SPEC_TYPE)='INDIVIDUAL';
		%IF %SUPERQ(REPORTYPE)=HISTIND      %THEN %LET CHKVALUE=WHERE UPCASE(SPEC_TYPE)=UPCASE("&VALUE");
		%IF %SUPERQ(REPORTYPE)=PRODSTATS    %THEN %LET CHKVALUE=*;
		%IF %SUPERQ(REPORTYPE)=BATCHSTATS   %THEN %LET CHKVALUE=*;
		%IF %SUPERQ(REPORTYPE)=CORR  	    %THEN %LET CHKVALUE=WHERE UPCASE(SPEC_TYPE)=UPCASE("&VALUE");
		%IF %SUPERQ(REPORTYPE)=CIPROFILES   %THEN %LET CHKVALUE=WHERE UPCASE(SPEC_TYPE)='INDIVIDUAL';
		
		PROC SORT DATA=SPECS2 NODUPKEY OUT=SPECTYPE0; BY PRODUCT TEST STAGE PEAK SPEC_TYPE TXT_LIMIT_A TXT_LIMIT_B TXT_LIMIT_C; RUN;

		proc freq data=spectype0 noprint; tables spec_type/out=checkspec; run;

		data _null_; set checkspec; value="&value"; put spec_type; run;

		DATA SPECTYPE1; SET SPECTYPE0;
			&CHKVALUE;
			put product test stage peak;
		RUN;

		Proc Sort data=spectype1 nodupkey; by PRODUCT TEST STAGE PEAK txt_limit_a txt_limit_b txt_limit_c; run;
				
		DATA SPECTYPE; LENGTH SPEC $750; SET SPECTYPE1 NOBS=maxobs; 
			BY PRODUCT TEST STAGE PEAK /*SPECTYPE*/;
			RETAIN OBS 0 SPEC SPECTXTLIST;
			IF FIRST.PEAK THEN OBS=1;
			ELSE OBS=OBS+1;
			*IF upcase(Product)=upcase("&Product") and upcase(test)=upcase("&test") and upcase(stage)="&stage" and peak="&peak";
			reportype="&reportype";
			SPEC=TRIM(TXT_LIMIT_A)||TRIM(TXT_LIMIT_B)||TRIM(TXT_LIMIT_C);
			PUT PRODUCT TEST STAGE PEAK SPEC_TYPE TXT_LIMIT_A SPEC;
			IF SPEC=' ' THEN SPEC='N/A';
			IF OBS=1 AND SPEC^='' THEN DO;
				SPECTXTLIST=TRIM(SPEC);
				CALL SYMPUT('SPECLABEL1', TRIM(LEFT(SPEC)));
				CALL SYMPUT('FOOTNOTE1', 'FOOTNOTE&K F=ARIAL h=1 "Specification: '||TRIM(LEFT(SPEC))||'"');
			END;
			ELSE IF SPEC^='' THEN DO;
				SPECTXTLIST=TRIM(SPECTXTLIST)||'; '||TRIM(LEFT(SPEC));
				CALL SYMPUT('SPECLABEL'||TRIM(LEFT(OBS)),TRIM(SPEC)); 
				CALL SYMPUT('FOOTNOTE'||TRIM(LEFT(OBS)), 'FOOTNOTE&K F=ARIAL h=1 "'||TRIM(LEFT(SPEC))||'"');
			END;

			PUT PRODUCT TEST STAGE PEAK SPEC_TYPE TXT_LIMIT_A SPEC;
			IF LAST.PEAK THEN OUTPUT;

			CALL SYMPUT('NUMSPECS',MAXOBS);
		RUN;
  		
		DATA _NULL_;                                 /***  Setup Reference Lines for TestA specifications        ***/
 			VALUE=UPCASE("&VALUE");
  			REPORTYPE="&REPORTYPE";  SpecList="&speclist";
  			IF speclist^='' THEN CALL SYMPUT("vref","vref = &speclist"); 
			IF speclist^='' AND REPORTYPE IN ('HISTIND') THEN CALL SYMPUT("HREF","HREF= &SPECLIST");
			put 'speclist check' speclist;
		RUN;
	%END;

	%ELSE %DO;                                           /***  Setup dummy dataset when specifications do not exist. ***/
		DATA MAXDATA; SET MAXDATA;
		  minLOWI=.; minUPI=.; MINLOWM=.; MINUPM=.; maxLOWI=.; maxUPI=.; MAXLOWM=.; MAXUPM=.;
		RUN;
	%END;
   *************************************************************************************************************************;		
   ***  Setup axis range values based on the spec if all data is within spec or based on the data if data is outside     ***;
   ***  specs.   Setup plot variable and axis labels.                                                                    ***;
   *************************************************************************************************************************;		
	%GLOBAL PLOTVAR VALUE2;
	DATA PlotSetup;  SET MaxData;  
		REPORT=upcase("&reportype");  VALUE=upcase("&VALUE");
  		/***  Setup lower and upper axis values for plotting individuals  ***/
  		IF (VALUE ='INDIVIDUAL' AND REPORT IN ('CORR','HISTIND')) OR REPORT IN ('INDRUN') THEN DO;
	    		IF minind < minlowI or minlowI=. THEN lowaxis=max(0,minind*.9);
					     		 ELSE lowaxis=minlowI*.9;
           
    			IF maxind > maxupI or maxupI=.   THEN upaxis=maxind*1.1;
    							 ELSE upaxis=maxupI*1.1;
        	END;
		/***  Setup lower and upper axis values for plotting means         ***/
  		IF (VALUE='MEAN' AND REPORT IN ('CORR','HISTIND')) OR REPORT IN ('XBAR') THEN DO;

    			IF minlowI ^=. THEN DO;
      				IF minmean < minlowI     THEN lowaxis=max(0,minmean*.9);
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
 			END;
	
    			ELSE upaxis= maxmean*1.1;
		END;
		IF REPORT = 'SBAR' THEN DO;
			/*** Setup lower and upper axis values for plotting standard deviation  ***/
				lowaxis = max(0, minstd*.9);
    				upaxis = maxstd * 1.1; 
    			END;
		IF REPORT='CIPROFILES' THEN DO;
		   LOWAXIS=MINMEAN*.9;
		   UPAXIS=MAXMEAN*1.1;
		   END;

		put product test stage peak report value ' : ' minmean minstd minind minlowi minlowm lowaxis ' - ' maxmean maxind maxstd maxupi maxupm upaxis;
		CALL SYMPUT('CalcLowAxis',PUT(LowAxis,trnc2D.));
		CALL SYMPUT('CalcUpAxis',PUT(UpAxis,trnc2D.));
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
	RUN;
	
	%GLOBAL INVALIDAXIS XPIXELS YPIXELS XPIXELS0 YPIXELS0 LOWAXIS UPAXIS AXISBY;   /***  Setup Vertical Axis Range.  ***/
	DATA _NULL_; 
		SET plotsetup;
		%IF %SUPERQ(TESTA)^=ALL %THEN %DO;
			%IF %SUPERQ(IMPFLAG)=YES %THEN %DO;
				WHERE COMPRESS(test)="&testANEW" AND COMPRESS(stage2,'- ')="&stageANEW";
			%END;
			%ELSE %DO;
				WHERE COMPRESS(test)="&testANEW" AND COMPRESS(stage,'- ')="&stageANEW" AND COMPRESS(peak)="&peakANEW";
			%END;
		%END;
		reportchk="&reportype";
		IF reportchk='HISTIND' THEN  divisor=40; /*** If the plot is a histogram THEN SET the axisby divisor to 40  ***/
  		                    ELSE  divisor=5 ; /*** and the ypixels to 700, otherwise SET the axisby divisor to 5 ***/
                                                      /*** and the ypixels to 400.                                       ***/
		INVALIDAXIS="&INVALIDVAXIS"; VAXISCHK="&VAXISCHK";
		USERLOWAXIS="&USERLOWAXIS"; USERUPAXIS="&USERUPAXIS"; USERAXISBY="&USERAXISBY";		
		IF LOWAXIS=0 AND UPAXIS=0 THEN DO;
			LOWAXIS=0;
			UPAXIS=1;
		END;

		/*** Check to see if user has entered valid axis values.  If no, then set to default.   ***/
		IF INVALIDAXIS='YES' OR (VAXISCHK^='USER')  THEN CALL SYMPUT("LowAxis",PUT(lowaxis,7.3)); 
							    ELSE CALL SYMPUT("LowAxis","&USERLOWAXIS");	  
		IF INVALIDAXIS='YES' OR (VAXISCHK^='USER')  THEN CALL SYMPUT("UpAxis", PUT(upaxis,7.3));   
		                                            ELSE CALL SYMPUT("UpAxis","&USERUPAXIS");		  
  		IF INVALIDAXIS='YES' OR (VAXISCHK^='USER')  THEN CALL SYMPUT("AxisBy", PUT((upaxis-lowaxis)/divisor,8.4)); 
							    ELSE CALL SYMPUT("AxisBy","&USERAXISBY");	
		
		/*** Setup x and y plot size variables  ***/
                xpixelchk=SYMGET('xpixels0');	ypixelchk=SYMGET('ypixels0');
  		IF xpixelchk= '' THEN DO;				       /*** Set xpixels to default               ***/
	    		CALL SYMPUT("xpixels", 'xpixels= 700'); CALL SYMPUT("xpixels0", '700'); 
		END;
  		ELSE CALL SYMPUT("xpixels","xpixels=&xpixels0");               /*** Set xpixels to user entry            ***/

		IF REPORTCHK IN ('XBAR','SBAR','INDRUN', 'CORR', 'HISTIND','CIPROFILES') THEN sizeinit=500;
	 		 	
  		IF ypixelchk ='' OR YPIXELCHK=. THEN DO;		       /*** Set ypixels to default               ***/
     			CALL SYMPUT("ypixels", 'ypixels='||COMPRESS(sizeinit)); 
	 		CALL SYMPUT("ypixels0",COMPRESS(sizeinit));
  		END;
  		ELSE CALL SYMPUT("ypixels", 'ypixels='||compress("&YPIXELS0")); /*** Set ypixels to user entry            ***/
	RUN;

	%IF %SUPERQ(REPORTYPE)=CIPROFILES %THEN %DO;
		%GLOBAL TIMETITLE CILOWAXIS CIUPAXIS CIAXISBY CIWARNING;       /*** Setup CIProfiles axis values         ***/

		DATA _NULL_; SET ALLDATA_WITH_STATS;
		PUT STAGE;
		RUN;

                /* v9 */
	        %IF %INDEX(%SUPERQ(PRODUCT),Advair Diskus) %THEN %DO;
		        DATA CIData; SET ALLDATA_WITH_STATS;  /*** Keep only needed stages, reformat stage values                ***/
	     	        	IF stage NOT IN ("STAGE: THROAT", "STAGE: PRESEPARATOR", "STAGE: 0","STAGE: 1",
		        	"STAGE: 2","STAGE: 3","STAGE: 4","STAGE: 5","STAGE: 6-F") THEN delete;
  		        	IF stage = "STAGE: PRESEPARATOR" THEN stage="P";
  		        	ELSE IF stage = "STAGE: THROAT"  THEN stage="T";
  		        	ELSE IF stage = "STAGE: 6-F"     THEN STAGE='6,7&F'; 
		        	ELSE STAGE=COMPRESS(STAGE, 'STAGE: ');
		        	%IF %SUPERQ(CIType)=NONPOOLED %THEN %DO;
	     	        		*IF stage NOT IN ('T','P','0','1','2','3','4','5','6,7&F') THEN DELETE;
		        	%END;
		        	%IF %SUPERQ(CIType)=POOLED %THEN %DO;
		        		IF stage NOT IN ('TP0','12','34','5','6,7&F') THEN DELETE;
		        	%END;
		        	%IF %SUPERQ(CIType)=FULL %THEN %DO;
	     	        		IF stage NOT IN ('T','P','0','1','2','3','4','5','6','7','F') THEN DELETE;
		        	%END;
  		        RUN;
                %END;
	        %ELSE %IF %INDEX(%SUPERQ(PRODUCT),Relenza Rotadisk) %THEN %DO;
		        DATA CIData; SET ALLDATA_WITH_STATS;
	     	        	IF stage NOT IN ('TMP','1','2','3','4','5','PRESEP-0','TP0','1-3','4-5','1-5','TP0') THEN delete;

		        	%IF %SUPERQ(CIType)=NONPOOLED %THEN %DO;
                                        /* TODO ??? */
	     	        		*IF stage NOT IN ('T','P','0','1','2','3','4','5','6,7&F') THEN DELETE;
		        	%END;

		        	%IF %SUPERQ(CIType)=POOLED %THEN %DO;
		        		IF stage NOT IN ('TP0','1-3','4-5','1-5') THEN DELETE;
		        	%END;

                                %if %SUPERQ(CIType)=FULL %THEN %DO;
	     	        		IF stage NOT IN ('TMP','PRESEP-0','1','2','3','4','5') THEN DELETE;
		        	%END;
  		        RUN;
                %END;

		PROC SORT DATA=CIDATA; BY product test peak stage; RUN;  

  		PROC SUMMARY DATA=CIDATA;                                      /*** Calculate means by stage             ***/
  			VAR result;
  			BY product test peak stage;
  			OUTPUT OUT=meanstages mean=CImean;
  		RUN; 

		PROC SUMMARY DATA=meanstages;                                  /*** Calculate the maximum mean           ***/
  			VAR CImean;
  			OUTPUT OUT=maxmeans min=min max=max;
  		RUN; 

		DATA _NULL_; LENGTH LOWAXISCHK UPAXISCHK AXISBYCHK 3; SET MAXMEANS;
			INVALIDAXIS="&INVALIDVAXIS";
			LOWAXISCHK="&USERLOWAXIS";
			UPAXISCHK="&USERUPAXIS";
			AXISBYCHK="&USERAXISBY";
			/*** Check to see if user has entered validated axis values.  If no, then set to default. ***/
			IF lowaxischk = '' OR INVALIDAXIS='YES' THEN CALL SYMPUT("lowaxis",0);  	  
			IF upaxischk  = '' OR INVALIDAXIS='YES' THEN DO;
                                        /* v9 */
	 	  			     IF MAX < 5   THEN CALL SYMPUT('UPAXIS',5);
					ELSE IF MAX < 10  THEN CALL SYMPUT('UPAXIS',10);
					ELSE IF MAX < 20  THEN CALL SYMPUT('UPAXIS',20);
					ELSE IF MAX < 30  THEN CALL SYMPUT('UPAXIS',30);
					ELSE IF MAX < 50  THEN CALL SYMPUT('UPAXIS',50);
					ELSE IF MAX < 75  THEN CALL SYMPUT('UPAXIS',75);
					ELSE IF MAX < 75  THEN CALL SYMPUT('UPAXIS',75);
					ELSE IF MAX < 100 THEN CALL SYMPUT('UPAXIS',100);
	 	  			ELSE IF MAX < 125 THEN CALL SYMPUT('UPAXIS',125);
					ELSE IF MAX < 150 THEN CALL SYMPUT('UPAXIS',150);
					ELSE IF MAX < 175 THEN CALL SYMPUT('UPAXIS',175);
	 	  			ELSE IF MAX < 200 THEN CALL SYMPUT('UPAXIS',200);
	 	  			ELSE IF MAX < 225 THEN CALL SYMPUT('UPAXIS',225);
					ELSE IF MAX < 250 THEN CALL SYMPUT('UPAXIS',250);
	 	  			ELSE IF MAX < 300 THEN CALL SYMPUT('UPAXIS',300);
					ELSE IF MAX < 350 THEN CALL SYMPUT('UPAXIS',350);
					ELSE IF MAX < 400 THEN CALL SYMPUT('UPAXIS',400);
	 	  			ELSE IF MAX < 450 THEN CALL SYMPUT('UPAXIS',450);
					ELSE IF MAX < 500 THEN CALL SYMPUT('UPAXIS',500);
			END;
/*********************************
			IF axisbychk  = '' OR INVALIDAXIS='YES' THEN DO;
				IF MAX < 125 THEN CALL SYMPUT("axisby", 5 );
					     ELSE CALL SYMPUT("axisby", 10);
			END;
*********************************/

			IF UPAXISCHK ^='' AND (MAX > Upaxischk or MIN < Lowaxischk) AND INVALIDAXIS^='YES' THEN DO;
				CALL SYMPUT('CIWARNING', 'YES');
			END;
			PUT _ALL_;
		RUN; 
	%END;

	%GLOBAL HLOWAXIS HUPAXIS HAXISBY;
	DATA _NULL_; 
		SET PLOTSETUP;		
		
		%IF %SUPERQ(REPORTYPE)=CORR %THEN %DO;        /*** Subset for reportype = CORR to select only testB data ***/
			%IF %SUPERQ(IMPFLAG)=YES %THEN %DO;
				WHERE COMPRESS(test)="&testBNEW" AND COMPRESS(stage2,'- ')="&stageBNEW";
			%END;
			%ELSE %DO;
				WHERE COMPRESS(test)="&testBNEW" AND COMPRESS(stage,'- ')="&stageBNEW" AND COMPRESS(peak)="&peakBNEW";
			%END;
		%END;

		INVALIDAXIS="&INVALIDHAXIS"; HAXISCHK="&HAXISCHK";  USERHLOWAXIS="&USERHLOWAXIS"; USERHUPAXIS="&USERHUPAXIS"; USERHAXISBY="&USERHAXISBY";
		/*** Check to see if user entered valid axis values, otherwise set to default ***/
		
		%IF %SUPERQ(reportype)=CORR %THEN %DO;
			IF INVALIDAXIS='YES' OR (HAXISCHK^='USER')  THEN CALL SYMPUT('hlowaxis', put(lowaxis,7.3)); ELSE CALL SYMPUT('HLOWAXIS',"&USERHLOWAXIS");
			IF INVALIDAXIS='YES' OR (HAXISCHK^='USER')  THEN CALL SYMPUT('hupaxis', put(upaxis,7.3));   ELSE CALL SYMPUT('HUPAXIS',"&USERHUPAXIS");
			IF INVALIDAXIS='YES' OR (HAXISCHK^='USER')  THEN CALL SYMPUT('haxisby',put((upaxis-lowaxis)/5,7.3)); ELSE CALL SYMPUT('HAXISBY',"&USERHAXISBY");
		%END;
	RUN;
		
	%GLOBAL FOOTNOTE HWARNING VWARNING WARNING userupaxis userlowaxis HAXIS HAXISHIST;

	DATA HAXIS; SET MAXDATA; 
		/***  Setup axis statements for horizontal axis ***/
		CALL SYMPUT("HAXIS","ORDER= (&hlowaxis TO &hupaxis BY &haxisby)");     /*** For SCATTER and CORR plots   ***/
  		VALUE="&VALUE";
		HAXISCHK="&HAXISCHK";
		minchk="&hlowaxis";    /***  Check to see if user axis values do not include all data points.  If not    ***/
  		maxchk="&hupaxis";     /***  setup warning macro variable.  Setup warning2 macro variable to alert user with ***/
  		IF HAXISCHK='USER' THEN DO; /***  asterisk that slopes were calculated inside of data range              ***/
			
			%IF %SUPERQ(REPORTYPE)=CORR %THEN %DO;
				IF TEST="&TESTB" THEN DO;  
					IF (VALUE='MEAN' AND (minMEAN < minCHK) OR (maxMEAN > maxchk)) OR
			   		(VALUE='INDIVIDUAL' AND (minIND < minCHK) OR (maxIND > maxchk))
					THEN CALL SYMPUT('Hwarning','YES');
					ELSE CALL SYMPUT('HWARNING',' ');
				END;
			%END;
		END;
	RUN;

   	%GLOBAL VAXIS MIDPOINTS;       /***  Setup vertical axis and histogram midpoints for TestA only.                 ***/
				       /***  Create warning MACRO variables if data exists outside of user               ***/
	DATA VAXIS; SET maxdata;       /***  defined axis range.                                                         ***/

		%IF %SUPERQ(TESTA)^=ALL %THEN %DO;
			/*** Select only testa data                                  ***/
			%IF %SUPERQ(IMPFLAG)=YES %THEN %DO;  
				WHERE test="&testA" AND COMPRESS(stage,'- ')="&stageANEW";
			%END;
			%ELSE %DO;
				WHERE test="&testA" AND COMPRESS(stage,'- ')="&stageANEW" AND peak="&peakA";
			%END;
		%END;
  		VALUE="&VALUE";
  		lowaxischk2="&lowaxis";  upaxischk2="&upaxis";  AXISBYCHK="&AXISBY";
  		reporttype="&reportype";
		INVALIDAXIS="&INVALIDVAXIS";
		VAXISCHK="&VAXISCHK";
		reportchk="&reportype";
		CALL SYMPUT("VAXIS","ORDER= (&lowaxis TO &upaxis BY &axisby)"); /*** Setup vertical axis statement       ***/

		IF lowaxischk2=upaxischk2 AND INVALIDAXIS ^='YES' THEN CALL SYMPUT('VAXIS','');
		IF upaxischk2<0.01 or axisbyCHK<0.01 THEN CALL SYMPUT('MIDPOINTS','');
		/*** Setup histogram midpoints statement ***/
  		ELSE CALL SYMPUT('HAXISHIST','midpoints='||put(&lowaxis,7.3)||' TO '||put(&upaxis,7.3)||' BY '||put(&axisby,8.4));  
		/***  Check to see if user axis values do not include all data points.   ***/
   		IF reporttype IN ('CORR','HISTIND','SBAR','XBAR','INDRUN','CIPROFILES') AND TEST="&TESTA" THEN DO;  
			IF VAXISCHK='USER' THEN DO;	
				/***  If not, setup warning flag.  ***/
			     IF reportchk='HISTIND' THEN  divisor=40; 	/* If the plot is a histogram THEN SET the axisby divisor to 40 */
  		                                    ELSE  divisor=5 ;   /* and the ypixels to 700,otherwise SET the axisby divisor to 5 */
						   		        /* and the ypixels to 400. */
			     IF reporttype='SBAR' THEN DO;
				IF  (VALUE='MEAN'       and ((minstd < lowaxischk2) OR (maxstd > upaxischk2))) OR
				    (VALUE='INDIVIDUAL' and ((minind < lowaxischk2) OR (maxind > upaxischk2)))    
				    THEN DO;
					CALL SYMPUT('vwarning','YES');	
					CALL SYMPUT("VAXIS","ORDER= (&LowAxis TO &UpAxis BY &axisby)"); /*** Setup vertical axis statement       ***/	
					CALL SYMPUT('LowAxis',"&LowAxis");
					CALL SYMPUT('UpAxis',"&UpAxis");
/***********
					CALL SYMPUT("VAXIS","ORDER= (&CalcLowAxis TO &CalcUpAxis BY &axisby)"); 
					CALL SYMPUT('LowAxis',"&CalcLowAxis");
					CALL SYMPUT('UpAxis',"&CalcUpAxis");
************/
				    END;
			     END;
			     ELSE DO;
				IF  (VALUE='MEAN'       and ((minmean < lowaxischk2) OR (maxmean > upaxischk2))) OR
				    (VALUE='INDIVIDUAL' and ((minind  < lowaxischk2) OR (maxind > upaxischk2)))    
				    THEN DO;
					CALL SYMPUT('vwarning','YES');	
					IF reporttype^='INDRUN' THEN DO;
						CALL SYMPUT("VAXIS","ORDER= (&LowAxis TO &UpAxis BY &axisby)"); /*** Setup vertical axis statement       ***/
						CALL SYMPUT('LowAxis',"&LowAxis");
						CALL SYMPUT('UpAxis',"&UpAxis");
/***********
					CALL SYMPUT("VAXIS","ORDER= (&CalcLowAxis TO &CalcUpAxis BY &axisby)"); 
					CALL SYMPUT('LowAxis',"&CalcLowAxis");
					CALL SYMPUT('UpAxis',"&CalcUpAxis");
************/
					END;
				    END;
			     END;
			     CALCAXISBY=(&calcupaxis-&calclowaxis)/divisor;
			     CALL SYMPUT('CALCAXISBY',CALCAXISBY);
			END;  
   		END;
	RUN;		
	********************************;
	***  Create title variables  ***;
	********************************;

	/*** Create dataset with one observation per product ***/
	PROC SORT DATA=ALLDATA_WITH_STATS NODUPKEY OUT=product0; BY product; where product is not null;
	RUN; 

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
		***********************************************************************************;
		*** If there are only 2 products, separate by the word (and)                    ***;
                *** Other wise separate by commas except for final 2 products separate by (and) ***;
		***********************************************************************************;
   		%IF &i < &numprods %THEN %DO;
 	        	%IF &numprods=2 	  %THEN %LET prodlist0=&prodlist and;  
 			%ELSE %IF &i = &numprods2 %THEN %LET prodlist0=&prodlist and;  
 			%ELSE  			  %LET prodlist0=&prodlist ,;
     		%END;
    	%END;

	%GLOBAL TITLE_product TITLE_test TITLE_testb TITLE_PEAKA TITLE_PEAKb;
	/*** Create MACRO variable for product for use in title statements ***/
	%LET TITLE_product=&prodlist;	

	DATA _NULL_;
	    peakA="&peakA";  TESTA="&TESTA";
		stageA="&stageA";  IMPFLAG="&IMPFLAG"; /*** Create MACRO variable for test A for use in title statements ***/
	    	IF STAGEA not IN ('NONE','') THEN CALL SYMPUT('TITLE_test',TRIM("&testA")||' '||left(TRIM(STAGEA)));
		                             ELSE CALL SYMPUT('TITLE_test',TRIM("&testA"));
		IF PEAKA not IN ('NONE','') AND IMPFLAG^='YES' 
			/*** Create MACRO variable for peak A for use in title statements ***/
			THEN CALL SYMPUT('TITLE_PEAKA', TRIM(PEAKA)); 

		TESTB="&TESTB";peakb="&peakb";stageb="&stageb";

	    	/*** Create MACRO variable for test B for use in title statements ***/
		IF STAGEB not IN ('NONE','') THEN CALL SYMPUT('TITLE_testb',TRIM("&testb")||' '||left(TRIM(STAGEb)));
		                             ELSE CALL SYMPUT('TITLE_testb',TRIM("&testb"));
		IF PEAKb not IN ('NONE','') AND UPCASE(COMPRESS(TESTB)) NOT IN ('HPLCRELATEDIMP.INADVAIRMDPI') 
		THEN CALL SYMPUT('TITLE_PEAKb', TRIM(PEAKb));  /*** Create MACRO variable for peak B for use in title statements ***/
	RUN;

	%IF %SUPERQ(TESTA)=ALL %THEN %LET TITLE_TEST= ;

	%GLOBAL testAchk TESTBchk STAGEBchk PEAKBCHK condchk prodchk stageAchk peakAchk; /*** Setup comparison variables ***/

	DATA _NULL_ ;
  		CALL SYMPUT('testachk', TRIM("&testA"));
  		CALL SYMPUT('testbchk', TRIM("&testB"));
  		CALL SYMPUT('prodchk',  TRIM("&product"));
  		CALL SYMPUT('stageAchk', TRIM("&stageA"));
  		CALL SYMPUT('peakachk',  TRIM("&peakA"));
  		CALL SYMPUT('stagebchk',TRIM("&stageB"));
  		CALL SYMPUT('peakbchk', TRIM("&peakB"));
	RUN;

	%GLOBAL _REPLAY2;
	DATA _NULL_; LENGTH replay $ 23767 dummy $40;       /*** Setup replay macros based on current time to ensure new ***/
  		replay=symget('_replay');		    /*** graph is displayed for each request.                    ***/
  		dummy= PUT(datetime(), best12.);
  		replay = tranwrd(replay,'&_entry=','&dummy=' ||COMPRESS(dummy)|| '&_entry=');
  		CALL SYMPUT('_replay2',TRIM(replay));
	RUN;

	PROC SUMMARY DATA=BATCHES2A;&where2; 
		VAR MATL_MFG_DT;
		OUTPUT OUT=DATESUM MIN=MINDATE MAX=MAXDATE;
	RUN;
	%GLOBAL MINYEAR MAXYEAR STARTDATETITLE ENDDATETITLE;
	DATA _NULL_;SET DATESUM;
		NEWSTARTDT	=MINDATE;
		NEWENDDT	=MAXDATE;
		FORMAT newstartdt newenddt datetime20.;
		IF _N_ = 1 THEN PUT newstartdt newenddt;
	RUN;

	DATA _NULL_; LENGTH STARTDAY STARTMONTH STARTYEAR ENDDAY ENDMONTH ENDYEAR 3; SET DATESUM;
		MINDATE2=DATEPART(MINDATE);
		MAXDATE2=DATEPART(MAXDATE);
		CALL SYMPUT('MINYEAR',YEAR(MINDATE2));
		CALL SYMPUT('MAXYEAR',YEAR(MAXDATE2));
		DATECHECK="&DATECHECK";
		STARTDAY="&STARTDAY";
		STARTMONTH="&STARTMONTH";
		STARTYEAR="&STARTYEAR";
		%IF %SUPERQ(reportype)^=CORR %THEN %DO;
			IF STARTDAY=. OR DATECHECK='STOP' OR "&TESTA"^="&save_testinit" OR "&REPORTYPE"^="&save_rptinit" THEN DO;
				STARTDAY=COMPRESS(DAY(MINDATE2));
				CALL SYMPUT('STARTDAY',COMPRESS(DAY(MINDATE2)));
			END;
			IF STARTMONTH=. OR DATECHECK='STOP' OR "&TESTA"^="&save_testinit" OR "&REPORTYPE"^="&save_rptinit" THEN DO;
				STARTMONTH=COMPRESS(MONTH(MINDATE2));
				CALL SYMPUT('STARTMONTH',COMPRESS(MONTH(MINDATE2)));
			END;
			IF STARTYEAR=. OR DATECHECK='STOP' OR "&TESTA"^="&save_testinit" OR "&REPORTYPE"^="&save_rptinit" THEN DO;
				STARTYEAR=COMPRESS(YEAR(MINDATE2));
				CALL SYMPUT('STARTYEAR',COMPRESS(YEAR(MINDATE2)));
			END;
		%END;
		ENDDAY="&ENDDAY";
		ENDMONTH="&ENDMONTH";
		ENDYEAR="&ENDYEAR";
		%IF %SUPERQ(reportype)^=CORR %THEN %DO;
			IF ENDDAY=. OR DATECHECK='STOP' OR "&TESTA"^="&save_testinit" OR "&REPORTYPE"^="&save_rptinit" THEN DO;
				ENDDAY=COMPRESS(DAY(MAXDATE2));
				CALL SYMPUT('ENDDAY',COMPRESS(DAY(MAXDATE2)));
			END;
			IF ENDMONTH=. OR DATECHECK='STOP' OR "&TESTA"^="&save_testinit" OR "&REPORTYPE"^="&save_rptinit" THEN DO;
				ENDMONTH=COMPRESS(MONTH(MAXDATE2));
				CALL SYMPUT('ENDMONTH',COMPRESS(MONTH(MAXDATE2)));
			END;
			IF ENDYEAR=. OR DATECHECK='STOP' OR "&TESTA"^="&save_testinit" OR "&REPORTYPE"^="&save_rptinit" THEN DO;
				ENDYEAR=COMPRESS(YEAR(MAXDATE2));
				CALL SYMPUT('ENDYEAR',COMPRESS(YEAR(MAXDATE2)));
			END;
		%END;
		%IF %SUPERQ(reportype)=CORR %THEN %DO;
				STARTDAY=COMPRESS(DAY(MINDATE2));
				CALL SYMPUT('STARTDAY',COMPRESS(DAY(MINDATE2)));
				STARTMONTH=COMPRESS(MONTH(MINDATE2));
				CALL SYMPUT('STARTMONTH',COMPRESS(MONTH(MINDATE2)));
				STARTYEAR=COMPRESS(YEAR(MINDATE2));
				CALL SYMPUT('STARTYEAR',COMPRESS(YEAR(MINDATE2)));
				ENDDAY=COMPRESS(DAY(MAXDATE2));
				CALL SYMPUT('ENDDAY',COMPRESS(DAY(MAXDATE2)));
				ENDMONTH=COMPRESS(MONTH(MAXDATE2));
				CALL SYMPUT('ENDMONTH',COMPRESS(MONTH(MAXDATE2)));
				ENDYEAR=COMPRESS(YEAR(MAXDATE2));
				CALL SYMPUT('ENDYEAR',COMPRESS(YEAR(MAXDATE2)));
		%END;


		CALL SYMPUT('STARTDATETITLE', PUT(MDY(STARTMONTH, STARTDAY, STARTYEAR),MMDDYY8.));
		CALL SYMPUT('ENDDATETITLE', PUT(MDY(ENDMONTH, ENDDAY, ENDYEAR), MMDDYY8.));

		CALL SYMPUT('STARTQUERYDATE',MDY(STARTMONTH, STARTDAY, STARTYEAR));
		CALL SYMPUT('ENDQUERYDATE',MDY(ENDMONTH, ENDDAY, ENDYEAR));

		FORMAT MINDATE2 MAXDATE2 MMDDYY8.;PUT MINDATE2 MAXDATE2;
	RUN;

	DATA BATCHES2; SET BATCHES2;
		WHERE CREATE_DATE2 >= &STARTQUERYDATE AND CREATE_DATE2 <= &ENDQUERYDATE;
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
	%IF %SUPERQ(reportype)^=HISTIND %THEN %DO;%LET MAXPERCENT=1;%END;
	DATA _NULL_;  /* Setup Warning macro variables */
		FORMAT UprRefLine LowRefLine 7.;
		VALUE="&VALUE";SPECVAL="&SPECVAL";
		VAXISCHK="&VAXISCHK";
		USERUPAXIS="&USERUPAXIS";
		UprRefLine="&UprRefLine";
		USERLOWAXIS="&USERLOWAXIS";
		LowRefLine="&LowRefLine";
		%IF (%SUPERQ(VALUE)=%SUPERQ(SPECVAL) OR %SUPERQ(TESTA)=%STR(CU of Emitted Dose in Advair MDPI)) AND %SUPERQ(REPORTYPE)^=CORR %THEN %DO;
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
	%IF %SUPERQ(REPORTYPE)=XBAR %THEN %DO;
		DATA LIMITS; LENGTH _MEAN_ _LCLX_ _UCLX_ 3; SET MAXDATA;
		_LCLX_="&LCL";
		_UCLX_="&UCL";
		_X_="&BAR";
		_MEAN_=PUT(GRMEAN,6.2); 
		_VAR_='MEAN';
		_SUBGRP_='BATCH_NBR';
		%IF %SUPERQ(CTLLIMITS)=DEFAULT %THEN %DO;
			_LCLX_=PUT(GRMEAN-3*BETSTD,6.2);
			_UCLX_=PUT(GRMEAN+3*BETSTD,6.2);
			_X_=PUT(GRMEAN,6.2);
			_MEAN_=PUT(GRMEAN,6.2);
		%END;
		%ELSE %IF %SUPERQ(CTLLIMITS)=USER %THEN %DO;
			_LCLX_="&USERLCL";
			_UCLX_="&USERUCL";
			_X_   ="&USERBAR";
			_MEAN_="&USERBAR";
	/*		_X_ = ("&USERUCL"-"&USERLCL")/2 + "&USERLCL";*/
		%END;
		_STDDEV_=BETSTD;
		CHARFLAG='N';
		IF _LCLX_ < 0 THEN _LCLX_=0;
		if indexc(COMPRESS(UPCASE(_LCLX_)),'ABCDEFGHIJKLMNOPQRSTUVWXYZ !@#$%^&*()_-+=') > 0 OR
		   indexc(COMPRESS(UPCASE(_UCLX_)),'ABCDEFGHIJKLMNOPQRSTUVWXYZ !@#$%^&*()_-+=') > 0 OR
		   indexc(COMPRESS(UPCASE(_X_)),'ABCDEFGHIJKLMNOPQRSTUVWXYZ !@#$%^&*()_-+=') > 0 
			THEN CHARFLAG='Y';		
		%IF %SUPERQ(CTLLIMITS)^=NONE OR CHARFLAG='Y' %THEN %DO;
			
			IF _UCLX_ < _LCLX_ OR CHARFLAG='Y' THEN DO; 
				_LCLX_ = PUT(GRMEAN-3*BETSTD,6.2); 	CALL SYMPUT('LCL',_LCLX_);
				_UCLX_ = PUT(GRMEAN+3*BETSTD,6.2); 	CALL SYMPUT('UCL',_UCLX_);
				_X_    = PUT(GRMEAN,6.2);		CALL SYMPUT('BAR',_X_);
				_MEAN_ = PUT(GRMEAN,6.2);		CALL SYMPUT('BAR',_MEAN_);
				CALL SYMPUT('INVALIDLIMITS','YES');
				CALL SYMPUT('CTLLIMITS','DEFAULT');
			END;
		%END;
		put _MEAN_ _VAR_ _SUBGRP_ _LCLX_ _UCLX_ _STDDEV_ _X_ GRMEAN BETSTD charflag;
		KEEP TEST STAGE PEAK _MEAN_ _VAR_ _SUBGRP_ _LCLX_ _UCLX_ _STDDEV_ _X_ ;
		RUN;
	%END;

	/* Print warning for invalid user axis values */
  	%IF %SUPERQ(PRINT)^=ON and %SUPERQ(TESTA) ^= ALL %THEN %DO;
		%IF %SUPERQ(INVALIDLIMITS)=YES %THEN %DO;
			/******************************************************/
			/* Added V9 - warn about error caused by single batch */
			/*            (no std dev is possible)                */
			/******************************************************/
			%IF %SUPERQ(DATACHECK3)=STOP %THEN %DO;
			    DATA _NULL_; FILE _WEBOUT;
				CALL SYMPUT("VAXIS","ORDER= (&lowaxis TO &upaxis BY &axisby)"); /*** Setup vertical axis statement       ***/
		  		PUT '</BR><P ALIGN=CENTER><STRONG><FONT FACE=ARIAL COLOR=RED>**Insufficient data to create chart.**</FONT></STRONG></BR></BR>';
 			    RUN;
			%END;
		%ELSE %DO;
		    DATA _NULL_; FILE _WEBOUT;
			CALL SYMPUT("VAXIS","ORDER= (&lowaxis TO &upaxis BY &axisby)"); /*** Setup vertical axis statement       ***/
	  		PUT '</BR><P ALIGN=CENTER><STRONG><FONT FACE=ARIAL COLOR=RED>**NOTE: You entered invalid control limits.  Default limits were used.**</FONT></STRONG></BR>';
 		    RUN;
		%END;
		%END;
		%ELSE %IF (%SUPERQ(INVALIDVAXIS)=YES OR %SUPERQ(INVALIDHAXIS)=YES) %THEN %DO;
			DATA _NULL_; FILE _WEBOUT;
				PUT '</BR><P ALIGN=CENTER><STRONG><FONT FACE=ARIAL COLOR=RED>**NOTE: You entered invalid axis values.  Default axis values were used.**</FONT></STRONG></BR>';
				CALL SYMPUT('INVALIDAXIS','YES');
				lowaxis=put(&lowaxis,7.3);CALL SYMPUT('Lowaxis',lowaxis);
				upaxis=put(&upaxis,7.3); CALL SYMPUT('Upaxis',upaxis);
				axisby=put(&axisby,8.4);  CALL SYMPUT('axisby',axisby);
/*********
				lowaxis=put(&low_error,7.3);CALL SYMPUT('Lowaxis',lowaxis);
				upaxis=put(&upr_error,7.3); CALL SYMPUT('Upaxis',upaxis);
				axisby=put(&err_axis,8.4);  CALL SYMPUT('axisby',axisby);
********/
				CALL SYMPUT('MAXPERCENT',"&OBSMAXPCT");
	 		RUN;
		%END;
		%ELSE %IF %SUPERQ(INVALIDMAXAXIS)=YES  %THEN %DO;
			DATA _NULL_; FILE _WEBOUT;
				PUT '</BR><P ALIGN=CENTER><STRONG><FONT FACE=ARIAL COLOR=RED>**NOTE: You entered an invalid max axis value.  Default axis value was used.**</FONT></STRONG></BR>';
				CALL SYMPUT('MAXPERCENT',"&OBSMAXPCT");
	 		RUN;
		%END;
	%END;

	DATA _NULL_;  /* Setup Warning macro variables */
		reportchk="&reportype";lowaxis=TRIM(LEFT("&lowaxis"));upaxis=TRIM(LEFT("&upaxis"));
		IF reportchk='HISTIND' THEN  divisor=40; 	/* If the plot is a histogram THEN SET the axisby divisor to 40 */
  		                       ELSE  divisor=5 ;        /* and the ypixels to 700,otherwise SET the axisby divisor to 5 */
								/* and the ypixels to 400. */
		INVALIDVAXIS="&INVALIDVAXIS"; VAXISCHK="&VAXISCHK"; INVALIDAXIS="&INVALIDAXIS";
		USERLOWAXIS="&USERLOWAXIS"; USERUPAXIS="&USERUPAXIS"; USERAXISBY="&USERAXISBY";	
		/* Check to see if user has entered valid axis values.  If no, then set to default. */
		AXISBY=PUT((upaxis-lowaxis)/divisor,8.4);
		%IF %SUPERQ(INVALIDAXIS)=YES OR %SUPERQ(INVALIDVAXIS)=YES OR %SUPERQ(VAXISCHK)^=USER  
			%THEN %DO;
				CALL SYMPUT("lowaxis",PUT(lowaxis,7.3)); 
			        CALL SYMPUT("upaxis", PUT(upaxis,7.3));    
				CALL SYMPUT("axisby", PUT(axisby,8.4));          
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
		IF REFWARNING='' AND INVALIDAXIS='' THEN DO;
			IF (HWARNING='' AND INVALIDHAXIS='') AND (VWARNING='YES' OR INVALIDVAXIS='YES') THEN DO;
			IF REPORTYPE='PRODRELEASE' THEN CALL SYMPUT('WARNING', 'FOOTNOTE F=ARIAL H=1.2 COLOR=red "**NOTE: Data points exist outside user defined axis range. Default axis used.**"');
			                           ELSE CALL SYMPUT('WARNING', 'FOOTNOTE F=ARIAL H=1.2 COLOR=red "**WARNING: Data points exist outside user defined vertical axis range.**"');
			END;
			ELSE IF (HWARNING='YES' OR INVALIDHAXIS='YES') AND (VWARNING='' AND INVALIDVAXIS='')   
						   THEN CALL SYMPUT('WARNING', 'FOOTNOTE F=ARIAL H=1.2 COLOR=red "**WARNING: Data points exist outside user defined horizontal axis range.**"');
	  		ELSE IF (HWARNING='YES' OR INVALIDHAXIS='YES') AND (VWARNING='YES' OR INVALIDVAXIS='YES')
						   THEN CALL SYMPUT('WARNING', 'FOOTNOTE F=ARIAL H=1.2 COLOR=red "**WARNING: Data points exist outside both user defined axis ranges.**"');
	  		ELSE                            CALL SYMPUT('WARNING','');
		END;
	RUN;

	DATA _NULL_;SET maxdata;	
  		%IF %SUPERQ(IMPFLAG)=YES %THEN %DO;  /* Select only testa data */
			WHERE test="&testA" AND COMPRESS(stage,'- ')="&stageANEW";
		%END;
		%ELSE %DO;
			WHERE compress(test)=compress("&testA") AND COMPRESS(stage,'- ')="&stageANEW" AND UPCASE(peak)=UPCASE("&peakA");
		%END;
  		VALUE="&VALUE";
  		lowaxischk2=TRIM(LEFT("&lowaxis"));     upaxischk2=TRIM(LEFT("&upaxis"));      AXISBYCHK=TRIM(LEFT("&AXISBY"));
  		lowuserchk2="&USERLOWAXIS";  upuserchk2="&USERUPAXIS";  
  		reporttype="&reportype";
		INVALIDAXIS="&INVALIDVAXIS";
		VAXISCHK="&VAXISCHK";

		IF lowaxischk2=upaxischk2 AND INVALIDAXIS ^='YES' THEN CALL SYMPUT('VAXIS','');
		IF upaxischk2<0.01 or axisbyCHK<0.01 THEN CALL SYMPUT('MIDPOINTS','');
  		ELSE CALL SYMPUT('HAXISHIST','midpoints='||put(&lowaxis,7.3)||' TO '||put(&upaxis,7.3)||' BY '||put(&axisby,8.4));  /** Setup histogram midpoints statement **/
  
                ******************************************;
  		*** V2 - Revised Axis for graphs       ***; 
                ******************************************;
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

	%IF %SUPERQ(REFWARNING)^= AND %SUPERQ(INVALIDVAXIS)= AND %SUPERQ(INVALIDHAXIS)= %THEN %DO;
		DATA _NULL_; FILE _WEBOUT;
			PUT	"<P ALIGN=CENTER><BR><STRONG><FONT FACE=ARIAL COLOR=RED>**NOTE: Reference Lines exist outside user defined axis range. Default axis used.**</FONT></STRONG></BR>";
			lowaxis=put(&lowRefLine*.90,7.3);CALL SYMPUT('Lowaxis',lowaxis);
			upaxis=put(&uprRefLine*1.1,7.3); CALL SYMPUT('Upaxis',upaxis);
			axisby=put((upaxis-lowaxis)/5,8.4);  CALL SYMPUT('axisby',axisby);
		RUN;
	%END;
	%IF %SUPERQ(REPORTYPE)^=CORR AND %SUPERQ(REPORTYPE)^=INDRUN AND %SUPERQ(REPORTYPE)^=SCATTER %THEN %DO;

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
  		CALL SYMPUT('HAXISHIST','midpoints='||put(&lowaxis,7.3)||' TO '||put(&upaxis,7.3)||' BY '||put(&axisby,7.4));  /** Setup histogram midpoints statement **/
	RUN;

	%IF %SUPERQ(REPORTYPE)=HISTIND AND (%SUPERQ(INVALIDVAXIS)=YES OR %SUPERQ(INVALIDHAXIS)=YES) %THEN %DO;
			DATA _NULL_;
				CALL SYMPUT('VAXIS',"VAXIS=0 TO &MAXPERCENT");
			RUN;
			%IF %SUPERQ(VALUE)=MEAN %THEN %LET HISTRES=MEAN;
			%IF %SUPERQ(VALUE)=INDIVIDUAL %THEN %LET HISTRES=RESULT;
		  	PROC CAPABILITY DATA=ALLDATA_WITH_STATS noprint normaltest ;                                            
		    	VAR &HISTRES;                                                                
		    	LABEL result="Individual Batch Results"
				  mean="Batch Means";   
		     	HISTOGRAM  / NOCHART NOPLOT
		       		&href 
		       		&HAXIShist 
				nocurvelegend
			   	&VAXIS 
				OUTHISTOGRAM=OUTTABLE
			;   
		  	RUN;     
			DATA _NULL_;RETAIN HIGH 0;SET OUTTABLE;BY _VAR_;
				MAXPERCENT="&MAXPERCENT"; OBSMAXPCT="&OBSMAXPCT"; INVALIDMAXAXIS="&INVALIDMAXAXIS";
				PUT _ALL_;IF _OBSPCT_ > HIGH THEN HIGH = _OBSPCT_;
				IF LAST._VAR_ THEN CALL SYMPUT('MAXPERCENT',HIGH);
			RUN;
	%END;

	DATA _NULL_;
		CALL SYMPUT("VAXIS",'order=('||put(&lowaxis,7.3)||' TO '||put(&upaxis,7.3)||' BY '||put(&axisby,7.4)||')'); /** Setup vertical axis statement **/
	RUN;

%PUT _all_;
%MEND Warnings;
*******************************************************************************************************;
*                                      MODULE HEADER                                                  *;
*-----------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                        *;
*	     REQUIREMENT: See LINKS Report SOP                                                        *;
*       INPUT           : Macro variable: _replay                                                     *;
*       PROCESSING      : This code will be used if the user wants to save or print                   *;
*		 	  a LINKS report.   It also does the following:                               *;
*			  Sets up macro variables to ensure a new graph is displayed for each request.*;
*			  Opens ODS RTF statement.                                                    *;
*			  Sets up ODS close statement and device name.                                *;
*       OUTPUT          : Macro variable _replay2, close, device.                                     *;
*******************************************************************************************************;
%MACRO Print;
	%GLOBAL close device ;
	%IF %SUPERQ(VALUE)=ALLTESTS %THEN %LET VALUE=SUMMARY;
	DATA _NULL_;
		%IF %SUPERQ(REPORTYPE)=BATCHSTATS AND (%SUPERQ(VALUE)=SUMMARY OR %SUPERQ(VALUE)=INDIVIDUAL) %THEN %DO;
 			rc=appsrv_header('Content-disposition',"attachment; FILEname=LINKSBATCH&value.&save_uid..rtf");
	 	%END;
		%ELSE %IF %SUPERQ(REPORTYPE)=CORR AND (%SUPERQ(CORRTYPE)=PLOT OR %SUPERQ(CORRTYPE)=TABLE) %THEN %DO;
 			rc=appsrv_header('Content-disposition',"attachment; FILEname=LINKSCORR&corrtype.&save_uid..rtf");
	 	%END;
		%ELSE %DO;
 			rc=appsrv_header('Content-disposition',"attachment; FILEname=LINKS&reportype.&save_uid..rtf");
	 	%END;

		%IF %SUPERQ(REPORTYPE)=PRODSTATS %THEN %DO;  /* Added V2 - Change Option of print to Landscape for PRODSTATS */
 			OPTIONS ORIENTATION=LANDSCAPE;
	 	%END;
	RUN;

	ODS PATH work.templat(update) sasuser.templat(read)
		sashelp.tmplmst(read);

	/*** Define RTF file style ***/
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

***********************************************************************************************************;
*                                      MODULE HEADER                                                      *;
*---------------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                            *;
*	     REQUIREMENT: See LINKS Report SOP                                                            *;
*       INPUT           : Macro variables: _Replay2, _SERVICE, _PROGRAM, _SERVER, _PORT,                  *;
*			_SESSIONID, STUDY0, STUDY1,...STUDY#, LOWAXIS, UPAXIS, AXISBY, USERLOWAXIS,       *;
*			USERUPAXIS, USERAXISBY, HLOWAXIS, HUPAXIS, HAXISBY, USERHLOWAXIS,                 *;
*			USERHUPAXIS, USERHAXISBY, PRODUCT, STORAGE, TESTA, STAGEA, PEAKA, TESTB,          *;
*			STAGEB, PEAKB, REPORTYPE, VALUE, ANALYST, TIME, RPTVALUE, REPORTYPE,              *;
*			GROUPVAR, CORRTYPE, XPIXELS0, YPIXELS0,                                           *;
*			NUMPRODUCT, PRODUCT1,...PRODUCT#, NUMSTORAGE, STORAGE1,...STORAGE#, NUMTESTS,     *;
*			TEST1,...,TEST#, NUMSTAGES, STAGEA1,...,STAGEA#, NUMPEAKS, PEAKA1,...,PEAKA#,     *;
*			NUMANALYST, ANALYST1,...ANALYST#, NUMTIMES, TIME1,...,TIME#, NUMSTAGEB,           *;
*			STAGEB1,...,STAGEB#, NUMPEAKB, PEAKB1,...,PEAKB#, REG0, REG2.                     *;
*                                                                                                         *;
*       PROCESSING: This code will setup the device and ODS close macro variables.                        *;
*			It will also open the ODS HTML statement.                                         *;
*			This code will also create 20 drop down box menu HTML forms located               *;
*			on the left of the screen.  The forms will be automatically submitted             *;
*			upon a change in one of the drop down boxes by the user.                          *;
*                                                                                                         *;
*       OUTPUT          : 16 HTML forms with drop down boxes output to screen.                            *;
***********************************************************************************************************;
%MACRO WEBOUT;
*OPTIONS nomlogic nomprint nosymbolgen;

	%GLOBAL DEVICE CLOSE ;
	%LET close = ODS HTML CLOSE;
	%LET device=GIF;
	
	/*** Setup standard form variables ***/
	%MACRO THISSESSION;
		PUT   '<INPUT TYPE="hidden" NAME="_service" 	VALUE="default">';
  		LINE= '<INPUT TYPE="hidden" NAME="_program" 	VALUE="'||"links.LRBatchAnalysis.sas"	||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=_server    	VALUE="'||symget('_server')	   	||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=_port      	VALUE="'||symget('_port')		||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=_sessionid 	VALUE="'||symget('_sessionid')		||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=_DEBUG 	VALUE="131">'; 					PUT LINE; 
  	%MEND;

	%MACRO DATESECTION;
		LINE= '<INPUT TYPE="hidden" NAME=StartDay   	VALUE="'||TRIM("&StartDay")	   	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=StartMonth	VALUE="'||TRIM("&StartMonth")	   	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=StartYear   	VALUE="'||TRIM("&StartYear")	   	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=EndDay   	VALUE="'||TRIM("&EndDay")	   	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=EndMonth   	VALUE="'||TRIM("&EndMonth")	   	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=EndYear   	VALUE="'||TRIM("&EndYear")	   	||'">'; PUT LINE; 
  	%MEND;
	
	DATA _NULL_; LENGTH LINE anchor $1000;                /*** Create html table for drop down menus and checkboxes. ***/
  		FILE _WEBOUT;

		%IF %SUPERQ(REPORTYPE) = 'BATCHSTATS' OR %SUPERQ(REPORTYPE)='PRODSTATS' %THEN %LET WIDTH=120%;
		%ELSE %LET WIDTH=100%;

  		/*** Set up LINKS banner ***/
   		PUT '<BODY BGCOLOR="#808080"><TITLE>LINKS Batch Trending Analysis Tools - Unofficial Report If Printed From Web Browser</TITLE></BODY>';
  		LINE= '<TABLE ALIGN=CENTER WIDTH='||"&WIDTH"||' HEIGHT="100%" BORDER="1" BORDERCOLOR="#003366" CELLPADDING="0" CELLSPACING="0">'; PUT LINE;
  		PUT '<TR ALIGN="LEFT" ><TD COLSPAN=2 BGCOLOR="#003366">';
  		PUT '<TABLE ALIGN=left VALIGN=top HEIGHT="100%" WIDTH="100%"><TR><TD ALIGN=left><BIG><BIG><BIG>';
		LINE= '<IMG SRC="//'||"&_server"||'/links/images/gsklogo1.gif" WIDTH="141" HEIGHT="62">'; PUT LINE;
  		PUT '<FONT FACE=ARIAL COLOR="#FFFFFF"><EM> LINKS </EM> Batch Trending Module</FONT></BIG></BIG></BIG></TD>';

		/*** Setup hyperlink to Batch Trend Menu ***/
		ANCHOR= '<TD ALIGN=RIGHT><A HREF="'|| "%SUPERQ(_THISSESSION)" ||
		'&_program=links.LRReport.sas"><FONT FACE=ARIAL color="#FFFFFF">Back to Batch Trending Menu</FONT></A>';
		PUT ANCHOR; 

		/*** Setup link to print or save LINKS report ***/
  		anchor= '<TD ALIGN=right><A HREF="'|| "%superq(_THISSESSION)" ||'&print=ON
		&_program='		||"links.LRBatchAnalysis.sas"	||
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
		'&testA='		||"&testa"		  	||
		'&stageA='		||"&stageA"	       		||
		'&peakA='		||"&peakA"			||
 		'&VALUE='		||"&VALUE"	       		||
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
		'&BATCH='	  	||"&BATCH"			||
		'&StartDay='		||"&StartDay"	   		||
		'&StartMonth='		||"&StartMonth"		   	||
		'&StartYear='   	||"&StartYear"		   	||
		'&EndDay='   		||"&EndDay"		   	||
		'&EndMonth='   		||"&EndMonth"		   	||
		'&EndYear='   		||"&EndYear"		   	||
		'">"<FONT FACE=ARIAL COLOR="#FFFFFF">Print or Save Analysis</FONT></A></TD></TR></TABLE>'; 
	    	PUT anchor; 

  		PUT '</TD></TR>';

  	RUN;
	ODS HTML BODY=_WEBOUT RS=NONE PATH=&_TMPCAT (URL=&_REPLAY2);

	******************************************************************;
	*** FORM 1: HTML to change data status.                        ***;
	******************************************************************;
	DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; 
  		PUT   '<FONT FACE=arial SIZE=1>';
  		PUT   '<TR HEIGHT="87%"><TD BGCOLOR="#ffffdd" nowrap HEIGHT="25" WIDTH="20%" ALIGN="left" VALIGN="top">';
		PUT   '<TABLE WIDTH="100%" BORDER="0" ><TR ><TD BORDER="0" >';
		LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

		%THISSESSION;  	
		%DATESECTION; 	

		LINE= '<INPUT TYPE="hidden" NAME=lowaxis    	VALUE="'||TRIM("&lowaxis")	   	||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=upaxis     	VALUE="'||TRIM("&upaxis") 	   	||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=axisby     	VALUE="'||TRIM("&axisby") 	   	||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=hlowaxis   	VALUE="'||TRIM("&hlowaxis")	   	||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=hupaxis    	VALUE="'||TRIM("&hupaxis")	   	||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=haxisby    	VALUE="'||TRIM("&haxisby")	   	||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=xpixels0   	VALUE="'||TRIM("&xpixels0")	  	||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=ypixels0   	VALUE="'||TRIM("&ypixels0")	   	||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=product    	VALUE="'||TRIM("&product")	    	||'">'; PUT LINE; 

  		LINE= '<INPUT TYPE="hidden" NAME=testA      	VALUE="'||TRIM(symget("testA"))		||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=stageA     	VALUE="'||TRIM("&stageA")	    	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=peakA      	VALUE="'||TRIM("&peakA")	    	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=testB      	VALUE="'||TRIM("&testB")	    	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=PeakB      	VALUE="'||TRIM("&PeakB")	    	||'">'; PUT LINE; 
 		LINE= '<INPUT TYPE="hidden" NAME=StageB     	VALUE="'||TRIM("&StageB")	    	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=reportype  	VALUE="'||TRIM("&reportype")		||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=rptvalue   	VALUE="'||TRIM("&rptvalue")	    	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=VALUE      	VALUE="'||TRIM("&VALUE")   		||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=time       	VALUE="'||TRIM("&time")	       		||'">'; PUT LINE; 
   		LINE= '<INPUT TYPE="hidden" NAME=groupvar   	VALUE="'||TRIM("&groupvar")    		||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=corrtype   	VALUE="'||TRIM("&corrtype")    		||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=CTLLIMITS   	VALUE="'||TRIM("&CTLLIMITS")	   	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=USERLCL   	VALUE="'||TRIM("&USERLCL")	   	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=USERUCL   	VALUE="'||TRIM("&USERUCL")	   	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=USERBAR   	VALUE="'||TRIM("&USERBAR")	   	||'">'; PUT LINE; 

		%IF %SUPERQ(REPORTYPE)=BATCHSTATS %THEN %DO;
			LINE= '<INPUT TYPE="hidden" NAME=BATCH  VALUE="'||TRIM("&BATCH")	   	||'">'; PUT LINE; 
		%END;

		PUT '<STRONG><SMALL><FONT FACE="Arial" COLOR="#003366">Data Status:</FONT></SMALL></STRONG>';
  		PUT '</br>&nbsp;&nbsp;&nbsp;<SELECT NAME="DataType" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';

  		%IF %SUPERQ(DATATYPE)=ALL %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
      		LINE= '<OPTION '||"&SELECT"||' VALUE="ALL">All Data</OPTION>'; PUT LINE;
    		%IF %SUPERQ(DATATYPE)=APP %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
      		LINE= '<OPTION '||"&SELECT"||' VALUE="APP">Approved Data Only</OPTION>'; PUT LINE;	

      		PUT '</SELECT></TD></TR></FORM>';
  	RUN;
  	
	******************************************************************;
	*** FORM 2: HTML to change product.  Select current product.   ***;
	******************************************************************;
  	DATA _NULL_; LENGTH LINE $1000 ;  
  		FILE _WEBOUT;
  		PUT   '<FONT FACE=arial SIZE=1>';
  		PUT   '<TR BGCOLOR="#ffffdd"><TD BGCOLOR="#FFFFDD">';
  		LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

		%THISSESSION;
		%DATESECTION;

  		LINE= '<INPUT TYPE="hidden" NAME=xpixels0   	VALUE="'||TRIM("&xpixels0")		||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=ypixels0   	VALUE="'||TRIM("&ypixels0")		||'">'; PUT LINE;
  		LINE= '<INPUT TYPE="hidden" NAME=stageA     	VALUE="'||TRIM("&stageA")	    	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=testA      	VALUE="'||TRIM("&testA")	   	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=VALUE      	VALUE="'||TRIM("&VALUE")	   	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=time       	VALUE="'||TRIM("&time")	       		||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=rptvalue   	VALUE="'||TRIM("&rptvalue")	   	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=testB      	VALUE="'||TRIM("&testB")	   	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=StageB     	VALUE="'||TRIM("&StageB")	   	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=PeakB      	VALUE="'||TRIM("&PeakB")	   	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=DataType   	VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=reportype  	VALUE="'||TRIM("&reportype")		||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=GROUPVAR   	VALUE="'||TRIM("&GROUPVAR")	    	||'">'; PUT LINE; 
 		LINE= '<INPUT TYPE="hidden" NAME=CORRTYPE   	VALUE="'||TRIM("&CORRTYPE")	    	||'">'; PUT LINE; 
		
		%IF %SUPERQ(REPORTYPE)=BATCHSTATS %THEN %DO;
			LINE= '<INPUT TYPE="hidden" NAME=BATCH  VALUE="'||TRIM("&BATCH")	   	||'">'; PUT LINE; 
		%END;

		PUT '<STRONG><SMALL><FONT FACE="Arial" COLOR="#003366">Product:</FONT></SMALL></STRONG>';
  		PUT '</br>&nbsp;&nbsp;&nbsp;<SELECT NAME="Product" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';

  		%LOCAL i;
	    	%DO i = 1 %TO &numproduct;   
      			%LET temp="&&product&i"; 
      			%LET temp2="&prodchk";   
                        *****************************************************************;
			*** If current product = product in list then select product. ***;
			*** Otherwise dont select it.                                 ***;
                        *****************************************************************;
      			%IF &temp=&temp2 %THEN %LET SELECT=selected; 	
      				 	 %ELSE %LET SELECT= ;		
      			LINE= '<OPTION '||"&SELECT"||' VALUE="'||"&&product&i"||'">'||"&&product&i"||'</OPTION>'; PUT LINE;
    		%END;
    	      	
  		PUT '</SELECT></TD></TR></FORM>';
  	RUN;
	******************************************************************;
	*** FORM 3: HTML to change test.  Select current test.         ***;
	******************************************************************;
/*
	DATA _NULL_; 
		CALL SYMPUT('temp', COMPRESS("&&test&i"));
		CALL SYMPUT('temp2', COMPRESS("&testACHK"));
	RUN;*/

	DATA _NULL_; LENGTH LINE $1000 ;   
  		FILE _WEBOUT;  
		reportype="&reportype";									
		IF REPORTYPE ^='CIPROFILES' THEN DO;							
  			PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
			LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

			%THISSESSION;
			%DATESECTION;

  			LINE= '<INPUT TYPE="hidden" NAME=xpixels0   	VALUE="'||TRIM("&xpixels0")	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=ypixels0   	VALUE="'||TRIM("&ypixels0")	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=product    	VALUE="'||TRIM("&product")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=reportype  	VALUE="'||TRIM("&reportype")   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=VALUE      	VALUE="'||TRIM("&VALUE")       	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=time       	VALUE="'||TRIM("&time")	        ||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=rptvalue   	VALUE="'||TRIM("&rptvalue")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testB      	VALUE="'||TRIM("&testB")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=StageB     	VALUE="'||TRIM("&StageB")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=PeakB      	VALUE="'||TRIM("&PeakB")	||'">'; PUT LINE; 
   			LINE= '<INPUT TYPE="hidden" NAME=CORRTYPE   	VALUE="'||TRIM("&CORRTYPE")	||'">'; PUT LINE;
			LINE= '<INPUT TYPE="hidden" NAME=DataType   	VALUE="'||TRIM("&DataType")	||'">'; PUT LINE; 

			%IF %SUPERQ(REPORTYPE)=BATCHSTATS %THEN %DO;
			LINE= '<INPUT TYPE="hidden" NAME=BATCH  	VALUE="'||TRIM("&BATCH")   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=StageA     	VALUE="'||TRIM("&StageA")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=PeakA      	VALUE="'||TRIM("&PeakA")	||'">'; PUT LINE; 
			%END;
						
  			PUT '<STRONG><SMALL><FONT FACE="Arial" COLOR="#003366">Test Method:</FONT></SMALL></STRONG>';
  			PUT '</br>&nbsp;&nbsp;&nbsp;<SELECT NAME="TestA" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';
  	    		%LOCAL i;
			/***  Select current test             ***/
    			%DO i = 1 %TO &numtest;                                     
		      		%LET temp="&&test&i";
	      			%LET temp2="&testachk";	

					%IF &temp=&temp2 %THEN %LET SELTEST=selected;
	      			                 %ELSE %LET selTEST= ;
			    	line= '<OPTION '||"&SELTEST"||' VALUE="'||"&&test&i"||'">'||
                                      '<FONT FACE=arial SIZE="1">'||"&&test&i"||'</FONT></OPTION>'; PUT line;
		    	%END;
			%IF %SUPERQ(REPORTYPE)=PRODSTATS OR %SUPERQ(REPORTYPE)=BATCHSTATS or %SUPERQ(REPORTYPE)=XBAR /*V?*/ %THEN %DO;
				%IF %SUPERQ(TESTA)=ALL %THEN %LET SELTEST=SELECTED;%ELSE %LET selTEST= ;
				line= '<OPTION '||"&SELTEST"||' VALUE="ALL">'||
                                      '<FONT FACE=arial SIZE="1">All Tests</FONT></OPTION>'; PUT line;
			%END;
			      	
	  		PUT '</SELECT></TD></TR></FORM>';
		END;											
 	RUN;

	******************************************************************;
	***  FORM 4: HTML TO CHANGE STAGE IF STAGE EXISTS              ***;
	******************************************************************;
	%IF %SUPERQ(TESTA) ^= ALL %THEN %DO;
	DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; 
  		numstages="&numstageA";	reportype="&Reportype";  PEAKA=COMPRESS(UPCASE("&PEAKA"));
  		IF numstages>1 and reportype ^= 'CIPROFILES' AND (peaka^='TOTALNUMBEROFPARTICLES') THEN DO;
  			PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
			LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

			%THISSESSION;
			%DATESECTION;  	
						
			LINE= '<INPUT TYPE="hidden" NAME=xpixels0   	VALUE="'||TRIM("&xpixels0")	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=ypixels0   	VALUE="'||TRIM("&ypixels0")	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=product    	VALUE="'||TRIM("&product")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testA      	VALUE="'||TRIM(symget("testA"))	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=peakA      	VALUE="'||TRIM("&peakA")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=reportype  	VALUE="'||TRIM("&reportype")	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=VALUE      	VALUE="'||TRIM("&VALUE")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=time       	VALUE="'||TRIM("&time")	       	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=rptvalue   	VALUE="'||TRIM("&rptvalue")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testB      	VALUE="'||TRIM("&testB")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=StageB     	VALUE="'||TRIM("&StageB")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=PeakB      	VALUE="'||TRIM("&PeakB")   	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=GROUPVAR   	VALUE="'||TRIM("&GROUPVAR")	||'">'; PUT LINE; 
 			LINE= '<INPUT TYPE="hidden" NAME=CORRTYPE   	VALUE="'||TRIM("&CORRTYPE")	||'">'; PUT LINE;
			LINE= '<INPUT TYPE="hidden" NAME=DataType   	VALUE="'||TRIM("&DataType")	||'">'; PUT LINE; 

			%IF %SUPERQ(REPORTYPE)=BATCHSTATS %THEN %DO;
			LINE= '<INPUT TYPE="hidden" NAME=BATCH  	VALUE="'||TRIM("&BATCH")   	||'">'; PUT LINE; 
			%END;

			CIFLAG="&CIFLAG";                                               /***  Setup drop down box label  ***/
  			IF CIFLAG NOT IN ("YES") 
				THEN PUT '<STRONG><FONT  FACE="Arial" SIZE="2" COLOR="#003366">&nbsp;&nbsp;&nbsp;<EM>Test Parameter:</EM></FONT></STRONG>';
  				ELSE PUT '<STRONG><FONT  FACE="Arial" SIZE="2" COLOR="#003366">&nbsp;&nbsp;&nbsp;<EM>CI Stage:</EM></FONT></STRONG>';
  
  			PUT '</br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
  			LINE= '<SELECT NAME="stageA" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">'; PUT LINE;

  			%LOCAL i;
	    		%DO i = 1 %TO &numstageA;   
     				%LET temp="&&stageA&i";                                 /***  Select current stage       ***/
      				%LET temp2="&stageAchk";
      				%IF &temp=&temp2 %THEN %LET selstage=selected;
      						 %ELSE %LET selstage= ;
      				line= '<OPTION '||"&selstage"||' VALUE="'||"&&stageA&i"||'">'||"&&stageA&i"||'</OPTION>'; PUT line;
    			%END;

			PUT '</SELECT></TD></TR></FORM>';
  		END;
	RUN;

	******************************************************************;
	***  FORM 5: HTML TO CHANGE PEAK IF PEAKS EXISTS               ***;
	******************************************************************;
	DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT;
  		numpeak="&numpeakA";	testa=COMPRESS("&testa");
  		IF numpeak>1 and UPCASE(COMPRESS(testa)) not IN ('HPLCRELATEDIMP.INADVAIRMDPI') THEN DO;
			PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
			LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

			%THISSESSION;
			%DATESECTION;
			
			LINE= '<INPUT TYPE="hidden" NAME=xpixels0    	VALUE="'||TRIM("&xpixels0")	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=ypixels0    	VALUE="'||TRIM("&ypixels0")	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=product     	VALUE="'||TRIM("&product")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testA       	VALUE="'||TRIM(symget("testA"))	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=stageA      	VALUE="'||TRIM("&stageA")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=reportype   	VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=time        	VALUE="'||TRIM("&time")	    	||'">'; PUT LINE; 
   			LINE= '<INPUT TYPE="hidden" NAME=VALUE       	VALUE="'||TRIM("&VALUE")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=rptvalue    	VALUE="'||TRIM("&rptvalue")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testB       	VALUE="'||TRIM("&testB")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=StageB      	VALUE="'||TRIM("&StageB")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=PeakB       	VALUE="'||TRIM("&PeakB")  	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=GROUPVAR    	VALUE="'||TRIM("&GROUPVAR")	||'">'; PUT LINE; 
 			LINE= '<INPUT TYPE="hidden" NAME=CORRTYPE    	VALUE="'||TRIM("&CORRTYPE")	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=DataType    	VALUE="'||TRIM("&DataType")	||'">'; PUT LINE; 

			%IF %SUPERQ(REPORTYPE)=BATCHSTATS %THEN %DO;
			LINE= '<INPUT TYPE="hidden" NAME=BATCH  	VALUE="'||TRIM("&BATCH")   	||'">'; PUT LINE; 
			%END;

			PUT '<STRONG><FONT  FACE="Arial" SIZE="2" COLOR="#003366" ><EM>';
			/*** Setup drop down box label                   ***/
			IF COMPRESS(TESTA) IN ('ForeignParticulateMatter') 
				THEN	PUT '&nbsp;&nbsp;&nbsp;Particle Size:'; 	
				ELSE	PUT '&nbsp;&nbsp;&nbsp;Drug Substance:';	
			PUT '</EM></FONT></STRONG>';
			PUT '</br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			PUT '<SELECT NAME="PeakA" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';

			%LOCAL i;
    			%DO i = 1 %TO &numpeakA;   
	    			%LET temp="&&peakA&i";                                        /***  Select current peak  ***/
		        	%LET temp2="&peakAchk";
      				%IF &temp=&temp2 %THEN %LET selpeak=selected;
      						 %ELSE %LET selpeak= ;
	        		line= '<OPTION '||"&selpeak"||' VALUE="'||"&&peakA&i"||'">'||"&&peakA&i"||'</OPTION>'; 
				PUT line;
    			%END;	  
  
	 	  	PUT '</SELECT></TD></TR></FORM>';
  		END;
	RUN;
	%END;

	******************************************************************;
	***  FORM 6: HTML to change report type                        ***;
	******************************************************************;
	DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; 
  		PUT   '<TR><TD ><HR></tD></tR>'; 
   		PUT '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
		LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

		%THISSESSION;
		%DATESECTION;

  		LINE= '<INPUT TYPE="hidden" NAME=product    	VALUE="'||TRIM("&product")	       	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=testA      	VALUE="'||TRIM(symget("testA"))		||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=stageA     	VALUE="'||TRIM("&stageA")	       	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=peakA      	VALUE="'||TRIM("&peakA")	       	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=DataType   	VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=SortValue   	VALUE="'||TRIM("&SortValue")	   	||'">'; PUT LINE; 

			%IF %SUPERQ(REPORTYPE)=BATCHSTATS %THEN %DO;
			LINE= '<INPUT TYPE="hidden" NAME=BATCH  	VALUE="'||TRIM("&BATCH")   	||'">'; PUT LINE; 
  			%END;
  		PUT '<STRONG><SMALL><FONT FACE="Arial" COLOR="#003366">Report:</FONT><SMALL></STRONG>';
  		PUT '</br>&nbsp;&nbsp;&nbsp;<SELECT NAME="Reportype" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';

  		%MACRO stats;
	    		%IF %SUPERQ(reportype2)=%SUPERQ(reportype) 
				%THEN %LET selectstat=selected;                             /***  Select current report  ***/
	    			%ELSE %LET selectstat= ;
	       		line='<OPTION '||"&selectstat"||' VALUE="'||"&reportype2"||'">'||"&reportype3"||'</OPTION>'; PUT line;
  		%MEND;

  		%LET reportype2=XBAR; 		%LET reportype3=Mean Run Chart; 			%stats;
		%LET reportype2=SBAR; 		%LET reportype3=Standard Deviation Run Chart; 		%stats;
		%LET reportype2=INDRUN; 	%LET reportype3=Individual Run Chart;  			%stats;  
  		%LET reportype2=HISTIND;	%LET reportype3=Histogram; 				%stats;
  		%LET reportype2=PRODSTATS; 	%LET reportype3=Product Summary Statistics;		%stats;
		%LET reportype2=BATCHSTATS;	%LET reportype3=Batch Summary Statistics;		%stats;
  		%LET reportype2=CORR; 		%LET reportype3=Correlation Analysis; 			%stats;  		
  	RUN;

  	%LET reportype2= ;
  	%LET reportype3= ;

	/*** SETUP VARIABLES FOR CI PROFILES             ***/
 	DATA _NULL_;  
  		CIFLAG="&CIFLAG";
  		IF CIFLAG='YES' THEN DO;
     			CALL SYMPUT('reportype2','CIPROFILES');
		 	CALL SYMPUT('reportype3','Cascade Impaction Profiles');
  		END;
  		IF "&reportype"='INDRUN' THEN DO;
     			CALL SYMPUT('VALUE','INDIVIDUAL');
  		END;
  	RUN;

  	DATA _NULL_; FILE _WEBOUT;
  		CIFLAG="&CIFLAG";
  		IF CIFLAG='YES' THEN %stats;
	    	PUT '</SELECT></TD></TR></FORM>';
  	RUN;

	******************************************************************;
	***  FORM 7: HTML to change sort value                         ***;
	******************************************************************;
  	DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT;  

  		%IF %SUPERQ(REPORTYPE)=XBAR OR %SUPERQ(REPORTYPE)=SBAR OR %SUPERQ(REPORTYPE)=INDRUN 
		OR %SUPERQ(REPORTYPE)=BATCHSTATS %THEN %DO;
   			PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
			LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

			%THISSESSION;
			%DATESECTION;	

	  		LINE= '<INPUT TYPE="hidden" NAME=hlowaxis   	VALUE="'||TRIM("&hlowaxis")	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=hupaxis    	VALUE="'||TRIM("&hupaxis")	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=haxisby    	VALUE="'||TRIM("&haxisby")	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=xpixels0   	VALUE="'||TRIM("&xpixels0")	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=ypixels0   	VALUE="'||TRIM("&ypixels0")	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=product    	VALUE="'||TRIM("&product")	||'">'; PUT LINE; 

  			LINE= '<INPUT TYPE="hidden" NAME=storage    	VALUE="'||TRIM("&storage")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testA      	VALUE="'||TRIM(symget("testA"))	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=stageA     	VALUE="'||TRIM("&stageA")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=peakA      	VALUE="'||TRIM("&peakA")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=reportype  	VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=DataType   	VALUE="'||TRIM("&DataType")	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=CTLLIMITS   	VALUE="'||TRIM("&CTLLIMITS")	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=USERLCL   	VALUE="'||TRIM("&USERLCL")	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=USERUCL   	VALUE="'||TRIM("&USERUCL")	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=USERBAR   	VALUE="'||TRIM("&USERBAR")	||'">'; PUT LINE; 

			%IF %SUPERQ(REPORTYPE)=BATCHSTATS %THEN %DO;
			LINE= '<INPUT TYPE="hidden" NAME=BATCH  	VALUE="'||TRIM("&BATCH")   	||'">'; PUT LINE; 
			%END;

  			PUT '<STRONG><FONT  FACE="Arial" SIZE="2" COLOR="#003366"><EM>&nbsp;&nbsp;&nbsp;Sort Batches By:</EM></br></FONT></STRONG>';
  			PUT '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<SELECT NAME="SORTVALUE" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';
  			%IF %SUPERQ(SORTVALUE)=MATL_MFG_DT 	%THEN %LET selreport=selected;
				  			        %ELSE %LET selreport= ;
  			LINE= '<OPTION '||"&SELREPORT"||' VALUE="MATL_MFG_DT">Manufactured Date</OPTION>'; PUT LINE;
  			%IF %SUPERQ(SORTVALUE)=SAMP_TST_DT 	%THEN %LET selreport=selected;
  							        %ELSE %LET selreport= ;
  			LINE= '<OPTION '||"&SELREPORT"||' VALUE="SAMP_TST_DT">Test Date</OPTION>'; PUT LINE;
  			
  			PUT '</SELECT></TD></TR></FORM>';
		
		%END;
	RUN; 

	******************************************************************;
	***  FORM 8: HTML to change histogram value variable           ***;
	******************************************************************;
	DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT;
 	%IF %SUPERQ(reportype)=HISTIND %THEN %DO;  
  		  		
  			PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
			LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

			%THISSESSION;
			%DATESECTION;

			LINE= '<INPUT TYPE="hidden" NAME=lowaxis    	VALUE="'||TRIM("&lowaxis")	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=upaxis     	VALUE="'||TRIM("&upaxis") 	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=axisby     	VALUE="'||TRIM("&axisby") 	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=hlowaxis   	VALUE="'||TRIM("&hlowaxis")	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=hupaxis    	VALUE="'||TRIM("&hupaxis")	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=haxisby    	VALUE="'||TRIM("&haxisby")	||'">'; PUT LINE;

  			LINE= '<INPUT TYPE="hidden" NAME=testA      	VALUE="'||TRIM(symget("testA"))	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=stageA     	VALUE="'||TRIM("&stageA")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=peakA      	VALUE="'||TRIM("&peakA")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=reportype  	VALUE="'||TRIM("&reportype")   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=time       	VALUE="'||TRIM("&time")	       	||'">'; PUT LINE; 
			LINE='<INPUT TYPE="hidden"  NAME=ObsMaxPct  	VALUE="'||TRIM("&ObsMaxPct")   	||'">'; PUT LINE;
			LINE= '<INPUT TYPE="hidden" NAME=DataType   	VALUE="'||TRIM("&DataType")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=product    	VALUE="'||TRIM("&product")	||'">'; PUT LINE; 

  			PUT '<STRONG><FONT  FACE="Arial" SIZE="2" COLOR="#003366"><EM>&nbsp;&nbsp;&nbsp;Variable:</EM></br></FONT></STRONG>';
	  		PUT '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<SELECT NAME="VALUE" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';
	  		%IF %SUPERQ(value)=MEAN 		%THEN %LET selVALUE=selected;
				  				%ELSE %LET selVALUE= ;
   			LINE= '<OPTION '||"&SELVALUE"||' VALUE="MEAN">Batch Means</OPTION>'; PUT LINE; 
  			%IF %SUPERQ(value)=INDIVIDUAL 		%THEN %LET selVALUE=selected;
  								%ELSE %LET selVALUE= ;
   			LINE= '<OPTION '||"&SELVALUE"||' VALUE="INDIVIDUAL">Batch Individuals</OPTION>'; PUT LINE; 
			
  			PUT '</SELECT></TD></TR></FORM>';
		RUN; 
	%END;

	*****************************************************************;
	***  FORM 9: HTML FOR 2ND TEST METHOD                         ***;
	*****************************************************************;
 	%IF %SUPERQ(reportype)=CORR %THEN %DO;
		DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; 
	  		PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
			LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

			%THISSESSION;	
			%DATESECTION;  	

			LINE= '<INPUT TYPE="hidden" NAME=lowaxis    	VALUE="'||TRIM("&lowaxis")	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=upaxis     	VALUE="'||TRIM("&upaxis") 	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=axisby     	VALUE="'||TRIM("&axisby") 	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=xpixels0   	VALUE="'||TRIM("&xpixels0")	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=ypixels0   	VALUE="'||TRIM("&ypixels0")	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=product    	VALUE="'||TRIM("&product")	||'">'; PUT LINE; 

	  		LINE= '<INPUT TYPE="hidden" NAME=testA     	VALUE="'||TRIM(symget("testA"))	||'">'; PUT LINE; 
	  		LINE= '<INPUT TYPE="hidden" NAME=stageA     	VALUE="'||TRIM("&stageA")	||'">'; PUT LINE; 
	  		LINE= '<INPUT TYPE="hidden" NAME=peakA      	VALUE="'||TRIM("&peakA")	||'">'; PUT LINE; 
	   		LINE= '<INPUT TYPE="hidden" NAME=time       	VALUE="'||TRIM("&time")	       	||'">'; PUT LINE; 
	     		LINE= '<INPUT TYPE="hidden" NAME=reportype  	VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
	  		LINE= '<INPUT TYPE="hidden" NAME=CORRTYPE   	VALUE="'||TRIM("&CORRTYPE")	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=VALUE	    	VALUE="'||TRIM("&VALUE")	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=DataType   	VALUE="'||TRIM("&DataType")	||'">'; PUT LINE; 

			PUT '<STRONG><FONT  FACE="Arial" SIZE="2" COLOR="#003366"><EM>&nbsp;&nbsp;&nbsp;2nd Correlation Variable: </EM></br>';		
	  		PUT '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<SELECT NAME="testB" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';
    
	    		%LOCAL i;
	    		%DO i = 1 %TO &numtest;                                      /***  Select current test B method  ***/
				%LET temp="&&test&i";
	      			%LET temp2="&testBchk";
      				%IF &temp=&temp2 %THEN %LET selTEST=selected;
      				                 %ELSE %LET selTEST= ;
				line= '<OPTION '||"&selTEST"||' VALUE="'||"&&test&i"||'">'||'<FONT FACE=arial SIZE="1">'||"&&test&i"||'</FONT></OPTION>'; PUT line;
				%END;

			/***  Include options for testdate and temperature and RH  ***/
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

	******************************************************************;
	***  FORM 10: HTML TO CHANGE STAGE B IF STAGE EXISTS           ***;
	******************************************************************;
	  	%IF %SUPERQ(RHTEMPFLG)= and %SUPERQ(TESTB)^=TESTDATE2 %THEN %DO;
			DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT;
		  	  	numstages="&numStageB";  PEAKB=UPCASE(COMPRESS("&PEAKB"));
		  		IF numstages > 1 AND (peakB^='TOTALNUMBEROFPARTICLES') THEN DO;
		  			PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD" >';
					LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;
	
					%THISSESSION;
					%DATESECTION; 	
	
					LINE= '<INPUT TYPE="hidden" NAME=lowaxis    	VALUE="'||TRIM("&lowaxis")	||'">'; PUT LINE;
		  			LINE= '<INPUT TYPE="hidden" NAME=upaxis     	VALUE="'||TRIM("&upaxis") 	||'">'; PUT LINE;
		  			LINE= '<INPUT TYPE="hidden" NAME=axisby     	VALUE="'||TRIM("&axisby") 	||'">'; PUT LINE;
		  			LINE= '<INPUT TYPE="hidden" NAME=xpixels0   	VALUE="'||TRIM("&xpixels0")	||'">'; PUT LINE;	
  					LINE= '<INPUT TYPE="hidden" NAME=ypixels0   	VALUE="'||TRIM("&ypixels0")	||'">'; PUT LINE;
	  				LINE= '<INPUT TYPE="hidden" NAME=product    	VALUE="'||TRIM("&product")	||'">'; PUT LINE; 

  					LINE= '<INPUT TYPE="hidden" NAME=testA      	VALUE="'||TRIM(symget("testA")) ||'">'; PUT LINE; 
  					LINE= '<INPUT TYPE="hidden" NAME=testB     	VALUE="'||TRIM(symget("testB")) ||'">'; PUT LINE;
  					LINE= '<INPUT TYPE="hidden" NAME=stageA     	VALUE="'||TRIM("&stageA")	||'">'; PUT LINE; 
  					LINE= '<INPUT TYPE="hidden" NAME=peakA      	VALUE="'||TRIM("&peakA")	||'">'; PUT LINE; 
   					LINE= '<INPUT TYPE="hidden" NAME=PeakB      	VALUE="'||TRIM("&PeakB")	||'">'; PUT LINE; 
   					LINE= '<INPUT TYPE="hidden" NAME=reportype  	VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
   					LINE= '<INPUT TYPE="hidden" NAME=time      	VALUE="'||TRIM("&time")	        ||'">'; PUT LINE; 
  					LINE= '<INPUT TYPE="hidden" NAME=GROUPVAR   	VALUE="'||TRIM("&GROUPVAR")	||'">'; PUT LINE; 
  					LINE= '<INPUT TYPE="hidden" NAME=CORRTYPE   	VALUE="'||TRIM("&CORRTYPE")	||'">'; PUT LINE; 
					LINE= '<INPUT TYPE="hidden" NAME=VALUE	    	VALUE="'||TRIM("&VALUE")	||'">'; PUT LINE; 
					LINE= '<INPUT TYPE="hidden" NAME=DataType   	VALUE="'||TRIM("&DataType")	||'">'; PUT LINE; 	

		  			test=symget('testb');                           /***  Setup drop down box label  ***/
		  			IF COMPRESS(TEST) ^= 'HPLCAdvairMDPlCas.Impaction' THEN 
		  			PUT '<STRONG><FONT  FACE="Arial" SIZE="2" COLOR="#003366">&nbsp;&nbsp;&nbsp;<EM>2nd Variable Test Parameter:</EM></FONT></STRONG></br>';	
		  			ELSE PUT '<STRONG><FONT  FACE="Arial" SIZE="2" COLOR="#003366">&nbsp;&nbsp;&nbsp;<EM>2nd Variable CI Stage:</EM></FONT></STRONG></br>';	
		  			PUT '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<SELECT NAME="StageB" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';
  
			  	    	%LOCAL i;
    					%DO i = 1 %TO &numStageB;                       /***  Select current Stage B     ***/
					    	%LET temp="&&StageB&i";
      						%LET temp2="&stagebchk";
      						%IF &temp=&temp2 %THEN %LET selstage=selected;
      								 %ELSE %LET selstage= ;
				    		line= '<OPTION '||"&selstage"||' VALUE="'||"&&StageB&i"||'">'||"&&StageB&i"||'</OPTION>'; PUT line;
		    			%END;
					PUT '</SELECT></TD></TR></FORM>';
	  			END;
			RUN;

	******************************************************************;
	***  FORM 11: HTML FOR 2ND PEAK                                ***;
	******************************************************************;
			DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT;
				testb=trim("&Testb");
	  			numpeak="&numPeakB";
		  		IF numpeak > 1 and UPCASE(COMPRESS(testb)) not IN ('HPLCRELATEDIMP.INADVAIRMDPI') THEN DO;
		  			PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
					LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

				%THISSESSION;	
				%DATESECTION;

				LINE= '<INPUT TYPE="hidden" NAME=lowaxis    	VALUE="'||TRIM("&lowaxis")	||'">'; PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME=upaxis     	VALUE="'||TRIM("&upaxis") 	||'">'; PUT LINE;
	  			LINE= '<INPUT TYPE="hidden" NAME=axisby     	VALUE="'||TRIM("&axisby") 	||'">'; PUT LINE;
  				LINE= '<INPUT TYPE="hidden" NAME=xpixels0   	VALUE="'||TRIM("&xpixels0")	||'">'; PUT LINE;
  				LINE= '<INPUT TYPE="hidden" NAME=ypixels0   	VALUE="'||TRIM("&ypixels0")	||'">'; PUT LINE;
  				LINE= '<INPUT TYPE="hidden" NAME=product    	VALUE="'||TRIM("&product")	||'">'; PUT LINE; 

  				LINE= '<INPUT TYPE="hidden" NAME=testA      	VALUE="'||TRIM(symget("testA")) ||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=testB      	VALUE="'||TRIM(symget("testB")) ||'">'; PUT LINE;
  				LINE= '<INPUT TYPE="hidden" NAME=stageA     	VALUE="'||TRIM("&stageA")	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=peakA      	VALUE="'||TRIM("&peakA")	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=StageB    	VALUE="'||TRIM("&StageB")	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=reportype  	VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=time       	VALUE="'||TRIM("&time")	        ||'">'; PUT LINE; 
	 			LINE= '<INPUT TYPE="hidden" NAME=GROUPVAR   	VALUE="'||TRIM("&GROUPVAR")	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=CORRTYPE   	VALUE="'||TRIM("&CORRTYPE")	||'">'; PUT LINE; 
 				LINE= '<INPUT TYPE="hidden" NAME=VALUE	    	VALUE="'||TRIM("&VALUE")	||'">'; PUT LINE; 
				LINE= '<INPUT TYPE="hidden" NAME=DataType   	VALUE="'||TRIM("&DataType")	||'">'; PUT LINE; 	

	  			PUT '<STRONG><FONT  FACE="Arial" SIZE="2" COLOR="#003366"><EM>';
				IF TESTB IN ('Foreign Particulate Matter') 
                                	THEN PUT '&nbsp;&nbsp;&nbsp;2nd Variable Particle Size:'; 	
					ELSE PUT '&nbsp;&nbsp;&nbsp;2nd Variable Drug Substance:';	
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

	******************************************************************;
	***  FORM 12: HTML TO CHANGE RESULT TYPE                       ***;
	******************************************************************;
		DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; 
   			testa="&testa"; testb="&testb"; rhtempflg="&rhtempflg";
 			IF testa=testb or rhtempflg='YES' THEN DO;
 		 		PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
				LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

				%THISSESSION;
				%DATESECTION;	

				LINE= '<INPUT TYPE="hidden" NAME=lowaxis    VALUE="'||TRIM("&lowaxis")	   	||'">'; PUT LINE;
		  		LINE= '<INPUT TYPE="hidden" NAME=upaxis     VALUE="'||TRIM("&upaxis") 	   	||'">'; PUT LINE;
		  		LINE= '<INPUT TYPE="hidden" NAME=axisby     VALUE="'||TRIM("&axisby") 	   	||'">'; PUT LINE;
		  		LINE= '<INPUT TYPE="hidden" NAME=hlowaxis   VALUE="'||TRIM("&hlowaxis")	   	||'">'; PUT LINE;	
		  		LINE= '<INPUT TYPE="hidden" NAME=hupaxis    VALUE="'||TRIM("&hupaxis")	   	||'">'; PUT LINE;
		  		LINE= '<INPUT TYPE="hidden" NAME=haxisby    VALUE="'||TRIM("&haxisby")	   	||'">'; PUT LINE;
		  		LINE= '<INPUT TYPE="hidden" NAME=xpixels0   VALUE="'||TRIM("&xpixels0")	   	||'">'; PUT LINE;
		  		LINE= '<INPUT TYPE="hidden" NAME=ypixels0   VALUE="'||TRIM("&ypixels0")	   	||'">'; PUT LINE;
		  		LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="'||TRIM("&product")	    	||'">'; PUT LINE; 

		  		LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="'||TRIM(symget("testA"))	||'">'; PUT LINE; 
		  		LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="'||TRIM("&stageA")	    	||'">'; PUT LINE; 
		  		LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="'||TRIM("&peakA")	    	||'">'; PUT LINE; 
		  		LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
		  		LINE= '<INPUT TYPE="hidden" NAME=RptValue   VALUE="'||TRIM("&rptvalue")	    	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=testB      VALUE="'||TRIM("&testB")	    	||'">'; PUT LINE; 
 				LINE= '<INPUT TYPE="hidden" NAME=StageB     VALUE="'||TRIM("&StageB")	    	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=PeakB      VALUE="'||TRIM("&PeakB")	    	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=time       VALUE="'||TRIM("&time")	        ||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=CORRTYPE   VALUE="'||TRIM("&CORRTYPE")	    	||'">'; PUT LINE; 
 				LINE= '<INPUT TYPE="hidden" NAME=groupvar   VALUE="'||TRIM("&groupvar")	    	||'">'; PUT LINE; 
				LINE= '<INPUT TYPE="hidden" NAME=DataType   VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE; 

		  		PUT '<FONT SIZE=2 FACE=arial COLOR="#003366"><EM><STRONG>&nbsp;&nbsp;&nbsp;Result Type: </EM></br></STRONG></FONT>';
		  		PUT '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<SELECT NAME="VALUE" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';

				%IF %SUPERQ(VALUE)=MEAN %THEN %LET SELECTtype=selected;
				                        %ELSE %LET SELECTtype= ;
		  		LINE='<OPTION '||"&selecttype"||' VALUE="MEAN">Batch Means</OPTION>'; PUT LINE;
  
				%IF %SUPERQ(VALUE)=INDIVIDUAL %THEN %LET SELECTtype=selected;
		  		                              %ELSE %LET SELECTtype= ;
		  		LINE='<OPTION '||"&selecttype"||' VALUE="INDIVIDUAL">Batch Individuals</OPTION>'; PUT LINE;

				PUT '</SELECT></TD></TR></FORM>';
	 		END;
		RUN;

	******************************************************************;
	***  FORM 13: HTML TO CHANGE GROUP VARIABLE                    ***;
	******************************************************************;
		DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; 
	  		testa="&testa"; testb="&testb";  		
	 		PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
			LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

			%THISSESSION;		
			%DATESECTION; 	

			LINE= '<INPUT TYPE="hidden" NAME=lowaxis    VALUE="'||TRIM("&lowaxis")	   	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=upaxis     VALUE="'||TRIM("&upaxis") 	   	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=axisby     VALUE="'||TRIM("&axisby") 	   	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=hlowaxis   VALUE="'||TRIM("&hlowaxis")	   	||'">'; PUT LINE;
	  		LINE= '<INPUT TYPE="hidden" NAME=hupaxis    VALUE="'||TRIM("&hupaxis")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=haxisby    VALUE="'||TRIM("&haxisby")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=xpixels0   VALUE="'||TRIM("&xpixels0")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=ypixels0   VALUE="'||TRIM("&ypixels0")	   	||'">'; PUT LINE;

  			LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="'||TRIM(symget("testA")) 	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="'||TRIM("&stageA")	    	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="'||TRIM("&peakA")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testB      VALUE="'||TRIM("&testB")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=StageB     VALUE="'||TRIM("&StageB")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=PeakB      VALUE="'||TRIM("&PeakB")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=RptValue   VALUE="'||TRIM("&rptvalue")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=Value      VALUE="'||TRIM("&Value")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=time       VALUE="'||TRIM("&time")	       	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=CORRTYPE   VALUE="'||TRIM("&CORRTYPE")	    	||'">'; PUT LINE; 
 			LINE= '<INPUT TYPE="hidden" NAME=ResultTYPE VALUE="'||TRIM("&ResultTYPE")	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=DataType   VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="'||TRIM("&product")	    	||'">'; PUT LINE; 

	  		PUT '<FONT SIZE=2 FACE=arial COLOR="#003366"><EM><STRONG>&nbsp;&nbsp;&nbsp;Group Variable: </EM></br></STRONG></FONT>';
	  		PUT '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<SELECT NAME="groupvar" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';

			%IF %SUPERQ(GROUPVAR)=NONE %THEN %LET SELECTGRP=selected;
	  		                           %ELSE %LET SELECTGRP= ;
	  			LINE='<OPTION '||"&selectGRP"||' VALUE="NONE">None</OPTION>'; PUT LINE;

	  		CIFLAG="&CIFLAG";
	  		resulttype="&VALUE";

		  	%IF (%SUPERQ(REPORTYPE)=CORR AND %SUPERQ(CORRTYPE)^=TABL) %THEN %DO;
		  		%IF %SUPERQ(GROUPVAR)=BATCH_NBR %THEN %LET SELECTGRP=selected;
		  	        	                      %ELSE %LET SELECTGRP= ;
				LINE='<OPTION '||"&selectGRP"||' VALUE="BATCH_NBR">Batches </OPTION>'; PUT LINE;
			%END;
			%IF %SUPERQ(SAVE_USERROLE)=LevelA %THEN %DO;
		  		IF  (CIFLAG ^= 'YES') AND (testa=testb) THEN DO;
		  			%IF %SUPERQ(GROUPVAR)=ANALYST %THEN %LET SELECTGRP=selected;
		  			                              %ELSE %LET SELECTGRP= ;
		  			LINE='<OPTION '||"&selectGRP"||' VALUE="ANALYST">Analyst </OPTION>'; PUT LINE;
		  		END;
			%END;

			PUT '</SELECT></TD></TR></FORM>';
  
  		RUN;

	******************************************************************;
	***  FORM 14: HTML TO CHANGE TYPE OF CORR ANALYSIS             ***;
	******************************************************************;
		  DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT;
			PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
			LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

			%THISSESSION; 	
			%DATESECTION;

			LINE= '<INPUT TYPE="hidden" NAME=lowaxis    VALUE="'||TRIM("&lowaxis")	   	||'">'; PUT LINE;
		  	LINE= '<INPUT TYPE="hidden" NAME=upaxis     VALUE="'||TRIM("&upaxis") 	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=axisby     VALUE="'||TRIM("&axisby") 	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=hlowaxis   VALUE="'||TRIM("&hlowaxis")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=hupaxis    VALUE="'||TRIM("&hupaxis")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=haxisby    VALUE="'||TRIM("&haxisby")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=xpixels0   VALUE="'||TRIM("&xpixels0")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=ypixels0   VALUE="'||TRIM("&ypixels0")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="'||TRIM("&product")	    	||'">'; PUT LINE; 

  			LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="'||TRIM(symget("testA")) 	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="'||TRIM("&stageA")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="'||TRIM("&peakA")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=Value      VALUE="'||TRIM("&Value")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=RptValue   VALUE="'||TRIM("&rptvalue")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testB      VALUE="'||TRIM("&testB")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=StageB     VALUE="'||TRIM("&StageB")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=PeakB      VALUE="'||TRIM("&PeakB")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=time       VALUE="'||TRIM("&time")	       	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=groupvar   VALUE="'||TRIM("&groupvar")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=ResultTYPE VALUE="'||TRIM("&ResultTYPE")	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=DataType   VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE;

		  	PUT '<FONT SIZE=2 FACE=arial COLOR="#003366"><EM><STRONG>&nbsp;&nbsp;&nbsp;Analysis Type: </EM></br></STRONG></FONT>';
		  	PUT '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<SELECT NAME="corrtype" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';

			%IF %SUPERQ(corrtype)=PLOT %THEN %LET SELCORR=selected;
		  	                           %ELSE %LET SELCORR= ;
	  		LINE='<OPTION '||"&selCORR"||' VALUE="PLOT">Scatter Plot</OPTION>'; PUT LINE;
  
		  	%IF %SUPERQ(corrtype)=TABLE %THEN %LET SELCORR=selected;
		  	                            %ELSE %LET SELCORR= ;
		    	Line='<OPTION '||"&selCORR"||' VALUE="TABLE">Summary Statistics</OPTION>'; PUT LINE;
	
			PUT '</SELECT></TD></TR></FORM>';
	  	RUN;
	%END;

	******************************************************************;
	***  FORM 15: HTML TO CHANGE Table TYPE                        ***;
	******************************************************************;
 	%IF %SUPERQ(reportype)=BATCHSTATS %THEN %DO;  
		DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT;
   			testa="&testa"; testb="&testb"; rhtempflg="&rhtempflg";
 		 		PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD">';
				LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

				%THISSESSION;
				%DATESECTION;	

				LINE= '<INPUT TYPE="hidden" NAME=lowaxis    VALUE="'||TRIM("&lowaxis")	   	||'">'; PUT LINE;
		  		LINE= '<INPUT TYPE="hidden" NAME=upaxis     VALUE="'||TRIM("&upaxis") 	   	||'">'; PUT LINE;
		  		LINE= '<INPUT TYPE="hidden" NAME=axisby     VALUE="'||TRIM("&axisby") 	   	||'">'; PUT LINE;
		  		LINE= '<INPUT TYPE="hidden" NAME=hlowaxis   VALUE="'||TRIM("&hlowaxis")	   	||'">'; PUT LINE;	
		  		LINE= '<INPUT TYPE="hidden" NAME=hupaxis    VALUE="'||TRIM("&hupaxis")	   	||'">'; PUT LINE;
		  		LINE= '<INPUT TYPE="hidden" NAME=haxisby    VALUE="'||TRIM("&haxisby")	   	||'">'; PUT LINE;
		  		LINE= '<INPUT TYPE="hidden" NAME=xpixels0   VALUE="'||TRIM("&xpixels0")	   	||'">'; PUT LINE;
		  		LINE= '<INPUT TYPE="hidden" NAME=ypixels0   VALUE="'||TRIM("&ypixels0")	   	||'">'; PUT LINE;

		  		LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="'||TRIM(symget("testA"))	||'">'; PUT LINE; 
		  		LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="'||TRIM("&stageA")	    	||'">'; PUT LINE; 
		  		LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="'||TRIM("&peakA")	    	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=testB      VALUE="'||TRIM("&testB")	    	||'">'; PUT LINE; 
 				LINE= '<INPUT TYPE="hidden" NAME=StageB     VALUE="'||TRIM("&StageB")	    	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=PeakB      VALUE="'||TRIM("&PeakB")	    	||'">'; PUT LINE; 
		  		LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
		  		LINE= '<INPUT TYPE="hidden" NAME=RptValue   VALUE="'||TRIM("&rptvalue")	    	||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=time       VALUE="'||TRIM("&time")	        ||'">'; PUT LINE; 
  				LINE= '<INPUT TYPE="hidden" NAME=CORRTYPE   VALUE="'||TRIM("&CORRTYPE")	    	||'">'; PUT LINE; 
 				LINE= '<INPUT TYPE="hidden" NAME=groupvar   VALUE="'||TRIM("&groupvar")	    	||'">'; PUT LINE; 
				LINE= '<INPUT TYPE="hidden" NAME=DataType   VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE; 
		  		LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="'||TRIM("&product")	    	||'">'; PUT LINE; 
				LINE= '<INPUT TYPE="hidden" NAME=Batch      VALUE="'||TRIM("&Batch")	   	||'">'; PUT LINE; 

		  		PUT '<FONT SIZE=2 FACE=arial COLOR="#003366"><EM><STRONG>&nbsp;&nbsp;&nbsp;Table Statistics: </EM></br></STRONG></FONT>';
		  		PUT '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<SELECT NAME="VALUE" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" onChange="this.form.submit();">';

				%IF %SUPERQ(VALUE)=SUMMARY %THEN %LET SELECTtype=selected;
				                           %ELSE %LET SELECTtype= ;
		  		LINE='<OPTION '||"&selecttype"||' VALUE="SUMMARY">Batch Summary</OPTION>'; PUT LINE;
  
				%IF %SUPERQ(VALUE)=INDIVIDUAL %THEN %LET SELECTtype=selected;
		  		                              %ELSE %LET SELECTtype= ;
		  		LINE='<OPTION '||"&selecttype"||' VALUE="INDIVIDUAL">Batch Individuals</OPTION>'; PUT LINE;
				
				%IF %SUPERQ(BATCH)^= %THEN %DO;
					%IF %SUPERQ(VALUE)=ALLTESTS %THEN %LET SELECTtype=selected;
					                            %ELSE %LET SELECTtype= ;
			  		LINE='<OPTION '||"&selecttype"||' VALUE="ALLTESTS">All Batches</OPTION>'; PUT LINE;
				%END;
	
				PUT '</SELECT></TD></TR></FORM>';
		RUN;
	%END;

  	DATA _NULL_; FILE _WEBOUT;
  		PUT   '<TR><TD ><HR></tD></tR>'; 
		PUT '<TR><TD>';
	RUN;

	******************************************************************;
	***  FORM 16: HTML TO CHANGE START DATE RANGE                  ***;
	******************************************************************;
	DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT;
			PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD" valign=top align=left>';
			PUT   '<FONT SIZE=2 FACE=arial COLOR="#003366"><STRONG>Manufacturing Date Range:</br></FONT></STRONG>';
			PUT   '<TABLE><TR><TD COLSPAN=3>';
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

  			LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="'||TRIM(symget("testA")) 	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="'||TRIM("&stageA")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=testB      VALUE="'||TRIM("&testB")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=StageB     VALUE="'||TRIM("&StageB")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=PeakB      VALUE="'||TRIM("&PeakB")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="'||TRIM("&peakA")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="'||TRIM("&reportype")	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=RptValue   VALUE="'||TRIM("&rptvalue")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=Value      VALUE="'||TRIM("&Value")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=time       VALUE="'||TRIM("&time")	       	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=groupvar   VALUE="'||TRIM("&groupvar")	    	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=DataType   VALUE="'||TRIM("&DataType")	   	||'">'; PUT LINE;
			LINE= '<INPUT TYPE="hidden" NAME=CORRType   VALUE="'||TRIM("&CORRType")	   	||'">'; PUT LINE;
  			LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="'||TRIM("&product")	    	||'">'; PUT LINE; 
  			LINE= '<INPUT TYPE="hidden" NAME=ResultTYPE VALUE="'||TRIM("&ResultTYPE")	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=CTLLIMITS  VALUE="'||TRIM("&CTLLIMITS")	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=USERLCL    VALUE="'||TRIM("&USERLCL")	   	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=USERUCL    VALUE="'||TRIM("&USERUCL")	   	||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=USERBAR    VALUE="'||TRIM("&USERBAR")	   	||'">'; PUT LINE; 

			PUT '<FONT SIZE=2 FACE=arial COLOR="#003366"><EM><STRONG>&nbsp;Start Date: </EM></STRONG></FONT></TD></TR>';
		  	PUT '<TR><TD><SELECT NAME="StartMONTH" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" >';

			*****************************************************;
			***  FORM 16: HTML TO CHANGE DATE RANGE MONTH     ***;
			*****************************************************;
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
		/*IF STARTMONTH IN (1, 3, 5, 7, 8, 10,12) THEN CALL SYMPUT('MAXDAY',31);
		ELSE IF STARTMONTH IN (2) THEN CALL SYMPUT('MAXDAY',29);
		ELSE CALL SYMPUT('MAXDAY',30);*/
		CALL SYMPUT('MAXDAY',31);
		RUN;

		*****************************************************;
		***  FORM 16: HTML TO CHANGE DATE RANGE DAY       ***;
		*****************************************************;
		DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; 
			PUT   '<TD BGCOLOR="#FFFFDD" valign=top align=left>';
		  	PUT '<SELECT NAME="StartDAY" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" >';
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
		  	PUT '<SELECT NAME="StartYEAR" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" >';
			%DO I=&MINYEAR %TO &MAXYEAR;
				%IF %SUPERQ(startYEAR)=&I %THEN %LET SELYEAR=selected;  
                                                          %ELSE %LET SELYEAR= ;
	  			LINE='<OPTION '||"&selYEAR"||' VALUE="'||"&I"||'">'||"&I"||'</OPTION>'; PUT LINE;
  			%END;
			PUT '</SELECT></TD></TR></TABLE></TD></TR>';
	  	RUN;

	******************************************************************;
	***  FORM 16: HTML TO CHANGE END DATE RANGE                    ***;
	******************************************************************;
		DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT;
			PUT   '<TR BGCOLOR="#FFFFDD"><TD BGCOLOR="#FFFFDD" valign=top align=left><TABLE><TR><TD COLSPAN=3>';
			
			*****************************************************;
			***  FORM 16: HTML TO CHANGE DATE RANGE MONTH     ***;
			*****************************************************;
			PUT '<FONT SIZE=2 FACE=arial COLOR="#003366"><EM><STRONG>&nbsp;&nbsp;End Date: </EM></STRONG></FONT></TD></TR>';
		  	PUT '<TR><TD><SELECT NAME="ENDMONTH" SIZE="1" STYLE="FONT-SIZE: xx-SMALL">';

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

		*****************************************************;
		***  FORM 16: HTML TO CHANGE DATE RANGE DAY       ***;
		*****************************************************;
		DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; 
			PUT   '<TD BGCOLOR="#FFFFDD" align=left valign=top>';
		  	PUT '<SELECT NAME="ENDDAY" SIZE="1" STYLE="FONT-SIZE: xx-SMALL">';
			%DO I=1 %TO &MAXDAY;
				%IF %SUPERQ(ENDDAY)=&I %THEN %LET SELDAY=selected;  
                                                       %ELSE %LET SELDAY= ;
	  			LINE='<OPTION '||"&selDAY"||' VALUE="'||"&I"||'">'||"&I"||'</OPTION>'; PUT LINE;
  			%END;
			PUT '</SELECT></TD>';
	  	RUN;
		*****************************************************;
		***  FORM 16: HTML TO CHANGE DATE RANGE YEAR      ***;
		*****************************************************;
		DATA _NULL_; LENGTH LINE $1000 ; FILE _WEBOUT; 
			PUT   '<TD BGCOLOR="#FFFFDD" align=left valign=top>';
			LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;
		  	PUT '<SELECT NAME="ENDYEAR" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" >';
			%DO I=&MINYEAR %TO &MAXYEAR;
				%IF %SUPERQ(ENDYEAR)=&I %THEN %LET SELYEAR=selected;  
                                                        %ELSE %LET SELYEAR= ;
	  			LINE='<OPTION '||"&selYEAR"||' VALUE="'||"&I"||'">'||"&I"||'</OPTION>'; PUT LINE;
  			%END;
			PUT '</SELECT></TD></TR></TABLE>';
			PUT '</br><INPUT TYPE="submit" NAME="submit" VALUE="Update Date Range"></br></TD></TR></FORM>';
	  	RUN;
	
	DATA _NULL_; FILE _WEBOUT;
  		PUT '</TABLE></TD><TD VALIGN=top ALIGN=LEFT BGCOLOR="#E0E0E0">';
  		PUT '</FONT>';
  	RUN;

OPTIONS mlogic mprint symbolgen;
%MEND WEBOUT;

****************************************************************************************************;
*                                    MODULE HEADER                                                 *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;
*	    REQUIREMENT : See LINKS Report SOP                                                     *;
*       INPUT Datasets  : Batches1, Batches2.                                                      *;
*       PROCESSING      : Creates general report datasets and macro variables.                     *;
*       OUTPUT          : General report datasets and macro variables.                             *;
****************************************************************************************************;
%MACRO DATECHECK;

	/*** Setup FLAG if there are any missing SAMP_TST_DT values ***/

	%LET NOSAMPDT=NO;
	
	DATA _NULL_;SET BATCHES2;
	   IF SAMP_TST_DT = . THEN CALL SYMPUT('NOSAMPDT','YES');
	RUN;
	
%MEND DATECHECK;

****************************************************************************************************;
*                                      MODULE HEADER                                               *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;
*	    REQUIREMENT: See LINKS Report SOP                                                      *;
*       INPUT:   DATASET: BATCHES2.		                                                   *;
*       PROCESSING: Determine mean of each batch.  Check to ensure                                 *;
*			all datapoints are not equal (cannot generate chart), if so                *;
*			print warning for insufficient data.  Otherwise create x bar chart         *; 
*			stratifying by quarter.  Plot batch on horizontal axis.  Connect points    *;
*			with a solid line.  Plot specifications as reference lines.                *; 
*       OUTPUT:   1 PLOT to web browser or RTF file.                                               *;
****************************************************************************************************;
%MACRO XBAR;

	%LET DATACHKFLAG=;
	%LET INVALIDLIMITS=;
	%DATECHECK;

	%IF %SUPERQ(NOSAMPDT)=YES AND %SUPERQ(SORTVALUE)=SAMP_TST_DT %THEN %DO;
		DATA BATCHES1;SET BATCHES1;IF SAMP_TST_DT = . THEN DELETE;
		DATA BATCHES2;SET BATCHES2;IF SAMP_TST_DT = . THEN DELETE;
	%END;

	PROC SORT DATA=BATCHES2; BY PRODUCT TEST STAGE PEAK BATCH_NBR; RUN;
	/***  Calculate means by lot                                           ***/
	PROC SUMMARY DATA=BATCHES2;
		VAR RESULT;
		BY PRODUCT TEST STAGE PEAK BATCH_NBR;
		ID MATL_MFG_DT SAMP_TST_DT QUARTER;
		OUTPUT OUT=BATCHSUM MEAN=MEAN;
	RUN;

	PROC SORT DATA=BATCHES1 NODUPKEY OUT=TEST; BY BATCH_NBR; RUN;
		
	/***  Check to see if all results are the same if so set flag to STOP  ***/
	DATA _NULL_; SET BATCHSUM NOBS=MAXOBS;
		RETAIN DATACHK OBS 0;
		OBS=OBS+1;
		DATACHK=MEAN-DATACHK;
		IF OBS=MAXOBS AND DATACHK =0 THEN CALL SYMPUT('DATACHKFLAG','STOP');
	RUN;

	%WARNINGS;
	

        /***  If datachkflag is not STOP then proceed                          ***/
	%IF %SUPERQ(DATACHKFLAG)^=STOP %THEN %DO;  
		GOPTIONS reset=all;             /***  Setup goptions           ***/
		GOPTIONS device=&device display;
		GOPTIONS &xpixels &ypixels  gsfmode=replace  BORDER;

		/*** Setup titles and footnotes ***/
		TITLE h=1 F=SWISSB "&TITLE_product &TITLE_test &TITLE_PEAKA";       /***  Setup titles, legend and axis  ***/
		title2 h=1 F=SWISSB "Batch Mean Run Chart for Batches Manufactured &STARTDATETITLE through &ENDDATETITLE";
	/*
		%IF %SUPERQ(WARNING)^= AND (%SUPERQ(HWARNING)=YES OR %SUPERQ(VWARNING)=YES) %THEN %DO;
			DATA _NULL_; FILE _WEBOUT;
				PUT	"<P ALIGN=CENTER><BR><STRONG><FONT FACE=ARIAL COLOR=RED>**NOTE: Data points exist outside user defined axis range. Default axis used.**</FONT></STRONG></BR>";
			RUN;
		%END;

		%DO I = 1 %TO &NUMSPECS;
			%LET K=%EVAL(&I);
			&&FOOTNOTE&I;
		%END;
		%LET J = %EVAL(&NUMSPECS+1);
		FOOTNOTE&J H=.2 ' ';
		%LET J = %EVAL(&NUMSPECS+2);
		FOOTNOTE&J F=ARIAL j=l h=.95 "Generated by the LINKS System on &today at &rpttime" j=r "Data last updated: &Save_Last_Update_Date at &Save_Last_Update_Time";
  	*/
%IF %SUPERQ(SPECCHK)=YES  AND %SUPERQ(TESTA) ^=ALL %THEN %DO;
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
		FOOTNOTE1 F=ARIAL j=L h=.95 "Generated by the LINKS System on &today at &rpttime" j=r "Data last updated: &Save_Last_Update_Date at &Save_Last_Update_Time";
  		FOOTNOTE2 H=.3 ' ';
		%IF %SUPERQ(UNAPPFLAG)=YES %THEN %DO;
			FOOTNOTE3 F=ARIAL C=RED J=C H=.95 'Report contains approved and unapproved data. '; 
			FOOTNOTE4 H=.3 ' ';
		%END;
	%END;


		%GLOBAL VREF2;
		/*** Setup specification dataset                               ***/
		%IF %SUPERQ(SPECCHK)=YES %THEN %DO;  
			PROC SORT DATA=PRODSPECS0 NODUPKEY; BY test stage peak spec_type LOWERM UPPERM LOWERI UPPERI; RUN;
			%LET VREF2= vref=vref;
			DATA VREF (KEEP= TEST STAGE PEAK _var_ _ref_ _reflab_); LENGTH _REFLAB_ $40; SET PRODSPECS0;
				*where spec_type="MEAN";
				IF lowerm ^=0 THEN DO;
					_var_='Mean'; _ref_=lowerm; _REFLAB_='Mean Spec'; OUTPUT;
				END;
				IF upperm^=0 THEN DO;
					_var_='Mean'; _ref_=upperm; _REFLAB_='Mean Spec'; OUTPUT;
				END;
			/*	IF loweri ^=0 THEN DO;
					_var_='Mean'; _ref_=loweri; _REFLAB_='Indiv. Spec'; OUTPUT;
				END;
				IF upperi^=0 THEN DO;
					_var_='Mean'; _ref_=upperi; _REFLAB_='Indiv. Spec'; OUTPUT;
				END; */
				ELSE CALL SYMPUT('VREF2','');
				put product test stage peak _var_ _ref_ _reflab_ lowerm upperm;
			RUN;

data _null_;set PRODSPECS0;put _all_;run;

		PROC SORT DATA=VREF; BY TEST STAGE PEAK; RUN;
data _null_;set VREF;put _all_;run;
			
		%END;
		
		AXIS1 LABEL=(a=90 FONT=SIMPLEX "Batch Mean") &VAXIS ;
		%IF %SUPERQ(SORTVALUE)=SAMP_TST_DT %THEN %DO;
			AXIS2 OFFSET=(2,2) LABEL=(FONT=SIMPLEX "Batch Number (Sorted by Test Date)");
		%END;
		%ELSE %DO;
			AXIS2 OFFSET=(2,2) LABEL=(FONT=SIMPLEX "Batch Number (Sorted by Manufacture Date)");
		%END;
		SYMBOL1 v=DOT w=.5 h=.75 c=black;
		SYMBOL2 v=DOT w=.5 c=red;
		LEGEND1 ORDER=(0,1);

		
		

		DATA BATCHSUM; SET BATCHSUM;
		SYMBOLLINK='HREF="' || "%superq(_THISSESSION)" ||
      			'&_program=' || "links.LRBATCHANALYSIS.sas" || '&BATCH=' || TRIM(BATCH_NBR) ||'&product='||"&PRODUCT"||	
	  				'&TESTA='||TEST||'&stagea='||"&stagea"||'&peaka='||"&peaka"||'&REPORTYPE=BATCHSTATS"';
		RUN;

		PROC SORT DATA=BATCHSUM; BY TEST STAGE PEAK &SORTVALUE; RUN;

		PROC SORT DATA=LIMITS; BY TEST STAGE PEAK; RUN;
data _null_;set LIMITS;put _all_;run;
		
		proc freq data=batchsum noprint;
		table test*stage*peak/out=numgraphs;
		run;

		data numgraphs; set numgraphs Nobs=numgraphs;
		retain graph 0;
		graph=graph+1;
		call symput('numgraphs', numgraphs);
		put test stage peak graph numgraphs;
		run;

		%DO I= 1 %TO &NUMGRAPHS;
		DATA _NULL_; SET NUMGRAPHS;
		WHERE GRAPH=&I;
		CALL SYMPUT("GRSUBSET", "where test='"||trim(test)||"' and stage= '"||trim(stage)||"' and peak = '"||trim(peak)||"'" );
		put test stage peak;
		RUN;

		proc sort data=specs0 nodupkey out=gettitle; by test stage peak SPEC_TYPE; run;
		data _null_; set gettitle;
		put test stage peak;
		run;

		%let titlechk= ;  %let grtitle= ; %LET FOOTNOTE1= ;
		DATA _NULL_; SET gettitle;
		&GRSUBSET;
		SPEC=TRIM(TXT_LIMIT_A)||TRIM(TXT_LIMIT_B)||TRIM(TXT_LIMIT_C);
		CALL SYMPUT('GRTITLE', trim(REG_METH_NAME));
		IF SPEC ^= '' AND UPCASE(SPEC_TYPE)='MEAN' THEN 
		CALL SYMPUT('FOOTNOTE1', 'FOOTNOTE1 F=ARIAL h=1 "Specification: '||TRIM(LEFT(SPEC))||'"');
		CALL SYMPUT('TITLECHK', 'GO');
		put reg_meth_name SPEC;
		RUN;

		footnote1 ' ';
		%IF %SUPERQ(TITLECHK)=GO %THEN %DO;
		OPTIONS NOBYLINE; 
		&FOOTNOTE1;
		%END;
		%else %do;
		OPTIONS BYLINE;
		%END;

	/* Added v6 */
	FOOTNOTE2 F=ARIAL j=l h=.95 "Generated by the LINKS System on &today at &rpttime" j=r "Data last updated: &Save_Last_Update_Date at &Save_Last_Update_Time";
	Footnote3 h=.2 ' ';	
	%IF %SUPERQ(UNAPPFLAG)=YES %THEN %DO;
		FOOTNOTE4 C=RED F=ARIAL J=C H=.95 'Report contains approved and unapproved data. '; 
		FOOTNOTE5 H=.2 ' ';
	%END;

/*** Setup titles and footnotes ***/
		TITLE h=1 F=SWISSB "&TITLE_product &GRTITLE";       /***  Setup titles, legend and axis  ***/
		title2 h=1 F=SWISSB "Batch Mean Run Chart for Batches Manufactured &STARTDATETITLE through &ENDDATETITLE";

		
		/*** Create chart                                              ***/
		PROC SHEWHART DATA=BATCHSUM LIMITS=LIMITS;
 			XCHART MEAN*BATCH_NBR(QUARTER)/ NPANELPOS=1000
 					  VAXIS=axis1
					  HAXIS=AXIS2
					  %IF %SUPERQ(CTLLIMITS)=NONE %THEN %DO;
                	  			NOLCL
					  	NOUCL
						NOLIMITLABEL
					  %END;
					  %ELSE %DO;
					  	READLIMITS
					  %END;
					  &VREF2
					  LVREF=1
					  BLOCKPOS=1
					  BLOCKLABTYPE=scaled
					  CCONNECT=black
					  NOLEGEND 
					  HTML=SYMBOLLINK
					  SYMBOLLEGEND=LEGEND1
					  TABLEALL(noprint exceptions)
					  ;	
        BY TEST STAGE PEAK;  /*V?*/	
		&GRSUBSET;
		RUN;
		%END;
	%END;
	%ELSE %DO;
		/* If not already in an insufficient data condition */
		%IF &DATACHECK3 NE STOP %THEN %DO;
		/*** Print warning in HTML for insufficient data               ***/
			DATA _NULL_; FILE _WEBOUT;
				PUT '<TABLE WIDTH="50%" ALIGN=CENTER VALIGN=CENTER><TR><TD>';
				PUT '<FONT FACE="Arial" ></BR></BR>Insufficient data to create chart.</FONT></TD></TR></TABLE>';
			RUN;
		%END;
	%END;
	%IF %SUPERQ(NOSAMPDT)=YES AND %SUPERQ(SORTVALUE)=SAMP_TST_DT %THEN %DO;
		DATA _NULL_; FILE _WEBOUT;
			PUT '<TABLE WIDTH="80%" ALIGN=CENTER VALIGN=CENTER><TR><TD>';
			PUT "<FONT FACE=Arial COLOR=RED></BR><STRONG>**NOTE: Some batch data points missing due to insufficient test date values.**</FONT></STRONG></TD></TR></TABLE>";
		RUN;
	%END;
	%IF %SUPERQ(DATECHECK)=STOP %THEN %DO;
		DATA _NULL_; FILE _WEBOUT;
			PUT "</BR><P ALIGN=CENTER><STRONG><FONT FACE=ARIAL COLOR=RED>You entered invalid date ranges.  Default date ranges were used.</FONT></STRONG></BR>";
		RUN;
	%END;

%MEND XBAR;

****************************************************************************************************;
*                                      MODULE HEADER                                               *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;
*	     REQUIREMENT: See LINKS Report SOP                                                     *;
*       INPUT DATASET   : BATCHES2.		                                                   *; 
*       PROCESSING      : Check to ensure all datapoints are not equal (cannot generate chart), if *;
*		          so print warning for insufficient data.  Otherwise create s bar chart    *; 
*		          stratifying by quarter.  Plot batch on horizontal axis.  Connect points  *;
*		          with a solid line.                                                       *;
*       OUTPUT          : 1 PLOT to web browser or RTF file.                                       *;
****************************************************************************************************;
%MACRO SBAR;

	%LET DATACHKFLAG=;

	%DATECHECK;

	%IF %SUPERQ(NOSAMPDT)=YES AND %SUPERQ(SORTVALUE)=SAMP_TST_DT %THEN %DO;
		DATA BATCHES1;SET BATCHES1;IF SAMP_TST_DT = . THEN DELETE;
		DATA BATCHES2;SET BATCHES2;IF SAMP_TST_DT = . THEN DELETE;
	%END;

	PROC SORT DATA=BATCHES2; BY BATCH_NBR; RUN;
	/*** Calculate std dev by lot                                        ***/
	PROC SUMMARY DATA=BATCHES2;
		VAR RESULT;
		BY BATCH_NBR;
		ID MATL_MFG_DT SAMP_TST_DT QUARTER;
		OUTPUT OUT=BATCHSUM STD=PRSTD N=N;
	RUN;

	/*** Check to see if all results are the same if so set flag to STOP ***/
	DATA _NULL_; SET BATCHSUM NOBS=MAXOBS;
		RETAIN DATACHK OBS 0;
		OBS=OBS+1;
		DATACHK=PRSTD-DATACHK;
		PUT DATACHK PRSTD;
		IF OBS=MAXOBS AND DATACHK =0 OR DATACHK=. THEN CALL SYMPUT('DATACHKFLAG','STOP');
	RUN;

	%WARNINGS;

        /*** If datachkflag is not STOP then proceed                         ***/
	%IF %SUPERQ(DATACHKFLAG)^=STOP %THEN %DO;  
		GOPTIONS reset=all;                  /***  Setup goptions    ***/
		GOPTIONS device=&device display;
		GOPTIONS &xpixels &ypixels  gsfmode=replace  BORDER;

		FOOTNOTE1 F=ARIAL j=L h=.95 "Generated by the LINKS System on &today at &rpttime" j=r "Data last updated: &Save_Last_Update_Date at &Save_Last_Update_Time";
  		FOOTNOTE2 H=.3 ' ';
		%IF %SUPERQ(UNAPPFLAG)=YES %THEN %DO;
			FOOTNOTE3 F=ARIAL C=RED J=C H=.95 'Report contains approved and unapproved data. '; 
			FOOTNOTE4 H=.3 ' ';
		%END;

		/*** Setup titles and footnotes ***/
		TITLE h=1 F=SWISSB "&TITLE_product &TITLE_test &TITLE_PEAKA";       /***  Setup titles, legend and axis  ***/
		title2 h=1 F=SWISSB "Batch Standard Deviation Run Chart for Batches Manufactured &STARTDATETITLE through &ENDDATETITLE";
	
		*FOOTNOTE2 F=ARIAL j=l h=.95 "Generated by the LINKS System on &today at &rpttime" j=r "Data last updated: &Save_Last_Update_Date at &Save_Last_Update_Time";
		
		AXIS1 LABEL=(a=90 FONT=SIMPLEX "Batch Standard Deviation") &VAXIS ;
		%IF %SUPERQ(SORTVALUE)=SAMP_TST_DT %THEN %DO;
			AXIS2 OFFSET=(2,2) LABEL=(FONT=SIMPLEX "Batch Number (Sorted by Test Date)");
		%END;
		%ELSE %DO;
		AXIS2 OFFSET=(2,2) LABEL=(FONT=SIMPLEX "Batch Number (Sorted by Manufacture Date)");
		%END;
		SYMBOL1 v=DOT w=.5 h=.75 c=black;
		SYMBOL2 v=DOT w=.75 c=red;
		LEGEND1 ORDER=(0,1);

		
		DATA BATCHes2; SET BATCHes2;
		SYMBOLLINK='HREF="' || "%superq(_THISSESSION)" ||
      			'&_program=' || "links.LRBATCHANALYSIS.sas" || '&BATCH=' || TRIM(BATCH_NBR) ||'&product='||"&PRODUCT"||	
	  				'&TESTA='||TEST||'&stagea='||"&stageanew"||'&peaka='||"&peakanew"||'&REPORTYPE=BATCHSTATS"';
		RUN;

		PROC SORT DATA=BATCHES2; BY TEST STAGE PEAK &SORTVALUE; RUN;
		/*** Create chart ***/
		/*** V7 - Added BY line to SHEWHART ***/
		PROC SHEWHART DATA=BATCHES2 LIMITS=STDCTL;
 			SCHART RESULT*BATCH_NBR(QUARTER)/ NPANELPOS= 1000
 					  VAXIS=AXIS1
					  HAXIS=AXIS2
                	  %IF %SUPERQ(CTLLIMITS)=NONE %THEN %DO;
                	  	NOLCL
				NOUCL
				NOLIMITLABEL
			  %END;
			  %ELSE %DO;
				READLIMITS
			  %END;
			  LIMITN=&LIMITNMIN  
			  ALLN
			  NMARKERS
			  LVREF=1
			  BLOCKPOS=1
			  BLOCKLABTYPE=scaled
			  CCONNECT=black
			  HTML=SYMBOLLINK
			  SYMBOLLEGEND=LEGEND1
			  TABLEALL(noprint exceptions);
			  LABEL BATCH_NBR='Batch Number';
		BY TEST STAGE PEAK;
		RUN;
	%END;
	%ELSE %DO;
		/*** Print warning in HTML for insufficient data ***/
		DATA _NULL_; FILE _WEBOUT;
			PUT '<TABLE WIDTH="50%" ALIGN=CENTER VALIGN=CENTER><TR><TD>';
			PUT '<FONT FACE="Arial" ></BR></BR>Insufficient data to create chart.</FONT></TD></TR></TABLE>';
		RUN;
	%END;
	%IF %SUPERQ(NOSAMPDT)=YES AND %SUPERQ(SORTVALUE)=SAMP_TST_DT %THEN %DO;
		DATA _NULL_; FILE _WEBOUT;
			PUT '<TABLE WIDTH="80%" ALIGN=CENTER VALIGN=CENTER><TR><TD>';
			PUT "<FONT FACE=Arial COLOR=RED></BR><STRONG>**NOTE: Some batch data points missing due to insufficient test date values.**</FONT></STRONG></TD></TR></TABLE>";
		RUN;
	%END;
	%IF %SUPERQ(DATECHECK)=STOP %THEN %DO;
		DATA _NULL_; FILE _WEBOUT;
			PUT "</BR><P ALIGN=CENTER><STRONG><FONT FACE=ARIAL COLOR=RED>You entered invalid date ranges.  Default date ranges were used.</FONT></STRONG></BR>";
		RUN;
	%END;

%MEND SBAR;

****************************************************************************************************;
*                                      MODULE HEADER                                               *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;
* 	     REQUIREMENT: See LINKS Report SOP                                                     *;
*       INPUT DATASET   : BATCHES2.		                                                   *; 
*       PROCESSING      : Determine mean of each batch.  Check to ensure                           *;
*		 	  all datapoints are not equal (cannot generate chart), if so              *;
*			  print warning for insufficient data.  Otherwise create x bar chart       *; 
*			  stratifying by quarter.  Plot batch on horizontal axis.  Connect points  *; 
*			  with a solid line.  Plot specifications as reference lines.              *;
*       OUTPUT          : 1 PLOT to web browser or RTF file.                                       *;
****************************************************************************************************;
%MACRO INDRUN;
	%DATECHECK;
	
	%IF %SUPERQ(NOSAMPDT)=YES AND %SUPERQ(SORTVALUE)=SAMP_TST_DT %THEN %DO;
		DATA BATCHES1;SET BATCHES1;IF SAMP_TST_DT = . THEN DELETE;
		DATA BATCHES2;SET BATCHES2;IF SAMP_TST_DT = . THEN DELETE;
	%END;

	GOPTIONS reset=all;   /***  Setup goptions ***/
	GOPTIONS device=&device display;
	GOPTIONS &xpixels &ypixels  gsfmode=replace  BORDER;

	/*** Setup titles and footnotes ***/
	TITLE h=1 F=SWISSB "&TITLE_product &TITLE_test &TITLE_PEAKA";         /***  Setup titles, legend and axis ***/
	title2 h=1 F=SWISSB "Batch Individuals Run Chart for Batches Manufactured &STARTDATETITLE through &ENDDATETITLE";
	
	%WARNINGS;

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
		FOOTNOTE1 F=ARIAL j=L h=.95 "Generated by the LINKS System on &today at &rpttime" j=r "Data last updated: &Save_Last_Update_Date at &Save_Last_Update_Time";
  		FOOTNOTE2 H=.3 ' ';
		%IF %SUPERQ(UNAPPFLAG)=YES %THEN %DO;
			FOOTNOTE3 F=ARIAL C=RED J=C H=.95 'Report contains approved and unapproved data. '; 
			FOOTNOTE4 H=.3 ' ';
		%END;
	%END;

 		
	DATA BATCHES2; SET BATCHES2;
		SYMBOLLINK='HREF="' || "%superq(_THISSESSION)" ||
      			'&_program=' || "links.LRBATCHANALYSIS.sas" || '&BATCH=' || TRIM(BATCH_NBR) || '&VALUE=' || "INDIVIDUAL" ||
	  		'&product='||"&product"||'&TESTA='||TEST||'&STAGEA='||TRIM(STAGE)||'&PEAKA='||TRIM(PEAK)||'&REPORTYPE=BATCHSTATS"';
	RUN;

	AXIS1 LABEL=(a=90 FONT=SIMPLEX "Individual Result") &VAXIS ;
	%IF %SUPERQ(SORTVALUE)=SAMP_TST_DT %THEN %DO;
		AXIS2 OFFSET=(2,2) LABEL=(FONT=SIMPLEX "Batch Number (Sorted by Test Date)");
	%END;
	%ELSE %DO;
		AXIS2 OFFSET=(2,2) LABEL=(FONT=SIMPLEX "Batch Number (Sorted by Manufacture Date)");
	%END;
	SYMBOL1 v=STAR w=.5 h=.75 c=black I=STD3TMJ;
	SYMBOL2 v=DOT w=.5 h=.75 c=red;

	PROC SORT DATA=BATCHES2; BY &SORTVALUE matl_nbr batch_nbr; RUN;

	DATA BATCHES2; RETAIN BATCHOBS 0; FORMAT BATCHN $10.; SET BATCHES2; BY &sortvalue matl_nbr BATCH_NBR;

	IF first.batch_nbr then	do;BATCHOBS=BATCHOBS+1;END; 

	if batchobs <10 then batchN="0"||left(TRIM(substr(LEFT(BATCHOBS),1))); 
	else batchN=left(TRIM(substr(LEFT(BATCHOBS),1)));
	run;

       DATA FORMATdata;
		LENGTH	START	$10.
				label   $10.
				FMTNAME	$8.
			;
		SET BATCHES2;
		RETAIN FMTNAME;
		FMTNAME = "$batch";
		IF _N_ = 1 THEN DO;	
			HLO = 'O'; LABEL = ''; START = ' '; OUTPUT; HLO = ' '; 
			END;
		START = BATCHn;
		LABEL = Batch_Nbr;
		KEEP START LABEL HLO FMTNAME;
		OUTPUT;
	RUN;

	PROC SORT NODUPKEY DATA=FORMATdata;
		BY FMTNAME START HLO;
	RUN;

	data _null_;set FORMATdata;
		PUT FMTNAME label START HLO;
	RUN;

	PROC FORMAT CNTLIN=FORMATdata;
	RUN;

	data _null_; set batches2;
	put batchn $batch.;
	run;


	/*** Create chart - Generate plot ***/
	PROC GPLOT DATA=BATCHES2;		
        PLOT RESULT * batchn / HAXIS=axis2 VAXIS=axis1 HTML=SYMBOLLINK
    	&vref LEGEND=legend1;
		format batchn $batch.;
	RUN;
	%IF %SUPERQ(NOSAMPDT)=YES AND %SUPERQ(SORTVALUE)=SAMP_TST_DT %THEN %DO;
		DATA _NULL_; FILE _WEBOUT;
			PUT '<TABLE WIDTH="80%" ALIGN=CENTER VALIGN=CENTER><TR><TD>';
			PUT "<FONT FACE=Arial COLOR=RED></BR><STRONG>**NOTE: Some batch data points missing due to insufficient test date values.**</FONT></STRONG></TD></TR></TABLE>";
		RUN;
	%END;
	%IF %SUPERQ(DATECHECK)=STOP %THEN %DO;
		DATA _NULL_; FILE _WEBOUT;
			PUT "</BR><P ALIGN=CENTER><STRONG><FONT FACE=ARIAL COLOR=RED>You entered invalid date ranges.  Default date ranges were used.</FONT></STRONG></BR>";
		RUN;
	%END;

%MEND INDRUN;

****************************************************************************************************;
*                                     MODULE HEADER                                                *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;
*	     REQUIREMENT: See LINKS Report SOP                                                     *; 
*       INPUT           : MACRO VARIABLES: HREF, MAXPERCENT, TIME, ANALYST,                        *;
*			  NUMTIMES, MAXPERCENT, OBSMAXPCT, TITLE_product, TITLE_test,              *;
*			  TITLE_PEAKA, STORAGE, INVALIDVAXIS, SPECLABEL1, SPECLABEL2               *;
*       PROCESSING      : Setup variables needed to generate comparative histograms                *;
*			  by time, study or analyst.                                               *;
*       OUTPUT          : 1 COMPARATIVE HISTOGRAM to web browser or RTF file.                      *; 
****************************************************************************************************;
%MACRO HIST;

	%LET INVALIDMAXAXIS=;

	/***  If there are no specifications, set href to null   ***/
	DATA _NULL_;  
	    	href=UPCASE(COMPRESS("&href"));
	    	IF href='HREF=' THEN CALL SYMPUT('href',' ');
  	RUN;
 
	/********************************************************************************************************/
	/**** IR001 - #7 CHANGED - CREATED ERROR MESSAGE IF INVALID CHARACTERS WERE ENTERED FOR "MAXPERCENT" ****/
	/********************************************************************************************************/
	DATA _NULL_;
		maxpercent="&maxpercent";
		if indexc(UPCASE(maxpercent),'ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()_-+=') > 0 THEN do;
			maxpercent='';
			CALL SYMPUT('INVALIDMAXAXIS','YES');
		end;
		obsmaxpct=TRIM(LEFT("&obsmaxpct")); 	
		/***  Check for invalid user axis values, if invalid axis, set to null  ***/
		IF MAXPERCENT ^= '' AND OBSMAXPCT ^= '' THEN DO;
			difference=maxpercent-obsmaxpct;
			IF difference ^=. AND difference < 0 THEN DO;
				CALL SYMPUT('MAXPERCENT',' ');
				CALL SYMPUT('INVALIDMAXAXIS','YES');
				CALL SYMPUT('WARNING','YES');
			END;
		END;
  	RUN;

	/***********/
	  %WARNINGS;
	/***********/
	/***  Setup vertical axis values                         ***/

	DATA _NULL_;  
		maxpercent="&maxpercent";
		if indexc(UPCASE(maxpercent),'ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()_-+=') > 0 THEN do;
			maxpercent='';
			CALL SYMPUT('INVALIDMAXAXIS','YES');
			CALL SYMPUT('WARNING','YES');
		end;
		IF maxpercent in ('',' ') THEN CALL SYMPUT('VAXIS',' '); 
		ELSE CALL SYMPUT('VAXIS',"VAXIS=0 TO &MAXPERCENT");
	RUN;

	%IF %SUPERQ(VALUE)=MEAN %THEN %LET HISTRES=MEAN;

	%IF %SUPERQ(VALUE)=INDIVIDUAL %THEN %LET HISTRES=RESULT;

	/***  Setup goptions                                      ***/
  	GOPTIONS reset=all;  
	GOPTIONS device=&device display;
	GOPTIONS &xpixels &ypixels  gsfmode=replace  BORDER ftext=simplex;

        /***  Setup title and footnote                            ***/
        TITLE H=1 F=SWISSB "&TITLE_product &TITLE_test &TITLE_PEAKA";  
	%IF %SUPERQ(VALUE)=MEAN %THEN %DO;
	TITLE2 H=1 F=SWISSB "Histogram of Batch Means for Batches Manufactured &STARTDATETITLE through &ENDDATETITLE"; %END;
	%IF %SUPERQ(VALUE)=INDIVIDUAL %THEN %DO;
	TITLE2 H=1 F=SWISSB "Histogram of Batch Individuals for Batches Manufactured &STARTDATETITLE through &ENDDATETITLE"; %END;
  	  	
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
		FOOTNOTE1 F=ARIAL j=L h=.95 "Generated by the LINKS System on &today at &rpttime" j=r "Data last updated: &Save_Last_Update_Date at &Save_Last_Update_Time";
  		FOOTNOTE2 H=.3 ' ';
		%IF %SUPERQ(UNAPPFLAG)=YES %THEN %DO;
			FOOTNOTE3 F=ARIAL C=RED J=C H=.95 'Report contains approved and unapproved data. '; 
			FOOTNOTE4 H=.3 ' ';
		%END;
	%END;

	DATA _NULL_;RETAIN PLUSDATA 0;SET ALLDATA_WITH_STATS;
		HISTRES="&HISTRES";
		IF HISTRES='MEAN'   AND MEAN   GT 0 THEN PLUSDATA=1;
		IF HISTRES='RESULT' AND RESULT GT 0 THEN PLUSDATA=1;
		IF PLUSDATA=0 THEN CALL SYMPUT('DATACHKFLAG','STOP');
	RUN;

	%IF %SUPERQ(DATACHKFLAG)^=STOP %THEN %DO;  
	  	/***  Generate histograms                                 ***/
	  	PROC CAPABILITY DATA= ALLDATA_WITH_STATS noprint normaltest;                                            
	    	VAR &HISTRES;                                                                
	    	LABEL result="Individual Batch Results"
			  mean="Batch Means";   
	     	HISTOGRAM /   
	       		&href 
	       		&HAXIShist nocurvelegend
		   	&VAXIS OUTHISTOGRAM=OUTPCT;                                                                           
	  	RUN;     
	        /*** Determine observed maximum percentage of histograms  ***/
		PROC SUMMARY DATA=OUTPCT;  
		  	VAR _OBSPCT_;
		  	OUTPUT OUT=MAXPCT MAX=MAXPCT;
		RUN;
	
		%GLOBAL OBSMAXPCT;
		DATA _NULL_; SET MAXPCT;
			MAXPERCENT="&MAXPERCENT";VAXISCHK="&VAXISCHK";OBSMAXPCT="&OBSMAXPCT";
			if indexc(UPCASE(maxpercent),'ABCDEFGHIJKLMNOPQRSTUVWXYZ!@#$%^&*()_-+=') > 0 THEN maxpercent='';
			IF MAXPERCENT IN ('','.') THEN CALL SYMPUT('MAXPERCENT',ceil(MAXPCT));
			IF VAXISCHK^='USER' THEN CALL SYMPUT('MAXPERCENT',ceil(MAXPCT));
			CALL SYMPUT('OBSMAXPCT',ceil(MAXPCT));	
			PUT _ALL_;
		RUN;
	%END;
	%ELSE %DO;
		/*** Print warning in HTML for insufficient data ***/
		DATA _NULL_; FILE _WEBOUT;
			PUT '<TABLE WIDTH="50%" ALIGN=CENTER VALIGN=CENTER><TR><TD>';
			PUT '<FONT FACE="Arial" ></BR></BR>Insufficient data to create chart.</FONT></TD></TR></TABLE>';
		RUN;
	%END;
/***
	%IF %SUPERQ(DATECHECK)=STOP %THEN %DO;
		DATA _NULL_; FILE _WEBOUT;
			PUT "</BR><P ALIGN=CENTER><STRONG><FONT FACE=ARIAL COLOR=RED>You entered invalid date ranges.  Default date ranges were used.</FONT></STRONG></BR>";
		RUN;
	%END;
***/
	%IF %SUPERQ(MAXPERCENT) < %SUPERQ(OBSMAXPCT) AND %SUPERQ(INVALIDMAXAXIS)= %THEN %DO;
		DATA _NULL_;
			CALL SYMPUT('MAXPERCENT',"&OBSMAXPCT");
		RUN;
	%END;

%MEND Hist;

****************************************************************************************************;
*                                        MODULE HEADER                                             *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;  
*	     REQUIREMENT: See LINKS Report SOP                                                     *;
*       INPUT           : MACRO VARIABLES: RPTVALUE, SPECLABEL. DATASET: STABILITY3                *;
*       PROCESSING      : Generate summary statistics table by time point for a                    *;
*		          user chosen statistic.  If the report is for individual results,         *; 
*		          put all results in a comma delimited list in one cell per timepoint      *;
*		          for each study.  Time points should be listed horizontally across        *;
*		          the table.                                                               *;
*       OUTPUT          : 1 summary statistics table to Web browser or RTF file.                   *;
****************************************************************************************************;
%MACRO PRODSTATS;

OPTIONS nomlogic nomprint nosymbolgen;
	%IF %SUPERQ(speclabel1)^=  %THEN %DO;
	  	%LET SPECLABEL=;
  		%DO I = 1 %TO &NUMSPECS;
  			%LET SPECLABEL=&SPECLABEL &&SPECLABEL&I;
  			%IF &I < &NUMSPECS %THEN %LET SPECLABEL=&SPECLABEL ,;
  		%END;
  	%END;
  	%ELSE %LET SPECLABEL=N/A;
OPTIONS mlogic mprint symbolgen;

	%IF %SUPERQ(SPECCHKM)=YES OR %SUPERQ(SPECCHKI)=YES% THEN %DO;
	
		PROC SORT DATA=MAXDATA; BY PRODUCT TEST STAGE PEAK; RUN;
		DATA MAXDATA; MERGE MAXDATA(IN=IN1) SPECTYPE(IN=IN2);
		BY PRODUCT TEST STAGE PEAK;
		PUT PRODUCT TEST STAGE PEAK SPEC SPECTXTLIST;
		RUN;

	%END;

	DATA BATCHSUM; length GRN 3 RANGE2 GRMEAN2 cpkM2 CPKIND2 betSTD2 TEST speclabEL $800; SET MAXDATA;
		IF (MINlowM^=. and MAXUPM^=.) AND betSTD^=0 THEN DO;
      			CPLM=(grmean-MINLOWM)/(3*betSTD);
      			CPUM=(MAXUPM-grmean)/(3*betSTD);
      			CPKMean=min(CPLM,CPUM);
		END;

   		if (MINLOWM^=. and MAXUPM=.) and betSTD^=0 then CPKMean=(grmean-MINLOWM)/(3*betSTD);
   		if (MINLOWM=. and MAXUPM^=.) and betSTD^=0 then CPKMean=(MAXUPM-grmean)/(3*betSTD);

		IF (MINLOWi^=. and MAXUPI^=.) AND GRSTD^=0 THEN DO;
      			CPLI=(grmean-MINLOWI)/(3*GRSTD);
      			CPUI=(MAXUPI-grmean)/(3*GRSTD);
      			CPKIND=MIN(CPLI,CPUI);
   		END;

   		IF (MINLOWI^=. and MAXUPI=.) AND GRSTD^=0 THEN CPKIND=(grmean-MINLOWi)/(3*GRSTD);
   		IF (MINLOWI=. and MAXUPI^=.) AND GRSTD^=0 THEN CPKIND=(MAXUPI-grmean)/(3*GRSTD);

		ucl=grmean+(3*betSTD);
   		lcl=grmean-(3*betSTD);
   		IF lcl < 0 THEN lcl=0;

		limits=RIGHT(COMPRESS(PUT(lcl,trnc2D.)))||', '||LEFT(COMPRESS(PUT(ucl,trnc2D.)));
   		betSTD2=COMPRESS(PUT(betSTD,trnc2D.));
   		IF CPKMean^=. THEN cpkM2=COMPRESS(put(cpkMEAN,trnc2D.)); 
		IF CPKIND^=. THEN cpkIND2=COMPRESS(put(cpkIND,trnc2D.)); 
		IF GRN < 10 THEN DO;
      			limits='Insuff. Data';
      			betSTD2='Insuff. Data';
      			cpkM2='Insuff. Data';
			cpkIND2='Insuff. Data';
   		END;
   		IF CPKMean=. THEN CPKM2='N/A';
		IF CPKIND=.  THEN CPKIND2='N/A';
		IF MeanCheck=1 AND (betSTD2='Insuff. Data' OR betSTD2=0) THEN cpkM2='Insuff. Data';
		IF IndCheck=1  AND (betSTD2='Insuff. Data' OR betSTD2=0) THEN cpkInd2='Insuff. Data';

/*
    	OUTPUT OUT=MaxData min=minn  minmean minind minstd minrsd minmin minmax 
                           max=maxn  maxmean maxind maxstd maxrsd maxmin maxmax 
			  MEAN=meann GRMEAN  A      B      C      D      E 
		           STD=F     BETSTD  GRSTD  H      I      J      K 
			     N=G     GRN     L      M      N      O      P;
*/

		IF SPEC_PRECISION=0 THEN DO;
      			grmean2=COMPRESS(PUT(grmean,trnc1D.));
      			RANGE2=RIGHT(COMPRESS(PUT(minMEAN,trnc1D.)))||', '||LEFT(COMPRESS(PUT(MAXMEAN,trnc1D.)));
   		END;

   		IF SPEC_PRECISION=1 OR SPEC_PRECISION=. THEN DO;
      			grmean2=COMPRESS(PUT(grmean,trnc2D.));
      			RANGE2=RIGHT(COMPRESS(PUT(minmean,trnc2D.)))||', '||LEFT(COMPRESS(PUT(maxmean,trnc2D.)));
   		END;

   		IF SPEC_PRECISION=2 THEN DO;
      			grmean2=COMPRESS(PUT(grmean,trnc3D.));
      			RANGE2=RIGHT(COMPRESS(PUT(minmean,trnc3D.)))||', '||LEFT(COMPRESS(PUT(maxmean,trnc3D.)));
   		END;
	
		IF PEAK NOT IN ('NONE','') 	AND STAGE NOT IN ('NONE','') 	THEN TEST2=TRIM(TEST)||'-'||TRIM(STAGE)||'-'||TRIM(PEAK);
		IF PEAK IN ('NONE','') 		AND STAGE NOT IN ('NONE','') 	THEN TEST2=TRIM(TEST)||'-'||TRIM(STAGE);
		IF PEAK NOT IN ('NONE','') 	AND STAGE IN ('NONE','') 	THEN TEST2=TRIM(TEST)||'-'||TRIM(PEAK);
		IF PEAK IN ('NONE','') 		AND STAGE IN ('NONE','') 	THEN TEST2=TRIM(TEST);
		
		IF TEST='' THEN DELETE;

		%IF %SUPERQ(SPECCHKI)=YES OR %SUPERQ(SPECCHKM)=YES %THEN %DO;
			SPECLABEL=TRIM(SPECTXTLIST);
			IF SPECLABEL='' THEN SPECLABEL='N/A';
		%END;
		%ELSE %DO;
			SPECLABEL='N/A';
		%END;

		IF SPECLABEL='N/A' THEN DO; cpkM2='N/A';cpkIND2='N/A'; END;

   		*DROP CPLM CPUM CPLI CPUI;
   		PUT 	TEST STAGE PEAK SPEC_PRECISION MINLOWI MAXUPI cpkmean cpkmean2 cpkind cpkind2 betSTD2 GRSTD grmean meann G L;
	RUN;
	
	/*** Setup titles and footnotes                           ***/
	TITLE h=2 c=black F=swissb "&TITLE_product Summary Statistics - &STARTDATETITLE through &ENDDATETITLE";
	
	FOOTNOTE1 H=1 F=ARIAL "Generated by the LINKS System on &today at &rpttime";
	FOOTNOTE2 H=1 F=ARIAL "Data last updated: &Save_Last_Update_Date at &Save_Last_Update_Time";

	%IF %SUPERQ(UNAPPFLAG)=YES %THEN %DO;
		%LET J = %EVAL(&NUMSPECS+5);
		FOOTNOTE&J C=RED F=ARIAL J=C H=.95 'Report contains approved and unapproved data. '; 
		%LET J = %EVAL(&NUMSPECS+6);
		FOOTNOTE&J H=.2 ' ';
	%END;

	/*** If sending output to screen setup HTML               ***/
  	DATA _NULL_; FILE _WEBOUT;
		print="&print";
  		IF print ^='ON' THEN DO;
  			PUT '<TABLE WIDTH="95%" ALIGN=CENTER><TR><TD>';
		END;
  	RUN;
 
	/*** Setup report style characteristics                   ***/
	%LET stylereport= STYLE(column) = {background = white} STYLE(LINES)=[FONT_SIZE=1 FOREGROUND=BLACK] STYLE(report) = [background=white outputwidth=100%] ;
	/*** Setup macro variable for style of table headers      ***/

	%IF %SUPERQ(PRINT)=ON %THEN %DO;
		%LET CELLWIDTH=CELLWIDTH=90;
		%LET FONTSIZE=FONT_SIZE=1;
		%END;
	%ELSE %DO;
		%LET CELLWIDTH= ;
		%LET FONTSIZE=FONT_SIZE=2;
		%END;
	%LET styleheader=STYLE(header)=[&FONTSIZE background=#C0C0C0 foreground=black &cellwidth];

	/*** Generate report                                      ***/
        
	PROC REPORT DATA=BATCHSUM NOWD BOX NOCENTER SPLIT='*' &STYLEREPORT ps=35 ls=200;
   		COLUMN test2 speclabEL grn grmean2 limits betSTD2 RANGE2 cpkM2 CPKIND2;
   		DEFINE test2     / "Test"                                            order=data id left   width=10 &STYLEheader;
   		DEFINE speclabEL / "Specification"                                              left   width=10 &STYLEheader;
   		DEFINE GRN       / "Total*Number*of*Batches"                                    center width=8  &STYLEheader;
   		DEFINE grmean2   / "Overall*Batch*Mean"                                         center width=10 &STYLEheader;
   		DEFINE limits    / "Limits*To*Contain*99.7% of*Batch*Means (1)" center width=10 &STYLEheader;
   		DEFINE betSTD2   / "Between*Batch*Standard*Deviation"                           center width=10 &STYLEheader;
   		DEFINE RANGE2    / "Minimum*and*Maximum*Batch*Mean"                             center width=10 &STYLEheader;
   		DEFINE cpkM2     / "Ppk on*Batch*Means*(1)"                                     center width=10 &styleheader;   /* Modified V4  */
		DEFINE cpkIND2   / "Ppk on*Batch*Indi-*viduals(2)"                              center width=10 &styleheader;   /* Modified V4  */
   		
   		COMPUTE AFTER;
   		LINE '(1) Calculations performed using between batch standard deviation.';
		LINE '(2) Calculation performed using overall standard deviation.';
   		ENDCOMP;
	RUN;
	
	%IF %SUPERQ(DATECHECK)=STOP %THEN %DO;
		DATA _NULL_; FILE _WEBOUT;
			PUT "</BR><P ALIGN=CENTER><STRONG><FONT FACE=ARIAL COLOR=RED>You entered invalid date ranges.  Default date ranges were used.</FONT></STRONG></BR>";
		RUN;
	%END;

	/*** If output is sent to the screen, setup HTML          ***/
	DATA _NULL_; FILE _WEBOUT;
  		print="&print";
  		IF print ^='ON' THEN DO;
  			PUT '</TR></TD></TABLE>';
		END;
  	RUN;

%MEND PRODSTATS;

****************************************************************************************************;
*                                        MODULE HEADER                                             *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;
**	     REQUIREMENT: See LINKS Report SOP                                                     *;
*       INPUT           : MACRO VARIABLES: RPTVALUE, SPECLABEL. DATASET: STABILITY3                *;
*       PROCESSING      : Generate summary statistics table by time point for a                    *;
*		          user chosen statistic.  If the report is for individual results,         *;
*		          put all results in a comma delimited list in one cell per timepoint      *; 
*		          for each study.  Time points should be listed horizontally across        *;
*		          the table.                                                               *;
*       OUTPUT          : 1 summary statistics table to Web browser or RTF file.                   *;
****************************************************************************************************;
%MACRO BATCHSTATS;
	%GLOBAL LOTTXT1 LOTTXT2 LOTTXT3;
	%LET NORECORDS = 0;

	/*** V7 - Set it to 4 decimal places ***/

	PROC FORMAT;
   		PICTURE trnc3D low-high="0009.999";
   		PICTURE trnc2D low-high="0009.99";
   		PICTURE trnc1D low-high="0009.9";
	RUN;

	DATA _NULL;
		TestA="&TestA";
		StageA="&StageA";
		IF TestA='HPLC Related Imp. In Advair MDPI' AND INDEX(StageA,'Salmeterol') > 0 
			THEN CALL SYMPUT('PeakA','Salmeterol');
		IF TestA='HPLC Related Imp. In Advair MDPI' AND INDEX(StageA,'Fluticasone') > 0 
			THEN CALL SYMPUT('PeakA','Fluticasone');
		IF TestA='HPLC Related Imp. In Advair MDPI' AND INDEX(StageA,'Total Degradants') > 0 
			THEN CALL SYMPUT('PeakA','NONE');
	RUN;

	%IF %SUPERQ(VALUE)=ALLTESTS OR %SUPERQ(VALUE)= %THEN %DO;
		%LET BATCH=;
		%LET VALUE=SUMMARY;
	%END;
	OPTIONS NOMLOGIC NOSYMBOLGEN NOSOURCE NOSERROR;

	%IF %SUPERQ(speclabel1)^=  %THEN %DO;
	  	%LET SPECLABEL=;
  		%DO I = 1 %TO &NUMSPECS;
  			%LET SPECLABEL=&SPECLABEL &&SPECLABEL&I;
  			%IF &I < &NUMSPECS %THEN %LET SPECLABEL=&SPECLABEL ,;
  		%END;
  	%END;
  	%ELSE %LET SPECLABEL=N/A;

	OPTIONS MLOGIC SYMBOLGEN SOURCE SERROR;

	%IF %SUPERQ(SPECCHKI)=YES OR %SUPERQ(SPECCHKM)=YES %THEN %DO;	
		DATA SPECTYPE; SET SPECTYPE; DROP MATL_NBR BATCH_NBR; RUN;
		PROC SORT DATA=MEANS; BY PRODUCT TEST STAGE PEAK BATCH_NBR; RUN;
		DATA MAXDATA; MERGE MEANS(IN=A) SPECTYPE(IN=B) MAXSPECS(IN=C);
			BY PRODUCT TEST STAGE PEAK ;
			IF A;
		RUN;
	%END;
	%ELSE %DO;
		PROC SORT DATA=MEANS; BY PRODUCT TEST STAGE PEAK BATCH_NBR; RUN;
		DATA MAXDATA; SET MEANS;
			BY PRODUCT TEST STAGE PEAK ;
			LOWERI=.; UPPERI=.; LOWERM=.; UPPERM=.; SPECTXTLIST='';
		RUN;
		%END;

		DATA _NULL_; SET SPECTYPE;
		PUT PRODUCT TEST STAGE PEAK BATCH_NBR ; RUN;

DATA _NULL_; SET MAXDATA;
		PUT PRODUCT TEST STAGE PEAK  ; RUN;

DATA _NULL_; SET MEANS;
		PUT PRODUCT TEST STAGE PEAK  ; RUN;

DATA _NULL_; SET MAXSPECS;
		PUT PRODUCT TEST STAGE PEAK  ; RUN;
		

	/* Modified v6 */
	%IF       %SUPERQ(BATCH)^= AND %SUPERQ(TESTA)=ALL   	%THEN %LET BATCHSUB=WHERE UPCASE(PRODUCT)=UPCASE("&PRODUCT") AND UPCASE(BATCH_NBR)=UPCASE("&BATCH");
	%ELSE %IF %SUPERQ(BATCH)^= AND %SUPERQ(TESTA)^= 	%THEN %LET BATCHSUB=WHERE UPCASE(PRODUCT)=UPCASE("&PRODUCT") AND UPCASE(STAGE)=UPCASE("&STAGEA") AND UPCASE(PEAK)=UPCASE("&PEAKA") AND UPCASE(BATCH_NBR)=UPCASE("&BATCH") AND UPCASE(TEST)=UPCASE("&TESTA");
	%ELSE %IF %SUPERQ(BATCH)=  AND %SUPERQ(TESTA)^=ALL 	%THEN %LET BATCHSUB=WHERE UPCASE(PRODUCT)=UPCASE("&PRODUCT") AND UPCASE(STAGE)=UPCASE("&STAGEA") AND UPCASE(PEAK)=UPCASE("&PEAKA") AND UPCASE(TEST)=UPCASE("&TESTA");
	%ELSE %IF %SUPERQ(BATCH)=  AND %SUPERQ(TESTA)=ALL 	%THEN %LET BATCHSUB=WHERE UPCASE(PRODUCT)=UPCASE("&PRODUCT");
	%ELSE %LET BATCHSUB=WHERE upcase(PRODUCT)=upcase("&PRODUCT") AND upcase(STAGE)=upcase("&STAGEA") AND upcase(PEAK)=upcase("&PEAKA") AND upcase(TEST)=upcase("&TESTA");
	
	**************************************;
	***       SUMMARY SECTION          ***;
	**************************************;
	%IF %SUPERQ(Value) =SUMMARY %THEN %DO;
	
	DATA BATCHSUM; LENGTH GRN 3 RANGE2 GRMEAN2 cpkM2 CPKIND2 betSTD2 TEST speclabEL $800 SAMP_TST_DT2 $20.; 
	SET MAXDATA;
	    &batchsub;
		
		%IF %SUPERQ(PRINT) ^= ON %THEN %DO;
			BATCH=	'<a HREF="' || "%superq(_THISSESSION)" || '&_program=' || "links.LRBATCHANALYSIS.sas" || 
				'&BATCH=' || TRIM(BATCH_NBR) ||'&product=' ||"&PRODUCT"|| '&TESTA=' || TRIM(TEST) ||  
				'&STAGEA=' || TRIM(STAGE) ||  '&PEAKA=' || TRIM(PEAK) || 			
				'&REPORTYPE=BATCHSTATS"><FONT FACE=ARIAL>' || TRIM(BATCH_NBR)|| '</FONT></a>';
		%END;
		%ELSE %DO;
			BATCH=TRIM(BATCH_NBR); 
		%END;
		IF (MINLOWi^=. and MAXUPI^=.) AND STD^=0 THEN DO;
      			CPLI   = (mean-MINLOWI)/(3*STD);
      			CPUI   = (MAXUPI-mean)/(3*STD);
      			CPKIND = min(CPLI,CPUI);
   		END;

   		IF (MINLOWI^=. and MAXUPI=.) AND STD^=0 THEN CPKIND=(mean-MINLOWi)/(3*STD);
   		IF (MINLOWI=. and MAXUPI^=.) AND STD^=0 THEN CPKIND=(MAXUPI-mean)/(3*STD);

		IF CPKIND^=. THEN cpkIND2=COMPRESS(put(cpkIND,trnc2D.)); ELSE CPKIND2='N/A';

		IF N < 10 THEN cpkIND2='Insuff. Data';

		IF CPKIND=.  THEN CPKIND2='N/A';
		IF IndCheck=1  AND (STD='Insuff. Data' OR STD=0) THEN cpkInd2='Insuff. Data';

   		PUT 	TEST STAGE PEAK BATCH_NBR MINLOWI MAXUPI mean STD cpkIND;
		N2=N;
		
		STD2=COMPRESS(PUT(std,trnc2D.));  IF STD2=. THEN STD2='N/A';
		rsd2=COMPRESS(PUT(rsd,trnc2D.));  IF RSD2=. THEN RSD2='N/A';
		IF SPEC_PRECISION=0 THEN DO;
      			mean2=compress(put(mean,trnc1D.));
      			RANGE2=right(compress(put(min,trnc1D.)))||', '||left(compress(put(MAX,trnc1D.)));
  		END;

   		ELSE IF SPEC_PRECISION=1 OR SPEC_PRECISION=. THEN DO;
      			mean2=compress(put(mean,trnc2D.));
      			RANGE2=right(compress(put(min,trnc2D.)))||', '||left(compress(put(max,trnc2D.)));
   		END;

   		ELSE IF SPEC_PRECISION=2 THEN DO;
      			mean2=compress(put(mean,trnc3D.));
      			RANGE2=right(compress(put(min,trnc3D.)))||', '||left(compress(put(max,trnc3D.)));
   		END;
		ELSE DO;
				mean2=compress(put(mean,trnc4D.));
      			RANGE2=right(compress(put(min,trnc4D.)))||', '||left(compress(put(max,trnc4D.)));
		END;

		put test stage peak spec_precision mean2 range2;

		IF PEAK NOT IN ('NONE','') AND STAGE NOT IN ('NONE','') THEN TEST2=TRIM(TEST)||'-'||TRIM(STAGE)||'-'||TRIM(PEAK);
		IF PEAK     IN ('NONE','') AND STAGE NOT IN ('NONE','') THEN TEST2=TRIM(TEST)||'-'||TRIM(STAGE);
		IF PEAK NOT IN ('NONE','') AND STAGE     IN ('NONE','') THEN TEST2=TRIM(TEST)||'-'||TRIM(PEAK);
		IF PEAK     IN ('NONE','') AND STAGE     IN ('NONE','') THEN TEST2=TRIM(TEST);
		
		IF TEST='' THEN DELETE;

		%IF %SUPERQ(SPECCHKI)=YES OR %SUPERQ(SPECCHKM)=YES %THEN %DO;
			SPECLABEL=TRIM(SPECTXTLIST);
			IF SPECLABEL='' THEN SPECLABEL='N/A';
		%END;
		%ELSE %DO;
			SPECLABEL='N/A';
		%END;

		IF SPECLABEL='N/A' THEN DO; cpkM2='N/A';cpkIND2='N/A'; END;

		CREATE_DATE2=PUT(PUT(DATEPART(MATL_MFG_DT),MMDDYY8.), $20.);
		MATL_DESC=TRIM(MATL_DESC);
		BATCH_NBR2=TRIM(MATL_NBR)||'-'||TRIM(LEFT(BATCH_NBR)); /* Added V3*/
		IF ASSY_BATCH='' THEN ASSY_BATCH='Not Available';
		IF FILL_BATCH='' THEN FILL_BATCH='Not Available';
		IF BLEND_BATCH='' THEN BLEND_BATCH='Not Available';

		 put 'lookhere ' prod_grp batch_nbr batch_nbr2 blend_batch fill_batch assy_batch assy_batch2;
		
		IF SAMP_TST_DT=. THEN SAMP_TST_DT2='N/A';
				 ELSE SAMP_TST_DT2=PUT(PUT(DATEPART(SAMP_TST_DT),mmddyy8.),$20.);
				
		IF PROD_GRP='MDPI' THEN DO;
		IF BATCH_NBR2=TRIM(BLEND_BATCH) THEN DO;
			CALL SYMPUT('LOTTXT1', "'Summary Statistics for Blend Batch Number: ' batch_nbr $15. 'Date of Manufacture: ' create_date2 $15.");
			CALL SYMPUT('LOTTXT2', "'Blend Batch Description: ' MATL_DESC $195.");
			CALL SYMPUT('LOTTXT3', "'Related Batches:  Fill Batch Number: '   FILL_BATCH $30. @75 'Assembled Batch Number: '   ASSY_BATCH $30."); 
			END;
		ELSE IF BATCH_NBR2=FILL_BATCH THEN DO;
			CALL SYMPUT('LOTTXT1', "'Summary Statistics for Fill Batch Number: ' batch_nbr $15. 'Date of Manufacture: ' create_date2 $15. ");
			CALL SYMPUT('LOTTXT2', "'Fill Batch Description: ' MATL_DESC $195.");			
			CALL SYMPUT('LOTTXT3', "'Related Batches:  Blend Batch Number: '   BLEND_BATCH $30. @75 'Assembled Batch Number: '   ASSY_BATCH $30."); 
			END;
		ELSE IF BATCH_NBR2=ASSY_BATCH THEN DO;
			CALL SYMPUT('LOTTXT1', "'Summary Statistics for Assembled Batch Number: ' batch_nbr $15. 'Date of Manufacture: ' create_date2 $15.");
			CALL SYMPUT('LOTTXT2', "'Assembled Batch Description: ' MATL_DESC $195.");		
			CALL SYMPUT('LOTTXT3', "'Related Batches:  Blend Batch Number: '   BLEND_BATCH $30. @75 'Fill Batch Number: '   FILL_BATCH $30."); 
			END;
		ELSE DO;  /* Added V3*/
			CALL SYMPUT('LOTTXT1', "'Summary Statistics for Batch Number: ' batch_nbr $15. ");
			CALL SYMPUT('LOTTXT2', "'Batch Description: '  MATL_DESC $195. ");		
			CALL SYMPUT('LOTTXT3', "'Date of Manufacture: ' create_date2 $15. "); 
			END;
			
			END;
		ELSE DO;  
				CALL SYMPUT('LOTTXT1', "'Summary Statistics for Batch Number: ' batch_nbr $15. 'Date of Manufacture: ' create_date2 $8.");
				CALL SYMPUT('LOTTXT2', "'Batch Description: ' MATL_DESC $195.");
				CALL SYMPUT('LOTTXT3', "'Related Batches:  Packaging Batch Number: '   ASSY_BATCH $30. @75 "); 
				END;

		CALL SYMPUT('SPECLABEL', TRIM(SPECLABEL));
		IF BATCH='' THEN DELETE;
		PUT BATCH_NBR BLEND_BATCH FILL_BATCH ASSY_BATCH;
   		DROP CPLI CPUI;
		RUN;
PROC SORT DATA=BATCHSUM;BY TEST PEAK STAGE &SORTVALUE ;RUN;

		data _null_; set batchsum;
		put batch_nbr batch matl_mfg_dt;
		run;

	%END;	
	/*** Setup titles and footnotes                           ***/
	%IF %SUPERQ(BATCH)= OR %SUPERQ(TESTA)=ALL %THEN %DO;
		TITLE h=2 c=black F=arial "&TITLE_product &TITLE_TEST &TITLE_PEAKA ";
 
		%IF %SUPERQ(SORTVALUE)=SAMP_TST_DT %THEN %DO;
			TITLE3 H=2 C=BLACK F=ARIAL "(Sorted by Test Date)";
		%END;
	%END;
	%ELSE %DO;
		TITLE h=2 c=black F=arial "&TITLE_product Summary Statistics for Batch &batch";
	%END;

	FOOTNOTE1 H=1 F=ARIAL "Generated by the LINKS System on &today at &rpttime";
	FOOTNOTE2 H=1 F=ARIAL "Data last updated: &Save_Last_Update_Date at &Save_Last_Update_Time";

	%IF %SUPERQ(UNAPPFLAG)=YES %THEN %DO;
		%LET J = %EVAL(&NUMSPECS+5);
		FOOTNOTE&J C=RED F=ARIAL J=C H=.95 'Report contains approved and unapproved data. '; 
		%LET J = %EVAL(&NUMSPECS+6);
		FOOTNOTE&J H=.2 ' ';
	%END;

	/*** If sending output to screen setup HTML               ***/
  	DATA _NULL_; FILE _WEBOUT;
		print="&print";
  		IF print ^='ON' THEN DO;
  			PUT '<TABLE WIDTH="95%" ALIGN=CENTER><TR><TD>';
		END;
  	RUN;
 
	**************************************;
	***      INDIVIDUAL SECTION        ***;
	**************************************;
	%IF %SUPERQ(Value) =INDIVIDUAL %THEN %DO;
			%GLOBAL BatchNum;
			%IF %SUPERQ(BATCH)= %THEN %LET BATCHNUM=Batch_Nbr; %ELSE %LET BATCHNUM=;
			PROC SORT DATA=MAXDATA OUT=SUMDATA NODUPKEY;&BATCHSUB;   
				BY PRODUCT TEST STAGE PEAK BATCH_NBR;RUN;
			%LET NoPrint1=;  %LET NoPrint2=NOPRINT;
	
data _null_;set ALLDATA_WITH_STATS;if _n_=1 then put _all_;run;

			PROC SORT DATA=ALLDATA_WITH_STATS;&BATCHSUB;
				BY &BatchNum Meth_Spec_Nm STAGE Meth_Peak_Nm;RUN;
			DATA BATCHSUM;Length Indvl2 $200 ;SET ALLDATA_WITH_STATS;
				BY &BatchNum Meth_Spec_Nm STAGE Meth_Peak_Nm;
				RETAIN Indvl2;
				IF FIRST.Meth_Peak_Nm THEN Indvl2=TRIM(LEFT(Result));
						      ELSE Indvl2=TRIM(LEFT(Indvl2))||', '||TRIM(LEFT(Result));
				IF LAST.Meth_Peak_Nm  THEN DO;
				%IF %SUPERQ(PRINT) ^= ON %THEN %DO;
				BATCH=	'<a HREF="' || "%superq(_THISSESSION)" || '&_program=' || "links.LRBATCHANALYSIS.sas" || 
				'&BATCH=' || TRIM(BATCH_NBR) ||'&product=' ||"&PRODUCT"|| '&TESTA=' || TRIM(TEST) ||  
				'&STAGEA=' || TRIM(STAGE) ||  '&PEAKA=' || TRIM(PEAK) || 			
				'&REPORTYPE=BATCHSTATS"><FONT FACE=ARIAL>' || TRIM(BATCH_NBR)|| '</FONT></a>';
				%END;
				%ELSE %DO;
					BATCH=TRIM(BATCH_NBR); 
				%END;
					OUTPUT;
					PUT &BATCHNUM Meth_Spec_Nm Meth_Peak_Nm Stage Indvl2;
				END;
				
				drop create_date2;
			RUN;
			PROC SORT DATA=BATCHSUM; BY PRODUCT TEST STAGE PEAK BATCH; RUN;
			DATA BATCHSUM;LENGTH SAMP_TST_DT2 $20.; MERGE BATCHSUM(IN=A) SPECTYPE MAXSPECS SUMDATA;
			BY PRODUCT TEST STAGE PEAK ;
			IF A;
				IF SAMP_TST_DT=. THEN SAMP_TST_DT2='N/A';
				 		 ELSE SAMP_TST_DT2=PUT(PUT(DATEPART(SAMP_TST_DT),mmddyy8.),$20.);
				CREATE_DATE2=PUT(PUT(DATEPART(MATL_MFG_DT),MMDDYY8.),$20.);
				%IF %SUPERQ(SPECCHKI)=YES OR %SUPERQ(SPECCHKM)=YES %THEN %DO;
					SPECLABEL=TRIM(SPECTXTLIST);
					IF SPECLABEL='' THEN SPECLABEL='N/A';
				%END;
				%ELSE %DO;
					SPECLABEL='N/A';
				%END;
		N2 = N;

		IF SPECLABEL='N/A' THEN DO; cpkM2='N/A';cpkIND2='N/A'; END;

		IF CPKIND=.  THEN CPKIND2='N/A';
		IF IndCheck=1  AND (STD='Insuff. Data' OR STD=0) THEN cpkInd2='Insuff. Data';

		IF PEAK NOT IN ('NONE','') 	AND STAGE NOT IN ('NONE','') 	THEN TEST2=TRIM(TEST)||'-'||TRIM(STAGE)||'-'||TRIM(PEAK);
		IF PEAK IN ('NONE','') 		AND STAGE NOT IN ('NONE','') 	THEN TEST2=TRIM(TEST)||'-'||TRIM(STAGE);
		IF PEAK NOT IN ('NONE','') 	AND STAGE IN ('NONE','') 	THEN TEST2=TRIM(TEST)||'-'||TRIM(PEAK);
		IF PEAK IN ('NONE','') 		AND STAGE IN ('NONE','') 	THEN TEST2=TRIM(TEST);

		BATCH_NBR2=TRIM(MATL_NBR)||'-'||TRIM(LEFT(BATCH_NBR)); /* Added V3*/

		IF ASSY_BATCH='' THEN ASSY_BATCH='Not Available';
		IF FILL_BATCH='' THEN FILL_BATCH='Not Available';
		IF BLEND_BATCH='' THEN BLEND_BATCH='Not Available';

		put 'lotcheck' assy_batch fill_batch blend_batch;

		IF PROD_GRP = 'MDPI' THEN DO;
		IF BATCH_NBR2=BLEND_BATCH THEN DO;
			CALL SYMPUT('LOTTXT1', "'Summary Statistics for Blend Batch Number: ' batch_nbr $15. 'Date of Manufacture: ' create_date2 $8.");
			CALL SYMPUT('LOTTXT2', "'Blend Batch Description: ' MATL_DESC $195.");
			CALL SYMPUT('LOTTXT3', "'Related Batches:  Fill Batch Number: '   FILL_BATCH $30. @75 'Assembled Batch Number: '   ASSY_BATCH $30."); 
			END;
		IF BATCH_NBR2=FILL_BATCH THEN DO;
			CALL SYMPUT('LOTTXT1', "'Summary Statistics for Fill Batch Number: ' batch_nbr $15. 'Date of Manufacture: ' create_date2 $8. ");
			CALL SYMPUT('LOTTXT2', "'FILL Batch Description: ' MATL_DESC $195.");			
			CALL SYMPUT('LOTTXT3', "'Related Batches:  Blend Batch Number: '   BLEND_BATCH $30. @75 'Assembled Batch Number: '   ASSY_BATCH $30."); 
			END;
		IF BATCH_NBR2=ASSY_BATCH THEN DO;
			CALL SYMPUT('LOTTXT1', "'Summary Statistics for Assembled Batch Number: ' batch_nbr $15. 'Date of Manufacture: ' create_date2 $8.");
			CALL SYMPUT('LOTTXT2', "'Batch Description: ' MATL_DESC $195.");		
			CALL SYMPUT('LOTTXT3', "'Related Batches:  Blend Batch Number: '   BLEND_BATCH $30. @75 'Fill Batch Number: '   FILL_BATCH $30."); 
			END;
			END;
		ELSE DO;
		/*	IF BATCH_NBR2=FILL_BATCH THEN DO; */
				CALL SYMPUT('LOTTXT1', "'Summary Statistics for Batch Number: ' batch_nbr $15. 'Date of Manufacture: ' create_date2 $8.");
				CALL SYMPUT('LOTTXT2', "'Batch Description: ' MATL_DESC $195.");
				CALL SYMPUT('LOTTXT3', "'Related Batches:  Packaging Batch Number: '   ASSY_BATCH $30. @75 "); 
			/*	END; */
		/*IF BATCH_NBR2=FILL_BATCH THEN DO;
				CALL SYMPUT('LOTTXT1', "'Summary Statistics for Packaging Batch Number: ' batch_nbr $15. 'Date of Manufacture: ' create_date2 $8. ");
				CALL SYMPUT('LOTTXT2', "'Batch Description: ' MATL_DESC $195.");			
				CALL SYMPUT('LOTTXT3', "'Related Batches:  Bulk Batch Number: '   BLEND_BATCH $30. @75 "); 
				END; */
				END;
				CALL SYMPUT('SPECLABEL', TRIM(SPECLABEL));
			RUN;
	%END;
	%ELSE %DO;
			%LET NoPrint2=;  %LET NoPrint1=NOPRINT;
	%END;

	DATA _NULL_;SET BATCHSUM;
		CALL SYMPUT('NORECORDS',_n_);
	RUN;
%PUT _NULL_;
	/*** Setup report style characteristics                   ***/
	%LET stylereport= STYLE(column) = {background = white} STYLE(LINES)=[FONT_SIZE=2 BACKGROUND=WHITE FOREGROUND=BLACK] STYLE(report) = [background=white outputwidth=100%] ;
	/*** Setup macro variable for style of table headers      ***/
	%LET styleheader=STYLE(header)=[FONT_SIZE=2 background=#C0C0C0 foreground=black];


	%IF %SUPERQ(BATCH)= AND %SUPERQ(TESTA)=ALL AND %SUPERQ(VALUE)=INDIVIDUAL %THEN %DO;
/***
		PROC SORT DATA=BATCHSUM;BY TEST PEAK STAGE &SORTVALUE ;
		WHERE Stage IN ('NONE','Stage: 1-5','Stage: 3-4','Stage: 6-F','Stage: TP0','Totals','Total Degradants',
			'GR103595X-Salmeterol','GR97980X-Salmeterol','Any Unspec. Degradant-Fluticasone','Any Unspec. Degradant-Salmeterol');
		RUN;
    		%DO i = 1 %TO &numstageA;   
			DATA Temp&I;SET BATCHSUM;
			IF STAGE="&&stageA&i";
		%END;
			DATA BATCHSUM;
			SET
		    		%DO i = 1 %TO &numstageA;   
				Temp&I
				%END;
			;
			RUN;
****/
		PROC SORT DATA=BATCHSUM;BY TEST PEAK STAGE &SORTVALUE ;RUN;

		data _null_; set batchsum;
		put mean2 range2;
		run;

		/*** Generate report for all tests and all batches        ***/
		PROC REPORT DATA=BATCHSUM NOWD BOX NOCENTER SPLIT='*' &STYLEREPORT;
		BY TEST peak stage;
   		  COLUMN BATCH_NBR create_date2 samp_tst_dt2 n2 indvl2 mean2 STD2 RSD2 RANGE2 CPKIND2;
   		  DEFINE BATCH_NBR    / "Batch"                                group order=data center width=40 &STYLEheader;
		  DEFINE create_date2 / "Manufacture*Date"                     group order=data center width=40 &STYLEheader;
		  DEFINE samp_tst_dt2 / "Test*Date"                            group order=data center width=40 &STYLEheader;
   		  DEFINE N2           / "Sample*Size"                                             center width=8  &STYLEheader;
	          DEFINE indvl2       / "Individuals"                                             center width=10 &STYLEheader;
   		  DEFINE mean2        / "Mean"                                            noprint center width=40 &STYLEheader;
		  DEFINE RSD2         / "RSD, %"                                          noprint center width=10 &STYLEheader;
		  DEFINE STD2         / "Standard*Deviation"                              noprint center width=10 &STYLEheader;
   		  DEFINE RANGE2       / "Minimum*and*Maximum"                             noprint center width=35 &STYLEheader;
   		  DEFINE cpkIND2      / "Ppk on*Batch*Individuals"   noprint center width=15 &STYLEheader;   /* Modified V4  */

   		  COMPUTE AFTER;
   			line 'Specification: ' "&SPECLABEL" ;
   		  ENDCOMP;
		RUN;
	%END;
	%ELSE %IF %SUPERQ(BATCH)= AND %SUPERQ(TESTA)=ALL %THEN %DO;
		PROC SORT DATA=BATCHSUM;BY TEST PEAK STAGE BATCH &SORTVALUE ;RUN;
		/*** Generate report for all tests and all batches        ***/
		PROC REPORT DATA=BATCHSUM NOWD BOX NOCENTER SPLIT='*' &STYLEREPORT;
		BY TEST PEAK STAGE;
   		  COLUMN BATCH create_date2 samp_tst_dt2 n2 mean2 STD2 RSD2 RANGE2 CPKIND2 SPECLABEL;
   		  DEFINE BATCH        / "Batch"                                group order=data center width=40 &STYLEheader;
		  DEFINE create_date2 / "Manufacture*Date"                     group order=data center width=40 &STYLEheader;
		  DEFINE samp_tst_dt2 / "Test*Date"                            group order=data center width=40 &STYLEheader;
   		  DEFINE N2           / "Sample*Size"                                           center width=8  &STYLEheader;
   		  DEFINE mean2        / "Mean"                                                  center width=10 &STYLEheader;
		  DEFINE RSD2         / "RSD, %"                                                center width=10 &STYLEheader;
		  DEFINE STD2         / "Standard*Deviation"                                    center width=10 &STYLEheader;
   		  DEFINE RANGE2       / "Minimum*and*Maximum"                                   center width=15 &STYLEheader;
   		  DEFINE cpkIND2      / "Ppk on*Batch*Individuals"         center width=15 &STYLEheader;   /* Modified V4  */
   		  DEFINE SPECLABEL    / "Specification"                                 noprint center width=15 &STYLEheader;

  		  COMPUTE AFTER _PAGE_ / CENTER;
			line 'Specification: ' SPECLABEL $100.;
   		  ENDCOMP;
		RUN;
	%END;
	%ELSE %IF %SUPERQ(BATCH)= AND %SUPERQ(TESTA)^=ALL AND %SUPERQ(VALUE)=INDIVIDUAL %THEN %DO;
		PROC SORT DATA=BATCHSUM;BY &SORTVALUE ;RUN;
		/*** Generate report for all batches                      ***/
		PROC REPORT DATA=BATCHSUM NOWD BOX NOCENTER SPLIT='*' &STYLEREPORT;
   		  COLUMN BATCH create_date2 samp_tst_dt2 n2 indvl2 mean2 STD2 RSD2 RANGE2 CPKIND2;
   		  DEFINE BATCH        / "Batch"                                group order=data center width=40 &STYLEheader;
		  DEFINE create_date2 / "Manufacture*Date"                     group order=data center width=40 &STYLEheader;
		  DEFINE samp_tst_dt2 / "Test*Date"                            group order=data center width=40 &STYLEheader;
   		  DEFINE N2           / "Sample*Size"                                             center width=8  &STYLEheader;
	          DEFINE indvl2       / "Individuals"                                             center width=10 &STYLEheader;
   		  DEFINE mean2        / "Mean"                                            noprint center width=10 &STYLEheader;
		  DEFINE RSD2         / "RSD, %"                                          noprint center width=10 &STYLEheader;
		  DEFINE STD2         / "Standard*Deviation"                              noprint center width=10 &STYLEheader;
   		  DEFINE RANGE2       / "Minimum*and*Maximum"                             noprint center width=15 &STYLEheader;
   		  DEFINE cpkIND2      / "Ppk on*Batch*Individuals"   noprint center width=15 &STYLEheader;  /* Modified V4  */

   		  COMPUTE AFTER;
   			line 'Specification: ' "&SPECLABEL" ;
   		  ENDCOMP;
		RUN;
	%END;
	%ELSE %IF %SUPERQ(BATCH)= AND %SUPERQ(TESTA)^=ALL %THEN %DO;
		PROC SORT DATA=BATCHSUM;BY &SORTVALUE ;RUN;

		/*** Generate report for all batches                      ***/
		PROC REPORT DATA=BATCHSUM NOWD BOX NOCENTER SPLIT='*' &STYLEREPORT;
   		  COLUMN BATCH create_date2 samp_tst_dt2 n2 mean2 STD2 RSD2 RANGE2 CPKIND2;
   		  DEFINE BATCH        / "Batch"                                group order=data center width=40 &STYLEheader;
		  DEFINE create_date2 / "Manufacture*Date"                     group order=data center width=40 &STYLEheader;
		  DEFINE samp_tst_dt2 / "Test*Date"                            group order=data center width=40 &STYLEheader;
   		  DEFINE N2           / "Sample*Size"                                           center width=8  &STYLEheader;
   		  DEFINE mean2        / "Mean"                                                  center width=10 &STYLEheader;
		  DEFINE RSD2         / "RSD, %"                                                center width=10 &STYLEheader;
		  DEFINE STD2         / "Standard*Deviation"                                    center width=10 &STYLEheader;
   		  DEFINE RANGE2       / "Minimum*and*Maximum"                                   center width=15 &STYLEheader;
   		  DEFINE cpkIND2      / "Ppk on*Batch*Individuals"         center width=15 &STYLEheader;   /* Modified V4  */

   		  COMPUTE AFTER;
   			line 'Specification: ' "&SPECLABEL" ;
   		  ENDCOMP;
		RUN;
	%END;
	%ELSE %DO;
		/*** Generate report for one batch                        ***/
		PROC REPORT DATA=BATCHSUM NOWD BOX NOCENTER SPLIT='*' &STYLEREPORT;
   		COLUMN BLEND_BATCH FILL_BATCH ASSY_BATCH MATL_DESC BATCH_NBR CREATE_DATE2 TEST2 SPECLABEL samp_tst_dt2 n2 indvl2 mean2 STD2 RSD2 RANGE2 CPKIND2;
   		DEFINE TEST2         /"Test*Method"                           group  order=data LEFT   width=40 &STYLEheader;
		DEFINE samp_tst_dt2  /"Test*Date"                             group  order=data center width=40 &STYLEheader;
		DEFINE speclabel     /"Specification"                         group  order=data LEFT   width=75 &STYLEheader;
   		DEFINE N2            /"Sample*Size"                                             center width=8  &STYLEheader;
   		DEFINE indvl2        /"Individuals"                                   &noprint1 center width=10 &STYLEheader;
   		DEFINE mean2         /"Mean"                                          &noprint2 center width=10 &STYLEheader;
		DEFINE RSD2          /"RSD, %"                                        &noprint2 center width=10 &STYLEheader;
		DEFINE STD2          /"Standard*Deviation"                            &noprint2 center width=10 &STYLEheader;
   		DEFINE RANGE2        /"Minimum*and*Maximum"                           &noprint2 center width=15 &STYLEheader;
   		DEFINE cpkIND2       /"Ppk on*Batch*Individuals" &noprint2 center width=15 &STYLEheader; /* Modified V4  */
		DEFINE BATCH_NBR       /   NOPRINT;
		DEFINE CREATE_DATE2  /   NOPRINT;
		DEFINE BLEND_BATCH     /   NOPRINT;
		DEFINE FILL_BATCH      /   NOPRINT;
		DEFINE ASSY_BATCH /   NOPRINT;
		DEFINE MATL_DESC/ NOPRINT;
		COMPUTE BEFORE _PAGE_  / LEFT;
      			LINE @5 ' '  &LOTTXT1;
			LINE @5 " ";
			LINE @5 ' '  &LOTTXT2;
			LINE ' ';	
			LINE @5 ' '  &LOTTXT3;
			LINE ' ';	
   		ENDCOMP;
		RUN;
	%END;

	%IF %SUPERQ(NORECORDS)=0 %THEN %DO;
	     DATA _NULL_;FILE _WEBOUT;
		PUT '</BR></BR></BR></BR></BR></BR></BR></BR></BR></BR></BR>';
		PUT '<P ALIGN=CENTER><STRONG><FONT FACE=ARIAL COLOR=RED>** NOTE: No data for requested selection criteria **</FONT></STRONG></BR></BR></BR>';
	     RUN;
	%END;
	%IF %SUPERQ(DATECHECK)=STOP %THEN %DO;
		DATA _NULL_; FILE _WEBOUT;
			PUT "</BR><P ALIGN=CENTER><STRONG><FONT FACE=ARIAL COLOR=RED>You entered invalid date ranges.  Default date ranges were used.</FONT></STRONG></BR>";
		RUN;
	%END;

	/*** If output is sent to the screen, setup HTML          ***/
	DATA _NULL_; FILE _WEBOUT;
  		print="&print";
  		IF print ^='ON' THEN DO;
  			PUT '</TR></TD></TABLE>';
		END;
  	RUN;
%MEND BATCHSTATS;

*****************************************************************************************************;
*                                      MODULE HEADER                                                *;
*---------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                      *; 
* 	     REQUIREMENT: See LINKS Report SOP                                                      *;
*       INPUT DATASET   : ALLDATA_WITH_STATS, STABILITY3, PLOTSETUP,                                *;
*				save.LRQUERYRES_PARAMETERS. MACRO VARIABLES: TESTBCHK,              *;
*				STAGEBCHK, PEAKBCHK, VALUE, HAXISCHK, INVALIDHAXIS, TESTB,          *; 
*				TIME, RHTEMPFLG, IMPFLAG, TESTACHK, STAGEACHK, PEAKACHK,            *; 
*				USERHLOWAXIS, USERHUPAXIS, USERHAXISBY, CORRTYPE,                   *;
*				NUMSTAGEA, NUMPEAKA, NUMSTAGEB, NUMPEAKB, PRINT, WARNING,           *;
*				GROUPVAR.                                                           *; 
*       PROCESSING: Setup specifications and reference lines for test B. If test B is a             *;
*		    parameter or TestDate, merge parameter dataset with test A data.  Select        *;
*		    only data for specified time point.  If the user choses a correlation plot,     *;
*		    generate plot of user specified value (mean or individual) where test A is      *;
*		    on the Y axis and test B is on the X axis.  Stratify plot points by user        *; 
*		    selected group variable (i.e. study).  If the user choses a correlation table,  *;
*		    generate an overall correlation table of test A vs test B, as well as           *;
*		    individual correlation table for each level of the grouping variable.           *;
*		    Include summary statistics: N, mean, standard deviation, min and max as well    *;
*		    as the correlation statistic with a corresponding p-value.                      *; 
*       OUTPUT:     Either 1 correlation plot to web browser or RTF file, or 2 or more              *;
*		    correlation tables to web browser or RTF file.                                  *;
*****************************************************************************************************;
%MACRO CORR;
	%GLOBAL  HAXISCORR HLOWAXIS HUPAXIS HAXISBY SPECLISTB;

	/**********/
	 %WARNINGS;
	/**********/

	/*** Setup flag for impurity test method                  ***/
	DATA _NULL_;
		TESTBCHK2="&TESTBCHK";	
		IF UPCASE(COMPRESS(testBchk2)) IN ('HPLCRELATEDIMP.INADVAIRMDPI') THEN CALL SYMPUT('IMPFLAGB','YES');  
		ELSE CALL SYMPUT('IMPFLAGB',' ');
	RUN;

	%IF %SUPERQ(RHTEMPFLG)= AND %SUPERQ(TESTB)^=TESTDATE2 %THEN %DO;

            /*** Create list of specs for testB. Setup reference lines ***/
	    %IF %SUPERQ(SPECCHKB)=YES %THEN %DO;
		DATA test2only; SET SPECS2;  
			%IF %SUPERQ(IMPFLAGB)=YES %THEN %DO;
				WHERE test="&testBchk" AND COMPRESS(stage,'- ')=COMPRESS("&stagebchk",'- ');
			%END;
			%ELSE %DO;
				WHERE test="&testBchk" AND COMPRESS(stage,'- ')=COMPRESS("&stagebchk",'- ') AND COMPRESS(peak)="&peakbchk";
			%END;
		RUN;

		PROC SORT DATA=test2only NODUPKEY OUT=PRODSPECS0; BY PRODUCT SPEC_TYPE ; RUN;

		DATA PRODSPECLIST; LENGTH SPECLISTm speclisti $1000 LOWERIC UPPERIC LOWERMC UPPERMC $15; SET PRODSPECS0 NOBS=NUMSPECS; BY PRODUCT SPEC_TYPE ;
  			RETAIN  OBS OBSALL 0 speclistM SPECLISTI;
			IF FIRST.SPEC_TYPE THEN OBS=1;
			ELSE OBS=OBS+1;
			OBSALL=OBSALL+1;
			IF LOWERI=. OR LOWERI=0 THEN LOWERIC=''; ELSE LOWERIC=LOWERI;
			IF UPPERI=. THEN UPPERIC=''; ELSE UPPERIC=UPPERI;
			IF LOWERM=. OR LOWERM=0 THEN LOWERMC=''; ELSE LOWERMC=LOWERM;
			IF UPPERM=. THEN UPPERMC=''; ELSE UPPERMC=UPPERM;
	
			IF OBS=1 AND UPCASE(SPEC_TYPE)='MEAN' THEN SPECLISTM=TRIM(LOWERMC)||' '||TRIM(UPPERMC);
			ELSE IF UPCASE(SPEC_TYPE)='MEAN' AND OBS > 1 THEN SPECLISTM=TRIM(SPECLISTM)||' '||TRIM(LOWERMC)||' '||TRIM(UPPERMC);
			
			IF OBS=1 AND UPCASE(SPEC_TYPE)='INDIVIDUAL' THEN SPECLISTI=TRIM(LOWERIC)||' '||TRIM(UPPERIC);
			ELSE IF UPCASE(SPEC_TYPE)='INDIVIDUAL' AND OBS > 1 THEN SPECLISTI=TRIM(SPECLISTI)||' '||TRIM(LOWERIC)||' '||TRIM(UPPERIC);
			
			IF OBSALL=NUMSPECS THEN OUTPUT;
  		RUN;

		/*** Create SpecListB macro variable                      ***/
		DATA _NULL_; SET PRODSPECLIST; 
			value=UPCASE("&value"); 
	    		IF VALUE='MEAN' THEN CALL SYMPUT("SpecListB", TRIM(SPECLISTM));
			ELSE CALL SYMPUT("SpecListB", TRIM(SPECLISTI));
			PUT SPECLISTI SPECLISTM;
  		RUN;

		%LET SPECLABELB=N/A;
			
		PROC SORT DATA=SPECS2 NODUPKEY OUT=SPECTYPE; BY SPEC_TYPE TXT_LIMIT_A TXT_LIMIT_B TXT_LIMIT_C;
		RUN;
		
		DATA SPECTYPE; LENGTH SPEC $750; SET SPECTYPE; BY SPEC_TYPE;
			value="&VALUE";
			RETAIN SPEC;
			WHERE UPCASE(SPEC_TYPE)=UPCASE(SYMGET('VALUE'));
			IF FIRST.SPEC_TYPE THEN SPEC=TXT_LIMIT_A||TXT_LIMIT_B||TXT_LIMIT_C;
			ELSE SPEC=TRIM(SPEC)||'; '||TXT_LIMIT_A||TXT_LIMIT_B||TXT_LIMIT_C;

			IF LAST.SPEC_TYPE THEN 
			CALL SYMPUT('SPECBLABEL',TRIM(SPEC));                /***  Create specification label            ***/
			CALL SYMPUT('SPECBCHK2','YES');                      /***  Create flag for test B specification  ***/
		RUN;
  		
		/*** Setup Reference Lines                                ***/
		DATA _NULL_; SET SPECTYPE;
			VALUE=UPCASE("&VALUE");
  			speclist="&speclistB";
			IF speclist^='' THEN CALL SYMPUT("Href","Href = &speclistB"); 
		RUN;
	    %END;
				
		DATA _NULL_; LENGTH HLOWAXISCHKC HUPAXISCHKC HAXISBYCHKC $25 HLOWAXISCHK HUPAXISCHK HAXISBYCHK 3;  
			/***  Setup horizontal Axis Range                 ***/
			SET plotsetup; 
			%IF %SUPERQ(IMPFLAGB)=YES %THEN %DO;
				WHERE test="&testb" AND COMPRESS(stage2,'- ')=COMPRESS("&stagebchk",'- ');
			%END;
			%ELSE %DO;
				WHERE test="&testB" AND COMPRESS(stage,'- ')=COMPRESS("&stagebchk",'- ') AND peak="&peakB";
			%END;

			HAXISCHK="&HAXISCHK";
			INVALIDAXIS="&INVALIDHAXIS";
			IF INVALIDAXIS='YES' OR (HAXISCHK^='USER')  THEN CALL SYMPUT("Hlowaxis",put(lowaxis,7.3));  ELSE CALL SYMPUT("HLOWAXIS","&USERHLOWAXIS");	  
			IF INVALIDAXIS='YES' OR (HAXISCHK^='USER')  THEN CALL SYMPUT("Hupaxis", put(upaxis,7.3));   ELSE CALL SYMPUT("HUPAXIS","&USERHUPAXIS");		  
  			IF INVALIDAXIS='YES' OR (HAXISCHK^='USER')  THEN CALL SYMPUT("Haxisby", put((upaxis-lowaxis)/5,7.4)); ELSE CALL SYMPUT("HAXISBY","&USERHAXISBY");	
		RUN;

		/*** Setup horizontal axis statement                      ***/
	    	DATA _NULL_; LENGTH HLOWAXISCHK HUPAXISCHK HAXISBYCHK 3;  
			HLOWAXISCHK="&HLOWAXIS"; HUPAXISCHK="&HUPAXIS"; HAXISBYCHK="&HAXISBY";
			IF HLOWAXISCHK^=HUPAXISCHK AND HAXISBYCHK>0 THEN 
			CALL SYMPUT("HAXISCORR","ORDER= (&hlowaxis TO &hupaxis BY &haxisby)");
			ELSE CALL SYMPUT('HAXISCORR',' ');
		RUN;

	%END;
	%ELSE %DO;
		/*** Setup data for RH, CINUM, Temperature and Testdate   ***/
		DATA _NULL_;
			TESTB="&TESTB";                                               /***  Reformat testB name          ***/
			IF TESTB = 'RH' 		THEN CALL SYMPUT('TESTB2','% Relative Humidity');
			IF TESTB = 'CINUM' 		THEN CALL SYMPUT('TESTB2','Cascade Impactor #');
			IF TESTB = 'TEMPERATURE' 	THEN CALL SYMPUT('TESTB2','Temperature');
			IF TESTB = 'TESTDATE2' 		THEN CALL SYMPUT('TESTB2','TESTDATE2');
		RUN;

		PROC SORT DATA=BATCHES2; 			BY SAMP_ID INDVL_TST_RSLT_DEVICE; RUN;
		PROC SORT DATA=SAVE.LRQUERYRES_PARAMETERS; 	BY SAMP_ID INDVL_TST_RSLT_DEVICE; RUN;

		/*** Merge parameter data with individual results         ***/
		DATA PARMDATA0; MERGE BATCHES2(IN=A) SAVE.LRQUERYRES_PARAMETERS; BY SAMP_ID INDVL_TST_RSLT_DEVICE; IF A;
		RUN;

		/*** Subset data for requested test parameter             ***/
		DATA PARMDATA; SET PARMDATA0;  
			%IF %SUPERQ(TESTB)^=TESTDATE2 %THEN %DO;
				WHERE UPCASE(TST_PARM_NM)=UPCASE("&TESTB2");
			%END;
			TESTBCHK="&TESTB";
			IF TESTBCHK IN ('RH','TEMPERATURE') THEN TESTB=TST_PARM_VAL_NUM;
			IF TESTBCHK IN ('CINUM') THEN TESTB=TST_PARM_VAL_CHAR;
			IF TESTBCHK IN ('TESTDATE2') THEN TESTB=TESTDATE2;
		RUN;

		PROC SORT DATA=PARMDATA; BY PRODUCT TEST STAGE PEAK BATCHLIST; RUN;
		/*** Calculate means by time point for each study         ***/
		PROC SUMMARY DATA=PARMDATA;
			VAR TESTB;
			BY PRODUCT TEST STAGE PEAK BATCHLIST;
			OUTPUT OUT=PARMDATESUM MEAN=MEAN;
		RUN;

		DATA PARMDATESUM1; SET PARMDATESUM;
	  		TESTB=mean;
	  		DROP mean;
		RUN; 
		
		PROC SORT DATA=MEANS;        BY PRODUCT BATCHLIST; RUN;
		PROC SORT DATA=PARMDATESUM1; BY PRODUCT BATCHLIST; RUN;
		/*** Merge Test A Means dataset from SETUP macro with Test B means ***/
		DATA means; MERGE means(in=a) PARMDATESUM1(IN=B); BY product BATCHLIST; RUN; 
		
	%END;

	/*** Setup titles, dataset variables                      ***/
%local dataset2 vartype grptitle;	
		%IF %SUPERQ(VALUE)=INDIVIDUAL %THEN %DO;
	           	%LET Grptitle=%STR(Correlation of Individual Results);
			%IF %SUPERQ(RHTEMPFLG)= AND %SUPERQ(TESTB)^=TESTDATE2 %THEN %DO;
				%LET DATASET2=BATCHES2; 
			%END;
			%ELSE %DO;
		   		%LET dataset2=PARMDATA; 
			%END;
			%LET vartype=result;
		%END;
		%IF %SUPERQ(VALUE)=MEAN OR %SUPERQ(VALUE)= %THEN %DO;
			%LET Grptitle=%STR(Correlation of Batch Means);
			%LET dataset2=means;
			%LET vartype=mean;
		%END;

	%IF %SUPERQ(RHTEMPFLG)= AND %SUPERQ(TESTB)^=TESTDATE2 %THEN %DO;

		/*** Divide appropriate dataset into TestA and TestB datasets ***/
		DATA testA testB; SET &dataset2;  
			%IF %SUPERQ(IMPFLAG)= %THEN %DO;
   				IF TRIM(test) IN ("&testAchk") and COMPRESS(stage2,'- ') = COMPRESS("&stageachk",'- ') and COMPRESS(peak) = COMPRESS("&peakachk") THEN OUTPUT testA;
			%END;
			%ELSE %DO;
				IF TRIM(test) IN ("&testAchk") and COMPRESS(stage2,'- ') = COMPRESS("&stageachk",'- ') THEN OUTPUT testA;
			%END;
			%IF %SUPERQ(IMPFLAGB)= %THEN %DO;
   				IF TRIM(test) IN ("&testBchk") and COMPRESS(stage2,'- ') = COMPRESS("&stagebchk",'- ') and COMPRESS(peak) = COMPRESS("&peakbchk") THEN OUTPUT testB;
			%END;
			%ELSE %DO;
				IF TRIM(test) IN ("&testBchk") and COMPRESS(stage2,'- ') = COMPRESS("&stagebchk",'- ') THEN OUTPUT testB;
			%END;
  		RUN;

		PROC SORT DATA=TESTA; BY PRODUCT BATCHLIST; RUN;
		PROC SORT DATA=TESTB; BY PRODUCT BATCHLIST; RUN;

		/*** Create testA variable                                ***/
  		DATA testA; SET testA;BY PRODUCT BATCHLIST; 
    		testA=&vartype;  
			DROP &vartype;
		if first.batchlist then counter+1;
  		RUN;

		/*** Create testB variable                                ***/
  		DATA testB; SET testB;BY PRODUCT BATCHLIST; 
    		testB=&vartype; 
			DROP &vartype;
		if first.batchlist then counter+1;
  		RUN;

		PROC SORT DATA=TESTA; BY PRODUCT BATCHLIST counter; RUN;
		PROC SORT DATA=TESTB; BY PRODUCT BATCHLIST counter; RUN;

		DATA bothtests; MERGE testA(IN=A) testB(IN=B);  
    		BY product BATCHLIST counter;
			*IF TESTA=. OR TESTB=. THEN DELETE;
			*IF TESTA > &LOWAXIS AND TESTA < &UPAXIS AND TESTB > &HLOWAXIS AND TESTB < &HUPAXIS THEN CALL SYMPUT('WARNING','');
  		RUN;
	%END;
	%ELSE %DO;
		/*** Keep only test A and parameter/date information      ***/
		DATA BOTHTESTS0; SET &dataset2;
   			%IF %SUPERQ(IMPFLAG)=YES %THEN %DO;
				WHERE TRIM(test)="&testAchk" AND COMPRESS(stage2,'- ')=COMPRESS("&stageachk",'- ');
			%END;
			%ELSE %DO;
				WHERE TRIM(test)="&testachk" AND COMPRESS(stage2,'- ')=COMPRESS("&stageachk",'- ') AND COMPRESS(peak)=COMPRESS("&peakachk");
			%END;
   		RUN;
   		
		/*** Setup date format                                    ***/
		%GLOBAL FORMAT;  
		%IF %SUPERQ(TESTB)=TESTDATE2 %THEN 	%LET FORMAT=format testb date9.;
		
		/*** Create test A variable                               ***/
  		DATA BOTHTESTS; SET BOTHTESTS0;
    		testA=&vartype; 
		
			DROP &vartype ;
			&FORMAT;
		RUN;

		/*** Calculate MIN and MAX values of Test B for axis statement  ***/
		PROC SUMMARY DATA=BOTHTESTS;  
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
			/*** Create horizontal axis statement ***/
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
				CALL SYMPUT('HAXISBY', PUT(AXISBY, 7.4));
			END;
			ELSE CALL SYMPUT('HAXISCORR','');
			
		RUN;
 
	%END;

	/*** Generate Correlation Plot                            ***/
	%IF %SUPERQ(corrtype)=PLOT %THEN %DO;
		%IF %SUPERQ(print)=ON %THEN %DO;%PRINT;%END;
		/*** Setup footnote macro variables               ***/
		%IF %SUPERQ(numstageA)>1 %THEN %DO;
			%IF %SUPERQ(numpeakA)>1 %THEN %LET footnote1= "   Test 1 = &TestA - &stageA - &peakA "; 
			                        %ELSE %LET footnote1= "   Test 1 = &TestA - &stageA "; 
		%END;
		%ELSE %DO;
			%IF %SUPERQ(numpeakA)>1 %THEN %LET footnote1= "   Test 1 = &TestA - &peakA "; 
			                        %ELSE %LET footnote1= "   Test 1 = &TestA "; 
		%END;

		%IF %SUPERQ(numstageB)>1 %THEN %DO;
			%IF %SUPERQ(numpeakB)>1 %THEN %LET footnote2= "   Test 2 = &TestB - &stageB - &peakB "; 
			                        %ELSE %LET footnote2= "   Test 2 = &TestB - &stageB "; 
		%END;
		%ELSE %DO;
			%IF %SUPERQ(numpeakB)>1 %THEN %LET footnote2= "   Test 2 = &TestB - &peakB ";
			                        %ELSE %LET footnote2= "   Test 2 = &TestB ";   
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
			
		/*** Create null horizontal reference line statement if no specifications exist ***/
		DATA _NULL_;  
			HREF=TRIM("&HREF");
			IF HREF='HREF=' THEN CALL SYMPUT('HREF',' ');
		RUN;

		/*** Setup plot options                                   ***/
		GOPTIONS reset=all;
		GOPTIONS device=&device display;
		GOPTIONS &xpixels ypixels=500  gsfmode=replace BORDER;

		/*** Create titles and footnotes                          ***/
		TITLE H=1 F=SWISSB "&TITLE_product &Grptitle - &STARTDATETITLE through &ENDDATETITLE";
 		
		/*** Print warning if applicable if data exists outside axis range ***/
		DATA _NULL_; FILE _WEBOUT;	
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
/**			FOOTNOTE1 F=ARIAL H=1.2 C=RED "WARNING: Not all data displayed.  Conclusions and interpretations may be incorrect.";***/
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

		/*** Generate plot                                        ***/
		PROC GPLOT DATA=bothtests;
			PLOT testA*TESTB&groupvar2/VAXIS=axis1 HAXIS=axis2 &href &vref ;
		RUN;
	%END;

        /*** Generate correlation tables                          ***/
	%ELSE %IF %SUPERQ(corrtype)=TABLE %THEN %DO; 
		%MACRO CorrStats;

			%IF %SUPERQ(byvar)^= %THEN %DO; PROC SORT DATA=bothtests; &byvar; RUN; %END;
			/*** Generate correlation statistics                      ***/

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

			/*** Calculate summary statistics for test A              ***/
			PROC SUMMARY DATA=bothtests;where testa^=.;
				VAR testa;
				&byvar;
				OUTPUT OUT=testasum n=n1 mean=mean1 std=std1 min=min1 max=max1;
			RUN;

			DATA testasum;  SET testasum;
   				temp="&groupvar2";
   				test="&TITLE_test &TITLE_PEAKA";                              /***  Setup test variable  ***/
			RUN;
	
			/*** Calculate summary statistics for test B              ***/
			PROC SUMMARY DATA=bothtests;where testb^=.;
				VAR testb;
				&byvar;
				OUTPUT OUT=testbsum n=n1 mean=mean1 std=std1 min=min1 max=max1;
				RUN;

				DATA testbsum; SET testbsum;
	      			temp="&groupvar2";                                            /*** Setup test variable   ***/
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

			/*** Combine testa and testb summary statistics           ***/
			DATA testsum; LENGTH test $100; SET testasum testbsum;  DROP _TYPE_ _freq_; RUN;

			PROC SORT DATA=testsum; BY &groupvar2; RUN;
			PROC SORT DATA=corr; BY  &groupvar2; RUN;

			/*** Setup formats and labels                             ***/
			%GLOBAL FORMAT LABEL; 
			%IF %SUPERQ(TESTB)=TESTDATE2 %THEN %DO;
				%LET FORMAT= DATE9.;
				%LET LABEL = LABEL TESTB='Test Date';
			%END;
			%ELSE %LET FORMAT=8.3;

			/*** Merge summary statistics with correlation statistics ***/
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

			/*** Setup title, footnotes and report characteristic variables ***/
  			TITLE h=2 "&TITLE";
			title2 h=1.5 "&TITLE_product - &STARTDATETITLE through &ENDDATETITLE";
  
			ODS noproctitle ;

			%LET stylereport=STYLE(column) = {background = white} STYLE(report) = [background=white outputwidth=90%]
			STYLE(lines)=[FONT_weight=bold FONT_SIZE=2] ;

			%LET styleheader=STYLE(header)=[FONT_SIZE=2 background=#C0C0C0 foreground=black];

			FOOTNOTE h=.95 FONT=ARIAL "Generated by the LINKS System on &today at &rpttime";
			FOOTNOTE2 F=ARIAL h=.95 "Data last updated: &Save_Last_Update_Date at &Save_Last_Update_Time";
  		  	
			/*** Generate table                                       ***/
			PROC REPORT DATA=allcorr SPLIT='*' &stylereport ; 
				COLUMNS &column test n1 meanc stdc minc maxc corr=corr2 prob=pcorr2; 
				&DEFINE;
				DEFINE test   / "Test"                       STYLE=[FONT_SIZE=2 cellwidth=350 ] &STYLEHeader;
				DEFINE n1     / "Sample*Size"         CENTER STYLE=[FONT_SIZE=2 cellwidth=100 ] &StyleHeader;
				DEFINE meanC  / "Mean"                CENTER STYLE=[FONT_SIZE=2 cellwidth=100 ] &STYLEheader;
				DEFINE stdC   / "Standard*Deviation"  CENTER STYLE=[FONT_SIZE=2 cellwidth=100 ] &STYLEheader;
				DEFINE minC   / "Minimum"             CENTER STYLE=[FONT_SIZE=2 cellwidth=100 ] &STYLEheader;
				DEFINE maxC   / "Maximum"             CENTER STYLE=[FONT_SIZE=2 cellwidth=100 ] &STYLEheader;
				DEFINE corr2  / analysis mean noprint;
				DEFINE pcorr2 / analysis mean noprint;
				COMPUTE AFTER &column;
				LINE "Correlation Statistic (r): &SIGN" corr2 6.3 "      P-Value:"  pcorr2 6.3; 
			ENDCOMP;
			RUN;

  		%MEND CorrStats;

  		%LET byvar=; 			                               /***  Generate Overall correlation table  ***/
  		%LET groupvar2=temp;
  		%LET column=;
  		%LET DEFINE=;
  		%LET TITLE = Overall &grptitle;
  		%corrstats;

		ods listing exclude ModelInfo Dimensions CovParms FitStatistics SolutionF Tests1;

		%IF %SUPERQ(GROUPVAR) ^= NONE %THEN %DO;
  			%LET byvar=BY &groupvar;  /*** Generate correlation table for each level of GroupVar classification variable ***/
  			%LET groupvar2=&groupvar;
  			%LET column=&groupvar;
  			%IF %SUPERQ(GROUPVAR) = BATCH_NBR %THEN %DO;
				%LET DEFINE=DEFINE &groupvar/"Batch Number"  GROUP STYLE=[FONT_SIZE=2 cellwidth=150 ] &STYLEheader;
   				%LET TITLE=&grptitle by Batch Number;
			%END;
  			%IF %SUPERQ(GROUPVAR) = ANALYST   %THEN %DO;
				%LET DEFINE=DEFINE &groupvar/"Analyst"  GROUP STYLE=[FONT_SIZE=2 cellwidth=150 ] &STYLEheader;
   				%LET TITLE=&grptitle by Analyst;
			%END;
  			%corrstats;
		%END;
	%END;

	%IF %SUPERQ(DATECHECK)=STOP %THEN %DO;
		DATA _NULL_; FILE _WEBOUT;
			PUT "</BR><P ALIGN=CENTER><STRONG><FONT FACE=ARIAL COLOR=RED>You entered invalid date ranges.  Default date ranges were used.</FONT></STRONG></BR>";
		RUN;
	%END;

%MEND CORR;

****************************************************************************************************;
*                                      MODULE HEADER                                               *;
*--------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                     *;
*	     REQUIREMENT: See LINKS Report SOP                                                     *; 
*       INPUT           : MACRO VARIABLES: STUDY0, XPIXELS, YPIXELS, RPTTIME, TODAY,               *;
*  		          INVALIDVAXIS, LOWAXIS, UPAXIS, AXISBY, VALUE.  DATASETS:                 *;
*  		          MEANSTAGES, CIDATA.                                                      *;
*       PROCESSING: If only one study, generate profile plot of cascade impaction individual data. *;
*  		    If more than one study, generate profile plot of cascade impaction mean data.  *; 
*                   Plot individual CI stages along the horizontal axis and results along vertical *;
*  		    axis.  Connect each stage with a solid line for each study.  		   *;	         
*       OUTPUT    : 1 plot to web browser or RTF file.                                             *;
****************************************************************************************************;
%MACRO CIPROFILES;
	
	%LET cidata=Meanstages;
	%LET VALUE=CIMean;
	%LET symbol1 = symbol1  c=black  v=dot i=std3tmj;

        /*** Setup plot options                                   ***/
	GOPTIONS reset=all;  
  	GOPTIONS device=&device display;
  	GOPTIONS &xpixels &ypixels  gsfmode=replace BORDER;

	/*** Setup titles                                         ***/
	TITLE H=1 F=SWISSB "&TITLE_product Cascade Impaction Profile &peakA Drug Substance";
  	TITLE2 H=1 F=SWISSB "&STARTDATETITLE through &ENDDATETITLE";

	%WARNINGS;

	%IF %SUPERQ(WARNING)^= OR %SUPERQ(CIWARNING)^= %THEN %DO;	
		FOOTNOTE1 F=ARIAL H=1.2 C=RED "WARNING: Not all data displayed.  Conclusions and interpretations may be incorrect.";
		FOOTNOTE2 H=.2 ' ';
		FOOTNOTE3 F=ARIAL j=l h=.95 "Generated by the LINKS System on &today at &rpttime" j=r "Data last updated: &Save_Last_Update_Date at &Save_Last_Update_Time";
  		FOOTNOTE4 H=.2 ' ';
	%END;
	%ELSE %DO;  /*** Setup footnotes. Plot warning if data exists outside user defined axis range ***/
		FOOTNOTE1 F=ARIAL j=l h=.95 "Generated by the LINKS System on &today at &rpttime" j=r "Data last updated: &Save_Last_Update_Date at &Save_Last_Update_Time";
  		FOOTNOTE2 H=.2 ' ';
	%END;

	%IF %SUPERQ(DATECHECK)=STOP %THEN %DO;
		DATA _NULL_; FILE _WEBOUT;
			PUT "</BR><P ALIGN=CENTER><STRONG><FONT FACE=ARIAL COLOR=RED>You entered invalid date ranges.  Default date ranges were used.</FONT></STRONG></BR>";
		RUN;
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
  
        /* v9 */
        %LOCAL AxisOrder;
        %IF %INDEX(%SUPERQ(PRODUCT),Advair Diskus) %THEN %DO;
	        %IF %SUPERQ(CIType)=NONPOOLED %THEN %DO;
	        	%LET AxisOrder='T' 'P' '0' '1' '2' '3' '4' '5' '6,7&F';
	        %END;
	        %ELSE %IF %SUPERQ(CIType)=POOLED %THEN %DO;
	        	%LET AxisOrder='TP0' '12' '34' '5' '6,7&F';
	        %END;
	        %ELSE %IF %SUPERQ(CIType)=FULL %THEN %DO;
	        	%LET AxisOrder='T' 'P' '0' '1' '2' '3' '4' '5' '6' '7' 'F';
	        %END;
        %END;
        %ELSE %IF %INDEX(%SUPERQ(PRODUCT),Relenza Rotadisk) %THEN %DO;
	        %IF %SUPERQ(CIType)=NONPOOLED %THEN %DO;
	        	%LET AxisOrder='TP0' 'TMP' 'PRESEP-0' '1' '2' '3' '4' '5';
	        %END;
	        %ELSE %IF %SUPERQ(CIType)=POOLED %THEN %DO;
	        	%LET AxisOrder='TP0' '1-3' '4-5' '1-5';
	        %END;
                %ELSE %IF %SUPERQ(CIType)=FULL %THEN %DO;
	        	%LET AxisOrder='TMP' 'PRESEP-0' '1' '2' '3' '4' '5';
	        %END;
        %END;
        /* TODO AdvHFA */
	AXIS1 OFFSET=(5,5) LABEL=(FONT=simplex 'Stage') ORDER=(&AxisOrder);

	AXIS2 LABEL=(A=90 FONT=simplex 'Mean Cascade Impaction')  ORDER=(&LOWAXIS TO &UPAXIS BY &AXISBY);

  	PROC GPLOT DATA=&cidata;
  		PLOT &VALUE*stage/HAXIS=axis1 VAXIS=AXIS2;
  	RUN;

%MEND CIPROFILES;

*****************************************************************************************************;
*                                      MODULE HEADER                                                *;
*---------------------------------------------------------------------------------------------------*;
*       DESIGN COMPONENT: See LINKS Report SOP                                                      *;
*	     REQUIREMENT: See LINKS Report SOP                                                      *;
*       DESIGN COMPONENT: See SDS REQUIREMENT: See FRS REQUIREMENT                                  *;
*       INPUT           : MACRO VARIABLES: PRODUCT, STORAGE, TESTA, STAGEA, PEAKA,                  *;
*		          TESTB, STAGEB, PEAKB, REPORTYPE, VALUE, ANALYST, TIME, OBSMAXPCT,         *;
*		          GROUPVAR, STUDY0, STUDY1,...,STUDY#, LOWAXIS, UPAXIS, AXISBY,             *;
*		          USERLOWAXIS, USERUPAXIS, USERAXISBY, HLOWAXIS, HUPAXIS, HAXISBY,          *;
*		          USERHLOWAXIS, USERHUPAXIS, USERHAXISBY, XPIXELS0, YPIXELS0, REG0, REG2.   *;
*       PROCESSING: Create html forms to edit plots.  For report type = SCATTER include text fields *; 
*		  for changing the horizontal and vertical axis, drop down boxes for changing the   *;
*		  plot size, and drop down boxes for changing regression line and confidence bounds.*;  
*		  For report type = CORR include text fields for changing the horizontal and        *;
*		  vertical axis and drop down boxes for changing the plot size,                     *;
*		  For report type = HISTIND include text fields for changing histogram midpoints,   *;
*		  changing vertical axis value, and drop down boxes for changing the plot size.     *;
*		  For report type=CIPROFILES and PRODRELEASE, include text fields for changing      *;
*		  vertical axis and drop down boxes for changing plot size.                         *;
*       OUTPUT:   1 of 5 different HTML forms depending on report type.                             *;
*****************************************************************************************************;
%MACRO Webout2;
	/************************************************************/
	/*** Setup HTML form for report editing menus             ***/
	/************************************************************/
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
  		LINE= '<INPUT TYPE="hidden" NAME=TIME  		VALUE="' ||TRIM("&time")     		||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=ObsMaxPct 	VALUE="' ||TRIM("&ObsMaxPct")		||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=GROUPVAR     	VALUE="' ||TRIM("&GROUPVAR")	    	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=CORRTYPE     	VALUE="' ||TRIM("&CORRTYPE")	    	||'">'; PUT LINE; 

		/*** Setup Plot edit fields for report type of CORR       ***/
		%IF (%SUPERQ(reportype) = CORR AND %SUPERQ(CORRTYPE)=PLOT) %THEN %DO;
		    	PUT '<TABLE BGCOLOR="#ffffdd" ALIGN=CENTER WIDTH="100%" >';
		    	PUT '<TR><TD COLSPAN=3 ALIGN=left BGCOLOR="#003366"><STRONG><FONT FACE="Arial" COLOR="#FFFFFF">Edit Plot</FONT></STRONG></TD></TR>';
		    	PUT '<TR ><TD  halign=right VALIGN=CENTER>';

			/*** Create text entry fields to change vertical axis values                                     ***/
			PUT '<SMALL><FONT FACE="Arial">Vertical Axis:</FONT></SMALL></TD>';
		    	LINE= '<TD VALIGN=CENTER HALIGN=LEFT><SMALL><FONT FACE="Arial" >Min: </SMALL><INPUT TYPE="text" NAME="USERlowaxis" VALUE="'||
				COMPRESS("&lowaxis")||'" SIZE="6">'; PUT LINE;
		    	LINE= '<SMALL>Max: </SMALL><INPUT TYPE="text" NAME="USERupaxis" VALUE="'||COMPRESS("&upaxis")||'" SIZE="6">'; PUT LINE;
		    	LINE= '<SMALL>By: </SMALL><INPUT TYPE="text" NAME="USERaxisby" VALUE="'||COMPRESS("&axisby")||'"  SIZE="6">'; PUT LINE;
		    	LINE= '</TD><TD><SMALL><FONT FACE=ARIAL>Pixel Size: </FONT></SMALL>'; PUT LINE;
			LINE= '<SELECT NAME="Ypixels0" SIZE=1>'; PUT LINE;

			/*** Create drop down boxes for changing vertical plot size (in pixels)                          ***/
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

			/*** Create text entry fields to change horizontal axis values                                   ***/
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

			/*** Create drop down boxes for changing horizontal plot size (in pixels) ***/
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
			RUN;

	/*********************************************************************/
	/*** Create submit button and form to reset to plot default values ***/
	/*********************************************************************/
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
  		LINE= '<INPUT TYPE="hidden" NAME=BATCH      VALUE="' ||TRIM("&BATCH")          ||'">'; PUT LINE; 

 		PUT '<INPUT TYPE="submit" VALUE="Reset to Default" NAME="B1">';
  		PUT '</FORM></TD></TR></TABLE>';
	%END;

	/************************************************************/
        /*** Setup fields to edit histograms                      ***/
	/************************************************************/
	%ELSE %IF %SUPERQ(reportype)=HISTIND %THEN %DO; 
  		PUT   '<TABLE ALIGN=CENTER WIDTH="100%" BORDER="0"  BGCOLOR="#ffffdd">';
		/*** Create fields for histogram midpoints, maximum percentage (display minimum possible percentage)     ***/
  		PUT   '<TR ><TD COLSPAN=3 BGCOLOR="#003366"><STRONG><SMALL><FONT COLOR="FFFFFF" FACE="Arial">Histogram Midpoints:</FONT></SMALL></STRONG></TD>'; 
  		PUT   '<TD  BGCOLOR="#003366"><STRONG><SMALL><FONT COLOR="FFFFFF"  FACE="Arial">Max Percent:</FONT></SMALL></STRONG></TD>';
		PUT   '<TD COLSPAN=2 BGCOLOR="#003366"><STRONG><SMALL><FONT COLOR="FFFFFF"  FACE="Arial">Size (In Pixels):</FONT></SMALL></STRONG></TD>';
  		LINE= '<TR ><TD VALIGN=CENTER halign=left ><SMALL><FONT FACE="Arial">Min: </FONT></SMALL><INPUT TYPE="text" NAME="userlowaxis" VALUE="'||put(&lowaxis,7.3)||'" SIZE="6"></TD>'; PUT LINE;
  		LINE= '<TD VALIGN=CENTER halign=left><SMALL><FONT FACE="Arial">Max: </FONT></SMALL><INPUT TYPE="text" NAME="userupaxis" VALUE="'||put(&upaxis,7.3)||'" SIZE="6"></TD>'; PUT LINE;
  		LINE= '<TD VALIGN=CENTER halign=left><SMALL><FONT FACE="Arial">By: </FONT></SMALL><INPUT TYPE="text" NAME="useraxisby" VALUE="'||put(&axisby,8.4)||'"  SIZE="6"></TD>'; PUT LINE;
  		LINE= '<TD VALIGN=CENTER halign=left><INPUT TYPE="text" NAME="maxpercent" VALUE="'||COMPRESS("&maxpercent")||'" SIZE="3"><FONT FACE=ARIAL SIZE=2> *Must be at least '||TRIM("&obsmaxpct")||'</FONT></TD>'; PUT LINE;
  		
  		LINE= '<TD VALIGN=CENTER halign=left><SMALL><FONT FACE=ARIAL>X: </FONT></SMALL>'; PUT LINE;
		LINE= '<SELECT NAME="xpixels0" SIZE=1>'; PUT LINE;
		/*** Create drop down boxes for plot size in pixels                                                      ***/

/***
		PUT   '<TD BGCOLOR="#FFFFDD" valign=top align=left>';
	  	PUT '<SELECT NAME="StartYEAR" SIZE="1" STYLE="FONT-SIZE: xx-SMALL" >';
		%DO I=&MINYEAR %TO &MAXYEAR;
			%IF %SUPERQ(startYEAR)=&I %THEN %LET SELYEAR=selected;  
                                                         %ELSE %LET SELYEAR= ;
  			LINE='<OPTION '||"&selYEAR"||' VALUE="'||"&I"||'">'||"&I"||'</OPTION>'; PUT LINE;
	       		LINE = '<OPTION '||"&SELECT"||' VALUE="700" SIZE="1">700</OPTION>'; PUT LINE;
		%END;
		PUT '</SELECT></TD></TR></TABLE></TD></TR>';
****/
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
		
		%IF %SUPERQ(YPIXELS0)=400  %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="400" SIZE="1">400</OPTION>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=500  %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="500" SIZE="1">500</OPTION>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=600  %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="600" SIZE="1">600</OPTION>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=700  %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="700" SIZE="1">700</OPTION>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=800  %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="800" SIZE="1">800</OPTION>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=900  %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="900" SIZE="1">900</OPTION>'; PUT LINE;
		%IF %SUPERQ(YPIXELS0)=1000 %THEN %LET SELECT=SELECTED; %ELSE %LET SELECT= ;
		LINE = '<OPTION '||"&SELECT"||' VALUE="1000" SIZE="1">1000</OPTION>'; PUT LINE;
 		LINE= '</SELECT> '; PUT LINE;
		PUT '</TD></TR>';
		LINE='</TD></TR></TABLE>'; PUT LINE;
		/*** Create submit button                                                                                ***/
		PUT '<TABLE WIDTH="100%" BGCOLOR="#FFFFDD"><TR ><TD COLSPAN=3 VALIGN=top ALIGN=right><INPUT TYPE="submit" VALUE="Update Histogram" NAME="B1"></TD>';
		/*** Create button to reset to default plot values                                                       ***/
		PUT '</FORM><TD COLSPAN=3 VALIGN=top ALIGN=left>';
		LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

		%THISSESSION;   		

		LINE= '<INPUT TYPE="hidden" NAME=product     VALUE="' ||TRIM("&product")       ||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=testA       VALUE="' ||TRIM("&testA")	       ||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=stageA      VALUE="' ||TRIM("&stageA")	       ||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=peakA       VALUE="' ||TRIM("&peakA")	       ||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=reportype   VALUE="' ||TRIM("&reportype")     ||'">'; PUT LINE; 
		LINE='<INPUT TYPE="hidden" NAME=TIME  	     VALUE="' ||TRIM("&time")          ||'">'; PUT LINE;

		PUT   '<INPUT TYPE="submit" VALUE="Reset to Default" NAME="B1">';
  		PUT   '</FORM></TD></TR></TABLE>';
	%END;
	
	/************************************************************/
        /*** Setup fields to edit CI Profiles                     ***/
	/************************************************************/
	%IF %SUPERQ(reportype)=CIPROFILES %THEN %DO;   
		/*** Setup vertical axis text fields                                                                     ***/
    		PUT '<TABLE BGCOLOR="#ffffdd" ALIGN=CENTER WIDTH="100%" >';
    		PUT '<TR><TD COLSPAN=2 ALIGN=left BGCOLOR="#003366"><STRONG><FONT FACE="Arial" COLOR="#FFFFFF">Edit Plot</FONT></STRONG></TD></TR>';
    		PUT '<TR ><TD WIDTH="20%" halign=right VALIGN=CENTER>';
	    	PUT '<SMALL><FONT FACE="Arial">Vertical Axis:</FONT></SMALL></TD>';
		
	    	LINE= '<TD VALIGN=CENTER><SMALL><FONT FACE="Arial" >Min: </SMALL><INPUT TYPE="text" NAME="USERlowaxis" VALUE="'||put(&lowaxis,7.3)||'" SIZE="6">'; PUT LINE;
	    	LINE= '<SMALL>Max: </SMALL><INPUT TYPE="text" NAME="USERupaxis" VALUE="'||put(&upaxis,7.3)||'" SIZE="6">'; PUT LINE;
	    	LINE= '<SMALL>By: </SMALL><INPUT TYPE="text" NAME="USERaxisby" VALUE="'||put(&axisby,8.4)||'"  SIZE="7">'; PUT LINE;
    	
		LINE= '</TD></TR>'; PUT LINE;

	     	/*** Setup drop down boxes to change plot size                                                           ***/
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

		/*** Create submit button and form to reset to default                                                   ***/
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

 		PUT '<INPUT TYPE="submit" VALUE="Reset to Default" NAME="B1">';
  		PUT '</FORM></TD></TR></TABLE>';
	%END;

	/************************************************************/
        /*** Setup fields to edit product release run charts      ***/
	/************************************************************/
	%IF %SUPERQ(TESTA)^=ALL %THEN %DO;
	%IF %SUPERQ(REPORTYPE) =XBAR OR %SUPERQ(REPORTYPE)=SBAR OR %SUPERQ(REPORTYPE)=INDRUN %THEN %DO;  
		PUT '<TABLE BGCOLOR="#ffffdd" ALIGN=CENTER WIDTH="100%" >';
	    	PUT '<TR><TD COLSPAN=4 ALIGN=left BGCOLOR="#003366"><STRONG><FONT FACE="Arial" COLOR="#FFFFFF">Edit Plot</FONT></STRONG></TD></TR>';
	    	PUT '<TR ><TD  halign=right VALIGN=CENTER>';
	    	PUT '<SMALL><FONT FACE="Arial">Vertical Axis:</FONT></SMALL></TD>';

		/*** Create text fields to change vertical axis values                                                   ***/
	    	LINE= '<TD VALIGN=CENTER HALIGN=LEFT><SMALL><FONT FACE="Arial" >Min: </SMALL><INPUT TYPE="text" NAME="USERlowaxis" VALUE="'||COMPRESS("&lowaxis")||'" SIZE="6">'; PUT LINE;
	    	LINE= '<SMALL>Max: </SMALL><INPUT TYPE="text" NAME="USERupaxis" VALUE="'||COMPRESS("&upaxis")||'" SIZE="6">'; PUT LINE;
	    	LINE= '<SMALL>By: </SMALL><INPUT TYPE="text" NAME="USERaxisby" VALUE="' ||COMPRESS("&axisby")||'"  SIZE="6">'; PUT LINE;
	    	LINE= '</TD><TD><SMALL><FONT FACE=ARIAL>X Pixel Size: </FONT></SMALL>'; PUT LINE;
		LINE= '<SELECT NAME="Xpixels0" SIZE=1>'; PUT LINE;

		/*** Create drop down boxes to change plot size                                                          ***/
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

		%IF %SUPERQ(REPORTYPE)^=INDRUN %THEN %DO;

		PUT '<TR><TD COLSPAN=6><table><tr><TD><FONT FACE="Arial" ><SMALL>Control Limits: </SMALL></FONT></td>';
		%IF %SUPERQ(CTLLIMITS)=NONE %THEN %LET CHECK=CHECKED; %ELSE %LET CHECK= ;
		LINE= '<td><input TYPE=radio NAME=CtlLimits '||"&CHECK"||' VALUE="NONE"><FONT FACE="Arial" ><SMALL>None</SMALL></FONT></TD>'; PUT LINE;
		%IF %SUPERQ(CTLLIMITS)=DEFAULT %THEN %LET CHECK=CHECKED; %ELSE %LET CHECK= ;
		LINE= '<td><input TYPE=radio NAME=CtlLimits '||"&CHECK"||' VALUE="DEFAULT"><FONT FACE="Arial" ><SMALL>Data Defined (3 Sigma)</SMALL></FONT></TD>'; PUT LINE;
		%IF %SUPERQ(CTLLIMITS)=USER %THEN %LET CHECK=CHECKED; %ELSE %LET CHECK= ;
		LINE= '<td><input TYPE=radio NAME=CtlLimits '||"&CHECK"||' VALUE="USER"><FONT FACE="Arial" ><SMALL>User Defined- </SMALL></FONT></TD>'; PUT LINE;
		LINE= '<TD><FONT FACE="Arial" ><SMALL>Lower: </SMALL></FONT><INPUT TYPE="text" NAME="USERLCL" VALUE="'||LEFT("&LCL")||'" SIZE="6"></TD>'; PUT LINE;
		LINE= '<TD><FONT FACE="Arial" ><SMALL>Upper: </SMALL></FONT><INPUT TYPE="text" NAME="USERUCL" VALUE="'||LEFT("&UCL")||'" SIZE="6"></TD>'; PUT LINE;
		/*** ONE BOX FOR EITHER XBAR OR SBAR ON EDIT SECTION                                                     ***/
			%IF %SUPERQ(REPORTYPE) =XBAR %THEN %DO;
				LINE= '<TD><FONT FACE="Arial" ><SMALL>XBar: </SMALL></FONT><INPUT TYPE="text" NAME="USERBAR" VALUE="'||
					LEFT("&BAR")||'" SIZE="6"></TD></tr></table></TD></TR>'; PUT LINE;
			%END;
			%IF %SUPERQ(REPORTYPE) =SBAR %THEN %DO;
				LINE= '<TD><FONT FACE="Arial" ><SMALL>SBar: </SMALL></FONT><INPUT TYPE="text" NAME="USERBAR" VALUE="'||
					LEFT("&BAR")||'" SIZE="6"></TD></tr></table></TD></TR>'; PUT LINE;
			%END;
		%END;
		/*** Create submit buttons and a form to reset plot to default                                           ***/
		PUT '<TABLE ALIGN=CENTER WIDTH="100%" BGCOLOR="#ffffdd"><TR><TD VALIGN=top ALIGN=right><INPUT TYPE="submit" VALUE="Update Plot" NAME="B1"></TD>';
  		PUT '</FORM><TD VALIGN=top ALIGN=left>';
		LINE= '<FORM METHOD="'||"&method"||'" ACTION="'||"&_url"||'">'; PUT LINE;

		%THISSESSION;

		LINE= '<INPUT TYPE="hidden" NAME=product    VALUE="' ||TRIM("&product")	       	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=testA      VALUE="' ||TRIM("&testA")	       	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=stageA     VALUE="' ||TRIM("&stageA")	       	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=peakA      VALUE="' ||TRIM("&peakA")	       	||'">'; PUT LINE; 
  		LINE= '<INPUT TYPE="hidden" NAME=reportype  VALUE="' ||TRIM("&reportype")	||'">'; PUT LINE; 
 		PUT '<INPUT TYPE="submit" VALUE="Reset to Default" NAME="B1">';
  		PUT '</FORM></TD></TR></TABLE>';
	%END;
	%END;	 	
		/*** Create HTML to make footer banner                                                                   ***/
		PUT '</TD></TR><TR  ALIGN="right" HEIGHT="8%"><TD COLSPAN=2 BGCOLOR="#003366">';
		line = '<A HREF="//'||SYMGET('_server')||'/links/'||"&SAVE_linkshome"||'.ASP"><FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Home</FONT></a>&nbsp&nbsp'; PUT line;

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
*	     REQUIREMENT: See LINKS Report SOP                                                     *;
*       INPUT           : MACRO VARIABLES: REPORTYPE2, DATACHECK1A, DATACHECK1B,                   *;
*		          DATACHECK2A, DATACHECK2B, DATACHECK3, PRINT, REPORTYPE                   *;
*       PROCESSING      : This macro decides on the program flow depending on the values of        *;
*		          certain parameters.                                                      *;
*       OUTPUT          : Report to screen or RTF file.                                            *;
****************************************************************************************************;
%MACRO LRBATCHANALYSIS;
	/*** If report = STUDYDESC then execute STUDYDESC macro   ***/
	%IF %SUPERQ(REPORTYPE2)=STUDYDESC %THEN %STUDYDESC;  
        /*** Otherwise do the following                           ***/
	%ELSE %DO;  
		%INIT;  
		%IF %SUPERQ(datacheck0)^=GO %THEN %DO;
			/*** Print warning                        ***/
			DATA _NULL_; LENGTH LINE $500; FILE _WEBOUT;										
				LINE='<BODY BGCOLOR="#C0C0C0"></BR></BR></BR><TABLE VALIGN=CENTER ALIGN=CENTER WIDTH="75%"><TR ><TD ROWSPAN=2 ALIGN=CENTER >'; PUT LINE;
				LINE='<IMG SRC="//'||"&_server"||'/links/images/j02702421.wmf" WIDTH="175" HEIGHT="200"></TD>'; PUT LINE;
    				LINE='<TD ><TABLE><TR><TD BGCOLOR="#FF0000"><FONT FACE=ARIAL SIZE=10 COLOR=WHITE><STRONG>No valid data exists.</STRONG><FONT></TD></TR>'; PUT LINE;
				LINE='<TR><TD ALIGN=CENTER><FONT FACE=ARIAL SIZE=5 COLOR=BLACK><STRONG>Please contact a LINKS Administrator.</STRONG><FONT></TD></TR></TABLE></TD></TR></TABLE>'; PUT LINE;
    			RUN;
		%END;  
		%ELSE %DO;  
			%SUBSET1;  
			%IF %SUPERQ(datacheck1)^=GO %THEN %DO;                /***  If data does not exist from Subset1  ***/
				/*** Print warning                ***/
				DATA _NULL_; LENGTH LINE $500; FILE _WEBOUT;										
					LINE='<BODY BGCOLOR="#C0C0C0"></BR></BR></BR><TABLE VALIGN=CENTER ALIGN=CENTER WIDTH="75%"><TR ><TD ROWSPAN=2 ALIGN=CENTER >'; PUT LINE;
					LINE='<IMG SRC="//'||"&_server"||'/links/images/j02702421.wmf" WIDTH="175" HEIGHT="200"></TD>'; PUT LINE;
    					LINE='<TD ><TABLE><TR><TD BGCOLOR="#FF0000"><FONT FACE=ARIAL SIZE=10 COLOR=WHITE><STRONG>No valid data exists for the query selections.</STRONG><FONT></TD></TR>'; PUT LINE;
					LINE='<TR><TD ALIGN=CENTER><FONT FACE=ARIAL SIZE=5 COLOR=BLACK><STRONG>Please use the back button to change your selection.</STRONG><FONT></TD></TR></TABLE></TD></TR></TABLE>'; PUT LINE;
	    			RUN;
			%END;
			%ELSE %DO;
				%SUBSET2;                         /*** If data does exist from Subset1, execute Subset2  ***/
				%IF %SUPERQ(datacheck2)^=GO  %THEN %DO;        /***  If data does not exist from Subset2 ***/
					/*** Print warning       ***/
					DATA _NULL_; LENGTH LINE $500; FILE _WEBOUT;										
						LINE='<BODY BGCOLOR="#C0C0C0"></BR></BR></BR><TABLE VALIGN=CENTER ALIGN=CENTER WIDTH="75%"><TR ><TD ROWSPAN=2 ALIGN=CENTER >'; PUT LINE;
						LINE='<IMG SRC="//'||"&_server"||'/links/images/j02702421.wmf" WIDTH="175" HEIGHT="200"></TD>'; PUT LINE;
    						LINE='<TD ><TABLE><TR><TD BGCOLOR="#FF0000"><FONT FACE=ARIAL SIZE=10 COLOR=WHITE><STRONG>No valid data exists for the query selections.</STRONG><FONT></TD></TR>'; PUT LINE;
						LINE='<TR><TD ALIGN=CENTER><FONT FACE=ARIAL SIZE=5 COLOR=BLACK><STRONG>Please use the back button to change your selection.</STRONG><FONT></TD></TR></TABLE></TD></TR></TABLE>'; PUT LINE;
    					RUN;
				%END;
				%ELSE %DO;
						%SETUP;            /*** If data does exist from Subset3, execute Setup   ***/
			
						********************************************************;
						*** If user has chosen to print, execute Print macro ***;
						*** Otherwise execute Webout macro                   ***;
						********************************************************;
						%IF %SUPERQ(print)=ON AND %SUPERQ(reportype)^=CORR %THEN %PRINT;  
						%ELSE %IF %SUPERQ(print)^=ON %THEN %WEBOUT;			     

						/*** Execute corresponding macro depending on value of reportype         ***/
						%IF       %SUPERQ(reportype)=HISTIND    %THEN %HIST;	
						%ELSE %IF %SUPERQ(reportype)=INDRUN     %THEN %INDRUN;       	
   				 		%ELSE %IF %SUPERQ(reportype)=PRODSTATS  %THEN %PRODSTATS;      
						%ELSE %IF %SUPERQ(reportype)=BATCHSTATS %THEN %BATCHSTATS;       
   						%ELSE %IF %SUPERQ(reportype)=XBAR       %THEN %XBAR;
						%ELSE %IF %SUPERQ(reportype)=SBAR       %THEN %SBAR;
   						%ELSE %IF %SUPERQ(reportype)=CORR       %THEN %CORR;
   						%ELSE %IF %SUPERQ(reportype)=CIPROFILES %THEN %CIPROFILES;

						/*** Close ODS statement ***/
						&close;                                          

						/*** If output is going to web browser, execute Webout2                  ***/
						%IF %SUPERQ(print)^=ON %THEN %Webout2;  
					%END;
				%END;
			%END;
		%END;
		/*** Save variables from current run for comparison to future runs ***/
		%LET save_prodinit=&product;
		%LET save_condinit=&storage;
		%LET save_staginit=&stagea;
		%LET save_peakinit=&peaka;
		%LET save_rptinit=&reportype;
		%IF %SUPERQ(TESTA)^=ALL %THEN 
			%LET save_testinit=&testA;
		%ELSE %LET SAVE_TESTINIT= ;

%MEND LRBATCHANALYSIS;

%LRBATCHANALYSIS;
%put _all_;
