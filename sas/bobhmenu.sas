	/* DEBUG */
	/* http://rtpsawn321/sasweb/cgi-bin/broker.exe?_service=default&_program=LINKS.bobhmenu.sas&UID=rsh86800&Submit=Control+Table+Menu&_debug=131 */
	**********************************************************************************;
	*                     PROGRAM HEADER                                             *;
	*--------------------------------------------------------------------------------*;
	*       PROJECT NUMBER: ZE0-986025-1                                             *;
	*       PROGRAM NAME: LACtlTblMenu.SAS               SAS VERSION: 8.1            *;
	*       DEVELOPED BY: Carol Hiser                    DATE: 10/20/02              *;
	*       PROJECT REPRESENTATIVE: Carol Hiser                                      *;
	*       PURPOSE: Create screens to execute LACtlTblRd and LACtlTblUpd.           *;
	*       SINGLE USE OR MULTIPLE USE? (SU OR MU) MU                                *;
	*       PROGRAM ASSUMPTIONS OR RESTRICTIONS: The LINKS database must be up and   *;
	*       running for this program to work.                                        *;
	*--------------------------------------------------------------------------------*;
	*       OTHER SAS PROGRAMS, MACROS OR MACRO VARIABLES USED IN THIS               *;
	*       PROGRAM:    GetParms.sas                                                 *;
	*--------------------------------------------------------------------------------*;
	*       DESCRIPTION OF OUTPUT: 4 screens (menu, LACtlTblRd, LACtlTblUpd, Help)   *;
	**********************************************************************************;
	*                     HISTORY OF CHANGE                                          *;
	* +-----------+---------+--------------+---------------------------------------+ *;
	* |   DATE    | VERSION | NAME         | Description                           | *;
	* +-----------+---------+--------------+---------------------------------------+ *;
	*  10/20/2002 |    1.0  | Carol Hiser  | Original                                *;
	* +-----------+---------+--------------+---------------------------------------+ *;
	*  02xxx2006  |    2.0  | Bob Heckel   | VCC54956                                *;
	**********************************************************************************;
	*                       SETUP MODULE                                             *;
	*--------------------------------------------------------------------------------*;

	*************************************************************************;
	*                       MODULE HEADER                                   *;
	*-----------------------------------------------------------------------*;
	*       DESIGN COMPONENT: SEE LINKS SDS     REQUIREMENT: SEE LINKS FRS  *;  
	*       INPUT:  Passed parameter &UID									*; 
	*       PROCESSING: Create a session and save &UID as a global variable.*;
	*       OUTPUT:  Global variable Save_UID								*;
	*************************************************************************;
	
%MACRO INIT;
	%GLOBAL SAVE_UID;
	%LET rc=%SYSFUNC(appsrv_session(create));
	%LET SAVE_UID=&UID;
%MEND INIT;

	*************************************************************************;
	*                       MODULE HEADER                                   *;
	*-----------------------------------------------------------------------*;
	*       DESIGN COMPONENT: SEE LINKS SDS     REQUIREMENT: SEE LINKS FRS  *;  
	*       INPUT:  NONE											  		*; 
	*       PROCESSING: Create menu screen with 2 buttons to generate	    *;
	*					LACtlTblRd and LACtlTblUpd screens.					*;
	*       OUTPUT:  1 screen												*;
	*************************************************************************;
	
%MACRO LAAdminMenu;
	DATA _NULL_;
		LENGTH anchor LINE $1000;
		FILE _WEBOUT;

		PUT	'<body bgcolor="#808080">';
		PUT	'<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" border="0" cellpadding="0" cellspacing="0">';
		PUT	'<TR align="LEFT" ><TD bgcolor="#003366">';
		line=	'<big><big><big><img src="http://'||"&_server"||'/links/images/gsklogo1.gif" width="141" height="62">'; put line;
		PUT	'<font FACE=ARIAL color="#FFFFFF"><em> LINKS </em> Control Table Module</FONT>';
		PUT	'</big></big></big></TD></TR>';

		line =	'<tr VALIGN="TOP"><td  HEIGHT="87%" BGCOLOR="#ffffdd" align=center>'; PUT line;
		PUT	'</br></br></br><p align=center><big><big><big><strong>';
		PUT	'<font color="#003366">Control Table Main Menu</font></big></big></big></strong><p>'; 
		
		line=  	'<p align=center><form method=GET action="'||"&_url"||'">'; PUT line;
		PUT 	'<input type="hidden" name="_service" value="default">';
