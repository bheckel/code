*************************************************************************************;
*                     PROGRAM HEADER                                                *;
*-----------------------------------------------------------------------------------*;
*  PROJECT NUMBER:  LINKS POT0204                                                   *;
*  PROGRAM NAME: LRXLSData.SAS                  SAS VERSION: 8.2                    *;
*  DEVELOPED BY: Carol Hiser                    DATE: 11/19/2002                    *;
*  PROJECT REPRESENTATIVE: Carol Hiser                                              *;
*  PURPOSE: This program saves LINKS data to a .csv spreadsheet.                    *;
*  SINGLE USE OR MULTIPLE USE? (SU OR MU) MU                                        *;
*  PROGRAM ASSUMPTIONS OR RESTRICTIONS: All documentation for this program          *;
*	is covered under the LINKS report SOP.                                      *;
*-----------------------------------------------------------------------------------*;
*  OTHER SAS PROGRAMS, MACROS OR MACRO VARIABLES USED IN THIS                       *;
*  PROGRAM:  SAS supplied Macro: Ds2Csv  , Macro variable Save_UID,                 *;
*            Save_Last_Update_Date, Save_Last_Update_Time, Save_UserRole,           *;
*            SAVE_STABILITY_STUDY_GRP_CDLST, SAVE_STABILITY_STUDY_NBR_CDLST         *;
*            SAVE_STABILITY_SAMP_STOR_CONDLST, save_lab_tst_meth_spec_desclst       *;
*			 SAVE_ITEM_DESCRIPTIONLST, SAVE_CREATE_START_DTLST,         *;
*			 SAVE_CREATE_END_DTLST.					    *;
*-----------------------------------------------------------------------------------*;
*  DESCRIPTION OF OUTPUT:  1 csv file.                                              *;
*-----------------------------------------------------------------------------------*;
*************************************************************************************;
*                     HISTORY OF CHANGE                                             *;
*-------------+---------+--------------+--------------------------------------------*;
*     DATE    | VERSION | NAME         | Description                                *;
*-------------+---------+--------------+--------------------------------------------*;
*  11/19/2002 |    1.0  | Carol Hiser  | Original                                   *;
*-----------------------------------------------------------------------------------*;
*  03/19/2003 |    2.0  | James Becker | Added functionality to save batch          *;
*             |         |              | release data.                              *;
*-----------------------------------------------------------------------------------*;
*  03/26/2003 |    3.0  | James Becker | - IR002                                    *;
*             |         |              |   * Changed "Filled" variable names to     *;
*             |         |              |     "Fill".                                *;
*             |         |              | - IR003                                    *;
*             |         |              |   * MACRO %REDATA changed to using BATCHES *;
*             |         |              |     dataset.                               *;
*-----------------------------------------------------------------------------------*;
*  06/10/2003 |   4.0   | James Becker | - VCC25658 - Amendmemt for MERPS/SAP       *;
*             |         |	       |   IN %MACRO REPORTS:                       *;
*             |         |              |   * Replaced sections refering to Lot_Nbr, *;
*             |         |              |     to Matl_Nbr & Batch_Nbr.               *;
*             |         |              |   * Replaced sections refering to Lot,     *;
*             |         |              |     to Nbr.                                *;
*-----------------------------------------------------------------------------------*;
*  03/31/2004 |   5.0   | James Becker | - VCC31135 -                               *;
*             |         |	       |   - Added Criteria Screens for Date Range  *;
*             |         |	       |     and Test Methods(%DateList, %TestList) *;
*             |         |	       |   - Added reading in only Release data     *;
*             |         |	       |     for %MACRO REDATA.                     *;
*             |         |	       |   - Added Indvl_tst_rslt_device to both    *;
*             |         |	       |     spreadsheets.                          *;
*             |         |	       |   - Added both % target and units in       *;
*             |         |	       |     result fields                          *;
*-----------------------------------------------------------------------------------*;
*  03/07/2005 |   6.0   | James Becker | - VCC37634 -                               *;
*             |         |	       |   - Added Criteria Screens for MDPI        *;
*             |         |	       |     In-Process Data spreadsheets.          *;
*-----------------------------------------------------------------------------------*;
*  12JUN2006  |  7.0    | Carol Hiser  | - VCC45936 -                               *;
*             |         |              | -  Modified to work for all product types  *;
*             |         |              | and new data file structure                *;
*-----------------------------------------------------------------------------------*;
*  29JUN06    |  8.0    | Carol Hiser  | - VCC51276                                 *;
*             |         |              | - Modified all batch columns to be material*;
*             |         |              | number - batch number.                     *;
*             |         |              | - Moved spec columns to after genealogy    *;
*             |         |              |   columns                                  *;
*-----------------------------------------------------------------------------------*;
*  31JUL06    |  9.0    | Carol Hiser  | - VCC51556   Removed specs                 *;
*             |         |              |                                            *;
*-----------------------------------------------------------------------------------*;
*  25JAN2007  | 10.0    | James Becker | - VCC53434   Added New Spec File           *;
*             |         |              |                                            *;
*************************************************************************************;
*************************************************************************************;
%GLOBAL SCREEN FORMMETHOD STARTMONTH STARTDAY STARTYEAR ENDMONTH ENDDAY ENDYEAR MINYEAR MAXYEAR MAXDAY WIDTH
	New_Start_Dt New_End_Dt New_Start_Dt2 New_End_Dt2 NODATA NODATAERR LIST_METHOD CLOSE HELP METHODTYPE
	Samp_Matl Samp_Batch
        CtlDir ServerName OraPath OraId OraPsw GisrPath GistId GistPsw CondCode;

/*OPTIONS MPRINT MLOGIC SYMBOLGEN NOSOURCE2;*/
OPTIONS NUMBER NODATE MLOGIC MPRINT SYMBOLGEN SOURCE2 PAGENO=1 ERROR=2
		MERGENOBY=ERROR MAUTOSOURCE LINESIZE=120 NOCENTER PAGENO=1 NOXWAIT
		SPOOL COMPRESS=YES BLKSIZE=2560 MSGLEVEL=I; 

	%LET CtlDir =;
        %LET ServerName =;
        %GetParm(SasServer, CtlDir, N);                 %LET CtlDir     = &parm;
        %GetParm(SasServer, ServerName, N);             %LET ServerName = &parm;

	%GetParm(DbServer, ServerName, N);              %LET OraPath    = &parm;
        %GetParm(DbServer, SysOperId, N);               %LET OraId      = &parm;
        %GetParm(DbServer, SysOperPsw, Y);              %LET OraPsw     = &parm;
	%GetParm(GistServer, ServerName, N);		%LET GistPath   = &parm;  
	%GetParm(GistServer, UserId, N);		%LET GistId     = &parm;  
	%GetParm(GistServer, UserPsw, Y);		%LET GistPsw    = &parm;  

*************************************************************************************;
*                             MODULE HEADER                                         *;
*-----------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: See LINKS Report SOP REQUIREMENT: See LINKS Report SOP        *;
*   INPUT:      Macro variable Save_UserRole                                        *;
*   PROCESSING: Check user role to determine if analyst column should be            *;
*               included.                                                           *;
*   OUTPUT:  Macro variables analystvar, format                                     *;
*************************************************************************************;
PROC FORMAT;
	picture date11_ (default=11) other='%0d-%0b-%Y' (datatype=date);
	picture date12_ (default=9) other='%0d%b%Y' (datatype=date);
	picture date13_ (default=11) other='%0d%b%0Y' (datatype=date);
RUN;

	%LET FORMMETHOD=get;	

%MACRO CHECKROLE;
	%GLOBAL ANALYSTVAR FORMAT;
	%IF %SUPERQ(SAVE_USERROLE)=LevelA %THEN %DO;
                %LET ANALYSTVAR=CHECKED_BY_USER_ID;
                %LET FORMAT=$30. ;
                %END;
	%ELSE %DO;
                %LET ANALYSTVAR=;
        	%LET FORMAT= ;
        %END;
%MEND;

