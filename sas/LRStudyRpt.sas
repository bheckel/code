********************************************************************************************;
*                     PROGRAM HEADER                                                       *;
*------------------------------------------------------------------------------------------*;
*  PROJECT NUMBER:  LINKS POT0205                                                          *;
*  PROGRAM NAME: LRStudyRpt.SAS                    SAS VERSION: 8.2                        *;
*  DEVELOPED BY: James Becker                      DATE: 11/21/2002                        *;
*  PROJECT REPRESENTATIVE: Carol Hiser                                                     *;
*  PURPOSE: Prompts the user to select study Reports, and enter report 	                   *;
*			characteristcs and then generates Report(s).                       *;
*  SINGLE USE OR MULTIPLE USE? (SU OR MU) MU                                               *;
*  PROGRAM ASSUMPTIONS OR RESTRICTIONS: All documentation for this program                 *;
*	is covered under the LINKS report SOP.                                             *;
*------------------------------------------------------------------------------------------*;
*  OTHER SAS PROGRAMS, MACROS OR MACRO VARIABLES USED IN THIS                              *;
*  PROGRAM:   None.                                                                        *;
*------------------------------------------------------------------------------------------*;
*  DESCRIPTION OF OUTPUT: 1 or more study reports in the user selected format.             *;											  
********************************************************************************************;
*                     HISTORY OF CHANGE                                                    *;
*-------------+---------+---------------+--------------------------------------------------*;
*     DATE    | VERSION | NAME          | Description                                      *;
*-------------+---------+---------------+--------------------------------------------------*;
*  11/21/2002 |    1.0  | James Becker  | Original                                         *;
*------------------------------------------------------------------------------------------*;
*  11/22/2002 |    2.0  | Carol Hiser   | - Added 'Salm' and 'Flut' to Individual          *;
*             |         |               |   Lab_tst_desc_str list for content              *;
*	      |		|	        |   per blister.                                   *;
*	      |		|	        | - Removed Microscopic Evaluation-SHAPE           *;
*	      |		|	        |   from mean calculations                         *;
*	      |		|	        |   Added unspecified impurities methods           *;
*	      |		|	        |   to mean calculations.                          *;
*------------------------------------------------------------------------------------------*;
*  11/22/2002 |    3.0  | Carol Hiser   | - Modified method variable creation for          *;
*             |         |               |   Microscopic Evaluation.  Modified              *;
*             |         |               |   code to include MLT for MDPI strips            *;
*	      |		|		|   Changed method=get to formmethod=get           *;
*------------------------------------------------------------------------------------------*;
*  12/17/2002 |    4.0  | James Becker  | - Displayed message on Web Page that if screen   *;
*             |         |               |   printed from Web Browser, and not RTF option,  *;
*             |         |               |   that the report is unofficial.                 *;
*------------------------------------------------------------------------------------------*;
*  10/21/2003 |    5.0  | James Becker  | - VCC25658 - Amendmemt for MERPS/SAP             *;
*             |         |	        |   IN %MACRO REPORTS:                             *;
*             |         |               |   * Modified input from LRQueryRes_SPECS file to *;
*             |         |               |     correctly create REPORT Field.               *;
*             |         |               |   * Replaced sections refering to Lot_Nbr, to    *;
*             |         |               |     Matl_Nbr & Batch_Nbr.                        *;
*------------------------------------------------------------------------------------------*;
*  14JUN2006  |    6.0  | Carol Hiser   |  VCC45936 - Modified code to reflect new file    *;
*             |         |               |  structure from LRQuery.                         *;
*             |         |               |   - Added code to accurately report impurities   *;
*             |         |               |      for all products.                           *;
*             |         |               |   - Modified report header information.          *;
*------------------------------------------------------------------------------------------*;
*  08JAN2007  |    7.0  | Bob Heckel    |  VCC56276 %Reports                               *;
*             |         |               |   - Modified condition to avoid deleting THROAT  *;
*             |         |               |     for Advair HFA Tests                         *;
*             |         |               |   - Prevent &COMMENT mvar from displaying when   *;
*             |         |               |     not filled                                   *;
*------------------------------------------------------------------------------------------*;
*  22JAN2007  |    8.0  | James Becker  |  VCC53434 %Reports                               *;
*             |         |               |   - Added New Spec File                          *;
*------------------------------------------------------------------------------------------*;
*  30APR2007  |    9.0  | Bob Heckel    |  VCC58655 %Reports                               *;
*             |         |               |   - Modified name of spec variable to            *;
*             |         |               |     meth_ord_num to align with links_spec_file   *;
*             |         |               |   - Removed empty column in output               *;
*             |         |               |   - Removed Mfg & Pkg dates, added Storage Date  *;
*             |         |               |   - Reformatted Study Condition display          *;
*             |         |               |   - Added Indvl_Meth_Stage_Nm to sort            *;
********************************************************************************************;
********************************************************************************************;
*                       SETUP MODULE                                                       *;
*------------------------------------------------------------------------------------------*;
OPTIONS NUMBER NODATE MLOGIC MPRINT SYMBOLGEN SOURCE2 PAGENO=1 COMPRESS=YES; 
%GLOBAL Test Report Screen Today Time TotalCnt save_rpttype ReportType ReportName
	DataType StatusFlag FooterFlag OutType Save_MaxTimes;

/* Changed method to formmethod in V3 */
%LET FORMMETHOD=GET;

DATA _NULL_;
   CALL SYMPUT('Today',TRIM(LEFT(PUT(Today(),WORDDATE.))));
   CALL SYMPUT('Time', TRIM(LEFT(PUT(Time(),timeampm9.))));
RUN;
%LET CtlDir =;
%LET ServerName =;
%GetParm(SasServer, CtlDir, N);                 %LET CtlDir     = &parm;
%GetParm(SasServer, ServerName, N);             %LET ServerName = &parm;


*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: See LINKS Report SOP REQUIREMENT: See LINKS Report SOP  *;                                             	  
*   INPUT:            MACRO VARIABLES: _SERVER, SAVE.LINKSHOME, _THISSESSION  *;	
*					  FILE: GSK1LOGO1.GIF        	      *;
*   PROCESSING:       Generates web page message stating that the user made   *;
*					  too many selections. 		      *;
*   OUTPUT:           1 HTML page to web browser                              *;
*******************************************************************************;

%MACRO OverLimit;
	DATA _NULL_; length line $2000; file _webout;
	  PUT '<BODY BGCOLOR="#808080">';  /* Create LINKS banner */
	  PUT '<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" border="0" cellpadding="0" cellspacing="0">';
	  PUT '<TR ALIGN="LEFT" ><TD BGCOLOR="#003366"><big><big><big>';
	  line=	'<IMG src="http://'||"&_server"||'/links/images/gsklogo1.gif" width="141" height="62">'; put line;
	  PUT '<FONT FACE=ARIAL color="#FFFFFF"><em> LINKS </em> Stability Module</FONT>';
	  PUT '</big></big></big></TD></TR>';
		/* Create warning message */
	  PUT '<TR><TD height="87%" BGCOLOR="#FFFFDD" vALIGN=top>';
	  PUT '<p ALIGN=center><STRONG><big><big><FONT FACE=ARIAL color="#FF0000"></br>';
	  PUT 'You have made too many selections.</br>Please go back and reselect.</big></big></FONT>';
	  PUT '</br></br></TD></TR>';
	  PUT '<TR ALIGN="right" ><TD BGCOLOR="#003366">';
	   /* Create footer */ 
 	  LINE = '<A HREF="//'||SYMGET('_server')||'/links/'||"&SAVE_linkshome"||'.ASP?UserRole='|| "%SUPERQ(Save_UserRole)" ||'">
	  <FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Home</FONT></a>&nbsp&nbsp'; PUT line;
	  ANCHOR= '&nbsp;&nbsp;<A HREF="'|| "%SUPERQ(_THISSESSION)" || 
		'&_program=LINKS.LRLogoff.sas"><FONT FACE=ARIAL color="#FFFFFF">Log off</FONT></A>&nbsp;&nbsp;'; 
	  PUT ANCHOR; 
	  PUT '</TD></TR></TABLE></BODY></html>';

%MEND OverLimit;

*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: See LINKS Report SOP REQUIREMENT: See LINKS Report SOP  *;
*   INPUT:            Save.LRQueryRes_DataBase   			      *;
*		      MACRO VARIABLES: _SERVER, SAVE.LINKSHOME, _THISSESSION  *;
*		      _server, _service, _port, _sessionid		      *;	
*		      FILE: GSK1LOGO1.GIF        			      *;		
*   PROCESSING:       Generates a table with a check box for each study	      *;
*		      Include corresponding product and study description     *;
*		      for each study in table				      *;
*   OUTPUT:           1 HTML screen to web browser    	                      *;
*******************************************************************************;

%MACRO Studies;

	%GLOBAL NumProduct NumReports;
	
	/* Generate unique list of study numbers, Storage conditions, time points & test methods */
	PROC SORT DATA=Save.LRQueryRes_DataBase NODUPKEY OUT=Studies; 
		BY Stability_Samp_Product Stability_Study_Nbr_Cd Stability_Samp_Stor_Cond Stability_Samp_Time_Weeks 
		Lab_Tst_Meth_Spec_Desc ; 
	RUN;

	/* Generate unique list of study numbers */

	PROC SORT DATA=Studies NODUPKEY OUT=VARLIST1; 
		BY Stability_Study_Nbr_Cd Matl_Desc; 
	RUN;

	/* Generate macro variable for total number of studies */
	DATA VARLIST2; SET VARLIST1 NOBS=NumStudies; BY Stability_Study_Nbr_Cd Matl_Desc;
		RETAIN Obs 0;
		Obs=Obs+1; OUTPUT;
		CALL SYMPUT("NumStudies",NumStudies);
	RUN;
	/* Create a macro variable list of all studies */
	%DO i = 1 %TO &NumStudies;  
		%GLOBAL Study&i ;
		DATA _NULL_; SET VARLIST2;
			WHERE Obs=&i;
			CALL SYMPUT("Study&i",TRIM(Stability_Study_Nbr_Cd));
		RUN;
	%END;
		
	/* Generate a screen containing a checkbox list of studies with a submit button */
	DATA _NULL_; LENGTH LINE $2000 ANCHOR $2000;
		FILE _WEBOUT;	/* Set up LINKS banner */
		PUT '<BODY BGCOLOR="#808080"><title>LINKS Stability Study Reports</title></BODY>';
		PUT '<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" border="1" bordercolor="#003366" cellpadding="0" cellspacing="0">';
		PUT '<TR ALIGN="LEFT" ><TD colspan=2 BGCOLOR="#003366">';
		PUT '<TABLE ALIGN=LEFT vALIGN=top height="100%" width="100%"><TR><TD ALIGN=LEFT><big><big><big>';
		LINE='<IMG src="//'||"&_server"||'/links/images/gsklogo1.gif" width="141" height="62">'; PUT LINE;
		PUT '<FONT FACE=ARIAL color="#FFFFFF"><em> LINKS </em> Stability Module</FONT></big></big></big></TD>';
		ANCHOR= '<TD ALIGN=RIGHT><A HREF="'|| "%SUPERQ(_THISSESSION)" ||
		'&_program=links.LRReport.sas"><FONT FACE=ARIAL color="#FFFFFF">Back to Stability Menu</FONT></A>';
	    PUT ANCHOR; 
		PUT '</TD></TR></TABLE></TD></TR>';
		PUT '<TR height="87%"><TD BGCOLOR="#ffffdd" nowrap   ALIGN="center" vALIGN="top">';
	RUN;
	/* Generate form parameters */
	DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;
		PUT   '<TABLE width="60%" ALIGN=center>';
		LINE= '<FORM  METHOD="'||"&FORMmethod"||'" ACTION="'||"&_url"||'" >'; 						PUT LINE;
		PUT   '<INPUT TYPE="hidden" NAME="_service"   VALUE="default">';
		LINE= '<INPUT TYPE="hidden" NAME="_program"   VALUE="links.LRStudyRpt.sas">'; 			PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME="_server"    VALUE="'||symget('_server')	   	||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME="_port"      VALUE="'||symget('_port')		   	||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME="_sessionid" VALUE="'||symget('_sessionid')	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME="screen" 	  VALUE="REPORTLIST">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME="_debug" 	  VALUE="0">'; PUT LINE; 
		PUT '<TABLE ><TR><TD ALIGN=LEFT></br>';
		PUT '<FONT face=arial color="#003366" SIZE=3><em><STRONG>';
		PUT 'Select one or more studies:</br></em></STRONG></FONT></TD></TR><TR>';
	RUN;
	/* Create table with checkboxes for each report */
	DATA _NULL_; FILE _WEBOUT;
	LINE= '<TD><TABLE BORDER=1 CELLPADDING=5 STYLE="FONT-family: Arial FONT-SIZE: smaller" BGCOLOR="#FFFFFF" bordercolor="#C0C0C0" bordercolorlight="#C0C0C0" bordercolordark="#C0C0C0">'; PUT LINE;
	PUT '<TR BGCOLOR="#C0C0C0"><TD><FONT face=arial SIZE=3><STRONG>Study</STRONG></FONT></TD><TD><FONT face=arial SIZE=3><STRONG>Product</STRONG></FONT></TD>';
	PUT '<TD><FONT face=arial SIZE=3><STRONG>Study Purpose</STRONG></FONT></TD></TR>';
	RUN;

	%DO I = 1 %TO &NUMStudies;
		DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT; SET VARLIST2; 
			WHERE OBS=&i;
			LINE= '<Tr><TD><STRONG><FONT face=arial SIZE=2>'; PUT LINE;
			LINE= '<INPUT TYPE=Checkbox NAME=Study VALUE="'||TRIM(Stability_Study_Nbr_Cd)||'"><STRONG>'||TRIM(Stability_Study_Nbr_Cd)||'</STRONG></TD>'; PUT LINE; 
			LINE= '<TD><FONT face=arial SIZE=2>'||Stability_Samp_Product||'</FONT></STRONG></TD>'; PUT LINE;
			LINE= '<TD><FONT face=arial SIZE=2>'||Stability_study_purpose_txt||'</FONT></STRONG></TD></TR>'; PUT LINE;
		RUN;
	%END;
				
	DATA _NULL_; LENGTH LINE ANCHOR $2000; FILE _WEBOUT;
  		PUT '</TABLE></TD><TR><TD colspan=3 ALIGN=center></br>'; 
		PUT '<INPUT TYPE=submit NAME=submit VALUE="Next"';
		PUT ' STYLE="background-color: rgb(192,192,192); color: rgb(0,0,0); ';
		PUT ' FONT-SIZE: 11pt; FONT-family: Arial Bold; FONT-weight: bolder; ';
		PUT ' text-ALIGN: center; border: medium OUTSET; padding-TOp: 2px; padding-botTOm: 4px"></BR></BR>'; 
		PUT '</FONT></TD></TR></FORM></TABLE></TD></TR>';
		PUT '<TR ALIGN=RIGHT ><TD BGCOLOR="#003366">';
	 	LINE = '<A HREF="//'||SYMGET('_server')||'/links/'||"&SAVE_linkshome"||'.ASP?UserRole='|| "%SUPERQ(Save_UserRole)" ||'">
		<FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Home</FONT></a>&nbsp&nbsp'; PUT line;
		ANCHOR= '&nbsp;&nbsp;<A HREF="'|| "%SUPERQ(_THISSESSION)" ||
				'&_program='||"LINKS.LRLogoff.sas"||
				'"><FONT FACE=ARIAL color="#FFFFFF">Log off</FONT></A>&nbsp;&nbsp;'; 
		PUT ANCHOR; 
		PUT '</TD></TR></TABLE>'; 
	RUN;

%MEND Studies;

*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: See LINKS Report SOP REQUIREMENT: See LINKS Report SOP  *;
*   INPUT:            Save.LRQueryRes_DataBase   			      *;
*		      MACRO VARIABLES: _SERVER, SAVE.LINKSHOME, _THISSESSION, *;
*		        _service, _port, _sessionid		              *;	
*	  	  	FILE: GSK1LOGO1.GIF        			      *;	
*   PROCESSING:       Generates a table with a check box for each report      *;
*			 (Stability_Study_Nbr_Cd & Stability_Samp_Stor_Cond)  *;
*			  Include corresponding product and study description *;
*			  for each report in table			      *;
*   OUTPUT:           1 HTML screen to web browser    	                      *;
*******************************************************************************;