/***		line= 	'<input type="hidden" name="_program" value=LINKS.LACtlTblMenu.sas>'; PUT line;***/
		line= 	'<input type="hidden" name="_program" value=LINKS.bobhmenu.sas>'; PUT line;
		PUT 	'<input type="hidden" name="_debug" value="131">';
		line= 	'<input type=hidden name=_server value='||SYMGET('_server')||'>';  PUT line;
		line= 	'<input type=hidden name=_port value='||SYMGET('_port')||'>';  PUT line;
		line= 	'<input type=hidden name=_sessionid value='||SYMGET('_sessionid')||'>';  PUT line;
		line= 	'<input type=hidden name=pecORspec value="PEC">';  PUT line;
		line= 	'<input type=hidden name=menu value="LACtlTblRd">';  PUT line;
		PUT 	'<br><input type="submit" name="Submit" value="  Read LINKS PEC Table"';
		PUT 	' style="background-color: rgb(192,192,192); color: rgb(0,0,0);';	
		PUT 	' font-size: 9pt; font-family: Arial ; font-weight: bolder;';
		PUT 	' letter-spacing: 0px; text-align: center; vertical-align: baseline; ';
		PUT 	' border: medium outset; padding-top: 2px; padding-bottom: 4px">';
		PUT 	'</form>'; 

		LINE= 	'<p align=center><form method=GET action="'||"&_url"||'">'; PUT LINE;
		PUT 	'<input type="hidden" name="_service" value="default">';
/***		line= 	'<input type="hidden" name="_program" value=LINKS.LACtlTblMenu.sas>'; PUT line;***/
		line= 	'<input type="hidden" name="_program" value=LINKS.bobhmenu.sas>'; PUT line;
		PUT 	'<input type="hidden" name="_debug" value="0">';
		line= 	'<input type=hidden name=_server value='||SYMGET('_server')||'>';  PUT line;
		line= 	'<input type=hidden name=_port value='||SYMGET('_port')||'>';  PUT line;
		line= 	'<input type=hidden name=_sessionid value='||SYMGET('_sessionid')||'>';  PUT line;
		line= 	'<input type=hidden name=pecORspec value="PEC">';  PUT line;
		line= 	'<input type=hidden name=menu value="LACtlTblUpd">';  PUT line;
		PUT 	'<input type="submit" name="Submit" value="Update LINKS PEC Table"';
		PUT 	' style="background-color: rgb(192,192,192); color: rgb(0,0,0);';
		PUT 	' font-size: 9pt; font-family: Arial ; font-weight: bolder;';
		PUT 	' letter-spacing: 0px; text-align: center; vertical-align: baseline; ';
		PUT 	' border: medium outset; padding-top: 2px; padding-bottom: 4px">';
		PUT 	'</form>'; 

		/* Read Spec - Added V2 */
		line=  	'<p align=center><form method=GET action="'||"&_url"||'">'; PUT line;
		PUT 	'<input type="hidden" name="_service" value="default">';
/***		line= 	'<input type="hidden" name="_program" value=LINKS.LACtlTblMenu.sas>'; PUT line;***/
		line= 	'<input type="hidden" name="_program" value=LINKS.bobhmenu.sas>'; PUT line;
		PUT 	'<input type="hidden" name="_debug" value="131">';
		line= 	'<input type=hidden name=_server value='||SYMGET('_server')||'>';  PUT line;
		line= 	'<input type=hidden name=_port value='||SYMGET('_port')||'>';  PUT line;
		line= 	'<input type=hidden name=_sessionid value='||SYMGET('_sessionid')||'>';  PUT line;
		line= 	'<input type=hidden name=pecORspec value="Specification">';  PUT line;
		line= 	'<input type=hidden name=menu value="LACtlTblRd">';  PUT line;
		PUT 	'<br><br><input type="submit" name="Submit" value="  Read LINKS Specification Table"';
		PUT 	' style="background-color: rgb(192,192,192); color: rgb(0,0,0);';	
		PUT 	' font-size: 9pt; font-family: Arial ; font-weight: bolder;';
		PUT 	' letter-spacing: 0px; text-align: center; vertical-align: baseline; ';
		PUT 	' border: medium outset; padding-top: 2px; padding-bottom: 4px">';
		PUT 	'</form>'; 

		/* Write Spec - Added V2 */
		line=  	'<p align=center><form method=GET action="'||"&_url"||'">'; PUT line;
		PUT 	'<input type="hidden" name="_service" value="default">';