%MACRO SetUp;
%PUT _ALL_;
	
	%GLOBAL INCOND2;
	%LET Help=;
	%IF %SUPERQ(Save_RptType)=ST %THEN %DO;
		%LET SAVE_PROGRAM=LINKS.LRQuery.sas;
		PROC SUMMARY DATA=SAVE.LRQUERYRES_Database;
	        VAR MATL_MFG_DT;
		OUTPUT OUT=DATEOUT MIN=MINDATE MAX=MAXDATE;
		RUN;
		DATA _NULL_;SET DATEOUT;
			CALL SYMPUT('SAVE_CREATE_START_DT',MINDATE);
			CALL SYMPUT('SAVE_CREATE_END_DT',MAXDATE);
			PUT _ALL_;
		RUN;

	%END;
	%IF %SUPERQ(Save_RptType)=RE %THEN %DO;
		%LET SAVE_PROGRAM=LINKS.LRQuery.sas;
	%END;
	
	
	%IF %SUPERQ(NODATAERR)= %THEN %DO;
		DATA _NULL_;	
			New_Start_Dt="&Save_Create_Start_Dt";
			New_End_Dt="&Save_Create_End_Dt";
			Start_Dt=DATEPART(New_Start_Dt);
			STARTMONTH=MONTH(Start_Dt);	CALL SYMPUT('STARTMONTH',STARTMONTH);
			STARTDAY=DAY(Start_Dt);		CALL SYMPUT('STARTDAY',STARTDAY);
			STARTYEAR=YEAR(Start_Dt);	CALL SYMPUT('STARTYEAR',STARTYEAR);
						CALL SYMPUT('MINYEAR',STARTYEAR);
			End_Dt=DATEPART(New_End_Dt);
			ENDMONTH=MONTH(End_Dt);		CALL SYMPUT('ENDMONTH',ENDMONTH);
			ENDDAY=DAY(End_Dt);		CALL SYMPUT('ENDDAY',ENDDAY);
			ENDYEAR=YEAR(End_Dt);		CALL SYMPUT('ENDYEAR',ENDYEAR);
						CALL SYMPUT('MAXYEAR',ENDYEAR);
			CALL SYMPUT('WIDTH','WIDTH=25%');
			PUT STARTMONTH STARTDAY STARTYEAR ENDMONTH ENDDAY ENDYEAR;
		RUN;
	%END;
	
%MEND SetUp;


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
%MACRO DateList;
	%GLOBAL NumProduct NumReports;
	
	DATA _NULL_;
		FILE _WEBOUT;
		PUT   '<BODY BGCOLOR="#808080">';
		SaveRptType="&Save_RptType";
		PUT 	'<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" BORDER="0" CELLPADDING="0" CALLSPACING="0">';
		PUT 	'<TR ALIGN="LEFT" ><TD BGCOLOR="#003366"><BIG><BIG><BIG>';
		LINE=	'<IMG SRC="http://'||"&_server"||'/links/images/gsklogo1.gif" WIDTH="141" HEIGHT="62">'; PUT LINE;
		IF SaveRptType='ST' THEN PUT 	'<FONT FACE=ARIAL COLOR="#FFFFFF"><EM> LINKS </EM> Stability Module</FONT>';
		IF SaveRptType='RE' THEN PUT 	'<FONT FACE=ARIAL COLOR="#FFFFFF"><EM> LINKS </EM> Batch Trending Module</FONT>';
		IF SaveRptType='MD' THEN PUT 	'<FONT FACE=ARIAL COLOR="#FFFFFF"><EM> LINKS </EM> MDPI Data Module</FONT>';
		LINE = '<FORM METHOD='||"&FORMMETHOD"||' ACTION="'||"&_url"||'">'; PUT LINE;
		PUT   '<INPUT TYPE="hidden" NAME="_service"      	VALUE="default">';
		LINE = '<INPUT TYPE="hidden" NAME="_program"      	VALUE="'||"links.LRXLSData.sas"||'">'; 	PUT LINE;
		LINE = '<INPUT TYPE="hidden" NAME="_server" 		VALUE="'||SYMGET('_server')||'">';	PUT LINE;
		LINE = '<INPUT TYPE="hidden" NAME="_port" 		VALUE="'||SYMGET('_port')||'">';       	PUT LINE;
		LINE = '<INPUT TYPE="hidden" NAME="_sessionid"    	VALUE="'||SYMGET('_sessionid')||'">';  	PUT LINE;
		PUT 	'</BIG></BIG></BIG></TD><TD ALIGN=right BGCOLOR="#003366">';
		PUT 	'</TD></TR>';
		PUT 	'<TR VALIGN="TOP"><TD colspan=2 HEIGHT="87%" BGCOLOR="#ffffdd" ALIGN=center>'; 
	RUN;

	DATA _NULL_;
		LENGTH LINE $500;
		FILE _WEBOUT;
		LINE = '</BR></BR></BR></BR></BR><TABLE '||"&WIDTH"||'>'; PUT LINE;
		LINE = '<TR><TD ALIGN=left><BIG><EM><STRONG><FONT FACE=ARIAL COLOR="#003366">'; PUT LINE;
		LINE= 'Please select a manufacture start date and end date:'||'</STRONG></FONT></EM></BIG></BIG></TD></TR></TABLE>'; PUT LINE;
		LINE= '<TABLE ALIGN=center BORDER=1 '||"&WIDTH"; PUT LINE;
		LINE= ' STYLE="FONT-family: Arial FONT-SIZE: smaller" BGCOLOR="#FFFFFF" ';  PUT LINE;
		LINE= ' bordercolor="#C0C0C0" bordercolorlight="#C0C0C0" bordercolordark="#C0C0C0">'; PUT LINE;
	RUN;

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
		LINE= '<FORM METHOD="'||"&formmethod"||'" ACTION="'||"&_url"||'">'; PUT LINE;
	  	PUT '<SELECT NAME="ENDYEAR" SIZE="1" STYLE="FONT-SIZE: SMALL" >';
		%DO I=&MINYEAR %TO &MAXYEAR;
			%IF %SUPERQ(ENDYEAR)=&I %THEN %LET SELYEAR=selected;  
                                                      %ELSE %LET SELYEAR= ;
  			LINE='<OPTION '||"&selYEAR"||' VALUE="'||"&I"||'">'||"&I"||'</OPTION>'; PUT LINE;
		%END;
		PUT '</SELECT></TD></TR></TABLE>';
		LINE= '<INPUT TYPE="hidden" NAME="screen" 	  VALUE="TESTLIST">'; PUT LINE; 
			PUT '</TABLE></BR><INPUT TYPE="submit" NAME="Submit" VALUE="       Next       "';
			PUT ' STYLE="background-COLOR: rgb(192,192,192); COLOR: rgb(0,0,0);';
			PUT ' FONT-SIZE: 9pt; FONT-family: Arial ; FONT-weight: bolder;';
			PUT ' LETter-spacing: 0px; text-ALIGN: center; vertical-ALIGN: baseline; ';
			PUT ' BORDER: medium outset; padding-top: 2px; padding-bottom: 4px">';
			PUT '</FORM>'; 
  	RUN;
	
	DATA _NULL_;
		FILE _WEBOUT;
		LENGTH LINE anchor1 anchor2 $500.;
		PUT '</TD></TR>';
		PUT '<TR ALIGN="right" HEIGHT="5%"><TD ALIGN=right BGCOLOR="#003366">';
		
	 	LINE= '<A HREF="//'||SYMGET('_server')||'/links/'||"&SAVE_linkshome"||'.ASP?UserRole='|| "%SUPERQ(Save_UserRole)" ||'">
		<FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Home</FONT></a>&nbsp&nbsp'; PUT line;
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