%MACRO ReportList;
	%GLOBAL NumReports ;
	
	/* Create comma delimited list of all studies chosen. */
	%IF %SUPERQ(Study0)= %THEN %DO; * Only one selection made;
		%GLOBAL Study0 Study1;
	 	DATA _NULL_; 
	    	CALL SYMPUT('Study0',1);
	    	CALL SYMPUT('Study1', SYMGET("Study"));
	 	RUN;
		%END;

	%LET StudyList= ;
	%DO i = 1 %TO &Study0;
		%LET StudyList=&StudyList  "&&Study&i";
		%IF i < &Study0 %THEN %LET StudyList=&StudyList , ;
		%END;

	DATA REPORTS; SET Save.LRQueryRes_DataBase;
		WHERE STABILITY_STUDY_NBR_CD IN (&STUDYLIST);
	RUN;
	
	/* Generate unique list of reports (study numbers/storage conditions combinations) */
	PROC SORT DATA=REPORTS NODUPKEY OUT=VARLIST1; 
		BY Stability_Study_Nbr_Cd Matl_Desc Stability_Samp_Stor_Cond; 
	RUN;
	/* Generate macro variable for total number of reports */
	DATA VARLIST2; SET VARLIST1 NOBS=NumReports; BY  Stability_Study_Nbr_Cd Matl_Desc Stability_Samp_Stor_Cond ;
		RETAIN Obs 0;
		Obs=Obs+1; OUTPUT;
		CALL SYMPUT("NumReports",NumReports);
	RUN;
	/* Create a macro variable list of all reports */
	%DO i = 1 %TO &NumReports;  
		%GLOBAL Report&i ;
		DATA _NULL_; SET VARLIST2;
			WHERE Obs=&i;
			CALL SYMPUT("Report&i",TRIM(Stability_Study_Nbr_Cd)||'-'||TRIM(Stability_Samp_Stor_Cond));
		RUN;
		%END;
		
	/* Generate a screen containing a checkbox list of reports with a submit button */
	DATA _NULL_; LENGTH LINE ANCHOR $2000;
		FILE _WEBOUT;	/* Set up LINKS banner */
		PUT '<BODY BGCOLOR="#808080"><title>LINKS Stability Study Reports</title></BODY>';
		PUT '<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" border="1" bordercolor="#003366" cellpadding="0" cellspacing="0">';
		PUT '<TR ALIGN="LEFT" ><TD colspan=2 BGCOLOR="#003366">';
		PUT '<TABLE ALIGN=LEFT vALIGN=top height="100%" width="100%"><TR><TD ALIGN=LEFT><big><big><big>';
		LINE='<IMG src="//'||"&_server"||'/links/images/gsklogo1.gif" width="141" height="62">'; PUT LINE;
		PUT '<FONT FACE=ARIAL color="#FFFFFF"><em> LINKS </em> Stability Module</FONT></big></big></big></TD>';
		ANCHOR= '<TD ALIGN=RIGHT><A HREF="'|| "%SUPERQ(_THISSESSION)" ||
		'&_program=links.LRReport.sas"><FONT FACE=ARIAL color="#FFFFFF">Back to Stability Menu</FONT></A>';
	   	PUT ANCHOR; 
		PUT '</TD></TR></TABLE></TD></TR>';
		PUT '<TR height="87%"><TD BGCOLOR="#ffffdd" nowrap   ALIGN="center" vALIGN="top">';
	RUN;
	/* Generate form parameters */
	DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;
		PUT   '<TABLE width="60%" ALIGN=center>';
		LINE= '<FORM  METHOD="'||"&FORMmethod"||'" ACTION="'||"&_url"||'" >'; 						PUT LINE;
		PUT   '<INPUT TYPE="hidden" NAME="_service"   VALUE="default">';
		LINE= '<INPUT TYPE="hidden" NAME="_program"   VALUE="links.LRStudyRpt.sas">'; 			PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME="_server"    VALUE="'||symget('_server')	   	||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME="_port"      VALUE="'||symget('_port')		   	||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME="_sessionid" VALUE="'||symget('_sessionid')	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME="screen" 	  VALUE="TIMELIST">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME="_debug" 	  VALUE="0">'; PUT LINE; 
		PUT '<TABLE ><TR><TD ALIGN=LEFT></br>';
		PUT '<FONT face=arial color="#003366" SIZE=3><em><STRONG>Select one or more study report(s):</br></em></STRONG></FONT></TD></TR><TR>';
	RUN;
	/* Create table with checkboxes for each report */
	DATA _NULL_; FILE _WEBOUT;
		LINE= '<TD><TABLE BORDER=1 CELLPADDING=5 STYLE="FONT-family: Arial FONT-SIZE: smaller" BGCOLOR="#FFFFFF" bordercolor="#C0C0C0" bordercolorlight="#C0C0C0" bordercolordark="#C0C0C0">'; PUT LINE;
		PUT '<TR BGCOLOR="#C0C0C0"><TD><FONT face=arial SIZE=3><STRONG>Report</STRONG></FONT></TD><TD><FONT face=arial SIZE=3><STRONG>Product</STRONG></FONT></TD>';
		PUT '<TD><FONT face=arial SIZE=3><STRONG>Purpose</STRONG></FONT></TD></TR>';
	RUN;

	%DO I = 1 %TO &NUMREPORTS;
		DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT; SET VARLIST2; 
			WHERE OBS=&i;
			LINE= '<Tr><TD><STRONG><FONT face=arial SIZE=2>'; PUT LINE;
			LINE= '<INPUT TYPE=Checkbox NAME=Report VALUE="'||TRIM(Stability_Study_Nbr_Cd)||'-'||TRIM(Stability_Samp_Stor_Cond)||'"><STRONG>'||TRIM(Stability_Study_Nbr_Cd)||'-'||TRIM(Stability_Samp_Stor_Cond)||'</STRONG></TD>'; PUT LINE; 
			LINE= '<TD><FONT face=arial SIZE=2>'||Stability_Samp_product||'</FONT></TD>'; PUT LINE;
			LINE= '<TD><FONT face=arial SIZE=2>'||Stability_study_purpose_txt||'</FONT></TD></TR>'; PUT LINE;
		RUN;
		%END;
				
	DATA _NULL_; LENGTH LINE ANCHOR $2000; FILE _WEBOUT;
  		PUT '</TABLE></TD><TR><TD colspan=3 ALIGN=center></br>'; 
		PUT '<INPUT TYPE=submit NAME=submit VALUE="Next"';
		PUT ' STYLE="background-color: rgb(192,192,192); color: rgb(0,0,0); ';
		PUT ' FONT-SIZE: 11pt; FONT-family: Arial Bold; FONT-weight: bolder; ';
		PUT ' text-ALIGN: center; border: medium OUTSET; padding-TOp: 2px; padding-botTOm: 4px"></BR></BR>'; 
		PUT '</FONT></TD></TR></FORM></TABLE></TD></TR>';
		PUT '<TR ALIGN=RIGHT ><TD BGCOLOR="#003366">';
	 	LINE = '<A HREF="//'||SYMGET('_server')||'/links/'||"&SAVE_linkshome"||'.ASP?UserRole='|| "%SUPERQ(Save_UserRole)" ||'">
		<FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Home</FONT></a>&nbsp&nbsp'; PUT line;
		ANCHOR= '&nbsp;&nbsp;<A HREF="'|| "%SUPERQ(_THISSESSION)" ||
				'&_program='||"LINKS.LRLogoff.sas"||
				'"><FONT FACE=ARIAL color="#FFFFFF">Log off</FONT></A>&nbsp;&nbsp;'; 
		PUT ANCHOR; 
		PUT '</TD></TR></TABLE>'; 
	RUN;

%MEND ReportList;
*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: See LINKS Report SOP REQUIREMENT: See LINKS Report SOP  *;
*   INPUT:            Save.LRQueryRes_DataBase   			      *;
*		      MACRO VARIABLES: _SERVER, SAVE.LINKSHOME, _THISSESSION, *;
*		       _service, _port, _sessionid		              *;	
*		      FILE: GSK1LOGO1.GIF        			      *;		
*   PROCESSING:       Generates HTML form with check box list for time points *;
*   OUTPUT:           1 HTML screen to web browser		              *;
*******************************************************************************;

%MACRO TimeList;
	/* Create comma delimited list of all reports chosen. */
	%IF %SUPERQ(Report0)= %THEN %DO; * Only one selection made;
		%GLOBAL Report0 Report1;
		 DATA _NULL_; 
		    CALL SYMPUT('Report0',1);
		    CALL SYMPUT('Report1', SYMGET("Report"));
		 RUN;
	%END;

	%LET ReportList= ;
	%DO i = 1 %TO &Report0;
		%LET ReportList=&ReportList  "&&Report&i";
		%IF i < &Report0 %THEN %LET ReportList=&ReportList , ;
	%END;
	
	DATA STAB0; SET Save.LRQueryRes_DataBase;
		Report=TRIM(Stability_Study_Nbr_Cd)||'-'||TRIM(Stability_Samp_Stor_Cond);
	RUN;
	/* Select only reports chosen */
	DATA ALLREPORTS; SET STAB0;
		WHERE Report IN (&ReportLIST);
	RUN;

	DATA _NULL_; LENGTH LINE ANCHOR $2000;
		FILE _WEBOUT;	/* Set up LINKS banner */
		PUT '<BODY BGCOLOR="#808080"><title>LINKS Stability Study Reports</title></BODY>';
		PUT '<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" border="1" bordercolor="#003366" cellpadding="0" cellspacing="0">';
		PUT '<TR ALIGN="LEFT" ><TD colspan=2 BGCOLOR="#003366">';
		PUT '<TABLE ALIGN=LEFT vALIGN=top height="100%" width="100%"><TR><TD ALIGN=LEFT><big><big><big>';
		LINE='<IMG src="//'||"&_server"||'/links/images/gsklogo1.gif" width="141" height="62">'; PUT LINE;
		PUT '<FONT FACE=ARIAL color="#FFFFFF"><em> LINKS </em> Stability Module</FONT></big></big></big></TD>';
		ANCHOR= '<TD ALIGN=RIGHT><A HREF="'|| "%SUPERQ(_THISSESSION)" ||
		'&_program=links.LRReport.sas"><FONT FACE=ARIAL color="#FFFFFF">Back to Stability Menu</FONT></A>';
	    PUT ANCHOR; 
		PUT '</TD></TR></TABLE></TD></TR>';
		PUT '<TR height="87%"><TD BGCOLOR="#ffffdd" nowrap   ALIGN="center" vALIGN="top">';
	RUN;
	/* Generate HTML form variables */
	DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;
		PUT   '<TABLE width="60%" ALIGN=center>';
		LINE= '<FORM  METHOD="'||"&FORMmethod"||'" ACTION="'||"&_url"||'" >'; 						PUT LINE;
		PUT   '<INPUT TYPE="hidden" NAME="_service" 	VALUE="default">';
		LINE= '<INPUT TYPE="hidden" NAME="_program" 	VALUE="links.LRStudyRpt.sas">'; 	   PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME="_server"    	VALUE="'||symget('_server')	   ||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME="_port"      	VALUE="'||symget('_port')	   ||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME="_sessionid" 	VALUE="'||symget('_sessionid')	   ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME="screen" 	VALUE="TESTLIST">'; 			   PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME="REPORT0" 	VALUE="'||symget('REPORT0')	   ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME="REPORT" 	VALUE="'||symget('REPORT')	   ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME="OUTTYPE"	VALUE="'||symget('outTYPE')	   ||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME="_debug" 	VALUE="0">'; PUT LINE; 
		PUT '<TABLE><TR><TD ALIGN=LEFT></br><FONT face=arial color="#003366" SIZE=3><em><STRONG>Select report time points:</EM></STRONG></br>';
		PUT '</FONT></TD></TR>';
		PUT '<TR><TD><TABLE BORDER=1 CELLPADDING=5 STYLE="FONT-family: Arial FONT-SIZE: smaller" BGCOLOR="#FFFFFF" bordercolor="#C0C0C0" bordercolorlight="#C0C0C0" bordercolordark="#C0C0C0">';
		PUT '<TR BGCOLOR="#c0c0c0"><TD><FONT face=arial><STRONG>Report</STRONG></FONT></TD><TD><FONT face=arial><STRONG>Time Points</STRONG></FONT></TD></TR>';
	RUN;

	/* Calculate maximum number of time points for all reports */
	PROC SORT DATA=ALLREPORTS OUT=TIME_LIST NODUPKEY; BY Stability_Samp_Time_Weeks; RUN;

	DATA _NULL_;	SET TIME_LIST NOBS=MAXTIME end=END_TIME;
       	IF END_TIME THEN CALL SYMPUT("Save_MaxTimes", maxtime);
	put Report Stability_Samp_Time_Weeks maxtime;
    RUN;

	/* Generate a unique list of time points for each report */
	PROC SORT DATA=ALLREPORTS OUT=TIME_LIST NODUPKEY; 
		BY Report Stability_Samp_Time_Weeks; 
	RUN;

	%DO I = 1 %TO &REPORT0;  /* Execute the following code for each report */
		
		/* Generate report HTML form variables and put report in first column of table */
		DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;
			LINE= '<INPUT TYPE="hidden" NAME=REPORT'||"&I"||' VALUE="'||symget("Report&I")	   ||'">'; PUT LINE; 
			LINE= '<TR><TD width="%20" ALIGN=LEFT><STRONG><FONT face=arial SIZE=2>'||"&&Report&i"||'</FONT></STRONG></TD>'; PUT LINE;
			PUT '<TD  ALIGN=LEFT>';
		RUN;

		/* Create dataset for initial data only*/
		DATA ZEROLIST;  SET TIME_LIST;
			where report="&&report&i";
			Stability_Samp_Time_Weeks=0;
			Stability_Samp_Time_Point='0';
		RUN; 

		/* Add initial data to all other data */
		DATA ALLREPORTOUT;	SET ALLREPORTS ZEROLIST;
			REPORT="&&Report&I"; 
			KEEP REPORT Stability_Samp_Time_Weeks Stability_Samp_time_point;	
		RUN;

		/* Create unique list of time points */
		PROC SORT DATA=ALLREPORTOUT OUT=TIMELIST1 NODUPKEY; BY Stability_Samp_Time_Weeks; RUN;

		/* Subset data for only current report */
		DATA ONEREPORT; SET ALLREPORTS;
			WHERE Report = "&&Report&I";
			Time_Chk=Stability_Samp_Time_Weeks;
		RUN;

		/* Add initial dataset to subsetted dataset */
		DATA ONEREPORT;	SET ONEREPORT ZEROLIST; RUN;

		/* Generate unique list of time points for current report */
		PROC SORT DATA=ONEREPORT OUT=TIMELIST2 NODUPKEY; BY Stability_Samp_Time_Weeks; RUN;

		DATA _NULL_;SET TIMELIST1;			WHERE Report = "&&Report&I";
		PUT Stability_Samp_Time_Weeks;RUN;
		%GLOBAL Time&I.00;
		DATA _NULL_;SET TIMELIST2;			WHERE Report = "&&Report&I";
		PUT REPORT Stability_Samp_Time_Weeks;	TotObs+1; CALL SYMPUT("Time&I.00",TRIM(LEFT(TotObs))); RUN;

		/* If the time point exists for the current report, set checked flag. */
		DATA REPORTTIMES; LENGTH Checked $7; MERGE TIMELIST1 TIMELIST2; 
			BY Stability_Samp_Time_Weeks; 
			IF Time_Chk ^= . THEN Checked='Checked';
					 ELSE Checked='';		
			IF Stability_Samp_Time_Weeks=0 THEN Disabled='';
				   		       ELSE Disabled='';		
		RUN;

		DATA _NULL_;SET Reporttimes;			WHERE Report = "&&Report&I";
			PUT report Stability_Samp_Time_Weeks;
		RUN;
			%GLOBAL Time&I.00;
		DATA _NULL_;SET reporttimes;	retain totobs 0;  by report;		WHERE Report = "&&Report&I";
		PUT REPORT Stability_Samp_Time_Weeks;	TotObs+1; if last.report then CALL SYMPUT("Time&I.00",TRIM(LEFT(TotObs))); RUN;
		PROC SORT DATA=REPORTTIMES;BY REPORT Stability_Samp_Time_Weeks;RUN;

DATA _NULL_;retain obs 0;SET REPORTTIMES;
	WHERE Report = "&&Report&I";
	BY REPORT Stability_Samp_Time_Weeks;
	IF FIRST.REPORT THEN OBS=0;OBS+1;
	CheckI=&I; I = (&I*100) + Obs; 
	Stability_Samp_time_weeks_Char=compress(' '||Stability_Samp_time_weeks);
	PUT REPORT Obs I Stability_Samp_Time_Weeks Stability_Samp_time_weeks_Char Stability_Samp_time_point Time_Chk "&&Time&I.00";
RUN;
		%DO GG = 1 %TO &&TIME&I.00; 
			%LET JJ = %EVAL((&I*100)+&GG); 
			%GLOBAL TIME&JJ;
		%END;

		/* Generate checkboxes for each time point, initially check all boxes with data for that time point */
		DATA _NULL_; retain obs 0; LENGTH LINE $2000 Stability_Samp_time_weeks_Char $4; FILE _WEBOUT; SET REPORTTIMES; BY REPORT Stability_Samp_Time_Weeks;
		      IF FIRST.REPORT THEN DO;
				OBS=0;
				LINE= '<INPUT TYPE="hidden" NAME=TIME'||"&I"||'00 VALUE="'||symget("Time&I.00")||'">'; PUT LINE; 
		      END;
			OBS+1;
			CheckI=&I; I = (CheckI *100) + Obs; 
			Stability_Samp_time_weeks_Char=compress(' '||Stability_Samp_time_weeks);
			LINE = '<FONT face=arial SIZE=2><INPUT TYPE=Checkbox '||CheckED||' '||DISABLED||' NAME="TIME'||COMPRESS(I)||'" VALUE="'||TRIM(LEFT(Stability_Samp_time_weeks_Char))||'">'||TRIM(LEFT(Stability_Samp_time_point)); PUT LINE; 
			
		RUN;

		DATA _NULL_; FILE _WEBOUT;
			PUT '</TD></TR>';
		RUN;

	%END;
	/* Print footer and create submit button */
	DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;
  		LINE= '</TABLE></TD></TR><TR><TD ALIGN=center><STRONG></BR><FONT face=arial COLOR="#000000" SIZE=2><STRONG>(Study data exists for initially checked timepoints.)</STRONG></FONT></br>'; PUT LINE;
		PUT '</BR><INPUT TYPE=submit NAME=submit VALUE="Next"';
		PUT ' STYLE="background-color: rgb(192,192,192); color: rgb(0,0,0); ';
		PUT ' FONT-SIZE: 11pt; FONT-family: Arial Bold; FONT-weight: bolder; ';
		PUT ' text-ALIGN: center; border: medium OUTSET; padding-TOp: 2px; padding-botTOm: 4px"></BR></BR>'; 
	RUN;
	/* Create HTML footer banner */
	DATA _NULL_; LENGTH LINE ANCHOR $2000; FILE _WEBOUT;
		PUT '</FONT></TD></TR></FORM></TABLE></TD></TR>';
		PUT '<TR ALIGN=RIGHT ><TD BGCOLOR="#003366">';
	 	LINE = '<A HREF="//'||SYMGET('_server')||'/links/'||"&SAVE_linkshome"||'.ASP?UserRole='|| "%SUPERQ(Save_UserRole)" ||'">
		<FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Home</FONT></a>&nbsp&nbsp'; PUT line;
		ANCHOR= '&nbsp;&nbsp;<A HREF="'|| "%SUPERQ(_THISSESSION)" ||
				'&_program='||"LINKS.LRLogoff.sas"||
				'"><FONT FACE=ARIAL color="#FFFFFF">Log off</FONT></A>&nbsp;&nbsp;'; 
		PUT ANCHOR; 
  
		PUT '</TD></TR></TABLE>'; 
	RUN;

%MEND TimeList;

*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: See LINKS Report SOP REQUIREMENT: See LINKS Report SOP  *;
*   INPUT:  DATASET: Save.LRQueryRes_DataBase,				      *;
*		      MACRO VARIABLES: _SERVER, SAVE.LINKSHOME, _THISSESSION, *;
*		       _service, _port, _sessionid		              *;	
*		      FILE: GSK1LOGO1.GIF        			      *;		
*   PROCESSING:  Generate HTML form with check box list of test methods.      *;
*   OUTPUT:      1 HTML screen to web browser				      *;
*******************************************************************************;