/***		line= 	'<input type="hidden" name="_program" value=LINKS.LACtlTblUpd.sas>'; PUT line;***/
		line= 	'<input type="hidden" name="_program" value=LINKS.bobhmenu.sas>'; PUT line;
		PUT 	'<input type="hidden" name="_debug" value="131">';
		line= 	'<input type=hidden name=_server value='||SYMGET('_server')||'>';  PUT line;
		line= 	'<input type=hidden name=_port value='||SYMGET('_port')||'>';  PUT line;
		line= 	'<input type=hidden name=_sessionid value='||SYMGET('_sessionid')||'>';  PUT line;
		line= 	'<input type=hidden name=pecORspec value="Specification">';  PUT line;
		line= 	'<input type=hidden name=menu value="LACtlTblUpd">';  PUT line;
		PUT 	'<input type="submit" name="Submit" value="  Update LINKS Specification Table"';
		PUT 	' style="background-color: rgb(192,192,192); color: rgb(0,0,0);';	
		PUT 	' font-size: 9pt; font-family: Arial ; font-weight: bolder;';
		PUT 	' letter-spacing: 0px; text-align: center; vertical-align: baseline; ';
		PUT 	' border: medium outset; padding-top: 2px; padding-bottom: 4px">';
		PUT 	'</form>'; 

		PUT 	'</td></tr>';
		PUT 	'<TR align="right" ><TD bgcolor="#003366">';
		LINE= 	'<A HREF="//'||SYMGET('_SERVER')||'/links/Sys_Admin.ASP"><font FACE=ARIAL color="#FFFFFF">LINKS Home</font></a>&nbsp&nbsp'; PUT LINE;

		anchor= '<A HREF="'|| "%SUPERQ(_THISSESSION)" ||
				'&_program=LINKS.LACtlTblMenu.sas&menu=HELP">
				<font FACE=ARIAL color="#FFFFFF">LINKS Help</font></A>'; 
		PUT anchor; 

		anchor= '<A HREF="'|| "%SUPERQ(_THISSESSION)" ||
				'&_program=LINKS.LRLogoff.sas"><font FACE=ARIAL color="#FFFFFF">Log off</font></A>'; 
		PUT anchor; 

		PUT 	'</TD></TR></table></body></html>';
	RUN;
%MEND LAAdminMenu;

	*************************************************************************;
	*                       MODULE HEADER                                   *;
	*-----------------------------------------------------------------------*;
	*       DESIGN COMPONENT: SEE LINKS SDS     REQUIREMENT: SEE LINKS FRS  *;  
	*       INPUT:  All files in control directory/new folder				*; 
	*       PROCESSING: Determine list of .xls filenames contained in 		*;
	*		ctlDir.New directory.  Use the list to create a dropdown box	*;
	*		form to submit LACtlTblUpd.  If no files exist, disable form.	*;
	*       OUTPUT:  1 Screen												*;
	*************************************************************************;