%MEND DateList;

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
	DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;
		LINE= '<FORM METHOD="'||"&formmethod"||'" ACTION="'||"&_url"||'" >'; 			PUT LINE;
		PUT   '<INPUT TYPE="hidden" NAME="_service"   VALUE="default">';
		LINE= '<INPUT TYPE="hidden" NAME="_program"   VALUE="links.LRXLSData.sas">'; 			PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME="_server"    VALUE="'||symget('_server')	   	||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME="_port"      VALUE="'||symget('_port')		   	||'">'; PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME="_sessionid" VALUE="'||symget('_sessionid')	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME="STARTMONTH" VALUE="'||symget('STARTMONTH')	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME="STARTDAY"   VALUE="'||symget('STARTDAY')	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME="STARTYEAR"  VALUE="'||symget('STARTYEAR')	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME="ENDMONTH"   VALUE="'||symget('ENDMONTH')	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME="ENDDAY"     VALUE="'||symget('ENDDAY')	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME="ENDYEAR"    VALUE="'||symget('ENDYEAR')	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME="_DEBUG"    VALUE="0">'; PUT LINE; 
	RUN;
	
	DATA _NULL_;
		New_Start_Dt=PUT(DHMS(MDY(&STARTMONTH,&STARTDAY,&STARTYEAR),0,0,0),DATETIME19.);
		Check_Start_Dt=MDY(&STARTMONTH,&STARTDAY,&STARTYEAR);
		New_Start_Dt2="'"||PUT(DHMS(MDY(&STARTMONTH,&STARTDAY,&STARTYEAR),0,0,0),DATETIME19.)||"'dt";
		CALL SYMPUT('New_Start_Dt',New_Start_Dt);
		CALL SYMPUT('New_Start_Dt2',New_Start_Dt2);
		New_End_Dt=PUT(DHMS(MDY(&ENDMONTH,&ENDDAY,&ENDYEAR),0,0,0),DATETIME19.);
		Check_End_Dt=MDY(&ENDMONTH,&ENDDAY,&ENDYEAR);
		New_End_Dt2="'"||PUT(DHMS(MDY(&ENDMONTH,&ENDDAY,&ENDYEAR),23,59,59),DATETIME19.)||"'dt";
		CALL SYMPUT('New_End_Dt',New_End_Dt);
		CALL SYMPUT('New_End_Dt2',New_End_Dt2);

		IF Check_Start_Dt GT Check_End_Dt      THEN CALL SYMPUT('NoDataErr','ENDSTART');
		IF Check_Start_Dt=.                    THEN CALL SYMPUT('NoDataErr','STARTERR');
		IF Check_End_Dt=.                      THEN CALL SYMPUT('NoDataErr','ENDERR');
		IF Check_Start_Dt=. AND Check_End_Dt=. THEN CALL SYMPUT('NoDataErr','BOTHERR');
		RUN;

	RUN;

	%IF %SUPERQ(Save_RptType)=ST %THEN %DO;
		PROC SORT DATA=Save.LRQueryRes_DataBase NODUPKEY OUT=Save.Res_DataBase; 
			BY Stability_Samp_Product Stability_Study_Nbr_Cd Stability_Samp_Stor_Cond Stability_Samp_Time_Weeks 
			Lab_Tst_Meth_Spec_Desc Matl_Mfg_Dt; 
		RUN;
		DATA Save.Res_DataBase;SET Save.Res_DataBase;WHERE Matl_Mfg_Dt BETWEEN &New_Start_Dt2 AND &New_End_Dt2;RUN;
	%END;
	%IF %SUPERQ(Save_RptType)=RE %THEN %DO;
		PROC SORT DATA=Save.LRQueryRes_Batches NODUPKEY OUT=Save.Res_DataBase; 
			BY Stability_Samp_Product Stability_Study_Nbr_Cd Stability_Samp_Stor_Cond Stability_Samp_Time_Weeks 
			Lab_Tst_Meth_Spec_Desc Matl_Mfg_Dt; 
		RUN;
		DATA Save.Res_DataBase;SET Save.Res_DataBase;WHERE Matl_Mfg_Dt BETWEEN &New_Start_Dt2 AND &New_End_Dt2;RUN;
	%END;
	

	/* Subset data for only chosen reports */
	%LET NoData=0;
	DATA ALLREPORTS; LENGTH METHOD $100 ; SET Save.Res_DataBase;
		Report=TRIM(Stability_Study_Nbr_Cd)||'-'||TRIM(Stability_Samp_Stor_Cond);
		METHOD=TRIM(Lab_Tst_Meth_Spec_Desc);
		MaxObs+1;
		CALL SYMPUT('NoData',MaxObs);
	RUN;

	%IF %SUPERQ(NoDataErr)=STARTERR OR %SUPERQ(NoDataErr)=ENDERR OR %SUPERQ(NoDataErr)=BOTHERR %THEN %DO; %NoData; %END;
	%ELSE %IF %SUPERQ(NoDataErr)=ENDSTART %THEN %DO; %NoData; %END;
	%ELSE %IF %SUPERQ(NoData)=0 %THEN %DO; %LET NoDataErr=NODATA; %NoData; %END;
	%ELSE %DO;

	/* Obtain unique test methods and total number of test methods */
	PROC SQL;
        CREATE TABLE METHODS AS SELECT * FROM 
	    (SELECT DISTINCT METHOD
		 FROM	ALLREPORTS		AREP
	    );
    	QUIT;
	RUN;

	DATA METHODS2; SET METHODS NOBS=NUMMETH;
		RETAIN METHOD_Obs 0;
		METHOD_Obs+1; 
		OUTPUT;
		CALL SYMPUT('NUMMETH',NUMMETH);
	RUN;

	DATA _NULL_; LENGTH LINE ANCHOR $2000;
		FILE _WEBOUT;	/* Set up LINKS banner */
		SaveRptType="&Save_RptType";
		PUT '<BODY BGCOLOR="#808080"><title>LINKS Spreadsheet Report</title></BODY>';
		PUT '<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" border="1" bordercolor="#003366" cellpadding="0" cellspacing="0">';
		PUT '<TR ALIGN="LEFT" ><TD colspan=2 BGCOLOR="#003366">';
		PUT '<TABLE ALIGN=LEFT vALIGN=top height="100%" width="100%"><TR><TD ALIGN=LEFT><big><big><big>';
		LINE='<IMG src="//'||"&_server"||'/links/images/gsklogo1.gif" width="141" height="62">'; PUT LINE;
		IF SaveRptType='ST' THEN PUT 	'<FONT FACE=ARIAL COLOR="#FFFFFF"><EM> LINKS </EM> Stability Module</FONT>';
		IF SaveRptType='RE' THEN PUT 	'<FONT FACE=ARIAL COLOR="#FFFFFF"><EM> LINKS </EM> Batch Trending Module</FONT>';
		
		ANCHOR= '<TD ALIGN=RIGHT><A HREF="'|| "%SUPERQ(_THISSESSION)" ||
		'&_program=links.LRReport.sas"><FONT FACE=ARIAL color="#FFFFFF">Back to Batch Trending Menu</FONT></A>';
	    PUT ANCHOR; 

		PUT '</TD></TR></TABLE></TD></TR>';
		PUT '<TR height="87%"><TD BGCOLOR="#ffffdd" nowrap   ALIGN="center" vALIGN="top">';
	RUN;
	/* Setup form variables */
	DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;
		LINE= '<FORM  METHOD="'||"&formmethod"||'" ACTION="'||"&_url"||'" >'; 			PUT LINE;
		PUT   '<width="80%" ALIGN=center>';					
		LINE= '<INPUT TYPE="hidden" NAME=screen         VALUE="REPORTS">'; 			PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME="NEW_START_DT" VALUE="'||symget('NEW_START_DT')||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME="NEW_END_DT"   VALUE="'||symget('NEW_END_DT')	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME="_debug"       VALUE="0">'; 				PUT LINE; 
		PUT   '<TABLE><TR><TD ALIGN=LEFT></br></br><FONT face=arial color="#003366" SIZE=3><em><STRONG>Select report test methods:</br></em></STRONG></FONT></TD></TR>';
		PUT   '<TR><TD><TABLE BORDER=1 CELLPADDING=5 STYLE="FONT-family: Arial FONT-SIZE: smaller" BGCOLOR="#FFFFFF" bordercolor="#C0C0C0" bordercolorlight="#C0C0C0" bordercolordark="#C0C0C0">';
		PUT   '<TR BGCOLOR="#C0C0C0"><TD><FONT SIZE=2 FACE=ARIAL><STRONG>Test Method</STRONG></FONT></TD></TR>';
	RUN;

	/* Add report and time variables from previous screens to form */

	/* Create checkboxes for each test method */
	%DO M = 1 %TO &NUMMETH;
		DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT; SET METHODS2;
			WHERE METHOD_Obs=&M;
			LINE= '<TR><TD><FONT face=arial SIZE=2><INPUT TYPE=Checkbox Checked NAME=METHOD VALUE="'||TRIM(METHOD)||'">'||TRIM(METHOD)||'</FONT></TD></TR>'; PUT LINE; 
		RUN;
	%END;		
		
		DATA _NULL_; FILE _WEBOUT; 
			PUT '</TABLE>'; 
		RUN;

	* Create form submit button ;
	DATA _NULL_; LENGTH LINE $2000; FILE _WEBOUT;
  		LINE= '</TD></TR><TR><TD ALIGN=center></br>'; PUT LINE;
		PUT '</BR><INPUT TYPE=submit NAME=submit VALUE="Create Spreadsheet"';
		PUT ' STYLE="background-color: rgb(192,192,192); color: rgb(0,0,0); ';
		PUT ' FONT-SIZE: 11pt; FONT-family: Arial Bold; FONT-weight: bolder; ';
		PUT ' text-ALIGN: center; border: medium OUTSET; padding-TOp: 2px; padding-botTOm: 4px"></BR></BR>'; 
	RUN;
	/* Create LINKS footer banner */
	DATA _NULL_; LENGTH LINE ANCHOR $2000; FILE _WEBOUT;
		PUT '</FONT></TD></TR></FORM></FORM></TABLE></TD></TR>';
		PUT '<TR ALIGN=RIGHT ><TD BGCOLOR="#003366">';

		SaveRptType="&Save_RptType";
		IF SaveRptType IN ('ST','RE') THEN DO;
 	  	LINE = '<A HREF="//'||SYMGET('_server')||'/links/'||"&SAVE_linkshome"||'.ASP?UserRole='|| "%SUPERQ(Save_UserRole)" ||'">'; PUT LINE;
	  	LINE = '<FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Home</FONT></a>&nbsp&nbsp'; PUT LINE;
	  	END;
	  	IF SaveRptType IN ('MD') THEN DO;
 	  	LINE = '<A HREF="//'||SYMGET('_server')||'/links/'||"MDPI_Menus.ASP?UserRole=LevelB&MenuType=CofA"||'">'; PUT LINE;
	  	LINE = '<FONT FACE=ARIAL COLOR="#FFFFFF">MDPI Home</FONT></a>&nbsp&nbsp'; PUT LINE;
	  	END;

		ANCHOR= '&nbsp;&nbsp;<A HREF="'|| "%SUPERQ(_THISSESSION)" ||
				'&_program='||"LINKS.LRLogoff.sas"||
				'"><FONT FACE=ARIAL color="#FFFFFF">Log off</FONT></A>&nbsp;&nbsp;'; 
		PUT ANCHOR; 
		PUT '</TD></TR></TABLE></HTML>'; 
	RUN;
	%END;