%MACRO TestList;
%PUT _ALL_;
	%DO I = 1 %TO &REPORT0;
		%LET J = %EVAL(&I*100);
		%LET J0= %EVAL(&I*100)+1;
		%GLOBAL TIME&J ;
	/*	%IF %SUPERQ(TIME&J)= %THEN %DO; * Only time point one selection made;
	  		DATA _NULL_; 
		    	CALL SYMPUT("TIME&J", "1");
		    	CALL SYMPUT("TIME&J0", SYMGET("TIME&J"));
		 	RUN;
		%END; 
		%ELSE %DO; */
			%DO K = 1 %TO &&TIME&J;
				%LET JJ= %EVAL((&I*100)+&K);
				%GLOBAL TIME&JJ;

		    		%LET TIME&JJ = &&TIME&JJ;
			%END;
		/*%END;*/

	%END;
	/* Create comma separated list of reports */
	%LET ReportList= ;
	%DO i = 1 %TO &Report0;
		%LET ReportList=&ReportList  "&&Report&I";
		%IF I < &Report0 %THEN %LET ReportList=&ReportList , ;
	%END;	
	
	/* Subset data for only chosen reports */
	DATA ALLREPORTS; LENGTH METHOD $100 ; SET Save.LRQueryRes_DataBase;
		Report=TRIM(Stability_Study_Nbr_Cd)||'-'||TRIM(Stability_Samp_Stor_Cond);
		METHOD=TRIM(Lab_Tst_Meth_Spec_Desc);
		IF Report IN (&ReportLIST);
	RUN;

	/* Obtain unique test methods and total number of test methods */
	PROC SORT DATA=ALLREPORTS NODUPKEY OUT=METHODS; BY METHOD; RUN;

	DATA METHODS2; SET METHODS NOBS=NUMMETH;
		RETAIN METHOD_Obs 0;
		METHOD_Obs+1; 
		OUTPUT;
		CALL SYMPUT('NUMMETH',NUMMETH);
	RUN;

	DATA _NULL_; LENGTH LINE ANCHOR $2000;
		FILE _WEBOUT;	/* Set up LINKS banner */

		PUT '<BODY BGCOLOR="#808080"><title>LINKS Stability Study Reports</title></BODY>';
		PUT '<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" border="1" bordercolor="#003366" cellpadding="0" cellspacing="0">';
		PUT '<TR ALIGN="LEFT" ><TD colspan=2 BGCOLOR="#003366">';
		PUT '<TABLE ALIGN=LEFT vALIGN=top height="100%" width="100%"><TR><TD ALIGN=LEFT><big><big><big>';
		LINE='<IMG src="//'||"&_server"||'/links/images/gsklogo1.gif" width="141" height="62">'; PUT LINE;
		PUT '<FONT FACE=ARIAL color="#FFFFFF"><em> LINKS </em> Stability Module</FONT></big></big></big></TD>';

		ANCHOR= '<TD ALIGN=RIGHT><A HREF="'|| "%SUPERQ(_THISSESSION)" ||
		'&_program=links.LRReport.sas"><FONT FACE=ARIAL color="#FFFFFF">Back to Stability Menu</FONT></A>';
	    PUT ANCHOR; 

		PUT '</TD></TR></TABLE></TD></TR>';
		PUT '<TR height="87%"><TD BGCOLOR="#ffffdd" nowrap   ALIGN="center" vALIGN="top">';
	RUN;
	/* Setup form variables */
	DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;
		PUT   '<TABLE width="60%" ALIGN=center>';
		LINE= '<FORM  METHOD="'||"&FORMmethod"||'" ACTION="'||"&_url"||'" >'; 						PUT LINE;
		PUT   '<INPUT TYPE="hidden" NAME="_service" VALUE="default">';
		LINE= '<INPUT TYPE="hidden" NAME="_program" VALUE="links.LRStudyRpt.sas">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=_server    VALUE="'||symget('_server')	   		||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=_port      VALUE="'||symget('_port')		    ||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=_sessionid VALUE="'||symget('_sessionid')	    ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=REPORT0 	VALUE="'||symget('REPORT0')	   		||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=REPORT 	VALUE="'||symget('REPORT')	   	 	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=screen 	VALUE="ReportType">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME="_debug" 	  VALUE="0">'; PUT LINE; 
		PUT   '<TABLE><TR><TD ALIGN=LEFT></br><FONT face=arial color="#003366" SIZE=3><em><STRONG>Select report test methods:</br></em></STRONG></FONT></TD></TR>';
		PUT   '<TR><TD><TABLE BORDER=1 CELLPADDING=5 STYLE="FONT-family: Arial FONT-SIZE: smaller" BGCOLOR="#FFFFFF" bordercolor="#C0C0C0" bordercolorlight="#C0C0C0" bordercolordark="#C0C0C0">';
		PUT   '<TR BGCOLOR="#C0C0C0"><TD><FONT SIZE=2 FACE=ARIAL><STRONG>Test Method</STRONG></FONT></TD></TR>';
	RUN;
	/* Add report and time variables from previous screens to form */
	%DO I = 1 %TO &REPORT0;
		%LET J = %EVAL(&I * 10);
		%LET JJ= %EVAL(&I * 100);
		DATA _NULL_; LENGTH LINE $2000 Weeks_Char $5; FILE _WEBOUT;
			LINE= '<INPUT TYPE="hidden" NAME=REPORT'||"&I"||' VALUE="'||symget("Report&I")	   ||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=TIME'||"&JJ"||' VALUE="'||"&&TIME&JJ"   ||'">'; PUT LINE; 
			%DO K = 1 %TO &&TIME&JJ;  /* CHANGED FROM SAVE_MAXTIME 5_15****/
				%LET JK = %EVAL((&I*100)+&K);
				/*%IF %SUPERQ(TIME&JK)^= %THEN %DO;*/
					OBS+1;
					CheckI=&I; I = (&I*100) + Obs;
					Weeks_Char="&&TIME&JK";
	 		        	LINE= '<INPUT TYPE="hidden" NAME=TIME'||TRIM(LEFT(I))||' VALUE='||TRIM(LEFT(Weeks_Char))||'>'; 
					PUT LINE; 
				/*%END;	
				%ELSE %DO; */
				    
			%END;
		RUN;
	%END;

	/* Create checkboxes for each test method */
	%DO M = 1 %TO &NUMMETH;
		DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT; SET METHODS2;
			WHERE METHOD_Obs=&M;
			LINE= '<TR><TD><FONT face=arial SIZE=2><INPUT TYPE=Checkbox Checked NAME=METHOD VALUE="'||TRIM(METHOD)||'">'||TRIM(METHOD)||'</FONT></TD></TR>'; PUT LINE; 
		RUN;
	%END;		

	/* Create form submit button */
	DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;
  		LINE= '</TABLE></TD></TR><TR><TD ALIGN=center></br>'; PUT LINE;
		PUT '</BR><INPUT TYPE=submit NAME=submit VALUE="Next"';
		PUT ' STYLE="background-color: rgb(192,192,192); color: rgb(0,0,0); ';
		PUT ' FONT-SIZE: 11pt; FONT-family: Arial Bold; FONT-weight: bolder; ';
		PUT ' text-ALIGN: center; border: medium OUTSET; padding-TOp: 2px; padding-botTOm: 4px"></BR></BR>'; 
	RUN;
	/* Create LINKS footer banner */
	DATA _NULL_; LENGTH LINE ANCHOR $2000; FILE _WEBOUT;
		PUT '</FONT></TD></TR></FORM></TABLE></TD></TR>';
		PUT '<TR ALIGN=RIGHT ><TD BGCOLOR="#003366">';
	 	LINE = '<A HREF="//'||SYMGET('_server')||'/links/'||"&SAVE_linkshome"||'.ASP?UserRole='|| "%SUPERQ(Save_UserRole)" ||'">
		<FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Home</FONT></a>&nbsp&nbsp'; PUT line;
		ANCHOR= '&nbsp;&nbsp;<A HREF="'|| "%SUPERQ(_THISSESSION)" ||
				'&_program='||"LINKS.LRLogoff.sas"||
				'"><FONT FACE=ARIAL color="#FFFFFF">Log off</FONT></A>&nbsp;&nbsp;'; 
		PUT ANCHOR; 
		PUT '</TD></TR></TABLE>'; 
	RUN;

%MEND TestList;

*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: See LINKS Report SOP REQUIREMENT: See LINKS Report SOP  *;
*   INPUT:            MACRO VARIABLES: METHOD0, METHOD, METHOD1 	      *;
*		      MACRO VARIABLES: _SERVER, SAVE.LINKSHOME, _THISSESSION, *;
*		       _service, _port, _sessionid		              *;	
*		      FILE: GSK1LOGO1.GIF        			      *;		
*   PROCESSING:       Generates HTML form with check box list for Report Type *;
*						& Options.            	      *;
*   OUTPUT:           1 HTML screen to web browser	                      *;
*******************************************************************************;

%MACRO ReportType;

	%IF %SUPERQ(METHOD0)= %THEN %DO; * Only one selection made;
	  
		%GLOBAL METHOD0 METHOD1;
		 DATA _NULL_; 
		    CALL SYMPUT('METHOD0',1);
		    CALL SYMPUT('METHOD1', SYMGET("METHOD"));
		 RUN;
	%END;
	/* Generate HTML form variables */
	DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;
		PUT   '<TABLE width="60%" ALIGN=center>';
		LINE= '<FORM  METHOD="'||"&FORMmethod"||'" ACTION="'||"&_url"||'" >'; 						PUT LINE;
		PUT   '<INPUT TYPE="hidden" NAME="_service" 	VALUE="default">';
		LINE= '<INPUT TYPE="hidden" NAME="_program" 	VALUE="links.LRStudyRpt.sas">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=_server    	VALUE="'||symget('_server')	   ||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=_port      	VALUE="'||symget('_port')	   ||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=_sessionid 	VALUE="'||symget('_sessionid') 	   ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=REPORT0 	VALUE="'||symget("REPORT0")	   ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=REPORT 	VALUE="'||symget("REPORT")	   ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=METHOD0 	VALUE="'||symget("METHOD0")	   ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=METHOD 	VALUE="'||symget("METHOD")	   ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=screen 	VALUE="REPORTS">'; 			   PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME="_debug" 	  VALUE="0">'; PUT LINE; 
	RUN;
	%LET TotalCnt=22;
	/* Add report and time variables from previous screens to form, count total variables */
/***
	%DO I = 1 %TO &REPORT0;
			%LET J = %EVAL(&I * 10);
			%DO K = 1 %TO &&TIME&J.0;
				%LET JJ= %EVAL((&I*100)+&K);
				%GLOBAL &TIME&JJ;
			%END;
	%END;
***/
	%DO I = 1 %TO &REPORT0;
		%LET J = %EVAL(&I * 10);
		%LET TotalCnt = %EVAL(&TotalCnt + 1);
		DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;
			LINE= '<INPUT TYPE="hidden" NAME=REPORT'||"&I"||' VALUE="'||symget("Report&I")	   ||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=TIME'||"&J"||'0 VALUE="'||"&&TIME&J.0"   ||'">'; PUT LINE; 
			%DO K = 1 %TO &&TIME&J.0;
				%LET JJ= %EVAL((&I * 100)+&K);
				%LET TotalCnt = %EVAL(&TotalCnt + 1);
				LINE= '<INPUT TYPE="hidden" NAME=TIME'||"&JJ"||' VALUE="'||"&&TIME&JJ"	   ||'">'; PUT LINE; 
			%END;
		RUN;
	%END;
	/* Add method variables from previous screens to form */
	%DO M = 1 %TO &METHOD0;
		DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;
			LINE= '<INPUT TYPE="hidden" NAME=METHOD'||"&M"||' VALUE="'||symget("METHOD&M")	   ||'">'; PUT LINE; 
		RUN;
		%LET TotalCnt = %EVAL(&TotalCnt + 1);
		%END;
	/* If user has made too many selections, execute overlimit macro */
	%LET TotalCnt = %EVAL(&TotalCnt + 5);
	%IF &TotalCnt > 120 %THEN %DO;	%OverLimit;	%END;
	%ELSE %DO;  /* Otherwise, generate screen */
	DATA _NULL_; LENGTH LINE ANCHOR $2000;
		FILE _WEBOUT;	/* Set up LINKS banner */
		PUT '<BODY BGCOLOR="#808080"><title>LINKS Stability Study Reports</title></BODY>';
		PUT '<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" border="1" bordercolor="#003366" cellpadding="0" cellspacing="0">';
		PUT '<TR ALIGN="LEFT" ><TD colspan=2 BGCOLOR="#003366">';
		PUT '<TABLE ALIGN=LEFT vALIGN=top height="100%" width="100%"><TR><TD ALIGN=LEFT><big><big><big>';
		LINE='<IMG src="//'||"&_server"||'/links/images/gsklogo1.gif" width="141" height="62">'; PUT LINE;
		PUT '<FONT FACE=ARIAL color="#FFFFFF"><em> LINKS </em> Stability Module</FONT></big></big></big></TD>';

		ANCHOR= '<TD ALIGN=RIGHT><A HREF="'|| "%SUPERQ(_THISSESSION)" ||
		'&_program=links.LRReport.sas"><FONT FACE=ARIAL color="#FFFFFF">Back to Stability Menu</FONT></A>';
	    PUT ANCHOR; 

		PUT '</TD></TR></TABLE></TD></TR>';

		PUT '<TR height="87%"><TD BGCOLOR="#ffffdd" nowrap   ALIGN="center" vALIGN="top">';
	RUN;
	/* Create radio boxes */
	DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;
		PUT '<TABLE width="60%"><TR><TD colspan=2 ALIGN=LEFT></br><FONT face=arial color="#003366" SIZE=4><em><STRONG>Report characteristics:</br></em></STRONG></FONT></TD></TR><TR>';
		/* Create radio box for type of report */
		LINE= '<TD  vALIGN=top ALIGN=LEFT><FONT face=arial color="#003366" SIZE=3><em><STRONG></br>Report Content:</em></STRONG></FONT>'; PUT LINE;
		PUT '</BR><input TYPE=radio NAME=ReportType Checked VALUE="SPEC"><FONT SIZE=2 face=arial>According to Specification.';
		PUT '</BR><input TYPE=radio NAME=ReportType  VALUE="BOTH"><FONT SIZE=2 face=arial>Means and Individuals.';
		PUT '</BR><input TYPE=radio NAME=ReportType  VALUE="MEANS"><FONT SIZE=2 face=arial>Means only.';
		PUT '</BR><input TYPE=radio NAME=ReportType  VALUE="IND">Individual values only.</FONT></TD>';
		/* Create radio box for type of data precision */
		LINE= '<TD vALIGN=top ALIGN=LEFT><FONT face=arial color="#003366" SIZE=3><em><STRONG></br>Data Precision:</em></STRONG></FONT>'; PUT LINE;
		PUT '</BR><input TYPE=radio NAME=DataType Checked VALUE="SPEC"><FONT SIZE=2 face=arial>Rounded to precision of specification.';
		PUT '</BR><input TYPE=radio NAME=DataType  VALUE="DATA1"><FONT SIZE=2 face=arial>Rounded one place past precision of specification.';
		PUT '</BR><input TYPE=radio NAME=DataType  VALUE="DATA2">Rounded two places past precision of specification.</FONT></TD></TR>';
		/* Create radio box for footnotes */
		LINE= '<TD vALIGN=top ALIGN=LEFT><FONT face=arial color="#003366" SIZE=3><em><STRONG></br>Study Specific Footnotes:</em></STRONG></FONT>'; PUT LINE;
		PUT '</BR><input TYPE=radio NAME=FooterFlag Checked VALUE="NONE"><FONT SIZE=2 face=arial>None.';
		PUT '</BR><input TYPE=radio NAME=FooterFlag  VALUE="DEFAULT"><FONT SIZE=2 face=arial>Default.';
		PUT '</BR><input TYPE=radio NAME=FooterFlag  VALUE="CUSTOM">Custom.</FONT></TD></TR>';
		/* Create radio box for type of data */
		LINE= '<TR><TD vALIGN=top ALIGN=LEFT><FONT face=arial color="#003366" SIZE=3><em><STRONG></br>Data Type:</br></em></STRONG></FONT>'; PUT LINE;
		PUT '<input TYPE=radio NAME=DataStatus Checked VALUE="APP"><FONT SIZE=2 face=arial>Approved Data Only.</br>';
		PUT '<input TYPE=radio NAME=DataStatus  VALUE="ALL"><FONT SIZE=2 face=arial>All Data.';
		PUT '</FONT></TD>';
		/* Create radio box for type of output */
		LINE= '<TD vALIGN=top ALIGN=LEFT colspan=2><FONT face=arial color="#003366" SIZE=3><em><STRONG></br>File Type:</br></em></STRONG></FONT>'; PUT LINE;
		PUT '<input TYPE=radio NAME=OutType Checked VALUE="HTML"><FONT SIZE=2 face=arial>Preview on Screen</br>';
		PUT '<input TYPE=radio NAME=OutType  VALUE="RTF"><FONT SIZE=2 face=arial>RTF file';
		/* PUT '<input TYPE=radio NAME=OutType  VALUE="PDF">PDF (Read Only)*/
		PUT '</FONT></TD></TR>';
	RUN;

	
	DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;  /* Pass total variable count to next screen */
		LINE= '<INPUT TYPE="hidden" NAME=TotalCnt VALUE="'||"&TotalCnt"||'">'; PUT LINE; 
	RUN;
	/* Create submit button */
	DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;
		/* Create radio box for name of report */
  		LINE= '<TR><TD ALIGN=center></br>'; PUT LINE;
		PUT '</BR><INPUT TYPE=submit NAME=submit VALUE="Finish"';
		PUT ' STYLE="background-color: rgb(192,192,192); color: rgb(0,0,0); ';
		PUT ' FONT-SIZE: 11pt; FONT-family: Arial Bold; FONT-weight: bolder; ';
		PUT ' text-ALIGN: center; border: medium OUTSET; padding-TOp: 2px; padding-botTOm: 4px">';
		PUT '</BR></BR>';
	RUN;
	/* Create LINKS footer banner */
	DATA _NULL_; LENGTH LINE ANCHOR $2000; FILE _WEBOUT;
		PUT '</FONT></TD></TR></FORM></TABLE></TD></TR>';
		PUT '<TR ALIGN=RIGHT ><TD BGCOLOR="#003366">';
	 	LINE = '<A HREF="//'||SYMGET('_server')||'/links/'||"&SAVE_linkshome"||'.ASP?UserRole='|| "%SUPERQ(Save_UserRole)" ||'">
		<FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Home</FONT></a>&nbsp&nbsp'; PUT line;
		ANCHOR= '&nbsp;&nbsp;<A HREF="'|| "%SUPERQ(_THISSESSION)" ||
				'&_program='||"LINKS.LRLogoff.sas"||
				'"><FONT FACE=ARIAL color="#FFFFFF">Log off</FONT></A>&nbsp;&nbsp;'; 
		PUT ANCHOR; 
		PUT '</TD></TR></TABLE>'; 
	RUN;

	%END;