%MACRO LACtlTblUpd(runwhich);
	/* Determine control directory */
	%LET CtlDir   = ;
	%GetParm(SasServer, CtlDir, N);		%LET CtlDir     = &parm;
	
	%GLOBAL disable;
	/* Create text file of all files in CtlDir.New directory */
	DATA _NULL_;
		dirrc = SYSTEM("DIR &CtlDir.New\*.XLS >&CtlDir.LAAdmin.txt");
	RUN;
	/* Read in text file */
	DATA LAAdmin01b;
		INFILE "&CtlDir.LAAdmin.txt"
				LENGTH=flen TRUNCOVER END=eofflg;
		LENGTH 	dsn		$57;
		INPUT @40 dsn $57.;
		IF INDEX(UPCASE(dsn),'.XLS') > 0 THEN OUTPUT;
		IF INDEX(UPCASE(dsn),'.XLS') > 0 THEN PUT '+++' dsn $57. '+++';
	RUN;
	/* Create record for no files exist */
	DATA LAAdmin01c;
		dsn = '--- No Files Exist ---';
	RUN;

	DATA LAAdmin01d;
		SET	LAAdmin01b
			LAAdmin01c;
	RUN;

	PROC SORT ;
		BY descending dsn ;
	RUN;
	/* Create variable for number of files, numlist. If number of files=1 then set 
	   disable variable to disabled, otherwise set subtract 1 from number
	   of files   */
	DATA datalist1;
		SET LAAdmin01d NOBS=MAXOBS; 
		RETAIN obsnum 0;
		PUT maxobs;
  		obsnum=obsnum+1; OUTPUT;
  		IF maxobs>1 THEN CALL SYMPUT('numlist', maxobs-1);
		 ELSE IF maxobs=1 THEN DO;
			CALL SYMPUT('numlist', 1);
			CALL SYMPUT('disable','disabled="disabled"');
			END;
	RUN;
	/* Create Screen */
	DATA _NULL_; LENGTH line $1000; FILE _WEBOUT;

		PUT 	'<body bgcolor="#808080">';
		PUT 	'<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" border="0" cellpadding="0" cellspacing="0">';
		PUT 	'<TR align="LEFT" ><TD bgcolor="#003366">';
		line=	'<big><big><big><img src="http://'||"&_server"||'/links/images/gsklogo1.gif" width="141" height="62">'; put line;
		PUT 	'<font FACE=ARIAL color="#FFFFFF"><em> LINKS </em> PKS Extraction Control Table / Specification Module</FONT>';
		PUT 	'</big></big></big></TD></TR>';

		PUT 	'<tr><td valign=top height="87%" bgcolor="#FFFFDD">';
		PUT 	'</br></br></br><p align=center><strong><font FACE=ARIAL color="#FF0000">';
		PUT 	'<big><big>You have chosen to submit the program: LACtlTblUpd.</font></big></big>';
		PUT 	"</br></br><font FACE=ARIAL color="#003366"><em>This program will update the LINKS &pecORspec table using the selected data file.</font></em>";
		PUT 	'</font></strong><p>'; 
		line= 	'<form method="post" action="'||"&_URL"||'">'; PUT line;
		PUT 	'<input type="hidden" name="_service" value="default">';
/***		line= 	'<input type="hidden" name="_program" value=LINKS.LACtlTblUpd.sas>'; PUT line;***/
		line= 	'<input type="hidden" name="_program" value=LINKS.bobhupdate.sas>'; PUT line;
		PUT 	'<input type="hidden" name="_debug" value="131">';
		PUT 	'<input type="hidden" name="INIT" value="NO">';
		line= 	'<input type=hidden name=_server value='||SYMGET('_server')||'>';  PUT line;
		line= 	'<input type=hidden name=_port value='||SYMGET('_port')||'>';  PUT line;
		line= 	'<input type=hidden name=_sessionid value='||SYMGET('_sessionid')||'>';  PUT line;
		line= 	"<input type=hidden name=pecORspec value=&runwhich>";  PUT line;
		PUT 	'<table align=center><tr><td valign=top align=right><STRONG>';

		PUT 	'<font FACE=ARIAL color="#003366">Select data file name:</FONT></STRONG></td>';
		line= 	'<td valign=top align=left><select name=DSN size=1 '||trim(SYMGET('disable'))||'>'; PUT line;
	RUN;

	%dropdown(datalist1,dsn);  /* Generate drop down list */

	DATA _NULL_; LENGTH line ANCHOR $1000; FILE _WEBOUT;
		PUT 	'<tr><td colspan=2 align=center></br>';
		line= 	'<input type="submit" name="Update" value="Submit Program: LACtlTblUpd"'||trim(SYMGET('disable')); PUT line;
		PUT 	' style="background-color: rgb(192,192,192); color: rgb(0,0,0);';
		PUT 	' font-size: 9pt; font-family: Arial ; font-weight: bolder;';
		PUT 	' letter-spacing: 0px; text-align: center; vertical-align: baseline; ';
		PUT 	' border: medium outset; padding-top: 2px; padding-bottom: 4px">';
		PUT 	'</td></tr></table>';
		PUT 	'</TD></TR>';
		PUT 	'<TR align="right" ><TD bgcolor="#003366">';
		LINE= 	'<A HREF="//'||SYMGET('_SERVER')||'/links/Sys_ADMIN.ASP"><font FACE=ARIAL color="#FFFFFF">LINKS Home</font></a>&nbsp&nbsp'; put line;

		anchor= '<A HREF="'|| "%SUPERQ(_THISSESSION)" ||
				'&_program=LINKS.LACtlTblMenu.sas&menu=HELP">
				<font FACE=ARIAL color="#FFFFFF">LINKS Help</font></A>'; 
		PUT anchor; 

		anchor= '<A HREF="'|| "%SUPERQ(_THISSESSION)" ||
				'&_program=LINKS.LRLogoff.sas"><font FACE=ARIAL color="#FFFFFF">Log off</font></A>'; 
		PUT anchor; 
 
		PUT 	'</TD></TR></table></body></html>';
	RUN;