%MEND TestList;
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
%PUT _ALL_;
	DATA _NULL_; length LINE $500; file _WEBOUT;
	  SaveRptType="&Save_RptType";NoDataErr="&NoDataErr";
	  PUT 	'<BODY BGCOLOR="#808080">';
	  PUT 	'<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" BORDER="0" CELLPADDING="0" CALLSPACING="0">';
	  PUT 	'<TR ALIGN="LEFT" ><TD BGCOLOR="#003366">';
	  LINE=	'<BIG><BIG><BIG><IMG SRC="http://'||"&_server"||'/links/images/gsklogo1.gif" WIDTH="141" HEIGHT="62">'; PUT LINE;
	  IF SaveRptType='ST' THEN PUT 	'<FONT FACE=ARIAL COLOR="#FFFFFF"><EM> LINKS </EM> Stability Module</FONT>';
	  IF SaveRptType='RE' THEN PUT 	'<FONT FACE=ARIAL COLOR="#FFFFFF"><EM> LINKS </EM> Batch Trending Module</FONT>';
	  IF SaveRptType='MD' THEN PUT 	'<FONT FACE=ARIAL COLOR="#FFFFFF"><EM> LINKS </EM> MDPI Data Module</FONT>';
	  PUT 	'</BIG></BIG></BIG></TD></TR>';
	  LINE=   '<TR><TD HEIGHT="87%" BGCOLOR="#FFFFDD" valign=top><p ALIGN=center><STRONG><BIG><BIG>';  PUT LINE;
	  IF NoDataErr='EMPTY' THEN 
		PUT '<FONT FACE=ARIAL COLOR="#FF0000"></BR></BR></BR></BR></BR></BR>There is no data in the tables for you to select.';
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
	  IF NoDataErr='ERRSCREEN' THEN DO;
		PUT '<FONT FACE=ARIAL COLOR="#FF0000"></BR></BR></BR></BR></BR></BR>Genealogy Error: An Email is being send to the LINKS Administrator.';
		PUT '<FONT FACE=ARIAL COLOR="#FF0000"></BR></BR></BR></BR></BR></BR>                 This should be fixed within the hour.';
	  END;
	  PUT   '</BIG></BIG></FONT></BR></BR>';
	  PUT '<TABLE ALIGN="center" WIDTH="80%"><TR><TD>';
	  PUT '<EM><FONT FACE=arial COLOR="#003366"><p ALIGN=center>';
	  PUT '</BR>Please use your browsers back button to go back and change your selection.</STRONG></FONT>';
	  PUT '</TD></TR></BR></BR>';
	  PUT '</TABLE>';
	  PUT '</TD></TR>';
	  PUT '<TR ALIGN="right" ><TD BGCOLOR="#003366">';

	  IF SaveRptType IN ('ST','RE') THEN DO;
 	  LINE = '<A HREF="//'||SYMGET('_server')||'/links/'||"&SAVE_linkshome"||'.ASP?UserRole='|| "%SUPERQ(Save_UserRole)" ||'">'; PUT LINE;
	  LINE = '<FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Home</FONT></a>&nbsp&nbsp'; PUT LINE;
	  END;
	  IF SaveRptType IN ('MD') THEN DO;
 	  LINE = '<A HREF="//'||SYMGET('_server')||'/links/'||"MDPI_Menus.ASP?UserRole=LevelB&MenuType=CofA"||'">'; PUT LINE;
	  LINE = '<FONT FACE=ARIAL COLOR="#FFFFFF">MDPI Home</FONT></a>&nbsp&nbsp'; PUT LINE;
	  END;

	  anchor1= '<A HREF="'|| "%SUPERQ(_THISSESSION)" || 
				'&_program='||"&SAVE_program"||
				'&help=HELP"><FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Help</FONT></A>'; 
	  PUT anchor1; 

	  anchor2= '&nbsp;&nbsp;<A HREF="'|| "%SUPERQ(_THISSESSION)" || 
		'&_program=LINKS.LRLogoff.sas"><FONT FACE=ARIAL COLOR="#FFFFFF">Log off</FONT></A>&nbsp;&nbsp;'; 
	  PUT anchor2; 
	  PUT '</TD></TR></TABLE></body></html>';
%MEND NoData;
*************************************************************************************;
*                       MODULE HEADER                                               *;
*-----------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: See LINKS Report SOP REQUIREMENT: See LINKS Report SOP        *;
*   INPUT:            SAVE.LRQUERYRES_DATABASE                                      *;
*   PROCESSING: Macro STDATA to create/format stability dataset                     *;
*	Setup Method variable by concatenating Lab_Tst_Meth_Spec_Desc,              *;
*               Indvl_Meth_Stage_Nm, Meth_Peak_Nm. Sort the data.                   *;
*               Create variable ResultN using individual results.  Format and       *;
*               calculate maximum unspecified degradation impurities.               *;
*   OUTPUT:  Dataset StabXLS0                                                       *;
*************************************************************************************;
%MACRO GetCriteria;
	DATA _NULL_; LENGTH LINE $2000; 
		LINE= '<METHOD="'||"&formmethod"||'" ACTION="'||"&_url"||'" >'; 			PUT LINE;
		LINE= '<INPUT TYPE="hidden" NAME="NEW_START_DT" VALUE="'||symget('NEW_START_DT')||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME="NEW_END_DT"   VALUE="'||symget('NEW_END_DT')	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME="DATETYPE"     VALUE="'||symget('DATETYPE')	||'">'; PUT LINE; 
		LINE= '<INPUT TYPE="hidden" NAME="NAMETYPE"     VALUE="'||symget('NAMETYPE')	||'">'; PUT LINE; 
	RUN;

	%IF %SUPERQ(Save_RptType)=MD %THEN %DO;
	DATA _NULL_; LENGTH LINE $2000; 
		LINE= '<INPUT TYPE="hidden" NAME="MDPIREPORT"   VALUE="'||symget('MDPIREPORT')||'">'; 	PUT LINE; 
	RUN;
	%END;

	DATA _NULL_;
		New_Start_Dt2="'"||"&New_Start_Dt"||"'dt";
		New_End_Dt2  ="'"||"&New_End_Dt"||"'dt";
		CALL SYMPUT('New_Start_Dt2',New_Start_Dt2);
		CALL SYMPUT('New_End_Dt2',New_End_Dt2);
	RUN;

	%IF %SUPERQ(Method0)= %THEN %DO; * Only one selection made;
		%GLOBAL Method0;
		DATA _NULL_; 
			CALL SYMPUT("Method0",1);
			CALL SYMPUT("Method1", SYMGET("Method"));
		RUN;
	%END;

	%GLOBAL Method_List;
	%LET Method_List=;
	%DO i = 1 %TO &Method0;  
 	    DATA _NULL;
		%IF &i=1 %THEN %DO;CALL SYMPUT('Method_List'," ^"||SYMGET("Method&i")||"^ ");			
			 %END;
		         %ELSE %DO;CALL SYMPUT('Method_List',"&Method_List"||",^"||left(TRIM(SYMGET("Method&i")))||"^ ");
			 %END;
	    RUN;
 	    DATA _NULL;
		PUT "&Method_List";
	    RUN;
    	%END;

	PROC SORT DATA=SAVE.LRQUERYRES_BATCHES;
        BY STABILITY_SAMP_PRODUCT LAB_TST_METH_SPEC_DESC MATL_NBR BATCH_NBR ;
	RUN;

	DATA _NULL_;
		Query2 = "&Method_List";
		CALL SYMPUT('List_Method',TRANWRD(Query2,'^',"'"));
	RUN;
%MEND GetCriteria;