%MEND ReportType;
*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: See LINKS Report SOP REQUIREMENT: See LINKS Report SOP  *;
*   INPUT:            MACRO VARIABLES: METHOD0, METHOD, METHOD1 	      *;
*		      MACRO VARIABLES: _SERVER, SAVE.LINKSHOME, _THISSESSION, *;
*		       _service, _port, _sessionid		              *;	
*		      FILE: GSK1LOGO1.GIF        			      *;		
*   PROCESSING:       Generates HTML form with check box list for Report Type *;
*						& Options.            	      *;
*   OUTPUT:           1 HTML screen to web browser	                      *;
*******************************************************************************;

%MACRO BatchInput;

	%IF %SUPERQ(METHOD0)= %THEN %DO; * Only one selection made;
	  
		%GLOBAL METHOD0 METHOD1;
		 DATA _NULL_; 
		    CALL SYMPUT('METHOD0',1);
		    CALL SYMPUT('METHOD1', SYMGET("METHOD"));
		 RUN;
	%END;
	/* Generate HTML form variables */
	DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;
		PUT   '<TABLE width="60%" ALIGN=center>';
		LINE= '<FORM  METHOD="'||"&FORMmethod"||'" ACTION="'||"&_url"||'" >'; 						PUT LINE;
		PUT   '<INPUT TYPE="hidden" NAME="_service" 	VALUE="default">';
		LINE= '<INPUT TYPE="hidden" NAME="_program" 	VALUE="links.LRStudyRpt.sas">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=_server    	VALUE="'||symget('_server')	   ||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=_port      	VALUE="'||symget('_port')	   ||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=_sessionid 	VALUE="'||symget('_sessionid') 	   ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=REPORT0 	VALUE="'||symget("REPORT0")	   ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=REPORT 	VALUE="'||symget("REPORT")	   ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=METHOD0 	VALUE="'||symget("METHOD0")	   ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=METHOD 	VALUE="'||symget("METHOD")	   ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=Screen 	VALUE="REPORTS">'; 			   PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=ReportName 	VALUE="BDT">'; 			   	   PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=ReportType 	VALUE="'||symget("ReportType")	   ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=DataType 	VALUE="'||symget("DataType")	   ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=StatusFlag 	VALUE="'||symget("StatusFlag")	   ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=FooterFlag 	VALUE="'||symget("FooterFlag")	   ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=DataStatus 	VALUE="'||symget("DataStatus")	   ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=OutType 	VALUE="'||symget("OutType")	   ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME="_debug" 	  VALUE="0">'; PUT LINE; 
	RUN;
	%LET TotalCnt=22;
	/* Add report and time variables from previous screens to form, count total variables */
	%DO I = 1 %TO &REPORT0;
		%LET J = %EVAL(&I * 10);
		%LET TotalCnt = %EVAL(&TotalCnt + 1);
		DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;
			LINE= '<INPUT TYPE="hidden" NAME=REPORT'||"&I"||' VALUE="'||symget("Report&I")	   ||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=TIME'||"&J"||'0 VALUE="'||"&&TIME&J.0"   ||'">'; PUT LINE; 
			%DO K = 1 %TO &&TIME&J.0;
				%LET JJ= %EVAL((&I * 100)+&K);
				%LET TotalCnt = %EVAL(&TotalCnt + 1);
				LINE= '<INPUT TYPE="hidden" NAME=TIME'||"&JJ"||' VALUE="'||"&&TIME&JJ"	   ||'">'; PUT LINE; 
			%END;
		RUN;
	%END;
	/* Add method variables from previous screens to form */
	%DO M = 1 %TO &METHOD0;
		%LET TotalCnt = %EVAL(&TotalCnt + 1);
		DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;
			LINE= '<INPUT TYPE="hidden" NAME=METHOD'||"&M"||' VALUE="'||symget("METHOD&M")	   ||'">'; PUT LINE; 
		RUN;
	%END;
	/* If user has made too many selections, execute overlimit macro */
	%LET TotalCnt = %EVAL(&TotalCnt + 5);
	%IF &TotalCnt > 120 %THEN %DO;	%OverLimit;	%END;
	%ELSE %DO;  /* Otherwise, generate screen */
	DATA _NULL_; LENGTH LINE ANCHOR $2000;
		FILE _WEBOUT;	/* Set up LINKS banner */
		PUT '<BODY BGCOLOR="#808080"><title>LINKS Stability Study Reports</title></BODY>';
		PUT '<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" border="1" bordercolor="#003366" cellpadding="0" cellspacing="0">';
		PUT '<TR ALIGN="LEFT" ><TD colspan=2 BGCOLOR="#003366">';
		PUT '<TABLE ALIGN=LEFT vALIGN=top height="100%" width="100%"><TR><TD ALIGN=LEFT><big><big><big>';
		LINE='<IMG src="//'||"&_server"||'/links/images/gsklogo1.gif" width="141" height="62">'; PUT LINE;
		PUT '<FONT FACE=ARIAL color="#FFFFFF"><em> LINKS </em> Stability Module</FONT></big></big></big></TD>';

		ANCHOR= '<TD ALIGN=RIGHT><A HREF="'|| "%SUPERQ(_THISSESSION)" ||
		'&_program=links.LRReport.sas"><FONT FACE=ARIAL color="#FFFFFF">Back to Stability Menu</FONT></A>';
	    PUT ANCHOR; 

		PUT '</TD></TR></TABLE></TD></TR>';

		PUT '<TR height="87%"><TD BGCOLOR="#ffffdd" nowrap   ALIGN="center" vALIGN="top">';
	RUN;

	%IF %SUPERQ(Report0)= %THEN %DO; * Only one selection made;
		%GLOBAL Report0 Report1;
		 DATA _NULL_; 
		    CALL SYMPUT('Report0',1);
		    CALL SYMPUT('Report1', SYMGET("Report"));
		 RUN;
	%END;
	%LET ReportList= ;  /* Create comma delimited list of reports */
	%DO i = 1 %TO &REPORT0;
		%LET ReportList=&ReportList  "&&Report&I";
		%IF &I < &REPORT0 %THEN %LET ReportList=&ReportList , ;
	%END;

	/* Create radio boxes */
	DATA DataBase;SET Save.LRQueryRes_DataBase;
		Report=TRIM(Stability_Study_Nbr_Cd)||'-'||TRIM(Stability_Samp_Stor_Cond);
		IF Report in (&ReportList);
	RUN;
	PROC SORT DATA=DataBase NODUPKEY;BY REPORT;RUN;
	DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;	
		PUT '<TABLE width="80%"><TR><TD colspan=2 ALIGN=LEFT></br><FONT face=arial color="#003366" SIZE=4><em><STRONG>Report characteristics:</br></em></STRONG></FONT></TD></TR><TR>';
		/* Create radio box for name of report */
		LINE= '<TD vALIGN=top ALIGN=LEFT colspan=2><FONT face=arial color="#003366" SIZE=3><em><STRONG></br>Manual Input Fields:</br></em></STRONG></FONT>'; PUT LINE;
	RUN;
	DATA _NULL_; FORMAT Stability_Samp_Stor_Cond $10.; FILE _WEBOUT;	SET DataBase;
		/* Create radio box for name of report */
		PUT 	
			'<u><b><big>' Stability_Study_Nbr_Cd   '</big></b></u>' ' - '
			'<u><b><big>' Stability_Samp_Stor_Cond '</big></b></u>' ' : '
			'</br>'
			'<input TYPE=text  NAME=ExpDate1 SIZE=19 VALUE="Enter Expire Date 1">'
			'<input TYPE=text  NAME=ExpDate2 SIZE=19 VALUE="Enter Expire Date 2">'
			'<input TYPE=text  NAME=MatlDesc SIZE=40 VALUE="Enter Material Description">'
			'</br>'
			;
	RUN;                                                                                                                                                                          
	DATA _NULL_; FILE _WEBOUT;
		PUT '</FONT></TD></TR>';
	RUN;

	DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;  /* Pass total variable count to next screen */
		LINE= '<INPUT TYPE="hidden" NAME=TotalCnt VALUE="'||"&TotalCnt"||'">'; PUT LINE; 
	RUN;
	/* Create submit button */
	DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;
  		LINE= '<TR><TD ALIGN=center></br>'; PUT LINE;
		PUT '</BR><INPUT TYPE=submit NAME=submit VALUE="Finish"';
		PUT ' STYLE="background-color: rgb(192,192,192); color: rgb(0,0,0); ';
		PUT ' FONT-SIZE: 11pt; FONT-family: Arial Bold; FONT-weight: bolder; ';
		PUT ' text-ALIGN: center; border: medium OUTSET; padding-TOp: 2px; padding-botTOm: 4px"></BR></BR>';
	RUN;
	/* Create LINKS footer banner */
	DATA _NULL_; LENGTH LINE ANCHOR $2000; FILE _WEBOUT;
		PUT '</FONT></TD></TR></FORM></TABLE></TD></TR>';
		PUT '<TR ALIGN=RIGHT ><TD BGCOLOR="#003366">';
	 	LINE = '<A HREF="//'||SYMGET('_server')||'/links/'||"&SAVE_linkshome"||'.ASP?UserRole='|| "%SUPERQ(Save_UserRole)" ||'">
		<FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Home</FONT></a>&nbsp&nbsp'; PUT line;
		ANCHOR= '&nbsp;&nbsp;<A HREF="'|| "%SUPERQ(_THISSESSION)" ||
				'&_program='||"LINKS.LRLogoff.sas"||
				'"><FONT FACE=ARIAL color="#FFFFFF">Log off</FONT></A>&nbsp;&nbsp;'; 
		PUT ANCHOR; 
		PUT '</TD></TR></TABLE>'; 
	RUN;
	%END;

%MEND BatchInput;

*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: See LINKS Report SOP REQUIREMENT: See LINKS Report SOP  *;
*   INPUT:            MACRO VARIABLES: METHOD0, METHOD, METHOD1,..METHOD#,    *;
*		      REPORT0, REPORT, REPORT1,...REPORT#, TIME10,...TIME##   *;
*		      REPORTYPE, DATATYPE, STATUSFLAG, OUTTYPE		      *;
*		      _SERVER, SAVE.LINKSHOME, _THISSESSION,                  *;
*		      _service, _port, _sessionid		              *;	
*		      FILE: GSK1LOGO1.GIF        			      *;		
*   PROCESSING:       Allows User To Input Their Custom Footer For Report     *;
*   OUTPUT:           1 HTML SCREEN TO WEB BROWSER	                      *;
*******************************************************************************;

%MACRO CustomFooter;

	DATA _NULL_; LENGTH LINE ANCHOR $2000;
		FILE _WEBOUT;	/* Set up LINKS banner */
		PUT '<BODY BGCOLOR="#808080"><title>LINKS Stability Study Reports</title></BODY>';
		PUT '<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" border="1" bordercolor="#003366" cellpadding="0" cellspacing="0">';
		PUT '<TR ALIGN="LEFT" ><TD colspan=2 BGCOLOR="#003366">';
		PUT '<TABLE ALIGN=LEFT vALIGN=top height="100%" width="100%"><TR><TD ALIGN=LEFT><big><big><big>';
		LINE='<IMG src="//'||"&_server"||'/links/images/gsklogo1.gif" width="141" height="62">'; PUT LINE;
		PUT '<FONT FACE=ARIAL color="#FFFFFF"><em> LINKS </em> Stability Module</FONT></big></big></big></TD>';
		ANCHOR= '<TD ALIGN=RIGHT><A HREF="'|| "%SUPERQ(_THISSESSION)" ||
		'&_program=links.LRReport.sas"><FONT FACE=ARIAL color="#FFFFFF">Back to Stability Menu</FONT></A>';
	    PUT ANCHOR; 
		PUT '</TD></TR></TABLE></TD></TR>';
		PUT '<TR height="87%"><TD BGCOLOR="#ffffdd" nowrap   ALIGN="center" vALIGN="top">';
	RUN;
	/* Setup form variables */
	DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;
		PUT   '<TABLE  ALIGN=center>';
		LINE= '<FORM  METHOD="'||"&FORMmethod"||'" ACTION="'||"&_url"||'" >'; 				   PUT LINE;
		PUT   '<INPUT TYPE="hidden" NAME="_service" VALUE="default">';
		LINE= '<INPUT TYPE="hidden" NAME="_program" VALUE="links.LRStudyRpt.sas">';        PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=_server    VALUE="'||symget('_server')	   ||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=_port      VALUE="'||symget('_port')	   ||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=_sessionid VALUE="'||symget('_sessionid') ||'">'; PUT LINE; 
		
		LINE= '<INPUT TYPE="hidden" NAME=ReportType VALUE="'||SYMGET('ReportType') ||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=DATATYPE   VALUE="'||SYMGET('DATATYPE')   ||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=DATASTATUS VALUE="'||SYMGET('DATASTATUS')   ||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=STATUSFLAG VALUE="'||SYMGET('STATUSFLAG') ||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME=OUTTYPE    VALUE="'||SYMGET('OUTTYPE')	   ||'">'; PUT LINE;
		
		LINE= '<INPUT TYPE="hidden" NAME=REPORT0    VALUE="'||symget("REPORT0")	   ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=REPORT'||' VALUE="'||symget("REPORT")	   ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=METHOD0    VALUE="'||symget("METHOD0")	   ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=METHOD'||' VALUE="'||symget("METHOD")	   ||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=SCREEN     VALUE="REPORTS">'; 					   PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME=FOOTERFLAG VALUE="CUSTOM2">'; 					   PUT LINE;
		PUT '<TABLE width="30%"><TR><TD colspan=2 ALIGN=LEFT></br><FONT face=arial color="#003366" SIZE=4><em><STRONG>Report footnotes:</br></em></STRONG></FONT></TD></TR><TR>';
	RUN;
	/* Add report and time variables from previous screens */
	%DO I = 1 %TO &REPORT0;
		%IF &I > 9 %THEN %LET J = %EVAL(&I + 90);
			       %ELSE %LET J = %EVAL(&I + 0);
		DATA _NULL_; LENGTH LINE $500; FILE _WEBOUT;
			LINE= '<INPUT TYPE="hidden" NAME=REPORT'||"&I"||' VALUE="'||symget("Report&I")	   ||'">'; PUT LINE; 
			LINE= '<INPUT TYPE="hidden" NAME=TIME'||"&J"||'0 VALUE="'||"&&TIME&J.0"   ||'">'; PUT LINE; 
			%DO K = 1 %TO &&TIME&J.0;
				LINE= '<INPUT TYPE="hidden" NAME=TIME'||"&J"||"&K"||' VALUE="'||"&&TIME&J.&K"	   ||'">'; PUT LINE; 
			%END;
		RUN;
	%END;
	/* Add test methods from previous screen */
	%DO M = 1 %TO &METHOD0;
		DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;
			LINE= '<INPUT TYPE="hidden" NAME=METHOD'||"&M"||' VALUE="'||symget("METHOD&M")	   ||'">'; PUT LINE; 
		RUN;
	%END;
	/* Generate text boxes for entering custom footnotes */
	DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;
		LINE= '<TD vALIGN=top ALIGN=LEFT><FONT face=arial color="#003366" SIZE=3><em><STRONG></br>Enter custom footnote(s):</em></STRONG></FONT>'; PUT LINE;
		PUT '</BR><FONT SIZE=2 face=arial>Footnote 1:<input TYPE=TEXT NAME=CUSTFOOT1 LENGTH=100>';
		PUT '</BR>Footnote 2:<input TYPE=TEXT NAME=CUSTFOOT2 LENGTH=100>';
		PUT '</BR>Footnote 3:<input TYPE=TEXT NAME=CUSTFOOT3 LENGTH=100></FONT></TD></TR>';		
	RUN;
	/* Create submit button */
	DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;
  		LINE= '<TR><TD ALIGN=center></br>'; PUT LINE;
		PUT '</BR><INPUT TYPE=submit NAME=submit VALUE="Finish"';
		PUT ' STYLE="background-color: rgb(192,192,192); color: rgb(0,0,0); ';
		PUT ' FONT-SIZE: 11pt; FONT-family: Arial Bold; FONT-weight: bolder; ';
		PUT ' text-ALIGN: center; border: medium OUTSET; padding-TOp: 2px; padding-botTOm: 4px"></BR></BR>';
	RUN;
	/* Create LINKS footer banner */
	DATA _NULL_; LENGTH LINE ANCHOR $2000; FILE _WEBOUT;
		PUT '</FONT></TD></TR></FORM></TABLE></TD></TR>';
		PUT '<TR ALIGN=RIGHT ><TD BGCOLOR="#003366">';
	 	LINE = '<A HREF="//'||SYMGET('_server')||'/links/'||"&SAVE_linkshome"||'.ASP?UserRole='|| "%SUPERQ(Save_UserRole)" ||'">
		<FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Home</FONT></a>&nbsp&nbsp'; PUT line;
		ANCHOR= '&nbsp;&nbsp;<A HREF="'|| "%SUPERQ(_THISSESSION)" ||
				'&_program='||"LINKS.LRLogoff.sas"||
				'"><FONT FACE=ARIAL color="#FFFFFF">Log off</FONT></A>&nbsp;&nbsp;'; 
		PUT ANCHOR; 
		PUT '</TD></TR></TABLE>'; 
	RUN;

%MEND CustomFooter;

*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: See LINKS Report SOP REQUIREMENT: See LINKS Report SOP  *;
*   INPUT:            MACRO VARIABLES: _SERVER, SAVE.LINKSHOME, _THISSESSION, *;
*		       _service, _port, _sessionid, STOP 	              *;
*		      FILE: GSK1LOGO1.GIF        			      *;
*   PROCESSING:       Called only if submit button was pressed with no        *;
*                     selection made                                          *;
*   OUTPUT:           1 HTML screen to web browser	                      *;
*******************************************************************************;