%MEND LACtlTblUpd;
	*************************************************************************;
	*                       MODULE HEADER                                   *;
	*-----------------------------------------------------------------------*;
	*       DESIGN COMPONENT: SEE LINKS SDS     REQUIREMENT: SEE LINKS FRS  *;  
	*       INPUT:  Meth_Spec_Nm filed from LINKS PEC table.  				*; 
	*       PROCESSING: Determine list of spec names from PEC table.  Create*;
	*		a screen with a drop down box to call LACtlTblRd.				*;
	*       OUTPUT:  1 Screen												*;
	*************************************************************************;

%MACRO LACtlTblRd(runwhich);
	/* Obtain parameters for LINKS database */
	%LET ServerName = ;
	%LET CondCode   = 0;
	%GetParm(SasServer, CtlDir, N);		%LET CtlDir     = &parm;
	%GetParm(SasServer, ServerName, N);	%LET ServerName = &parm;

	%GetParm(DbServer, UserId, N);		%LET OraId = &PARM;
	%GetParm(DbServer, UserPsw, Y);		%LET OraPsw = &parm;
	%GetParm(DbServer, ServerName, N);	%LET OraPath = &parm;
	/* Query LINKS database to obtain a list of all spec names */
	PROC SQL;
		CONNECT TO ORACLE(USER=&OraId ORAPW=&OraPsw BUFFSIZE=5000 PATH="&OraPath");
		CREATE TABLE LAAdmin01a AS SELECT * FROM CONNECTION TO ORACLE (
			SELECT	DISTINCT Meth_Spec_Nm
			FROM	PKS_Extraction_Control
			ORDER BY Meth_Spec_Nm);
		%LET HSQLXRC = &SQLXRC;
		%LET HSQLXMSG = &SQLXMSG;
		DISCONNECT FROM ORACLE;
		QUIT;
		%PUT &SQLXMSG;
		%PUT &SQLXRC;
	RUN;
	/* Count the number of specs */
	DATA datalist1;
		SET 	LAAdmin01a nobs=maxobs;
		BY		meth_spec_nm;
  		RETAIN	obsnum 0;
  		obsnum = obsnum+1; OUTPUT;
  		CALL SYMPUT('numlist', maxobs);
	RUN;
	/* Create method selection screen */
	DATA _NULL_;
		LENGTH line $500;
		FILE _WEBOUT;

		PUT 	'<body bgcolor="#808080">';
		PUT 	'<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" border="0" cellpadding="0" cellspacing="0">';
		PUT 	'<TR align="LEFT" ><TD bgcolor="#003366">';
		line=	'<big><big><big><img src="http://'||"&_server"||'/links/images/gsklogo1.gif" width="141" height="62">'; put line;
		PUT 	'<font FACE=ARIAL color="#FFFFFF"><em> LINKS </em> PKS Extraction Control Table / Specification Module</FONT>';
		PUT 	'</big></big></big></TD></TR>';

		PUT 	'<tr><td height="87%" bgcolor="#FFFFDD" valign=top>';
		PUT 	"<p align=center><strong><big><big><font FACE=ARIAL color='#FF0000'></br></br>You have chosen to submit the program: LACtlTblRd</big></big></font>";
		PUT 	"</br></br><em><font FACE=ARIAL color="#003366">DEBUG This program will read the selected specification from the LINKS &runwhich table </br> and save it to a spreadsheet file.</em></font></br>";
		PUT 	'</font></big></strong><p>'; 
		LINE= 	'<form method="get" action="'||"&_URL"||'">'; PUT LINE;
		PUT 	'<input type="hidden" name="_service" value="default">';