*************************************************************************************;
*                       MODULE HEADER                                               *;
*-----------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: See LINKS Report SOP REQUIREMENT: See LINKS Report SOP        *;
*   INPUT:            SAVE.LRQUERYRES_DATABASE                                      *;
*   PROCESSING: Macro STDATA to create/format stability dataset                     *;
*	Setup Method variable by concatenating Lab_Tst_Meth_Spec_Desc,              *;
*               Indvl_Meth_Stage_Nm, Meth_Peak_Nm. Sort the data.                   *;
*               Create variable ResultN using individual results.  Format and       *;
*               calculate maximum unspecified degradation impurities.               *;
*   OUTPUT:  Dataset StabXLS0                                                       *;
*************************************************************************************;
%MACRO STDATA;
	%GetCriteria;

	PROC SORT DATA=SAVE.LRQUERYRES_Database;
        BY STABILITY_SAMP_STOR_COND STABILITY_STUDY_NBR_CD STABILITY_SAMP_TIME_VAL ;
	RUN;

	DATA StabXLS0 ; SET save.LRQueryRes_Database;LENGTH Short_Stage_Nm $6. Short_Peak_Nm $3. Method $100.  ; 
	    IF UPCASE(LAB_TST_METH_SPEC_DESC) IN ('CU OF EMITTED DOSE IN ADVAIR MDPI', 'ADVAIR CONTENT PER BLISTER') THEN
                        resultN=INDVL_TST_RSLT_VAL_UNIT;
                ELSE RESULTN=INDVL_TST_RSLT_VAL_NUM;

        IF SAMP_STATUS < 17 AND SAMP_STATUS^=. THEN DATASTATUS='Unapproved';
        ELSE IF SAMP_STATUS >= 17 THEN DATASTATUS='Approved';
		Matl_Batch_Nbr=TRIM(Matl_Nbr)||'-'||TRIM(LEFT(Batch_Nbr)); /* Modifed V8 */

	
        IF Indvl_Meth_Stage_Nm^='NONE' AND Meth_Peak_Nm^='NONE' THEN
                        Method=TRIM(Lab_Tst_Meth_Spec_Desc)||'-'||TRIM(Indvl_Meth_Stage_Nm)||'-'||TRIM(Meth_Peak_Nm);
        ELSE IF Indvl_Meth_Stage_Nm ='NONE' AND Meth_Peak_Nm^='NONE' THEN Method=TRIM(Lab_Tst_Meth_Spec_Desc)||'-'||TRIM(Meth_Peak_Nm);
        ELSE IF Indvl_Meth_Stage_Nm^='NONE' AND Meth_Peak_Nm ='NONE' THEN
                 Method=TRIM(Lab_Tst_Meth_Spec_Desc)||'-'||TRIM(Indvl_Meth_Stage_Nm);
        ELSE  Method=TRIM(Lab_Tst_Meth_Spec_Desc);

		
        IF UPCASE(METHOD) IN ("HPLC RELATED IMP. IN ADVAIR MDPI-TOTAL") THEN
        METHOD = "HPLC Related Imp. in Advair MDPI-Total Degradation Impurities";

		IF UPCASE(METHOD) IN ("HPLC RELATED IMP. IN ADVAIR MDPI-UNSPECIFIED-FLUTICASONE") 
		THEN DO;
        	IF INDVL_TST_RSLT_NM='' THEN METHOD = "HPLC Related Imp. in Advair MDPI-Any Unspecified Fluticasone Related Degradent Impurity";
			ELSE METHOD='HPLC RELATED IMP. IN ADVAIR MDPI-UNSPECIFIED-'||TRIM(LEFT(METH_PEAK_NM))||'-'||LEFT(TRIM(INDVL_TST_RSLT_NM));        
			END;	
	
		IF UPCASE(METHOD) IN ("HPLC RELATED IMP. IN ADVAIR MDPI-UNSPECIFIED-SALMETEROL") THEN DO;
        	IF INDVL_TST_RSLT_NM='' THEN METHOD = "HPLC Related Imp. in Advair MDPI-Any Unspecified Salmeterol Related Degradent Impurity";
        	ELSE METHOD='HPLC RELATED IMP. IN ADVAIR MDPI-UNSPECIFIED-'||TRIM(LEFT(METH_PEAK_NM))||'-'||LEFT(TRIM(INDVL_TST_RSLT_NM));        
			END;	   

		Result=INDVL_TST_RSLT_VAL_NUM;
        Resultu=INDVL_TST_RSLT_VAL_UNIT;
        	
		IF Samp_Tst_Dt=. THEN Samp_Tst_Dt=DHMS(MDY(01,01,1960),00,00,00);
		else samp_tst_dt2=PUT(DATEPART(samp_tst_dt),DATE11_.);	
		
		LENGTH Samp_Tst_Dt2 $15.;  	    CALL SYMPUT('datefmt','$15.');
	RUN;

*************************************************************************************;
*                       MODULE HEADER                                               *;
*-----------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: See LINKS Report SOP REQUIREMENT: See LINKS Report SOP        *;
*   INPUT:   Macro variable Save_Uid, Save_Last_Update_Date,                        *;
*            Save_Last_Update_Time, SAVE_STABILITY_STUDY_GRP_CDLST,                 *;
*            SAVE_STABILITY_STUDY_NBR_CDLST, SAVE_STABILITY_SAMP_STOR_CONDLST,      *;
*            save_lab_tst_meth_spec_desclst. Dataset StabXLS0                       *;
*   PROCESSING: Setup variables Query, RptCreatedBy, RptCreateDate,                 *;
*               and LastDataUpdate.  Merge new variables with StabXLS0 dataset      *;
*               so new variables are populated only on the first line.              *;
*               Setup variable resultn depending on test                            *;
*               method and PKS_Format value.  Create DATASTATUS variable            *;
*               which is 'Approved' if SAMP_STATUS is >= 17 or 'Unapproved' if      *;
*               SAMP_STATUS is < 17.   Execute CheckRole macro to verify user       *;
*	            role.  Order variables in FDAStat format.                       *;
*   OUTPUT:  Dataset StabXLS1                                                       *;
*************************************************************************************;
	*** Create dataset for first line of report ***;
	DATA FIRSTLINE; LENGTH studygrps studies storcond tests $1000;
	OBSNBR=1;

		%IF %SUPERQ(SAVE_STABILITY_STUDY_GRP_CDlsT)=  %THEN %LET SAVE_STABILITY_STUDY_GRP_CDlsT=ALL; 
        studygrps=trim(tranwrd(SYMGET("SAVE_STABILITY_STUDY_GRP_CDLST"),'^','"'));
		%IF %SUPERQ(SAVE_STABILITY_STUDY_NBR_CDlsT)=  %THEN %LET SAVE_STABILITY_STUDY_NBR_CDlsT=ALL; 
		studies=trim(tranwrd(SYMGET("SAVE_STABILITY_STUDY_NBR_CDLST"),'^','"'));
		%IF %SUPERQ(SAVE_STABILITY_SAMP_STOR_CONDlsT)=  %THEN %LET SAVE_STABILITY_SAMP_STOR_CONDlsT=ALL; 
		storcond=trim(tranwrd(SYMGET("SAVE_STABILITY_SAMP_STOR_CONDLST"),'^','"'));
		%IF %SUPERQ(SAVE_lab_tst_meth_spec_desclsT)=  %THEN %LET SAVE_lab_tst_meth_spec_desclsT=ALL;
        tests=trim(TRANWRD(SYMGET('save_lab_tst_meth_spec_desclst'),'^','"'));
        Query=  'Study Groups: '                ||trim(studygrps)||
                        ' Studies: '            ||trim(studies)  ||
                        ' Storage Conditions: ' ||trim(storcond) ||
                        ' Tests: '              ||trim(tests) ;
        RptCreatedby = "&save_uid";
        RptCreateDate=PUT(DATE(),MMDDYY10.)||', '||PUT(TIME(),TIMEAMPM9.);
        LastDataUpdate = trim("&save_last_update_date")||', '||trim(left("&save_last_update_TIME"));
	RUN;

	
	%CHECKROLE;

	PROC SORT DATA=STABXLS0 NODUPKEY;
	     BY stability_samp_stor_cond stability_study_nbr_cd stability_samp_time_val result resultu
             Indvl_tst_rslt_device METHOD LAB_TST_METH  DATASTATUS  
             Indvl_tst_rslt_val_char samp_tst_dt2 &ANALYSTVAR STABILITY_SAMP_PRODUCT
             matl_batch_nbr stability_study_purpose_txt res_id indvl_tst_rslt_row Indvl_tst_rslt_nm METH_VAR_NM;
	RUN;

	DATA STABXLS0; SET STABXLS0; RETAIN OBSNBR 0; OBSNBR=OBSNBR+1; RUN;

	*** Merge first line into STABXLS0 dataset and create DataStatus variable. ***;
	DATA STABXLS1; LENGTH DATASTATUS $15; MERGE FIRSTLINE STABXLS0 ; BY OBSNBR;RUN;

	/**************************************************************/
	/*** V4 - Changed lot number and item description variables ***/
	/*** V5 - Added Indvl_tst_rslt_device to spreadsheet        ***/
	/**************************************************************/
	
	PROC SQL;CREATE INDEX SORTED1 ON STABXLS1(stability_samp_stor_cond, stability_study_nbr_cd, stability_samp_time_val, method, Indvl_tst_rslt_device);QUIT;

	DATA LINKSXLS1;
        FORMAT stability_samp_stor_cond stability_study_nbr_cd $20. stability_samp_time_val 6.1 result resultu 10.5
               Indvl_tst_rslt_device $40. METHOD $100. LAB_TST_METH $50. DATASTATUS $15. 
               Indvl_tst_rslt_val_char $50. samp_tst_dt2 &Datefmt. &ANALYSTVAR &FORMAT STABILITY_SAMP_PRODUCT $25.
               matl_batch_nbr $40. stability_study_purpose_txt $200. rptcreatedby rptcreatedate LastDataUpdate $35. query $1000.;
        SET STABXLS1;
		BY stability_samp_stor_cond stability_study_nbr_cd stability_samp_time_val method Indvl_tst_rslt_device;

        LABEL   STABILITY_SAMP_PRODUCT		= "Product"
                stability_samp_stor_cond	= "Storage Condition"
                stability_study_nbr_cd		= "Study"
                stability_samp_time_val		= "Time Point"
                result				= "Numeric Result "
                resultu				= "Numeric Result (units)"
                Indvl_tst_rslt_device 		= "Device"
                method			 	= "Test Method Description"
                lab_tst_meth			= "Method Number"
                samp_tst_dt2			= "Test Date"
                indvl_tst_rslt_val_char		= "Character Result"
        	MATL_BATCH_NBR			= "Material-Batch Number"
                stability_study_purpose_txt	= "Study Description"
                Query				= "Report query conditions"
                RptCreatedBy			= "Report created by"
                RptCreateDate			= "Report create date"
                CHECKED_BY_USER_ID		= "Analyst"
                DATASTATUS			= "LIMS Data Status"
                lastdataupdate			= "Last LINKS data update"
				;
	KEEP stability_samp_stor_cond stability_study_nbr_cd stability_samp_time_val result resultu
             Indvl_tst_rslt_device METHOD LAB_TST_METH  DATASTATUS  
             Indvl_tst_rslt_val_char /* removed V9 low_limit upr_limit */ samp_tst_dt2 &ANALYSTVAR STABILITY_SAMP_PRODUCT
             matl_batch_nbr stability_study_purpose_txt rptcreatedby rptcreatedate LASTDATAUPDATE query ;
	put stability_samp_stor_cond stability_study_nbr_cd stability_samp_time_val result resultu
             Indvl_tst_rslt_device METHOD LAB_TST_METH  DATASTATUS  
             Indvl_tst_rslt_val_char /* removed V9 low_limit upr_limit */ samp_tst_dt2 &ANALYSTVAR STABILITY_SAMP_PRODUCT
             matl_batch_nbr stability_study_purpose_txt rptcreatedby rptcreatedate LASTDATAUPDATE query ;
	