%MACRO Warning;

	DATA _NULL_; LENGTH LINE ANCHOR $2000;
		FILE _WEBOUT;	/* Set up LINKS banner */

		PUT '<BODY BGCOLOR="#808080"><title>LINKS Stability Study Reports</title></BODY>';
		PUT '<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" border="1" bordercolor="#003366" cellpadding="0" cellspacing="0">';
		PUT '<TR ALIGN="LEFT" ><TD colspan=2 BGCOLOR="#003366">';
		PUT '<TABLE ALIGN=LEFT vALIGN=top height="100%" width="100%"><TR><TD ALIGN=LEFT><big><big><big>';
		LINE='<IMG src="//'||"&_server"||'/links/images/gsklogo1.gif" width="141" height="62">'; PUT LINE;
		PUT '<FONT FACE=ARIAL color="#FFFFFF"><em> LINKS </em> Stability Module</FONT></big></big></big></TD>';

		ANCHOR= '<TD ALIGN=RIGHT><A HREF="'|| "%SUPERQ(_THISSESSION)" ||
		'&_program=links.LRReport.sas"><FONT FACE=ARIAL color="#FFFFFF">Back to Stability Menu</FONT></A>';
	    PUT ANCHOR; 
		PUT '</TD></TR></TABLE></TD></TR>';
		PUT '<TR height="87%"><TD BGCOLOR="#ffffdd" nowrap   ALIGN="center" vALIGN="top">';
	RUN;
	/* Generate HTML message depending on value of STOP */
	DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;
		PUT   '<TABLE width="60%" ALIGN=center>';
		PUT '<TABLE ><TR><TD ALIGN=LEFT></br><FONT face=arial color="#003366" SIZE=3>';
		PUT '</BR></BR></BR></BR><FONT FACE=ARIAL color="#FF0000"><P ALIGN=center><big><big><STRONG>';

		%IF %SUPERQ(STOP)=STUDYMESSAGE %THEN %DO;
			PUT 'At least one study must be selected to continue.';
        	PUT '</br>Please use your browsers back button to go back to make a selection.</STRONG></FONT>';     
		%END;
		%IF %SUPERQ(STOP)=REPORTMESSAGE %THEN %DO;
			PUT 'At least one Report must be selected to continue.';
        	PUT '</br>Please use your browsers back button to go back to make a selection.</STRONG></FONT>';     
		%END;
		%ELSE %IF %SUPERQ(STOP)=TIMEMESSAGE %THEN %DO;
			PUT 'At least one time point per Report must be selected to continue.';
        	PUT '</br>Please use your browsers back button to go back to make a selection.</STRONG></FONT>';     
		%END;  
		%ELSE %IF %SUPERQ(STOP)=METHODMESSAGE %THEN %DO;
			PUT 'At least test METHOD must be selected to continue.';
        	PUT '</br>Please use your browsers back button to go back to make a selection.</STRONG></FONT>';     
		%END;  
	RUN;
	/* Create LINKS footer banner */
	DATA _NULL_; LENGTH LINE ANCHOR $2000; FILE _WEBOUT;
		PUT '</TD></TR></TABLE></TD></TR>';
		PUT '<TR ALIGN=RIGHT ><TD BGCOLOR="#003366">';
	 	LINE = '<A HREF="//'||SYMGET('_server')||'/links/'||"&SAVE_linkshome"||'.ASP?UserRole='|| "%SUPERQ(Save_UserRole)" ||'">
		<FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Home</FONT></a>&nbsp&nbsp'; PUT line;
		ANCHOR= '&nbsp;&nbsp;<A HREF="'|| "%SUPERQ(_THISSESSION)" ||
				'&_program='||"LINKS.LRLogoff.sas"||
				'"><FONT FACE=ARIAL color="#FFFFFF">Log off</FONT></A>&nbsp;&nbsp;'; 
		PUT ANCHOR; 
		PUT '</TD></TR></TABLE>'; 
	RUN;

%MEND Warning;

*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: See LINKS Report SOP REQUIREMENT: See LINKS Report SOP  *;
*   INPUT:            MACRO VARIABLES: METHOD0, METHOD, METHOD1,..METHOD#,    *;
*		      REPORT0, REPORT, REPORT1,...REPORT#, TIME10,...TIME##   *;
*		      REPORTYPE, DATATYPE, STATUSFLAG, OUTTYPE		      *;
*		      _SERVER, SAVE.LINKSHOME, _THISSESSION,                  *;
*		       _service, _port, _sessionid		              *;	
*		      FILE: GSK1LOGO1.GIF        			      *;		
*   PROCESSING:       Uses selected criteria to create study report           *;
*   OUTPUT:           1 or more report tables to web or RTF file.             *;
*******************************************************************************;

%MACRO Reports;
%LET HighTime  = 0;
	%IF %SUPERQ(ReportName)=AST %THEN %DO; 
		%LET ReportType = SPEC; 
	%END;

	%IF %SUPERQ(Report0)= %THEN %DO; * Only one selection made;
		%GLOBAL Report0 Report1;
		 DATA _NULL_; 
		    CALL SYMPUT('Report0',1);
		    CALL SYMPUT('Report1', SYMGET("Report"));
		 RUN;
	%END;

	%IF %SUPERQ(METHOD0)= %THEN %DO; * Only one selection made;
		%GLOBAL METHOD0 METHOD1;
		 DATA _NULL_; 
		    CALL SYMPUT('METHOD0',1);
		    CALL SYMPUT('METHOD1', SYMGET("METHOD"));
		 RUN;
	%END;

	/* Generate comma delimited list of test methods */
	%LET METHODList= ;
	%DO M = 1 %TO &METHOD0;
		%LET METHODList = &METHODList "&&METHOD&M";
		%IF &M < &METHOD0 %THEN %LET METHODList = &METHODList , ;
	%END;
	
	OPTIONS ORIENTATION=LANDSCAPE ;
	%IF %SUPERQ(OutType)=RTF %THEN %DO; /* Setup RTF ODS statements */
		DATA _NULL_;
  			rc=appsrv_header('Content-disposition','attachment; FILENAME=LINKSSTUDYREPORT.rtf');
		RUN; 

		ODS PATH work.templat(update) sasuser.templat(read)
		sashelp.tmplmst(read);

	/* Define RTF file style */
		PROC TEMPLATE;
     		DEFINE STYLE styles.newrtf;
       		PARENT=styles.rtf;
       		REPLACE FONTS /
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
          
       		END;
   		RUN;

		ODS LISTING CLOSE;
		ODS RTF BODY=_WEBOUT style=styles.newrtf;
		ODS NOPROCTITLE;

		%LET Close=ODS RTF Close;
	%END;
	%ELSE %IF %SUPERQ(OutType)=PDF %THEN %DO; /* Setup PDF ODS statements */
		DATA _NULL_;
  			rc=appsrv_header('Content-disposition','attachment; FILENAME=LINKSSTUDYREPORT.pdf');
		RUN; 

		ODS PATH work.templat(update) sasuser.templat(read)
		sashelp.tmplmst(read);

	/* Define PDF file style */
		PROC TEMPLATE;
     		DEFINE STYLE styles.newpdf;
       		PARENT=styles.pdf;
       		REPLACE FONTS /
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
          
       		END;
   		RUN;

		ODS LISTING CLOSE;
		ODS PDF BODY=_WEBOUT style=styles.newrtf;
		ODS NOPROCTITLE;

		%LET Close=ODS PDF Close;
	%END;
	%ELSE %IF %SUPERQ(OutType)=HTML %THEN %DO; /* Setup HTML ODS statements */
		OPTIONS ORIENTATION=LANDSCAPE;
		
		DATA _NULL_; FILE _WEBOUT;  /* Create LINKS banner */
   	              	PUT '<BODY BGCOLOR="#808080"><TITLE>LINKS Stability Study Reports - Unofficial Report If Printed From Web Browser</TITLE></BODY>';
			PUT '<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" border="1" bordercolor="#003366" cellpadding="0" cellspacing="0">';
			PUT '<TR ALIGN="LEFT" ><TD colspan=2 BGCOLOR="#003366">';
			PUT '<TABLE ALIGN=LEFT vALIGN=top height="100%" width="100%"><TR><TD ALIGN=LEFT><big><big><big>';
			LINE='<IMG src="//'||"&_server"||'/links/images/gsklogo1.gif" width="141" height="62">'; PUT LINE;
			PUT '<FONT FACE=ARIAL color="#FFFFFF"><em> LINKS </em> Stability Module</FONT></big></big></big></TD>';

			ANCHOR= '<TD ALIGN=RIGHT><A HREF="'|| "%SUPERQ(_THISSESSION)" ||
			'&_program=links.LRReport.sas"><FONT FACE=ARIAL color="#FFFFFF">Back to Stability Menu</FONT></A>';
	    	PUT ANCHOR; 

			PUT '</TD></TR></TABLE></TD></TR><TR BGCOLOR="#FFFFDD"><TD>';
		RUN;

		ODS HTML BODY=_WEBOUT;
		%LET Close=ODS HTML Close;
		
	%END;

	%LOCAL j;
************************************************************************************;
		%LET ReportList= ;  /* Create comma delimited list of reports */
		%DO i = 1 %TO &REPORT0;
			%LET ReportList=&ReportList  "&&Report&I";
			%IF &I < &REPORT0 %THEN %LET ReportList=&ReportList , ;
		%END;

		/* Subset for selected reports, Setup Method variable */
	  	DATA STAB0; LENGTH METHOD $60. SpecType $15 REPORT $35; ; SET Save.LRQueryRes_DataBase;
			Study_Nbr=TRIM(LEFT(Matl_Nbr))||'-'||TRIM(LEFT(Batch_Nbr));
			Report=TRIM(Stability_Study_Nbr_Cd)||'-'||TRIM(Stability_Samp_Stor_Cond);
			IF Report in (&ReportList);
			/* Added v7 - Diskus and HFA have different Cascade summaries */
			IF PROD_NM =: 'Advair Diskus' and Indvl_Meth_Stage_Nm IN ('THROAT','PRESEPARATOR','0','1','2','3','4','5','6','7','FILTER') THEN DELETE;
			IF PROD_NM =: 'Advair HFA' and Indvl_Meth_Stage_Nm IN ('0','1','2','3','4','5','6','7','FILTER') THEN DELETE;
                        /* TODO when Relenza stab data is available */
/***			IF PROD_NM =: 'Relenza' and Indvl_Meth_Stage_Nm IN ('TMP','PRESEP-0','1','2','3','4','5') THEN DELETE;***/
			IF Indvl_Meth_Stage_Nm^='NONE' AND Meth_Peak_Nm^='NONE' THEN 
			METHOD=TRIM(Lab_Tst_Meth_Spec_Desc)||'-'||TRIM(Summary_Meth_Stage_Nm)||'-'||TRIM(Meth_Peak_Nm);
			ELSE IF Summary_Meth_Stage_Nm ='NONE' AND Meth_Peak_Nm^='NONE' THEN METHOD=TRIM(Lab_Tst_Meth_Spec_Desc)||'-'||TRIM(Meth_Peak_Nm);
			ELSE IF Summary_Meth_Stage_Nm^='NONE' AND Meth_Peak_Nm ='NONE' THEN METHOD=TRIM(Lab_Tst_Meth_Spec_Desc)||'-'||TRIM(Summary_Meth_Stage_Nm);
			ELSE METHOD=TRIM(Lab_Tst_Meth_Spec_Desc);
						
			IF TRIM(LAB_TST_METH_SPEC_DESC)= 'MDPI Microscopic Evaluation' THEN DO;
				IF TRIM(METH_PEAK_NM)='SHAPE' THEN
				METHOD=TRIM(Lab_Tst_Meth_Spec_Desc)||'-'||TRIM(Meth_PEAK_Nm)||'-'||TRIM(INDVL_TST_RSLT_NM);
				END;	
			
			METHOD2=UPCASE(COMPRESS(METHOD,'-'));
			REPORTTYPE="&REPORTTYPE";
			/* Added V3  */
			IF TRIM(LAB_TST_METH_SPEC_DESC)='MLT for MDPI Strips' THEN 
				INDVL_METH_STAGE_NM=SUMMARY_METH_STAGE_NM;
/***/			IF METH_SPEC_NM='AM0908STABCASCADEHPLC' THEN PUT SAMP_ID METHOD STABILITY_study_nbr_cd
				Indvl_Tst_Rslt_Val_Char Indvl_Tst_Rslt_Val_Num;
		Batch_Nbr_Desc=Matl_Desc;	
		********************************************************************************;
		/* Setup Spectype variable depending on report type*/
	    %IF %SUPERQ(ReportType)=MEANS %THEN %DO;
			SpecType='MEANS';
		%END;
	    %IF %SUPERQ(ReportType)=IND   %THEN %DO;
			SpecType='INDIV';
		%END;
	    %IF %SUPERQ(ReportType)=BOTH  %THEN %DO;
			SpecType='BOTH ';
		%END;
	    %IF %SUPERQ(ReportType)=SPEC  %THEN %DO;
			SpecType='SPEC ';
		%END;

		%IF %SUPERQ(DATASTATUS)=APP %THEN %DO;  /* Include only approved data */
		   WHERE SAMP_STATUS >= '16';
	   %END;

	   
put 'check327 ' report method  prod_nm prod_grp Indvl_Tst_Rslt_Val_Num STABILITY_SAMP_TIME_POINT lab_tst_desc pks_format;
		RUN;

		
		DATA _NULL_;  SET STAB0;
		%GLOBAL UNAPPFLAG;
		   IF SAMP_STATUS < '16' THEN CALL SYMPUT('UNAPPFLAG','YES');
		RUN;

		PROC SORT DATA=STAB0 NODUPKEY OUT=PRODUCTS(KEEP=STABILITY_SAMP_PRODUCT REPORT); BY STABILITY_SAMP_PRODUCT REPORT; RUN;  

		%DO I=1 %TO &REPORT0;
			DATA _NULL_; SET PRODUCTS;
				WHERE REPORT="&&REPORT&I";
				CALL SYMPUT("PRODUCT&I",STABILITY_SAMP_PRODUCT);
			RUN;
			%END;
			

		LIBNAME META "&CtlDir.METADATA";

		DATA SPEC_OUT0; SET META.LINKS_Spec_File(where=(spec_group='STABILITY'));
		Stability_Samp_Spec_Nm=TRIM(LEFT(txt_limit_a))||TRim(left(txt_limit_b))||TRim(left(txt_limit_c));
		IF STABILITY_SAMP_SPEC_NM='' THEN DELETE;
		PUT 'look 1408 ' STABILITY_SAMP_PRODUCT REG_METH_NAME SPEC_TYPE Stability_Samp_Spec_Nm INDVL_METH_STAGE_NM;
		RUN;
			
		PROC SORT DATA=SPEC_OUT0 NODUPKEY ; 	BY Stability_Samp_Product REG_METH_NAME SPEC_TYPE STABILITY_SAMP_SPEC_NM; RUN;


		/* Combine specifications if more than one spec per test result type */
		DATA Spec_Out; LENGTH METHOD METHOD2 $200. Spec $1000.; SET SPEC_OUT0;
		BY Stability_Samp_Product REG_METH_NAME SPEC_TYPE INDVL_METH_STAGE_NM;
			RETAIN TEST Spec Obs;
			IF FIRST.REG_METH_NAME AND FIRST.SPEC_TYPE THEN Obs=1; 
				 ELSE Obs=Obs+1; 
			*IF FIRST.REG_METH_NAME AND FIRST.SPEC_TYPE THEN Spec=TRIM(LEFT(Stability_Samp_Spec_Nm));
				 *ELSE Spec=TRIM(Spec) ||', '||TRIM(LEFT(Stability_Samp_Spec_Nm));
			Spec=TRIM(LEFT(Stability_Samp_Spec_Nm));
			
			IF LAG(REG_METH_NAME)=REG_METH_NAME AND LAG(SPEC)=SPEC THEN SPEC='';
			

			TYPE=SPEC_TYPE;
			CHECK=LAG(SPEC);

			IF LAST.SPEC_TYPE THEN DO;
				IF Indvl_Meth_Stage_Nm^='NONE' AND Meth_Peak_Nm^='NONE' THEN 
				METHOD=TRIM(Lab_Tst_Meth_Spec_Desc)||'-'||TRIM(Indvl_Meth_Stage_Nm)||'-'||TRIM(Meth_Peak_Nm);
				ELSE IF Indvl_Meth_Stage_Nm ='NONE' AND Meth_Peak_Nm^='NONE' THEN METHOD=TRIM(Lab_Tst_Meth_Spec_Desc)||'-'||TRIM(Meth_Peak_Nm);
				ELSE IF Indvl_Meth_Stage_Nm^='NONE' AND Meth_Peak_Nm ='NONE' THEN METHOD=TRIM(Lab_Tst_Meth_Spec_Desc)||'-'||TRIM(Indvl_Meth_Stage_Nm);
				ELSE  METHOD=TRIM(Lab_Tst_Meth_Spec_Desc);
				METHOD2=UPCASE(COMPRESS(METHOD,'-'));
		*Added V3;  	*IF TRIM(LAB_TST_METH_SPEC_DESC) = 'MDPI Microscopic Evaluation' AND METH_PEAK_NM='SHAPE' THEN OUTPUT MICROEVAL;
				*ELSE OUTPUT Spec_Out; 
/***file 'd:/sql_loader/bobtest.log';;put '!!!';put _all_;;file LOG;***/
                        END;	
		RUN;

                /* Added V9 - added Indvl_Meth_Stage_Nm to avoid skipping "Content per Canister" */
		PROC SORT DATA=STAB0 NODUPKEY;
	     BY stability_samp_stor_cond stability_study_nbr_cd stability_samp_time_val 
             Indvl_tst_rslt_device  LAB_TST_METH  samp_STATUS  
             Indvl_tst_rslt_val_char samp_tst_dt STABILITY_SAMP_PRODUCT
             stability_study_purpose_txt res_id indvl_tst_rslt_row Indvl_tst_rslt_nm METH_VAR_NM INDVL_METH_STAGE_NM;
		RUN;
/***data _null_;set stab0;file 'd:/sql_loader/bobtest2.log';;put '!!!';put _all_;;file LOG;run;***/

				
		********************************************************************************;
		/* Setup precision of results based on DATATYPE, subset for only selected methods */
		DATA INDIVSTAB; LENGTH ResultN 8 ResultC0 $200 ; SET STAB0; 
			Report=TRIM(Stability_Study_Nbr_Cd)||'-'||TRIM(Stability_Samp_Stor_Cond);
			IF COMPRESS(Indvl_Meth_Stage_Nm,'-')=COMPRESS(Summary_Meth_Stage_Nm,'-');
			IF UPCASE(COMPRESS(Lab_Tst_Meth_Spec_Desc)) IN ('HPLCASSAYADVAIRMDPIBLENDS','ADVAIRCONTENTPERBLISTER','CUOFEMITTEDDOSEINADVAIRMDPI') THEN DO;
				ResultN=LEFT(Indvl_Tst_Rslt_Val_Unit);                                                       
				ResultC0=LEFT(Indvl_Tst_Rslt_Val_Unit);                                                       
			END;
		  
			ELSE DO;
				ResultN=LEFT(Indvl_Tst_Rslt_Val_Num);
				ResultC0=LEFT(Indvl_Tst_Rslt_Val_Num);
			END;
			DataChk="&DATATYPE";
			IF DataChk='DATA1' THEN PKS_Format2=PKS_Format + 1;
			ELSE IF DataChk='DATA2' THEN PKS_Format2=PKS_Format + 2;
			ELSE PKS_Format2=PKS_Format; 
/***/			IF trim(Lab_Tst_Meth_Spec_Desc) IN (&METHODList);	

			If Indvl_Tst_Rslt_Val_Char = 'NPI' then do; resultn=0; resultc0=''; pks_format=.; pks_format2=.; end;

			IF METH_SPEC_NM='AM0908STABCASCADEHPLC' THEN PUT SAMP_ID METHOD STABILITY_study_nbr_cd PKS_FORMAT2 
				ResultN RESULTC0 Indvl_Tst_Rslt_Val_Char Indvl_Tst_Rslt_Val_Num;