/***		line= 	'<input type="hidden" name="_program" value=LINKS.LACtlTblRd.sas>'; PUT line;***/
		line= 	'<input type="hidden" name="_program" value=LINKS.bobhread.sas>'; PUT line;
		PUT 	'<input type="hidden" name="_debug" value="131">';
		PUT 	'<input type="hidden" name="INIT" value="NO">';
		line= 	'<input type=hidden name=_server value='||SYMGET('_server')||'>';  PUT line;
		line= 	'<input type=hidden name=_port value='||SYMGET('_port')||'>';  PUT line;
		line= 	'<input type=hidden name=_sessionid value='||SYMGET('_sessionid')||'>';  PUT line;
		line= 	"<input type=hidden name=pecORspec value=&runwhich>";  PUT line;
		PUT 	'<table align=center><tr><td valign=top align=right><STRONG>';

		PUT 	'<font FACE=ARIAL color="#003366">Select specification name:</FONT></STRONG></td>';
		PUT 	'<td valign=top align=left><select name=SpecName size=1>';
	RUN;

	%dropdown(datalist1,Meth_Spec_Nm);

	DATA _NULL_; LENGTH LINE ANCHOR $1000; FILE _WEBOUT;
		PUT 	'</td></tr>';
		PUT 	'<tr><td colspan=2 align=center></br><input type="submit" name="Update" value="Submit Program: LACtlTblRd"';
		PUT 	' style="background-color: rgb(192,192,192); color: rgb(0,0,0);';
		PUT 	' font-size: 9pt; font-family: Arial ; font-weight: bolder;';
		PUT 	' letter-spacing: 0px; text-align: center; vertical-align: baseline; ';
		PUT 	' border: medium outset; padding-top: 2px; padding-bottom: 4px">';
		PUT 	'</td></tr></table>';
		PUT 	'</TD></TR>';
		PUT 	'<TR align="right" ><TD bgcolor="#003366">';
		LINE= 	'<A HREF="//'||SYMGET('_SERVER')||'/LINKS/Sys_Admin.ASP"><font FACE=ARIAL color="#FFFFFF">LINKS Home</font></a>&nbsp&nbsp'; put line;

		anchor= '<A HREF="'|| "%SUPERQ(_THISSESSION)" ||
				'&_program=LINKS.LACtlTblMenu.sas&menu=HELP">
				<font FACE=ARIAL color="#FFFFFF">LINKS Help</font></A>'; 
		PUT anchor; 

		anchor= '<A HREF="'|| "%SUPERQ(_THISSESSION)" ||
				'&_program=LINKS.LRLogoff.sas"><font FACE=ARIAL color="#FFFFFF">Log off</font></A>'; 
		PUT anchor; 

		PUT 	'</TD></TR></table></body></html>';
	RUN;
%MEND LACtlTblRd;
	*************************************************************************;
	*                       MODULE HEADER                                   *;
	*-----------------------------------------------------------------------*;
	*       DESIGN COMPONENT: SEE LINKS SDS     REQUIREMENT: SEE LINKS FRS  *;  
	*       INPUT:  None				  									*; 
	*       PROCESSING: Create screen with help text.						*;
	*       OUTPUT:  1 Screen												*;
	*************************************************************************;