RUN;
%MEND STDATA;

*************************************************************************************;
*                       MODULE HEADER                                               *;
*-----------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: See LINKS Report SOP REQUIREMENT: See LINKS Report SOP        *;
*   INPUT:            SAVE.LRQUERYRES_BATCHES                                       *;
*   PROCESSING: Create REDATA macro to save batch release data.                     *;
*		Setup Method variable by concatenating Lab_Tst_Meth_Spec_Desc,      *;
*               Indvl_Meth_Stage_Nm, Meth_Peak_Nm. Sort the data.                   *;
*               Create variable ResultN using individual results.  Format and       *;
*               calculate maximum unspecified degradation impurities.               *;
*   OUTPUT:  Dataset LINKSXLS0                                                      *;
*************************************************************************************;
%MACRO REDATA;
	
	%GetCriteria;
	/********************************************/
	/*** IR003 - Changed DATABASE to BATCHES  ***/
	/********************************************/
	DATA LINKSXLS0 ; Length Method $100. ; SET save.LRQueryRes_BATCHES;
	IF Stability_Study_Nbr_Cd='';
	IF Matl_Mfg_Dt GE &New_Start_Dt2 AND Matl_Mfg_Dt LE &New_End_Dt2;
	IF Lab_Tst_Meth_Spec_Desc IN (&List_Method);

		LAB_TST_DESC2=UPCASE(LAB_TST_DESC);  /* Revised V9 */
		/***  Setup specification type                              ***/
		
        RESULTN=INDVL_TST_RSLT_VAL_NUM;

        IF SAMP_STATUS < 17 AND SAMP_STATUS^=. THEN DATASTATUS='Unapproved';
        ELSE IF SAMP_STATUS >= 17 THEN DATASTATUS='Approved';
		Matl_Batch_Nbr=TRIM(Matl_Nbr)||'-'||TRIM(LEFT(Batch_Nbr));  /* Modified V8 */

        IF Indvl_Meth_Stage_Nm^='NONE' AND Meth_Peak_Nm^='NONE' THEN
                        Method=TRIM(Lab_Tst_Meth_Spec_Desc)||'-'||TRIM(Indvl_Meth_Stage_Nm)||'-'||TRIM(Meth_Peak_Nm);
        ELSE IF Indvl_Meth_Stage_Nm ='NONE' AND Meth_Peak_Nm^='NONE' THEN Method=TRIM(Lab_Tst_Meth_Spec_Desc)||'-'||TRIM(Meth_Peak_Nm);
        ELSE IF Indvl_Meth_Stage_Nm^='NONE' AND Meth_Peak_Nm ='NONE' THEN
                 Method=TRIM(Lab_Tst_Meth_Spec_Desc)||'-'||TRIM(Indvl_Meth_Stage_Nm);
        ELSE  Method=TRIM(Lab_Tst_Meth_Spec_Desc);

		IF UPCASE(METHOD) IN ("HPLC RELATED IMP. IN ADVAIR MDPI-TOTAL") THEN
        METHOD = "HPLC Related Imp. in Advair MDPI-Total Degradation Impurities";

		IF UPCASE(METHOD) IN ("HPLC RELATED IMP. IN ADVAIR MDPI-UNSPECIFIED-FLUTICASONE") 
		THEN DO;
        	IF INDVL_TST_RSLT_NM='' THEN METHOD = "HPLC Related Imp. in Advair MDPI-Any Unspecified Fluticasone Related Degradent Impurity";
			ELSE METHOD='HPLC RELATED IMP. IN ADVAIR MDPI-UNSPECIFIED-'||TRIM(LEFT(METH_PEAK_NM))||'-'||LEFT(TRIM(INDVL_TST_RSLT_NM));        
			END;	
	
		IF UPCASE(METHOD) IN ("HPLC RELATED IMP. IN ADVAIR MDPI-UNSPECIFIED-SALMETEROL") THEN DO;
        	IF INDVL_TST_RSLT_NM='' THEN METHOD = "HPLC Related Imp. in Advair MDPI-Any Unspecified Salmeterol Related Degradent Impurity";
        	ELSE METHOD='HPLC RELATED IMP. IN ADVAIR MDPI-UNSPECIFIED-'||TRIM(LEFT(METH_PEAK_NM))||'-'||LEFT(TRIM(INDVL_TST_RSLT_NM));        
			END;	   

		/* Modified V8 */
		Blend_Batch = TRIM(LEFT(SUBSTR(Blend_Batch,INDEX(Blend_Batch,'-')+1))) || '-' || TRIM(LEFT(SUBSTR(Blend_Batch,1,INDEX(Blend_Batch,'-')-1))); 
		Fill_Batch = TRIM(LEFT(SUBSTR(Fill_Batch,INDEX(Fill_Batch,'-')+1))) || '-' || TRIM(LEFT(SUBSTR(Fill_Batch,1,INDEX(Fill_Batch,'-')-1))); 
		Assy_Batch = TRIM(LEFT(SUBSTR(Assy_Batch,INDEX(Assy_Batch,'-')+1))) || '-' || TRIM(LEFT(SUBSTR(Assy_Batch,1,INDEX(Assy_Batch,'-')-1))); 
		Mfg_Batch = TRIM(LEFT(SUBSTR(Mfg_Batch,INDEX(Mfg_Batch,'-')+1))) || '-' || TRIM(LEFT(SUBSTR(Mfg_Batch,1,INDEX(Mfg_Batch,'-')-1))); 
		Pkg_Batch = TRIM(LEFT(SUBSTR(Pkg_Batch,INDEX(Pkg_Batch,'-')+1))) || '-' || TRIM(LEFT(SUBSTR(Pkg_Batch,1,INDEX(Pkg_Batch,'-')-1))); 
	
		Result=INDVL_TST_RSLT_VAL_NUM;
        	    Resultu=INDVL_TST_RSLT_VAL_UNIT;
        	
		IF Samp_Tst_Dt=. THEN Samp_Tst_Dt=DHMS(MDY(01,01,1960),00,00,00);
		
		/*********************************************************/
		/*** V10 - Added MFG and PKG information               ***/ 
		/*********************************************************/
		LENGTH Samp_Tst_Dt2 MATL_MFG_DT2 BLEND_mfg_dt2 FILL_MFG_DT2 ASSY_MFG_DT2 MFG_MFG_DT2 PKG_MFG_DT2 $15.;  	    
			if samp_tst_dt ^=.  then samp_tst_dt2       = PUT(DATEPART(samp_tst_dt),DATE11_.);	
			if matl_mfg_dt ^=.  then MATL_MFG_DT2       = PUT(DATEPART(MATL_MFG_DT),DATE11_.);	
			if blend_mfg_dt ^=. then BLEND_mfg_dt2      = PUT(DATEPART(BLEND_mfg_dt),DATE11_.);	
			if fill_mfg_dt ^=.  then FILL_MFG_DT2       = PUT(DATEPART(FILL_MFG_DT),DATE11_.);	
			if assy_mfg_dt ^=.  then ASSY_MFG_DT2 	    = PUT(DATEPART(ASSY_MFG_DT),DATE11_.);	
			if mfg_mfg_dt  ^=.  then MFG_MFG_DT2        = PUT(DATEPART(MFG_MFG_DT),DATE11_.);	
			if pkg_mfg_dt  ^=.  then PKG_MFG_DT2 	    = PUT(DATEPART(PKG_MFG_DT),DATE11_.);	
			CALL SYMPUT('datefmt','$15.');

	RUN;