PUT 'look345 '  Prod_Nm Prod_Grp METHOD STABILITY_study_nbr_cd  Indvl_Tst_Rslt_Val_Num Indvl_Tst_Rslt_Val_Char PKS_FORMAT PKS_FORMAT2;
		
		RUN;

		PROC SORT DATA=INDIVSTAB; BY REPORT DESCENDING STABILITY_SAMP_TIME_POINT ; RUN;

		DATA INDIVSTAB; LENGTH STUDYCOMP $20; SET INDIVSTAB;
			BY REPORT ;
			RETAIN STUDYCOMP ;
			IF FIRST.REPORT THEN DO;
			  IF STABILITY_STUDY_MAX_TP = STABILITY_SAMP_TIME_POINT THEN STUDYCOMP='Study Complete';
			  ELSE STUDYCOMP='Study Ongoing';
			END;
PUT 'maxcheck: ' PRod_Nm PRod_Grp REPORT STABILITY_STUDY_MAX_TP  STABILITY_SAMP_TIME_POINT STUDYCOMP;
		RUN; 

		PROC DATASETS NODETAILS NOLIST;
			DELETE STAB0 SPEC0 ;  /* Delete datasets */
		RUN;

		/* Create unique list of time points (in weeks) */
		PROC SORT DATA=INDIVSTAB OUT=TIMEOUT2 NODUPKEY;  BY Stability_Samp_Time_Weeks;  RUN;

		%LOCAL r;
		%GLOBAL time_list;
		* Check to see if user selected all available time points for a specified report;
		DATA TIMEOUT2;	SET TIMEOUT2;    		
			IF Stability_Samp_Time_Weeks='0' THEN DELETE;  * Delete initial time point ;
		RUN;

		%LET TIMECHK=STOP;
		DATA _NULL_; SET TIMEOUT2;
			CALL SYMPUT('TIMECHK', 'GO');
		RUN;

		DATA _NULL_;	* Set time1 macro to 0 to ensure initial always exists;
	   		CALL SYMPUT("Time1", "0");
			CALL SYMPUT("MAXOBS", 0);
		RUN;	

		%IF %SUPERQ(TIMECHK)=GO %THEN %DO;
		DATA TIMEOUT2;SET TIMEOUT2 NOBS=MaxObs;   * Count number of time points ; 		
			RETAIN NumObs 0;
			IF _N_ = 1 THEN NumObs+1;
	    	NumObs+1; 
        	CALL SYMPUT('MaxObs', MaxObs);
			PUT 'LOOK ' report Stability_Samp_Time_Weeks MAXOBS;
		RUN;

		%DO r = 2 %TO &MaxObs+1;  * Create macros for remaining time points;
			DATA _NULL_;  SET TIMEOUT2;
				WHERE NumObs=&r;	   
	   			CALL SYMPUT("Time&r", Stability_Samp_Time_Weeks);
	   		RUN;
		%END;
		%END;
%put _all_;
		%LET TIMELIST= ;	* Create comma delimited list of all time points;
		%DO R = 1 %TO &MaxObs+1;
			%LET TIMELIST  = &TIMELIST &&Time&R;
			%IF &R < %EVAL(&MaxObs+1) %THEN %LET TIMELIST = &TIMELIST , ;
		%END;  

		%LET REPORTCHKLIST= ; %LET WARNINGFLAG= ;
		%DO R= 1 %TO &REPORT0;
		        %LET S = %EVAL(&R * 10);
		        %LET SS= %EVAL(&R * 100);
			%LET TIMELIST&R= ;  
			%DO T = 1 %TO &&TIME&SS;
			    %LET ST= %EVAL((&R * 100)+&T);
				%LET TIMELIST&R = &&TIMELIST&R &&TIME&ST;
				%IF &T < &&TIME&SS %THEN %LET TIMELIST&R= &TIMELIST&R , ;
			%END; 

			DATA TIMESUB&R; SET INDIVSTAB;  /* Subset for selected time points */
				WHERE REPORT IN ("&&REPORT&R") AND Stability_Samp_Time_Weeks IN (&&TIMELIST&R);
			RUN;

			DATA INDIVCHK&R; SET INDIVSTAB;
				WHERE REPORT IN ("&&REPORT&R");
			RUN;

			PROC SORT DATA=INDIVCHK&R NODUPKEY OUT=ALLTIMES&R;   BY REPORT Stability_Samp_Time_Weeks; RUN;
			PROC SORT DATA=TIMESUB&R NODUPKEY OUT=SUBSETTIMES&R; BY REPORT Stability_Samp_Time_Weeks; RUN;

			DATA _NULL_; SET ALLTIMES&R NOBS=NUMALLTIMES;  /* Count all time points in entire dataset */
				CALL SYMPUT("NUMALLTIMES&r",NUMALLTIMES);
			RUN;

			DATA _NULL_; SET SUBSETTIMES&R NOBS=SUBALLTIMES;  /* Count all time points in subsetted dataset */
				CALL SYMPUT("SUBALLTIMES&R",SUBALLTIMES);
			RUN;
%PUT _ALL_;			
			/* If user did not select all time point for a report, setup warning variable */
			%IF %SUPERQ(NUMALLTIMES&R)^=&&SUBALLTIMES&R %THEN %DO;
				%LET WARNINGFLAG=YES;
				%IF %SUPERQ(REPORTCHKLIST)= %THEN %LET REPORTCHKLIST=&REPORTCHKLIST &&REPORT&R;
							    %ELSE %LET REPORTCHKLIST=&REPORTCHKLIST , &&REPORT&R;
			%END;
		%END;

		%IF %SUPERQ(WARNINGFLAG)=YES %THEN 
			%LET WARNING=footnote1 J=L H=1 F=ARIAL "Note: This output represents a subset of the stability time points for &reportchklist .";
			%ELSE %LET WARNING= *;
				
		**********************************************;
		***** INDIVIDUAL AND MEANS CALCULATIONS ******;
		**********************************************;
	
		/* Setup Individual results */
		%IF %SUPERQ(REPORTTYPE)=SPEC %THEN %DO;
			DATA STABINIT0; SET INDIVSTAB;
			IF UPCASE(METHOD) IN ("HPLC RELATED IMP. IN ADVAIR MDPI-UNSPECIFIED-FLUTICASONE", "HPLC RELATED IMP. IN ADVAIR MDPI-UNSPECIFIED-SALMETEROL")
			AND INDVL_TST_RSLT_NM^='' THEN DELETE;
PUT 'look342 '  Prod_Nm Prod_Grp METHOD STABILITY_study_nbr_cd  Indvl_Tst_Rslt_Val_Num Indvl_Tst_Rslt_Val_Char;
		
			RUN;
		%END;
		%ELSE %DO;
			DATA STABINIT0; LENGTH METHOD $200; SET INDIVSTAB;
				IF UPCASE(METHOD) IN ("HPLC RELATED IMP. IN ADVAIR MDPI-UNSPECIFIED-FLUTICASONE", "HPLC RELATED IMP. IN ADVAIR MDPI-UNSPECIFIED-SALMETEROL")
				AND INDVL_TST_RSLT_NM^='' THEN METHOD = TRIM(Lab_Tst_Meth_Spec_Desc)||'-'||'Unspecified'||'-'||TRIM(LEFT(METH_PEAK_NM))||'-'||TRIM(LEFT(INDVL_TST_RSLT_NM));
			RUN;
		%END;
		
		DATA STABINIT1; SET STABINIT0 ;   /* Setup results to given level of precision */
			IF INDEXC(METHOD,'-')>0 THEN METHODCHK=TRIM(SUBSTR(METHOD, 1, INDEXC(METHOD,'-')-1));
			                        ELSE METHODCHK=TRIM(SUBSTR(METHOD, 1));
			REPORTTYPECHK="&REPORTTYPE";
			IF REPORTTYPECHK='SPEC' THEN DO;   /* Modified V6 */
				IF UPCASE(METHODCHK) IN ("HPLC RELATED IMP. IN ADVAIR MDPI") AND RESULTN < 0.05 THEN  DO;
				*RESULTN=0; RESULTC0="<0.05";
				END;
				IF UPCASE(METHODCHK) IN ("HPLC RELATED IMP. IN ADVAIR MDPI") AND RESULTN >= 0.05 THEN  DO;
						SELECT;
	 					WHEN (PKS_Format2='0') ResultC0=LEFT(SUBSTR(LEFT(PUT(ROUND(ResultN,1),8.0)),1));
						WHEN (PKS_Format2='1') ResultC0=LEFT(SUBSTR(LEFT(PUT(ROUND(ResultN,.1),8.1)),1));
						WHEN (PKS_Format2='2') ResultC0=LEFT(SUBSTR(LEFT(PUT(ROUND(ResultN,.01),8.2)),1));
						WHEN (PKS_Format2='3') ResultC0=LEFT(SUBSTR(LEFT(PUT(ROUND(ResultN,.001),8.3)),1));
						OTHERWISE              ResultC0=LEFT(SUBSTR(LEFT(PUT(ROUND(ResultN,.1),8.1)),1));
						END;
				END;
				ELSE IF UPCASE(METHODCHK) IN ("IMPURITIES") THEN DO;
			   		IF UPCASE(COMPRESS(PROD_NM)) IN ('AGENERASECAPSULES') AND RESULTN <0.03 THEN DO;
						RESULTN=0; RESULTC0="<0.03"; END;
			   		ELSE IF UPCASE(COMPRESS(PROD_NM)) IN ('AGENERASECAPSULES') AND RESULTN >=0.03 and resultn <0.05
						THEN ResultC0=LEFT(SUBSTR(LEFT(PUT(ROUND(ResultN,.01),8.2)),1));
			  		ELSE IF UPCASE(COMPRESS(PROD_NM)) IN ('AMERGETABLETS') AND RESULTN <0.05 THEN DO;
						RESULTC0="<0.05";  RESULTN=0; END;
			   		ELSE IF UPCASE(COMPRESS(PROD_NM)) IN ('ZOVIRAXTABLETS', 
												'ZOVIRAXCAPSULES',
												'IMITREXTABLETS',
												'IMITREXFDTTABLETS',
												'LAMICTALTABLETS',
												'LAMICTALCDTABLETS',
												'LAMICTALXRTABLETS',
												'RETROVIRTABLETS',
												'RETROVIRCAPSULES',
												'TRIZIVIRTABLETS',
												'LANOXINTABLETS',
												'ZIAGENTABLETS',
												'LOTRONEXTABLETS',
												'VALTREXTABLETS',
												'ZOFRANTABLETS',
												'VENTOLINHFA') AND RESULTN <0.05 THEN DO;
						RESULTN=0; RESULTC0="<0.05"; END;
					ELSE IF UPCASE(COMPRESS(PROD_NM)) IN ('BUPROPIONHCLSRTABLETS',
												'WELLBUTRINSRTABLETS',
												'WATSONHCLSRTABLETS',
												'ZYBANSRTABLETS') 
						AND UPCASE(METH_PEAK_NM) IN ('827U76') AND RESULTN <0.01 THEN DO; 
						RESULTN=0; RESULTC0="<0.01"; END;
					ELSE IF UPCASE(COMPRESS(PROD_NM)) IN ('BUPROPIONHCLSRTABLETS',
												'WELLBUTRINSRTABLETS',
												'WATSONHCLSRTABLETS',
												'ZYBANSRTABLETS') AND resultn <0.05 THEN DO;
						RESULTN=0; RESULTC0="<0.05";
						END;
					ELSE IF UPCASE(COMPRESS(PROD_NM)) IN ('COMBIVIRTABLETS', 'EPIVIRTABLETS') AND RESULTN <0.01 THEN DO;
						RESULTN=0; RESULTC0="<0.01"; END;
					
			   		ELSE IF UPCASE(COMPRESS(PROD_NM)) IN ('COMBIVIRTABLETS', 'EPIVIRTABLETS') AND RESULTN >=0.01 and resultn <0.05
						THEN ResultC0=LEFT(SUBSTR(LEFT(PUT(ROUND(ResultN,.01),8.2)),1));
					ELSE DO;
							SELECT;
	 							WHEN (PKS_Format2='0') ResultC0=LEFT(SUBSTR(LEFT(PUT(ROUND(ResultN,1),8.0)),1));
								WHEN (PKS_Format2='1') ResultC0=LEFT(SUBSTR(LEFT(PUT(ROUND(ResultN,.1),8.1)),1));
								WHEN (PKS_Format2='2') ResultC0=LEFT(SUBSTR(LEFT(PUT(ROUND(ResultN,.01),8.2)),1));
								WHEN (PKS_Format2='3') ResultC0=LEFT(SUBSTR(LEFT(PUT(ROUND(ResultN,.001),8.3)),1));
								OTHERWISE              ResultC0=LEFT(SUBSTR(LEFT(PUT(ROUND(ResultN,.1),8.1)),1));
						END;
					END; 
				END;
			END; 
			IF REPORTTYPECHK IN ('IND','BOTH') THEN DO;
					SELECT;
	 					WHEN (PKS_Format2='0') ResultC0=LEFT(SUBSTR(LEFT(PUT(ROUND(ResultN,1),8.0)),1));
						WHEN (PKS_Format2='1') ResultC0=LEFT(SUBSTR(LEFT(PUT(ROUND(ResultN,.1),8.1)),1));
						WHEN (PKS_Format2='2') ResultC0=LEFT(SUBSTR(LEFT(PUT(ROUND(ResultN,.01),8.2)),1));
						WHEN (PKS_Format2='3') ResultC0=LEFT(SUBSTR(LEFT(PUT(ROUND(ResultN,.001),8.3)),1));
						OTHERWISE              ResultC0=LEFT(SUBSTR(LEFT(PUT(ROUND(ResultN,.1),8.1)),1));
					END;
			END; 

			IF UPCASE(METHODCHK) NOT IN ("HPLC RELATED IMP. IN ADVAIR MDPI", "IMPURITIES") THEN DO;
				SELECT;
	 				WHEN (PKS_Format2='0') ResultC0=LEFT(SUBSTR(LEFT(PUT(ROUND(ResultN,1),8.0)),1));
					WHEN (PKS_Format2='1') ResultC0=LEFT(SUBSTR(LEFT(PUT(ROUND(ResultN,.1),8.1)),1));
					WHEN (PKS_Format2='2') ResultC0=LEFT(SUBSTR(LEFT(PUT(ROUND(ResultN,.01),8.2)),1));
					WHEN (PKS_Format2='3') ResultC0=LEFT(SUBSTR(LEFT(PUT(ROUND(ResultN,.001),8.3)),1));
					OTHERWISE              ResultC0=LEFT(SUBSTR(LEFT(PUT(ROUND(ResultN,.1),8.1)),1));
				END;  
			END;
			


			IF /* ResultC0=. AND */ Indvl_Tst_Rslt_Val_Char NOT IN (' ') 
				THEN do;  ResultC0=Indvl_Tst_Rslt_Val_Char;   end;
			IF METH_SPEC_NM='AM0908STABCASCADEHPLC' THEN PUT SAMP_ID METHOD STABILITY_study_nbr_cd PKS_FORMAT2 
				ResultN RESULTC0 Indvl_Tst_Rslt_Val_Char;
PUT 'look338 ' prod_nm prod_grp method resultc0 resultn REPORTTYPECHK PKS_Format2;
		RUN;

		PROC SORT DATA=STABINIT1;
		BY REPORT Stability_Study_Nbr_Cd Stability_Samp_Stor_Cond METHOD ASSY_BATCH Matl_Mfg_Dt Stability_Samp_Time_Weeks /* ResultC0 */; 
		RUN;

		/* Create comma delimited list of results by time point */
		DATA STABINIT;  LENGTH ResultC $200 TYPE $15; SET STABINIT1; 
			BY REPORT Stability_Study_Nbr_Cd Stability_Samp_Stor_Cond METHOD ASSY_BATCH Matl_Mfg_Dt Stability_Samp_Time_Weeks;
			RETAIN ResultC;
			IF FIRST.Stability_Samp_Time_Weeks THEN DO;Obs=1;Time_Weeks_Cnt=0;END;
		                                           ELSE DO;Obs+1;END;
			IF METHOD='SIO MDPI Blends' THEN DO;Obs=1;Time_Weeks_Cnt=0;END;
			Time_Weeks_Cnt+1;
			IF Obs=1 THEN DO;
		   		ResultC=TRIM(LEFT(ResultC0)); put obs resultc;
			END;
			ELSE DO;
		   		ResultC=TRIM(ResultC) ||', '||TRIM(LEFT(ResultC0)); put obs resultc;
			END;
			IF last.Stability_Samp_Time_Weeks THEN DO;
				if indexc(COMPRESS(UPCASE(RESULTC)),'ABCDEFGHIJKLMNOPQRSTUVWXYZ') > 0 THEN TYPE='CHAR';
				ELSE Type='INDIVIDUAL';
put 'look331 ' prod_nm prod_grp REPORT Stability_Study_Nbr_Cd Stability_Samp_Stor_Cond METHOD ASSY_BATCH Matl_Mfg_Dt Stability_Samp_Time_Weeks obs ResultC;
				OUTPUT STABINIT;
			END;
			
		RUN;

		PROC SORT DATA=STABINIT; 
		BY REPORT Prod_Nm Prod_Grp Stability_Samp_Product Stability_Study_Nbr_Cd Stability_Samp_Stor_Cond METHOD ASSY_BATCH Matl_Mfg_Dt SpecType TYPE ; RUN;
		/* Transpose the data so that time points are horizontal */
		PROC TRANSPOSE DATA=STABINIT OUT=INDOUT;
	   		VAR ResultC;
	   		BY REPORT Prod_Nm Prod_Grp Stability_Samp_Product Stability_Study_Nbr_Cd Stability_Samp_Stor_Cond METHOD ASSY_BATCH Matl_Mfg_Dt SpecType TYPE 
			batch_nbr fill_batch assy_desc fill_desc assy_mfg_dt fill_mfg_dt blend_mfg_dt Pkg_mfg_dt Storage_dt studycomp;
	   		ID Stability_Samp_Time_Weeks ;
			COPY Time_Weeks_Cnt;
		RUN;
DATA _NULL_;SET INDOUT;
	PUT _ALL_;