%MACRO help;
	DATA _NULL_; LENGTH LINE $1000;
		FILE _WEBOUT;
		PUT 	'<body bgcolor="#808080">';
		PUT 	'<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" border="0" cellpadding="0" cellspacing="0">';
		PUT 	'<TR align="LEFT" ><TD bgcolor="#003366">';
		line=	'<big><big><big><img src="http://'||"&_server"||'/links/images/gsklogo1.gif" width="141" height="62">'; put line;
		PUT 	'<font FACE=ARIAL color="#FFFFFF"><em> LINKS </em> PKS Extraction Control Table Module / Specification</FONT>';
		PUT 	'</big></big></big></TD></TR>';

		PUT 	'<tr><td height="87%" bgcolor="#FFFFDD" valign=top>';
		PUT 	'<p align=center><strong><big><big><font FACE=ARIAL color="#FF0000"></br>LINKS Help</big></big></font>';
		PUT 	'</br></br>';

		PUT 	'<table align=center width="80%"><tr><td>';
		PUT 	'<big><font FACE=ARIAL color="#003366">The LINKS PKS Extraction Control Table / Specification Module provides an interface for LINKS Administrators';
		PUT 	' to perform the following LINKS administrator functions:</big></font>';
		PUT 	'</td></tr>';

		PUT 	'<tr><td align=left><font FACE=ARIAL>';
		PUT 	'</br><strong>"Read LINKS PEC Table Specification"</strong>- This function will read a selected specification from the LINKS';
		PUT 	'PEC (PKS_Extraction_Control) table.  A LINKS Administrator may use this function upon notification of a change to a specification' ;
		PUT 	' contained within the LINKS PEC table.   This screen contains a list of all current specifications contained within';
		PUT 	' the LINKS PEC table.   Submission of this screen will call the program LACtlTblRd which will read the desired';
		PUT 	' specification from the PEC table and save it to a file.  This file can then be modified per the SOP for PEC table maintenance.';
		PUT 	'</font></td></tr>';

		PUT 	'<tr><td align=left><font FACE=ARIAL>';
		PUT 	'</br><strong>"Update LINKS PEC Table Specification"</strong>- This function will update a specification within';
		PUT 	' the LINKS PEC (PKS_Extraction_Control) table.  A LINKS Administrator may use this function to load a selected file';
		PUT 	' containing an updated specification into the LINKS PEC table.</br></br>';
		PUT 	'</font></td></tr></table>';

		PUT 	'</TD></TR>';
		PUT 	'<TR align="right" ><TD bgcolor="#003366">';
		PUT 	'<TR align="right" ><TD bgcolor="#003366">';
		LINE= 	'<A HREF="//'||SYMGET('_SERVER')||'/links/Sys_ADMIN.ASP"><font FACE=ARIAL color="#FFFFFF">LINKS Home</font></a>&nbsp&nbsp'; PUT LINE;

		anchor= '<A HREF="'|| "%SUPERQ(_THISSESSION)" ||
				'&_program=LINKS.LRLogoff.sas"><font FACE=ARIAL color="#FFFFFF">Log off</font></A>'; 
		PUT anchor; 
		PUT '</TD></TR></table></body></html>';
	RUN;
%MEND help;

	*************************************************************************;
	*                       MODULE HEADER                                   *;
	*-----------------------------------------------------------------------*;
	*       DESIGN COMPONENT: SEE LINKS SDS     REQUIREMENT: SEE LINKS FRS  *;  
	*       INPUT:  sasdsn, varnm		  									*; 
	*       PROCESSING: Create macro to generate drop down list.			*;
	*       OUTPUT:  drop down list html code								*;
	*************************************************************************;

%MACRO dropdown(sasdsn,varnm);
	%LOCAL i;
	%DO i = 1 %TO &numlist;
		DATA _NULL_;
			LENGTH option $500;
			SET &sasdsn;
			FILE _webout;
	    		WHERE obsnum=&i;
		 	option= '<option value="'||trim(&varnm)||'">'||trim(&varnm)||'</option>';
		 	PUT option;
   		RUN;
	 	%END;
%MEND dropdown;

	*************************************************************************;
	*                       MODULE HEADER                                   *;
	*-----------------------------------------------------------------------*;
	*       DESIGN COMPONENT: SEE LINKS SDS     REQUIREMENT: SEE LINKS FRS  *;  
	*       INPUT:  SessionID, Menu  										*; 
	*       PROCESSING: If a session does not exist, execute INIT macro		*;
	*		If menu is null, execute LAAdminMenu.  If menu=LACtlTblRd,		*; 
	*		execute LACtlTblRd macro.  If menu=LACtlTblUpd, execute			*;
	*		LACtlTblUpd macro. If menu=Help then execulte Help macro.		*;
	*       OUTPUT:  Various Screens										*;
	*************************************************************************;

%MACRO Decide;
	%IF %SUPERQ(_SESSIONID)=				%THEN %INIT;
	%IF %SUPERQ(menu)= 						%THEN %LAAdminMenu;
	   %ELSE %IF %SUPERQ(menu)=LACtlTblRd	%THEN %LACtlTblRd(&pecORspec);
	   %ELSE %IF %SUPERQ(menu)=LACtlTblUpd	%THEN %LACtlTblUpd(&pecORspec);
	   %ELSE %IF %SUPERQ(menu)=HELP			%THEN %HELP;
%MEND Decide;
OPTIONS SOURCE SOURCE2 MPRINT MLOGIC NOSYMBOLGEN;
%GLOBAL INIT MENU;
OPTIONS	NOXWAIT;

%Decide;