*************************************************************************************;
*                       MODULE HEADER                                               *;
*-----------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: See LINKS Report SOP REQUIREMENT: See LINKS Report SOP        *;
*   INPUT:   Macro variable Save_Uid, Save_Last_Update_Date,                        *;
*            Save_Last_Update_Time, SAVE_ITEM_DESCRIPTIONLST,                       *;
*            SAVE_CREATE_START_DTLST, SAVE_CREATE_END_DTLST,                        *;
*            save_lab_tst_meth_spec_desclst. Dataset LINKSXLS0                      *;
*   PROCESSING: Setup variables Query, RptCreatedBy, RptCreateDate,                 *;
*               and LastDataUpdate.  Merge new variables with LINKSXLS0 dataset     *;
*               so new variables are populated only on the first line.              *;
*               Setup variable resultn depending on test                            *;
*               method and PKS_Format value.  Create DATASTATUS variable            *;
*               which is 'Approved' if SAMP_STATUS is >= 17 or 'Unapproved' if      *;
*               SAMP_STATUS is < 17. Execute Checkrole macro.                       *;
*		Order and label variables in dataset.                               *;
*   OUTPUT:  Dataset LINKSXLS1                                                      *;
*************************************************************************************;
	*** Create dataset for first line of report ***;
	DATA FIRSTLINE; LENGTH studygrps studies storcond tests $1000;
		OBSNBR=1;
        products=trim(TRANWRD(SYMGET('SAVE_PROD_NMLST'), '^','"'));
        startdate=trim(SYMGET('New_Start_Dt2'));
        enddate=trim(SYMGET('New_End_Dt2'));
        tests=trim(SYMGET('List_Method'));
        Query=  'Products: '                ||trim(products) ||
                ' Start Date Range: '       ||trim(startdate) ||
		' End Date Range: '         ||trim(enddate)   ||
                ' Tests: '                  ||trim(tests) ;
        RptCreatedby = "&save_uid";
        RptCreateDate=PUT(DATE(),MMDDYY10.)||', '||PUT(TIME(),TIMEAMPM9.);
        LastDataUpdate = trim("&save_last_update_date")||', '||trim(left("&save_last_update_TIME"));
	RUN;

	%CHECKROLE;

	PROC SORT DATA=LINKSXLS0 NODUPKEY;
        BY    MATL_BATCH_nbr MATL_MFG_DT METHOD result resultu Indvl_tst_rslt_device 
	      Indvl_tst_rslt_val_char LAB_TST_METH datastatus samp_tst_dt 
	      &ANALYSTVAR  BLEND_batch BLEND_mfg_dt BLEND_DESC 
	      FILL_BATCH FILL_MFG_DT FILL_DESC
	      ASSY_BATCH ASSY_MFG_DT ASSY_DESC res_Id indvl_tst_rslt_row Indvl_tst_rslt_nm METH_VAR_NM;
	RUN;

	PROC SORT DATA=LINKSXLS0; BY MATL_MFG_DT; RUN;
	DATA LINKSXLS0; SET LINKSXLS0; RETAIN OBSNBR 0; OBSNBR=OBSNBR+1; RUN;

	%GLOBAL MDPIFLAG MDIFLAG SOLIDFLAG batchlist keeplist;
	*** Merge first line into STABXLS0 dataset and create DataStatus variable. ***;
	DATA BATCHXLS1; LENGTH DATASTATUS $15 indvl_tst_rslt_device_num 8; MERGE FIRSTLINE LINKSXLS0 ; BY OBSNBR;
	if prod_grp='MDPI'       then CALL SYMPUT('MDPIFLAG','YES');   /* Added V7  */
	if prod_grp='Solid Dose' then CALL SYMPUT('SOLIDFLAG','YES');  /* Added V10 */
	if prod_grp='MDI'        then CALL SYMPUT('MDIFLAG','YES');    /* Added V10 */
	put prod_grp;
    indvl_tst_rslt_device_num=indvl_tst_rslt_device;
	RUN;

	/*********************************************************/
	/*** V7  - Added			               ***/
	/*** V10 - Modified %ELSE changing to MFG and PKG      ***/ 
	/*********************************************************/

	DATA _NULL_;  
	%IF %SUPERQ(MDPIFLAG)=YES %THEN %DO;
		%LET BATCHLIST = BLEND_batch $15. BLEND_mfg_dt2 &DATEFMT BLEND_DESC $75.
	       		     	 FILL_BATCH $15.  FILL_MFG_DT2 &DATEFMT FILL_DESC $75. 
	       			 ASSY_BATCH $15. ASSY_MFG_DT2 &DATEFMT ASSY_DESC $75.;
		%LET KEEPLIST = BLEND_batch BLEND_mfg_dt2  BLEND_DESC FILL_BATCH FILL_MFG_DT2 FILL_DESC  
	       			 ASSY_BATCH ASSY_MFG_DT2 ASSY_DESC ;
	%END;
	%ELSE %DO;
		%LET BATCHLIST= MFG_BATCH $15. MFG_MFG_DT2 &DATEFMT MFG_DESC $75.
				PKG_BATCH $15.  PKG_MFG_DT2 &DATEFMT PKG_DESC $75. ;
		%LET KEEPLIST = MFG_BATCH MFG_MFG_DT2 MFG_DESC PKG_BATCH PKG_MFG_DT2 PKG_DESC ;
	%END;

	/* Changed variable names V4 */

	/*********************************************************/
	/*** IR002 - Changed "Filled" variable names to "Fill" ***/
	/*** V5 - Added Indvl_tst_rslt_device to spreadsheet   ***/
	/*********************************************************/

	PROC SQL;CREATE INDEX SORTED1 ON BATCHXLS1(STABILITY_SAMP_PRODUCT, MATL_BATCH_NBR, METHOD, INDVL_TST_RSLT_DEVICE_NUM);QUIT;

	DATA LINKSXLS1;
        FORMAT STABILITY_SAMP_PRODUCT $60. MATL_BATCH_NBR $40. MATL_MFG_DT2 &DATEFMT METHOD $100. result resultu 10.5 Indvl_tst_rslt_device $40.
	       Indvl_tst_rslt_val_char $50.   LAB_TST_METH $50. DATASTATUS $15. samp_tst_dt2 &DATEFMT 
	       &ANALYSTVAR &FORMAT &BATCHLIST  
	       rptcreatedby rptcreatedate LastDataUpdate $35. query $1000.;
        SET BATCHXLS1;
		BY STABILITY_SAMP_PRODUCT MATL_BATCH_NBR METHOD INDVL_TST_RSLT_DEVICE_NUM;

        LABEL   STABILITY_SAMP_PRODUCT		= "Product"
                result				= "Numeric Result "
                resultu				= "Numeric Result (units)"
                Indvl_tst_rslt_device 		= "Device"
                method				= "Test Method Description"
                lab_tst_meth			= "Method Number"
                samp_tst_dt2			= "Test Date"
                indvl_tst_rslt_val_char		= "Character Result"
       		MATL_BATCH_NBR			= "Material-Batch Number"
		MATL_MFG_DT2			= "Manufacture Date"
		Query				= "Report query conditions"
                RptCreatedBy			= "Report created by"
                RptCreateDate			= "Report create date"
                CHECKED_BY_USER_ID		= "Analyst"
                DATASTATUS			= "LIMS Data Status"
                lastdataupdate			= "Last LINKS data update"
				;

		%IF %SUPERQ(MDPIFLAG)=YES %THEN %DO;  /* added V7 */
		label
		BLEND_batch			= "Blend Number "
		FILL_BATCH			= "Fill Number "
		ASSY_BATCH			= "Assembled Number  "
		BLEND_mfg_dt2			= "Blend Nbr Manufacture Date"
		FILL_MFG_DT2			= "Fill Nbr Manufacture Date "
		ASSY_MFG_DT2			= "Assembled Nbr Manufacture Date"
		BLEND_DESC			= "Blend Nbr Description (MDPI ONLY)"
		FILL_DESC			= "Fill Nbr Description (MDPI ONLY)"
		ASSY_DESC			= "Assembled Nbr Description (MDPI ONLY)";
		%END;

		%ELSE %DO;
		label
		Pkg_BATCH			= "Packaged Batch Number"
		Pkg_MFG_DT2			= "Packaging Date"
		Mfg_MFG_DT2			= "Manufacture Date"
		Mfg_BATCH			= "Manufactured Batch Number"
		Mfg_DESC			= "Manufactured Batch Description"
		Pkg_DESC			= "Packaged Batch Description";
		%END;
		
		
            
        KEEP Stability_samp_product MATL_BATCH_nbr MATL_MFG_DT2 METHOD result resultu Indvl_tst_rslt_device 
	      Indvl_tst_rslt_val_char /* removed V9 low_limit upr_limit */ LAB_TST_METH datastatus samp_tst_dt2 
	      &ANALYSTVAR  &KEEPLIST  /*added V7 */
	      rptcreatedby rptcreatedate LASTDATAUPDATE query;
		  
		
	RUN;