RUN;
		

		/* Setup Means results */

		DATA MEANS; LENGTH METHOD $200; SET INDIVSTAB;
		/* Added V2 */
		IF TRIM(method) in ('MDPI Microscopic Evaluation-SHAPE-AGGLOMERATES','MDPI Microscopic Evaluation-SHAPE-INDIVIDUALS') then delete;
		IF UPCASE(METHOD) IN ("HPLC RELATED IMP. IN ADVAIR MDPI-UNSPECIFIED-FLUTICASONE", "HPLC RELATED IMP. IN ADVAIR MDPI-UNSPECIFIED-SALMETEROL")
			AND INDVL_TST_RSLT_NM^='' THEN METHOD = TRIM(Lab_Tst_Meth_Spec_Desc)||'-'||'Unspecified'||'-'||TRIM(LEFT(METH_PEAK_NM))||'-'||TRIM(LEFT(INDVL_TST_RSLT_NM));
			
		RUN;
		
		PROC SORT DATA=MEANS; 
		BY METHOD Prod_Nm Prod_Grp Stability_Samp_Product METH_PEAK_NM Stability_Samp_Stor_Cond ASSY_BATCH Matl_Mfg_Dt SpecType Stability_Study_Nbr_Cd Stability_Samp_Time_Weeks /*Indvl_Tst_Rslt_Val_Char Meth_Rslt_Char Meth_Rslt_Numeric*/; 
		RUN;

		PROC SUMMARY DATA=MEANS;  /* Calculate mean summary stats */
			VAR ResultN;
			BY METHOD Prod_Nm Prod_Grp Stability_Samp_Product METH_PEAK_NM Stability_Samp_Stor_Cond ASSY_BATCH Matl_Mfg_Dt SpecType Stability_Study_Nbr_Cd Stability_Samp_Time_Weeks ;
			ID studycomp REPORT PKS_Format2 Indvl_Tst_Rslt_Val_Char Meth_Rslt_Char Meth_Rslt_Numeric batch_nbr fill_batch assy_desc fill_desc assy_mfg_dt fill_mfg_dt blend_mfg_dt Pkg_mfg_dt Storage_dt;
			WHERE ResultN ^=. ;
			OUTPUT OUT=STABMEAN(DROP=_TYPE_ _freq_) Mean=Mean;
		RUN;

		DATA STABMEAN; LENGTH Type $12 Meanc $200; SET STABMEAN; 
			BY METHOD Prod_Nm Prod_Grp Stability_Samp_Product Stability_Samp_Stor_Cond ASSY_BATCH Matl_Mfg_Dt SpecType Stability_Study_Nbr_Cd Stability_Samp_Time_Weeks;
			RETAIN Obs -1;
			IF FIRST.Stability_Samp_Time_Weeks THEN DO;Obs=-1;   Time_Weeks_Cnt=0;END; 
			                                   ELSE DO;Obs=Obs-1;END; 
			Time_Weeks_Cnt+1;
			TYPE='MEAN';  
			IF INDEXC(METHOD,'-')>0 THEN METHODCHK=TRIM(SUBSTR(METHOD, 1, INDEXC(METHOD,'-')-1));
			                        ELSE METHODCHK=TRIM(SUBSTR(METHOD, 1));
			REPORTTYPECHK="&REPORTTYPE";
			IF REPORTTYPECHK='SPEC' THEN DO;   /* Modified V6 */
				IF UPCASE(METHODCHK) IN ("HPLC RELATED IMP. IN ADVAIR MDPI") AND MEAN < 0.05 THEN  DO;
				*MEAN=0; MEANC="_<0.05_";
				END;
				IF UPCASE(METHODCHK) IN ("HPLC RELATED IMP. IN ADVAIR MDPI") AND MEAN >= 0.05 THEN  DO;
						SELECT;
	 					WHEN (PKS_Format2='0') MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,1),8.0)),1));
						WHEN (PKS_Format2='1') MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.1),8.1)),1));
						WHEN (PKS_Format2='2') MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.01),8.2)),1));
						WHEN (PKS_Format2='3') MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.001),8.3)),1));
						OTHERWISE              MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.1),8.1)),1));
						END;
				END;
				ELSE IF UPCASE(METHODCHK) IN ("IMPURITIES") THEN DO;
			   		IF UPCASE(COMPRESS(PROD_NM)) IN ('AGENERASECAPSULES') AND MEAN <0.03 THEN DO;
						MEAN=0; MEANC="<0.03"; END;
			   		ELSE IF UPCASE(COMPRESS(PROD_NM)) IN ('AGENERASECAPSULES') AND MEAN >=0.03 and MEAN <0.05
						THEN MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.01),8.2)),1));
			  		ELSE IF UPCASE(COMPRESS(PROD_NM)) IN ('AMERGETABLETS') AND MEAN <0.05 THEN DO;
						MEANC="<0.05";  MEAN=0; END;
			   		ELSE IF UPCASE(COMPRESS(PROD_NM)) IN ('ZOVIRAXTABLETS', 
												'ZOVIRAXCAPSULES',
												'IMITREXTABLETS',
												'IMITREXFDTTABLETS',
												'LAMICTALTABLETS',
												'LAMICTALCDTABLETS',
												'LAMICTALXRTABLETS',
												'RETROVIRTABLETS',
												'RETROVIRCAPSULES',
												'TRIZIVIRTABLETS',
												'LANOXINTABLETS',
												'ZIAGENTABLETS',
												'LOTRONEXTABLETS',
												'VALTREXTABLETS',
												'ZOFRANTABLETS',
												'VENTOLINHFA') AND MEAN <0.05 THEN DO;
						MEAN=0; MEANC="<0.05"; END;
					ELSE IF UPCASE(COMPRESS(PROD_NM)) IN ('BUPROPIONHCLSRTABLETS',
												'WELLBUTRINSRTABLETS',
												'WATSONHCLSRTABLETS',
												'ZYBANSRTABLETS') 
						AND UPCASE(METH_PEAK_NM) IN ('827U76') AND MEAN <0.01 THEN DO; 
						MEAN=0; MEANC="<0.01"; END;
					ELSE IF UPCASE(COMPRESS(PROD_NM)) IN ('BUPROPIONHCLSRTABLETS',
												'WELLBUTRINSRTABLETS',
												'WATSONHCLSRTABLETS',
												'ZYBANSRTABLETS') AND MEAN <0.05 THEN DO;
						MEAN=0; MEANC="<0.05";
						END;
					ELSE IF UPCASE(COMPRESS(PROD_NM)) IN ('COMBIVIRTABLETS', 'EPIVIRTABLETS') AND MEAN <0.01 THEN DO;
						MEAN=0; MEANC="<0.01"; END;
					
					ELSE DO;
						SELECT;
	 					WHEN (PKS_Format2='0') MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,1),8.0)),1));
						WHEN (PKS_Format2='1') MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.1),8.1)),1));
						WHEN (PKS_Format2='2') MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.01),8.2)),1));
						WHEN (PKS_Format2='3') MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.001),8.3)),1));
						OTHERWISE              MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.1),8.1)),1));
						END;
					END; 
				END;	
			END; 
/***
			ELSE DO;
				SELECT;
	 				WHEN (PKS_Format2='0') MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,1),8.0)),1));
					WHEN (PKS_Format2='1') MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.1),8.1)),1));
					WHEN (PKS_Format2='2') MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.01),8.2)),1));
					WHEN (PKS_Format2='3') MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.001),8.3)),1));
					OTHERWISE              MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.1),8.1)),1));
				END;  
			END;
**/
			IF REPORTTYPECHK IN ('MEAN','BOTH') THEN DO;
					SELECT;
	 					WHEN (PKS_Format2='0') MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,1),8.0)),1));
						WHEN (PKS_Format2='1') MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.1),8.1)),1));
						WHEN (PKS_Format2='2') MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.01),8.2)),1));
						WHEN (PKS_Format2='3') MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.001),8.3)),1));
						OTHERWISE              MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.1),8.1)),1));
					END;
			END; 
			IF UPCASE(METHODCHK) NOT IN ("HPLC RELATED IMP. IN ADVAIR MDPI", "IMPURITIES") THEN DO;
				SELECT;
	 				WHEN (PKS_Format2='0') MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,1),8.0)),1));
					WHEN (PKS_Format2='1') MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.1),8.1)),1));
					WHEN (PKS_Format2='2') MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.01),8.2)),1));
					WHEN (PKS_Format2='3') MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.001),8.3)),1));
					OTHERWISE              MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.1),8.1)),1));
				END;  
			END;


			put method mean meanc;
		RUN;
		
		DATA STABMEAN; LENGTH TYPE $15; SET STABMEAN;  /* Setup mean to specified precision level */
			IF meanc='' THEN DO;
			SELECT;
	 			WHEN (PKS_Format2='0') MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,1),8.0)),1));
				WHEN (PKS_Format2='1') MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.1),8.1)),1));
				WHEN (PKS_Format2='2') MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.01),8.2)),1));
				WHEN (PKS_Format2='3') MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.001),8.3)),1));
				OTHERWISE              MEANC=LEFT(SUBSTR(LEFT(PUT(ROUND(MEAN,.1),8.1)),1));
			END; 
			END;
			TYPE='MEAN';
			*PUT METHOD PKS_FORMAT2 MeanC;
			put mean mean1 meanc;
		RUN;

		PROC SORT DATA=STABMEAN; 
	   		BY studycomp REPORT Prod_Nm Prod_Grp Stability_Samp_Product Stability_Study_Nbr_Cd Stability_Samp_Stor_Cond METHOD 
				ASSY_BATCH assy_desc batch_nbr assy_mfg_dt blend_mfg_dt fill_desc fill_mfg_dt Matl_Mfg_Dt Pkg_mfg_dt Storage_dt SpecType TYPE;
	   	RUN;	
		/* Transpose data so time points are horizontal */
		PROC TRANSPOSE DATA=STABMEAN OUT=MEANOUT;  
	   		VAR Meanc;
	   		BY studycomp REPORT Prod_Nm Prod_Grp Stability_Samp_Product Stability_Study_Nbr_Cd Stability_Samp_Stor_Cond METHOD 
				ASSY_BATCH assy_desc batch_nbr assy_mfg_dt blend_mfg_dt fill_desc fill_mfg_dt Matl_Mfg_Dt Pkg_mfg_dt Storage_dt SpecType TYPE;
	   		ID Stability_Samp_Time_Weeks;
		RUN;
		
		/* Conbine Individuals and Means Summary */
		%IF %SUPERQ(ReportType) = SPEC %THEN %DO;
			PROC SORT DATA=MEANOUT; BY REPORT METHOD SpecType Type; RUN;
			PROC SORT DATA=INDOUT;  BY REPORT METHOD SpecType Type; RUN;

			data _null_; set meanout; put REPORT METHOD SpecType Type meanc; run;
			data _null_; set indout; put REPORT METHOD SpecType Type; run;

			DATA ALLSTAB0; LENGTH METHOD2 $200; MERGE MEANOUT INDOUT; 
				BY REPORT METHOD SpecType TYPE;
				_NAME_ = UPCASE(_NAME_);
				METHOD2=UPCASE(COMPRESS(METHOD,'-'));		
				put 'LOOK ' REPORT METHOD SpecType TYPE ;	
			RUN;  
			data _null_; set allstab0; put REPORT STABILITY_SAMP_PRODUCT METHOD Type; run;
			data _null_; set spec_out; put STABILITY_SAMP_PRODUCT METHOD Type ; run;

			PROC SORT DATA=ALLSTAB0; 	BY STABILITY_SAMP_PRODUCT METHOD Type;	RUN; /* REVISED V?? */
			PROC SORT DATA=Spec_Out; 	BY STABILITY_SAMP_PRODUCT METHOD Type;	RUN;
			/* Merge specs with data */
			DATA ALLSTAB ; MERGE  Spec_Out(IN=b) ALLSTAB0(IN=a);  
				BY STABILITY_SAMP_PRODUCT METHOD TYPE;
				IF A AND B;  
				*IF SPEC='' THEN DELETE;
			RUN;
						   

		%END;

		%ELSE %IF %SUPERQ(ReportType)=BOTH %THEN %DO;
			/* Merge means and individuals */
			DATA INDOUT;  SET INDOUT;  SpecType='Individual'; RUN;
			DATA MEANOUT; SET MEANOUT; SpecType='Means';      RUN;
			DATA ALLSTAB0; SET INDOUT MEANOUT; 
 			    Spec='';
				_NAME_ = UPCASE(_NAME_);
			RUN;  

			PROC SORT DATA=ALLSTAB0; 	BY STABILITY_SAMP_PRODUCT METHOD;	RUN; /* REVISED V?? */
			PROC SORT DATA=Spec_Out; 	BY STABILITY_SAMP_PRODUCT METHOD;	RUN;

			DATA ALLSTAB ; MERGE  Spec_Out(IN=b) ALLSTAB0(IN=a);  
				BY STABILITY_SAMP_PRODUCT METHOD ;
				IF A AND B;  
				*IF SPEC='' THEN DELETE;
			RUN;


			%LET SECONDCOL=SpecType;  /* Setup second table column variable */
		%END;

		%ELSE %IF %SUPERQ(ReportType)=MEANS %THEN %DO;
			/* Include only means */
			DATA ALLSTAB0; SET MEANOUT; 
 			    Spec='';
				SpecType='Means';
				_NAME_ = upcase(_NAME_);
			RUN;  

			PROC SORT DATA=ALLSTAB0; 	BY STABILITY_SAMP_PRODUCT METHOD;	RUN; /* REVISED V?? */
			PROC SORT DATA=Spec_Out; 	BY STABILITY_SAMP_PRODUCT METHOD;	RUN;

			DATA ALLSTAB ; MERGE  Spec_Out(IN=b) ALLSTAB0(IN=a);  
				BY STABILITY_SAMP_PRODUCT METHOD ;
				IF A AND B;  
				*IF SPEC='' THEN DELETE;
			RUN;
			%LET SECONDCOL=SpecType; /* Setup second table column variable */
		%END;

		%ELSE %IF %SUPERQ(ReportType)=IND %THEN %DO;
			/* Include only individuals */
			DATA ALLSTAB0; SET INDOUT; 
 			    Spec='';
				SpecType='Individual';
				_NAME_ = upcase(_NAME_);
			RUN; 

			PROC SORT DATA=ALLSTAB0; 	BY STABILITY_SAMP_PRODUCT METHOD;	RUN; /* REVISED V?? */
			PROC SORT DATA=Spec_Out; 	BY STABILITY_SAMP_PRODUCT METHOD;	RUN;

			DATA ALLSTAB ; MERGE  Spec_Out(IN=b) ALLSTAB0(IN=a);  
				BY STABILITY_SAMP_PRODUCT METHOD ;
				IF A AND B;  
				*IF SPEC='' THEN DELETE;
			RUN;

			%LET SECONDCOL=SpecType; /* Setup second table column variable */
		%END; 
		/* Format data */
	/*	PROC SORT DATA=ALLSTAB;BY Stability_Study_Nbr_Cd ASSY_BATCH;RUN;
		PROC SORT DATA=LRQUERY01A;BY Stability_Study_Nbr_Cd ASSY_BATCH;RUN;
		DATA ALLSTAB; MERGE ALLSTAB(IN=A) LRQUERY01A;BY Stability_Study_Nbr_Cd ASSY_BATCH;IF A; */
		DATA ALLSTAB; SET ALLSTAB;
			RETAIN NewObs 0;
			NewObs=NewObs+1; OUTPUT;
			LABEL assy_desc='Product';
			LABEL Stability_Samp_Stor_Cond='Storage Condition';  
		RUN;

		PROC SORT DATA=ALLSTAB; 
		BY METHOD Stability_Samp_Stor_Cond ASSY_BATCH Matl_Mfg_Dt NewObs; 
		RUN;

		DATA ALLSTAB; SET ALLSTAB;
			IF _NAME_='ResultC' THEN DO;
				_NAME_='INDIVIDUAL';
			END;
			ELSE IF _NAME_='MEANC' THEN DO;
				_NAME_='MEAN';
			END;
		RUN;

		PROC SORT DATA=ALLSTAB; 
		BY Stability_Samp_Stor_Cond ASSY_BATCH Matl_Mfg_Dt Stability_Study_Nbr_Cd METHOD SpecType;
		RUN;

		DATA ALLSTAB;  SET ALLSTAB ;
			StorageA=COMPRESS('A'||LEFT(Stability_Samp_Stor_Cond),'A');
			Stability_Samp_Stor_Cond=TRIM(StorageA);
			ASSY_BATCH=TRIM(ASSY_BATCH);
			Stability_Study_Nbr_Cd=TRIM(Stability_Study_Nbr_Cd);
			Report=TRIM(Stability_Study_Nbr_Cd)||'-'||TRIM(Stability_Samp_Stor_Cond);
		RUN;  

		PROC SORT DATA=ALLSTAB OUT=CREATETIME NODUPKEY; 
		BY REPORT Stability_Study_Nbr_Cd Stability_Samp_Stor_Cond ASSY_BATCH METHOD Type;
		RUN;

		PROC SORT DATA=ALLSTAB NODUPKEY; 
		BY Stability_Study_Nbr_Cd Stability_Samp_Stor_Cond ASSY_BATCH METHOD TYPE;
		RUN;

		DATA CREATETIME;	SET CREATETIME;
			%DO FI = 0 %TO 100 %BY 2;  /* Setup dummy time point variables */
				_&FI = ' ';
				_&FI.B = ' ';
			%END;
		RUN;
*OPTIONS NOMLOGIC NOMPRINT NOSYMBOLGEN NOSOURCE2; 

		%DO R=1 %TO &Report0;
			%LET S = %EVAL(&R * 100);
			%LET HIGHTIME&R=0;
			DATA Create&R; SET CREATETIME;
				IF Report="&&Report&R";
				%IF %SUPERQ(TIME&S) NE 0 %THEN %DO;
					%DO T=1 %TO %SUPERQ(TIME&S);
						%LET SS= %EVAL((&R * 100)+&T);
						%IF %SUPERQ(TIME&SS)^= %THEN %DO;
						%PUT "&&TIME&SS";
						%IF &&TIME&SS >= &&HighTime&R %THEN %DO;
							%LET HighTime&R=&&TIME&SS; /* Find maximum time point */
						%END;
						_&&TIME&SS..B = '-';
						%END;
					%END;
				%END;
			RUN;
			PROC SORT DATA=CREATE&R; BY Stability_Study_Nbr_Cd Stability_Samp_Stor_Cond ASSY_BATCH METHOD TYPE; RUN;
		%END;

		%DO R=1 %TO &Report0;
		DATA ALLSTAB&R;
		MERGE	CREATE&R(IN=Insel1)
				ALLSTAB(IN=Insel2);
		BY Stability_Study_Nbr_Cd Stability_Samp_Stor_Cond ASSY_BATCH METHOD TYPE;
		IF Insel1;

			%DO FI = 0 %TO 100 %BY 2;
				%IF &FI <= &&HIGHTIME&R %THEN %DO;
					IF _&FI IN (' ','.') AND _&FI.B='-'  THEN 
						_&FI=_&FI.B;
					IF _&FI NOT IN (' ') AND _&FI.B=' '  THEN 
						_&FI=' ';
				%END;
				%ELSE %DO;
					_&FI=' ';
				%END;
				%END;		
		RUN;
		%END;