%MEND REDATA;


	

*************************************************************************************;
*                       MODULE HEADER                                               *;
*-----------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: See LINKS Report SOP REQUIREMENT: See LINKS Report SOP        *;
*   INPUT:            SAVE.LRQUERYRES_BATCHES                                       *;
*   PROCESSING: Create REDATA macro to save batch release data.                     *;
*		Setup Method variable by concatenating Lab_Tst_Meth_Spec_Desc,      *;
*               Indvl_Meth_Stage_Nm, Meth_Peak_Nm. Sort the data.                   *;
*               Create variable ResultN using individual results.  Format and       *;
*               calculate maximum unspecified degradation impurities.               *;
*   OUTPUT:  Dataset LINKSXLS0                                                      *;
*************************************************************************************;
%MACRO HELP;

	DATA _NULL_; length LINE $500; file _WEBOUT;
	  SaveRptType="&Save_RptType";
	  PUT 	'<BODY BGCOLOR="#808080">';
	  PUT 	'<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" BORDER="0" CELLPADDING="0" CALLSPACING="0">';
	  PUT 	'<TR ALIGN="LEFT" ><TD BGCOLOR="#003366">';
	  LINE=	'<BIG><BIG><BIG><IMG SRC="http://'||"&_server"||'/links/images/gsklogo1.gif" WIDTH="141" HEIGHT="62">'; PUT LINE;
	  IF SaveRptType='ST' THEN PUT 	'<FONT FACE=ARIAL COLOR="#FFFFFF"><EM> LINKS </EM> Stability Module</FONT>';
	  IF SaveRptType='RE' THEN PUT 	'<FONT FACE=ARIAL COLOR="#FFFFFF"><EM> LINKS </EM> Batch Trending Module</FONT>';
	  IF SaveRptType='MD' THEN PUT 	'<FONT FACE=ARIAL COLOR="#FFFFFF"><EM> LINKS </EM> MDPI Data Module</FONT>';
	  PUT 	'</BIG></BIG></BIG></TD></TR>';

	  LINE=   '<TR><TD HEIGHT="87%" BGCOLOR="#FFFFDD" valign=top><p ALIGN=center><STRONG><BIG><BIG>';  PUT LINE;
	  PUT   '<FONT FACE=ARIAL COLOR="#FF0000"></BR><U>LINKS/MDPI Help</U>';
	  PUT   '</BIG></BIG></FONT></BR></BR></BR></BR></BR></BR>';
	  PUT   '<FONT FACE=ARIAL>No Help Available at this time';
	  PUT   '</BR></BR></BR></BR></BR></BR></BR></BR></BR></BR></BR></BR>';

	  PUT '<TABLE ALIGN="center" WIDTH="80%"><TR><TD>';
	  PUT '<EM><FONT FACE=arial COLOR="#003366"><p ALIGN=center>';
	  PUT "Please press `Back` in your web browser or one of the links at the bottom right to continue.</FONT></EM>";
	  PUT '</TD></TR></BR></BR>';
	  PUT '</TABLE>';
	  PUT '</TD></TR>';
	  PUT '<TR ALIGN="right" ><TD BGCOLOR="#003366">';

	  IF SaveRptType IN ('ST','RE') THEN DO;
 	  LINE = '<A HREF="//'||SYMGET('_server')||'/links/'||"&SAVE_linkshome"||'.ASP?UserRole='|| "%SUPERQ(Save_UserRole)" ||'">'; PUT LINE;
	  LINE = '<FONT FACE=ARIAL COLOR="#FFFFFF">LINKS Home</FONT></a>&nbsp&nbsp'; PUT LINE;
	  END;
	  IF SaveRptType IN ('MD') THEN DO;
 	  LINE = '<A HREF="//'||SYMGET('_server')||'/links/'||"MDPI_Menus.ASP?UserRole=LevelB&MenuType=CofA"||'">'; PUT LINE;
	  LINE = '<FONT FACE=ARIAL COLOR="#FFFFFF">MDPI Home</FONT></a>&nbsp&nbsp'; PUT LINE;
	  END;

	  anchor1= '<A HREF="'|| "%SUPERQ(_THISSESSION)" || 
				'&_program='||"LINKS.LRXLSData.sas"||
				'&help=HELP"><FONT FACE=ARIAL COLOR="#FFFFFF">Help</FONT></A>'; 
	  PUT anchor1; 

	  anchor2= '&nbsp;&nbsp;<A HREF="'|| "%SUPERQ(_THISSESSION)" || 
		'&_program=LINKS.LRLogoff.sas"><FONT FACE=ARIAL COLOR="#FFFFFF">Log off</FONT></A>&nbsp;&nbsp;'; 
	  PUT anchor2; 
	  PUT '</TD></TR></TABLE></body></html>';


%MEND HELP;
*************************************************************************************;
*                       MODULE HEADER                                               *;
*-----------------------------------------------------------------------------------*;
*   DESIGN COMPONENT: See LINKS Report SOP REQUIREMENT: See LINKS Report SOP        *;
*   INPUT:     Macro variable Save_rpttype. Dataset LINKSXLS2                       *;
*   PROCESSING: If the rpttype is ST, call the macro STDATA. Otherwise call         *;
*	the macro REDATA.  Call ds2csv macro.                                       *;
*   OUTPUT:  CSV file named LINKSXLSData.csv                                        *;
*************************************************************************************;
%MACRO DECIDE;

%put _all_;
%LET DATETYPE=MMM;
	
		%IF %SUPERQ(HELP)=HELP %THEN %DO;			%Help;%END;
		%ELSE %IF %SUPERQ(SAVE_RPTTYPE)=RE %THEN %DO;
			 %IF %SUPERQ(SCREEN)= %THEN %DO;
				%SetUp; 
				%IF %SUPERQ(NODATAERR)= %THEN %DateList; 
				%END;		
			%ELSE %IF %SUPERQ(SCREEN)=TESTLIST %THEN %DO;
					%IF %SUPERQ(STOP)=TIMEMESSAGE %THEN %WARNING;
					%ELSE %TESTLIST;
					%END;
			%ELSE %IF %SUPERQ(SCREEN)=REPORTS %THEN %DO;
				%REDATA;
				%ds2csv(data=LINKSXLS1, labels=Y, formats=Y, colhead=Y,conttype=y,contdisp=y,savefile=LINKSXLSData.csv,
					csvfref=_webout, runmode=s, openmode=replace);
				%END;
		%END; 
		%ELSE %IF %SUPERQ(SAVE_RPTTYPE)=ST %THEN %DO;
				%STDATA;
					%ds2csv(data=LINKSXLS1, labels=Y, formats=Y, colhead=Y,conttype=y,contdisp=y,savefile=LINKSXLSData.csv,
					csvfref=_webout, runmode=s, openmode=replace);
				%END;
			
%MEND;

%DECIDE;