OPTIONS MLOGIC MPRINT SYMBOLGEN SOURCE2; 

		DATA ALLSTAB;  Set 
			%DO R=1 %TO &Report0;
				ALLSTAB&R
			%END;
			;
		RUN;
				
		/* Setup report footers */
		DATA FOOTERFLAG; SET ALLSTAB; 
			RETAIN NGTCNT NMTCNT NLTCNT 0;
			NGTFLAG=INDEXW(SPEC, 'NGT');
			NMTFLAG=INDEXW(SPEC, 'NMT');
			NLTFLAG=INDEXW(SPEC, 'NLT');
			IF NGTFLAG > 0 THEN NGTCNT=NGTCNT+1;
			IF NMTFLAG > 0 THEN NMTCNT=NMTCNT+1;
			IF NLTFLAG > 0 THEN NLTCNT=NLTCNT+1;
		RUN;

		DATA _NULL_; SET FOOTERFLAG;
			IF NGTCNT > 0 THEN  FOOTER1= 'NGT = Not greater than ';  
			ELSE FOOTER1='';
			IF NMTCNT > 0 THEN  FOOTER2= 'NMT = Not more than ';  
			ELSE FOOTER2='';
			IF NLTCNT > 0 THEN  FOOTER3= 'NLT = Not less than '; 
			ELSE FOOTER3='';
			CALL SYMPUT('FOOTER', 'Note: '||TRIM(FOOTER1)||'   '||TRIM(FOOTER2)||'   '||TRIM(FOOTER3));
		RUN;
	
		%LET DATALIST= ;
					
		%LET TIMELIST= ;
		%DO R = 1 %TO &MaxObs+1;
						
			DATA _NULL_;
				Check="&&TIME&R";
				time = Check/4;
				IF TIME = 0 THEN CALL SYMPUT('LABEL', 'Initial');
				ELSE CALL SYMPUT('LABEL',RIGHT(time)||' Month');
				CALL SYMPUT("NewTime&R",'_'||LEFT(TRIM(Check)));
			RUN;

			%LET TIMELIST  = &TIMELIST &&NewTime&R;
			%IF %SUPERQ(OUTTYPE)=HTML %THEN 
			%LET TIMESTYLE=STYLE=[FONT_face=arial FONT_SIZE=2 cellwidth=175] STYLE(header)=[FONT_face=arial FONT_SIZE=2 background=#C0C0C0 foreground=BLACK];
			%ELSE %LET TIMESTYLE=STYLE=[FONT_face=arial FONT_SIZE=2 cellwidth=175] STYLE(header)=[FONT_face=arial FONT_SIZE=2 background=#C0C0C0 foreground=BLACK];
			/* Setup define statements */
			%GLOBAL DEFINE&R;
  			%LET DEFINE&R= DEFINE &&NewTime&R /"&LABEL" NOZERO CENTER &TIMESTYLE;
		%END;

		%LET DATALIST = &DATALIST ALLSTAB;
		
		DATA ALLREPORTDATA; SET &DATALIST; 
			IF INDEXC(METHOD,'-')>0 THEN Lab_Tst_Meth_Spec_Desc=substr(METHOD,1,INDEX(METHOD,'-')-1);
			                        ELSE Lab_Tst_Meth_Spec_Desc=substr(METHOD,1);
		RUN;

		PROC SORT DATA=ALLREPORTDATA;BY Lab_Tst_Meth_Spec_Desc;RUN;

		PROC SORT DATA=ALLREPORTDATA; 
		BY Stability_Study_Nbr_Cd Stability_Samp_Stor_Cond ASSY_BATCH METHOD ;
		RUN;

		PROC FORMAT;
			picture date11_ (default=11) other='%0d-%0b-%Y' (datatype=date);
			picture date12_ (default=9) other='%0d%b%Y' (datatype=date);
			picture date13_ (default=11) other='%0d%b%0Y' (datatype=date);
		RUN;

                /* Modified V9 - deleted mfg and pkg, added storage date */
		DATA REPORTDATA; LENGTH Report_Batch_Nbr $10. /*Manufacture_Date2 Packaging_Date2*/ Storage_dt2 $15.; SET ALLREPORTDATA;
			Report_Batch_Nbr=Batch_Nbr;
                        IF Storage_DT='' THEN
                                Storage_dt2='Not Available';
                        ELSE
		                Storage_dt2= PUT(DATEPART(Storage_DT),date9.);

			%IF %SUPERQ(ReportType) = SPEC %THEN %DO;
			
			IF SPEC_TYPE='INDIVIDUAL' THEN SPEC_TYPE='';
			IF SPEC='' AND SPEC_TYPE='MEAN' THEN SPEC_TYPE='Avg.';
			ELSE SPEC_TYPE='';
			%END;

			%ELSE %DO;
			IF TYPE='CHAR' THEN DELETE;
			%END;
			
			IF SPEC_TYPE='CHAR' AND UPCASE(SPECTYPE)='MEANS' THEN DELETE;

		    	IF UPCASE(METHOD) IN ("HPLC RELATED IMP. IN ADVAIR MDPI-UNSPECIFIED-FLUTICASONE") THEN 
			METHOD = "HPLC Related Imp. in Advair MDPI-Any Unspecified Fluticasone Related Impurity";
		    	IF UPCASE(METHOD) IN ("HPLC RELATED IMP. IN ADVAIR MDPI-UNSPECIFIED-SALMETEROL") THEN 
			METHOD = "HPLC Related Imp. in Advair MDPI-Any Unspecified Salmeterol Related Impurity";
		
			IF UPCASE(METHOD) IN ("HPLC RELATED IMP. IN ADVAIR MDPI-TOTAL") THEN 
			METHOD = "HPLC Related Imp. in Advair MDPI-Total Degradation Impurities";
			IF SPECTYPE='Means'      THEN SPECTYPE='Mean';
			IF SPECTYPE='Individual' THEN SPECTYPE='Individuals';

			*assy_batch_create_date2= put(assy_batch_create_date2, date9.);
			put /*Manufacture_date2 Packaging_Date2*/ assy_mfg_dt fill_mfg_dt blend_mfg_dt Storage_dt pkg_mfg_dt SPEC_TYPE SPECTYPE;
			*format assy_batch_create_date2 blend_nbr_create_date2 dtdate9.;
		RUN;

		PROC SORT DATA=INDIVSTAB NODUPKEY OUT=TITLEOUT; BY Stability_Samp_Stor_Cond Stability_Study_Nbr_Cd; RUN;
		/* Setup testing status flag 
		%IF %SUPERQ(STATUSFLAG)=  %THEN %LET COMMENT= ;  /* Added v7 - prevent uninitialized &COMMENT mvar */
		%IF %SUPERQ(STATUSFLAG)=NONE %THEN %LET COMMENT= ;
		%IF %SUPERQ(STATUSFLAG)=ONGOING %THEN %LET COMMENT=(Testing Ongoing);
		%IF %SUPERQ(STATUSFLAG)=COMPLETE %THEN %LET COMMENT=(Testing Complete);*/
		/* Setup footnotes */
		%IF %SUPERQ(FOOTERFLAG)=NONE %THEN %DO;
			&WARNING;
			FOOTNOTE2 H=1 J=L F=ARIAL "Report generated by the LINKS system &today at &time..";
			FOOTNOTE3 H=1 J=L F=ARIAL "Data used in this report is current as of &Save_Last_Update_Date at &Save_Last_Update_Time";
			%IF %SUPERQ(UNAPPFLAG)=YES %THEN %DO;
				FOOTNOTE4 C=RED J=L H=1.5 'Report contains approved and unapproved data. '; 
			%END;
		%END;
		%ELSE %IF %SUPERQ(FOOTERFLAG)=DEFAULT %THEN %DO;
			&WARNING;
			FOOTNOTE2 H=1 J=L F=ARIAL "&FOOTER";	
			FOOTNOTE3 H=1 J=L F=ARIAL "Report generated by the LINKS system &today at &time..  ";
			FOOTNOTE4 H=1 J=L F=ARIAL "Data used in this report is current as of &Save_Last_Update_Date at &Save_Last_Update_Time";
			%IF %SUPERQ(UNAPPFLAG)=YES %THEN %DO;
				FOOTNOTE5 C=RED J=L H=1.5 'Report contains approved and unapproved data. '; 
			%END;
		%END;
		%ELSE %IF %SUPERQ(FOOTERFLAG)=CUSTOM2 %THEN %DO;
			&WARNING;
			FOOTNOTE2 H=1 J=L F=ARIAL "&CUSTFOOT1";
			FOOTNOTE3 H=1 J=L F=ARIAL "&CUSTFOOT2";
			FOOTNOTE4 H=1 J=L F=ARIAL "&CUSTFOOT3";
			FOOTNOTE5 H=1 J=L F=ARIAL "Report generated by the LINKS system &today at &time";
			FOOTNOTE6 H=1 J=L F=ARIAL "Data used in this Report is current as of &Save_Last_Update_Date at &Save_Last_Update_Time";
			%IF %SUPERQ(UNAPPFLAG)=YES %THEN %DO;
				FOOTNOTE7 C=RED J=L H=1.5 'Report contains approved and unapproved data. '; 
			%END;
		%END;
		/* setup report characteristics */
		ODS LISTING Close;
		%LET STYLEHTML =STYLE(Column) = [BORDERCOLOR=#000000 BORDERWIDTH=2 background = white vjust=top ];
		%LET STYLEHTML2=STYLE(Report) = [FONT_face=arial background=white outputwidth=90% BORDERCOLOR=#000000 CELLPADDING=5 ];
		%LET STYLEHTML3=STYLE(Lines)  = [FONT_face=arial FONT_weight=bold FONT_SIZE=2 background=#FFFFFF foreground=black] ;

		%IF %SUPERQ(OUTTYPE)=HTML AND %SUPERQ(UNAPPFLAG)=YES %THEN %DO;
			DATA _NULL_; FILE _WEBOUT;
			PUT '</BR><P ALIGN=CENTER><FONT FACE=ARIAL COLOR=RED><BIG><STRONG>NOTE: Report contains approved and unapproved data.</BIG></STRONG></FONT></BR>';
			RUN;
		%END;

		OPTIONS NOBYLINE ;

	%IF %SUPERQ(REPORTNAME)=SSR %THEN %DO;

                /* Modified V9 - meth_num changed to meth_ord_num */
		PROC SORT DATA=REPORTDATA;BY Stability_Study_Nbr_Cd Stability_Samp_Stor_Cond METH_ORD_NUM TYPE;RUN;

                /* Added V9 - eliminated extra column in report, move data into existing column if necessary */
                DATA REPORTDATA;
                        SET REPORTDATA;
                        IF Spec_Type EQ 'Avg.' AND Spec eq '' then Spec='(Avg.)';
                        /* Modified V9 - reformat storage cond string */
                        Stability_Samp_Stor_Cond=TRANWRD(LEFT(TRIM(Stability_Samp_Stor_Cond)), 'C', 'ºC')||'%RH';
                RUN;

		/* Generate Stability Study Report */
		PROC REPORT DATA=REPORTDATA NOWD BOX CENTER  SPLIT='*' MISSING ps=35 ls=200 &STYLEHTML &STYLEHTML2 &STYLEHTML3;
                        /* Modified V9 - meth_num changed to meth_ord_num */
 			COLUMNS METH_ORD_NUM  reg_prod_name studycomp Storage_dt2 /*Packaging_Date2*/ Stability_Study_Nbr_Cd Report_Batch_Nbr Stability_Samp_Stor_Cond REG_METH_NAME TYPE SPEC &&timeLIST ;
			DEFINE reg_prod_name        / NOPRINT;
			DEFINE studycomp         / NOPRINT;
			DEFINE Stability_Study_Nbr_Cd     / NOPRINT;
			DEFINE Stability_Samp_Stor_Cond   / NOPRINT;
			DEFINE Report_Batch_Nbr           / NOPRINT;
			DEFINE Storage_dt2          / NOPRINT;
			DEFINE METH_ORD_NUM / ORDER NOPRINT;
			
			DEFINE REG_METH_NAME   /"Test "  ORDER  ID GROUP LEFT width=35 STYLE=[FONT_face=arial FONT_SIZE=2 cellwidth=200 ]  STYLE(header)=[FONT_face=arial FONT_SIZE=2 JUST=LEFT background=#C0C0C0 BORDERCOLOR=black BORDERWIDTH=2 FOREGROUND=black];
			DEFINE TYPE /  ORDER NOPRINT;
			DEFINE Spec     /"End of Life*Specifications" ORDER  ID GROUP  LEFT width=20 STYLE=[FONT_face=arial FONT_SIZE=2 cellwidth=175 ] STYLE(header)=[FONT_face=arial FONT_SIZE=2 JUST=LEFT background=#C0C0C0 foreground=black];
			
			%DO S=1 %TO &MaxObs+1;
  				&&DEFINE&S;
			%END;
 			COMPUTE AFTER _PAGE_ / LEFT;
				LINE " "; 
			ENDCOMP;

			COMPUTE before _page_ / LEFT;
			
      			LINE @2 "Stability Study Report"  @176 StudyComp $20.  ;
			LINE @2 " ";
      			LINE @2 "Stability Data for : " reg_prod_name $200. @136 "Storage Condition : " Stability_Samp_Stor_Cond $15.     ;
			LINE @2 " ";

			LINE @2 "Stability Study Number : "  @35 Stability_Study_Nbr_Cd $8. /* @50 "Site of Manufacture : " 	@75 'Zebulon'                   @94 'Site of Packaging : ' @121 'Zebulon' */;
/* Modified V6 */
/***			LINE @2 "Batch Number :           "  @25 Report_Batch_Nbr $10.           @54 "Date of Manufacture : " 	@79 Manufacture_Date2 $15. @96 'Date of Packaging : ' @121 Packaging_Date2 $15. ;***/
			LINE @2 "Batch Number :           "  @25 Report_Batch_Nbr $10.           @54 "Date of Storage : " 	@79 Storage_dt2 $15.;

			LINE " ";		
   			ENDCOMP;
 			BY Stability_Study_Nbr_Cd Stability_Samp_Stor_Cond ;
 			LABEL Stability_Study_Nbr_Cd='Study';
		RUN;
	%END;
	

	data _null_; set reportdata;
	put stability_samp_product;
	run;

	
		OPTIONS BYLINE ;

	&Close;

	%IF %SUPERQ(OutType)=HTML %THEN %DO;
		/* Create LINKS footer banner */
		DATA _NULL_; LENGTH LINE ANCHOR $500; FILE _WEBOUT;
			PUT '</TD></TR>';
			PUT '<TR ALIGN=RIGHT ><TD BGCOLOR="#003366">';
		 	LINE = '<A HREF="//'||SYMGET('_server')||'/links/'||"&SAVE_linkshome"||'.ASP?UserRole='|| "%SUPERQ(Save_UserRole)" ||'">
			<FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Home</FONT></a>&nbsp&nbsp'; PUT line;
			ANCHOR= '&nbsp;&nbsp;<A HREF="'|| "%SUPERQ(_THISSESSION)" ||
				'&_program='||"LINKS.LRLogoff.sas"||
				'"><FONT FACE=ARIAL color="#FFFFFF">Log off</FONT></A>&nbsp;&nbsp;'; 
			PUT ANCHOR; 
  			PUT '</TD></TR></TABLE>'; 
		RUN;
	%END;

%MEND Reports;

*******************************************************************************;
*                       MODULE HEADER                                         *;
*-----------------------------------------------------------------------------*;
*   DESIGN COMPONENT: See LINKS Report SOP REQUIREMENT: See LINKS Report SOP  *;
*   INPUT:          MACRO VARIABLES: SCREEN, STUDY, REPORT, REPORT0, METHOD,  *;	
*			FOOTERFLAG.					      *;
*   PROCESSING:     Control execution of program.                             *;
*   OUTPUT:         1 or more reports to web browser or RTF file              *;
*******************************************************************************;

%MACRO Decide;
	%GLOBAL STOP REPORTNAME;
	%LET REPORTNAME=SSR;
	%IF %SUPERQ(SCREEN)= %THEN %STUDIES;
	%ELSE %IF %SUPERQ(SCREEN)=REPORTLIST %THEN %DO;
		%IF %SUPERQ(STUDY)= %THEN %DO;
			%LET STOP=STUDYMESSAGE;
			%WARNING;
		%END;
		%ELSE %REPORTList;		
	%END; 
	%ELSE %IF %SUPERQ(SCREEN)=TIMELIST %THEN %DO;
		%IF %SUPERQ(REPORT)= %THEN %DO;
			%LET STOP=REPORTMESSAGE;  * Set flag for no selections made;
			%WARNING;
		%END;
		%ELSE %TIMELIST;
	%END;
	
	%ELSE %IF %SUPERQ(SCREEN)=TESTLIST %THEN %DO;
		%DO I = 1 %TO &REPORT0;
			%LET II = %EVAL(&I*100); 
			%LET III = %EVAL((&I*100)+1); 
		    %GLOBAL TIME&II TIME&III ;
			%IF %SUPERQ(TIME&II)= %THEN %DO; * Only one selection made;
				 DATA _NULL_; 
				    CALL SYMPUT("TIME&II","1");
				    CALL SYMPUT("TIME&III", SYMGET("TIME&III"));
				 RUN;
			%END;
			%DO J = 1 %TO &&TIME&II;
		  		%IF %SUPERQ(TIME&II)= %THEN %LET STOP=TIMEMESSAGE;
			%END;
		%END;
		%IF %SUPERQ(STOP)=TIMEMESSAGE %THEN %WARNING;
		%ELSE %TESTLIST;
	%END;
	%ELSE %IF %SUPERQ(SCREEN)=ReportType %THEN %DO;
		%IF %SUPERQ(METHOD)= %THEN %DO;
			%LET STOP=METHODMESSAGE;  * Set flag for no selections made;
			%WARNING;
		%END;
		%ELSE %ReportType;
	%END;
	%ELSE %IF %SUPERQ(REPORTNAME)=BDTI %THEN %DO;
		%IF %SUPERQ(METHOD)= %THEN %DO;
			%LET STOP=METHODMESSAGE;  * Set flag for no selections made;
			%WARNING;
		%END;
		%ELSE %BATCHINPUT;
	%END;
	%ELSE %IF %SUPERQ(SCREEN)=REPORTS %THEN %DO;
		%IF %SUPERQ(FOOTERFLAG)=CUSTOM %THEN %CUSTOMFOOTER;
		%ELSE %REPORTS;
	%END;
%PUT _ALL_;
%MEND Decide;

%Decide;
