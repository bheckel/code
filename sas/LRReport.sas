*************************************************************************;
*                     PROGRAM HEADER                                    *;
*-----------------------------------------------------------------------*;
*       PROJECT NUMBER:  LINKS
*       PROGRAM NAME: LRREPORT.SAS          SAS VERSION: 8.2
*       DEVELOPED BY:  Carol Hiser          DATE:  11/05/02
*       PROJECT REPRESENTATIVE:  Carol Hiser
*       PURPOSE:  To generate the LINKS stability menu screen.
*       SINGLE USE OR MULTIPLE USE? (SU OR MU)  MU
*-----------------------------------------------------------------------*;
*       PROGRAM ASSUMPTIONS OR RESTRICTIONS:  None.
*-----------------------------------------------------------------------*;
*       OTHER SAS PROGRAMS, MACROS OR MACRO VARIABLES USED IN THIS PROGRAM:
*       Macro variable Save_RptType.
*-----------------------------------------------------------------------*;
*       DESCRIPTION OF OUTPUT:  1 screen with 3 push buttons, including a
        title banner with GSK logo and a footer banner with hyperlinks to
        LINKS home, LINKS help and Logoff.sas.
*******************************************************************************;
*                     HISTORY OF CHANGE                                       *;
* +-----------+---------+--------------+------------------------------------+ *;
* |   DATE    | VERSION | NAME         | Description                        | *;
* +-----------+---------+--------------+------------------------------------+ *;
*  11/05/2002 |    1.0  | Carol Hiser  | Original                             *;
* +-------------------------------------------------------------------------+ *;
*  11/14/2002 |    2.0  | Carol Hiser  | Removed debug parameter and added    *;
*             |         |              | method parameter.                    *;
* +-------------------------------------------------------------------------+ *;
*  01/07/2003 |    3.0  | James Becker | Added Menu Selections for Product    *;
*             |         |              | Release Section.                     *;
*******************************************************************************;
*                       SETUP MODULE                                          *;
*-----------------------------------------------------------------------------*;
title; footnote;
OPTIONS mprint symbolgen;
%GLOBAL HELP;
%LET METHOD=GET;

*************************************************************************;
*                       MODULE HEADER                                   *;
*-----------------------------------------------------------------------*;
*       DESIGN COMPONENT:  See LINKS SDS    REQUIREMENT:  See LINKS FRS
*       INPUT:  None.
*       PROCESSING:  
*					If reportype is ST then generate html to create screen 
*					with 3 form buttons:
*                        Button 1:  Calls LRSTAnalysis.sas
*                        Button 2:  Calls LRStudyRpt.sas
*                        Button 3:  Calls LRxlsdata.sas
*					If reportype is RE then generate html to create screen
*					with 2 form buttons:
*						 Button 1:  Calls LRBatchAnalysis.sas
*						 Button 2:  Calls LRxlsdata.sas
*                   For both report types, generate title and footer banner 
*					with hyperlinks.
*       OUTPUT:  LRReport screen to web browser.
*************************************************************************;

%MACRO MENUSCREEN;
%put _all_;
DATA _NULL_; LENGTH line $700; FILE _WEBOUT;
        PUT     '<body bgcolor="#808080">';

    /* Title banner */

	%IF %SUPERQ(save_rpttype)=ST %THEN %DO;

        PUT 	'<title>LINKS Stability Module</title>';
        PUT     '<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" border="0" cellpadding="0" cellspacing="0">';
        PUT     '<TR align="LEFT" HEIGHT="8%"><TD bgcolor="#003366">';
        line=   '<big><big><big><img src="http://'||"&_server"||'/links/images/gsklogo1.gif" width="141" height="62">'; put line;
        PUT     '<font FACE=ARIAL color="#FFFFFF"><em> LINKS </em> Stability Module</FONT>';
        PUT     '</big></big></BIG></TD></TR>';

        line = '<tr VALIGN="TOP"><td  HEIGHT="84%" BGCOLOR="#ffffdd" align=center>';    PUT line;

        /* Button 1 */

        PUT     '</br></br><p align=center><font FACE=ARIAL color="#003366"><big><big><strong> Stability Menu </strong></big></big>';
       line=   '</FONT><form method="'||"&METHOD"||'"  action="'||"&_url"||'">'; PUT line;
        PUT     '<inPUT type="hidden" name="_service"   value="default">';
        PUT     '<inPUT type="hidden" name="_program"   value=links.LRSTAnalysis.sas>';
        line=   '<inPUT type="hidden" name="_sessionid" value='||"&_sessionid"||'>';    PUT line;
        line=   '<inPUT type="hidden" name="_server"    value='||"&_server"||'>';       PUT line;
        line=   '<inPUT type="hidden" name="_port"      value='||"&_port"||'>';         PUT line;
        PUT     '<inPUT type="submit" name="Submit"     value="      Stability Analysis Tools      "';
        PUT     ' style="background-color: rgb(192,192,192); color: rgb(0,0,0); ';
        PUT     ' font-size: 11pt; font-family: Arial Bold; font-weight: bolder; ';
        PUT     ' text-align: center; border: medium OUTSET; padding-TOp: 2px; padding-botTOm: 4px">';
        PUT     '</form>';

        /* Button 2 */

        line=   '<form method="'||"&METHOD"||'"  action="'||"&_url"||'">'; PUT line;
        PUT     '<inPUT type="hidden" name="_service"   value="default">';
        PUT     '<inPUT type="hidden" name="_program"   value=links.LRStudyRpt.sas>';
        line=   '<inPUT type="hidden" name="_sessionid" value='||"&_sessionid"||'>';    PUT line;
        line=   '<inPUT type="hidden" name="_server"    value='||"&_server"||'>';       PUT line;
        line=   '<inPUT type="hidden" name="_port"      value='||"&_port"||'>';         PUT line;
        PUT     '<inPUT type="submit" name="Submit"     value="      Stability Study Reports       " ';
        PUT     ' style="background-color: rgb(192,192,192); color: rgb(0,0,0); ';
        PUT     ' font-size: 11pt; font-family: Arial Bold; font-weight: bolder; ';
        PUT     ' text-align: center; border: medium OUTSET; padding-TOp: 2px; padding-botTOm: 4px">';
        PUT     '</form>';

        /* Button 3 */

        line=   '<form method="'||"&METHOD"||'"  action="'||"&_url"||'">'; PUT line;
        PUT     '<inPUT type="hidden" name="_service"   value="default">';
        PUT     '<inPUT type="hidden" name="_program"   value="links.LRxlsDATA.sas">';
        line=   '<inPUT type="hidden" name="_sessionid" value='||"&_sessionid"||'>';    PUT line;
        line=   '<inPUT type="hidden" name="_server"    value='||"&_server"||'>';       PUT line;
        line=   '<inPUT type="hidden" name="_port"      value='||"&_port"||'>';         PUT line;

        PUT     '<inPUT type="submit" name="Submit" value="  Save Data as a Spreadsheet  " ';
        PUT     ' style="background-color: rgb(192,192,192); color: rgb(0,0,0); ';
        PUT     ' font-size: 11pt; font-family: Arial Bold; font-weight: bolder; ';
        PUT     ' text-align: center; border: medium OUTSET; padding-TOp: 2px; padding-botTOm: 4px">';
        PUT     '</form>';

	%END;

	*********************************************************;
	**** PRODUCT RELEASE SECTION   Added V2              ****;
	*********************************************************;

	%IF %SUPERQ(save_rpttype)=RE %THEN %DO;

        PUT 	'<title>LINKS Batch Trending Module</title>';
        PUT     '<TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" border="0" cellpadding="0" cellspacing="0">';
        PUT     '<TR align="LEFT" HEIGHT="8%"><TD bgcolor="#003366">';
        line=   '<big><big><big><img src="http://'||"&_server"||'/links/images/gsklogo1.gif" width="141" height="62">'; put line;
        PUT     '<font FACE=ARIAL color="#FFFFFF"><em> LINKS </em> Batch Trending Module</FONT>';
        PUT     '</big></big></BIG></TD></TR>';

        line = '<tr VALIGN="TOP"><td  HEIGHT="84%" BGCOLOR="#ffffdd" align=center>';    PUT line;

        /* Button 1 */

        PUT     '</br></br><p align=center><font FACE=ARIAL color="#003366"><big><big><strong> Batch Trending Menu </strong></big></big>';
       line=   '</FONT><form method="'||"&METHOD"||'"  action="'||"&_url"||'">'; PUT line;
        PUT     '<inPUT type="hidden" name="_service"   value="default">';
        PUT     '<inPUT type="hidden" name="_program"   value=links.LRBatchAnalysis.sas>';
        line=   '<inPUT type="hidden" name="_sessionid" value='||"&_sessionid"||'>';    PUT line;
        line=   '<inPUT type="hidden" name="_server"    value='||"&_server"||'>';       PUT line;
        line=   '<inPUT type="hidden" name="_port"      value='||"&_port"||'>';         PUT line;
		line=   '<inPUT type="hidden" name="_debug"      value="131">';         PUT line;
        PUT     '<inPUT type="submit" name="Submit"     value="     Batch Trending Tools      "';
        PUT     ' style="background-color: rgb(192,192,192); color: rgb(0,0,0); ';
        PUT     ' font-size: 11pt; font-family: Arial Bold; font-weight: bolder; ';
        PUT     ' text-align: center; border: medium OUTSET; padding-TOp: 2px; padding-botTOm: 4px">';
        PUT     '</form>';
      
        /* Button 2 */

        line=   '<form method="'||"&METHOD"||'"  action="'||"&_url"||'">'; PUT line;
        PUT     '<inPUT type="hidden" name="_service"   value="default">';
        PUT     '<inPUT type="hidden" name="_program"   value="links.LRXLSData.sas">';
        line=   '<inPUT type="hidden" name="_sessionid" value='||"&_sessionid"||'>';    PUT line;
        line=   '<inPUT type="hidden" name="_server"    value='||"&_server"||'>';       PUT line;
        line=   '<inPUT type="hidden" name="_port"      value='||"&_port"||'>';         PUT line;

        PUT     '<inPUT type="submit" name="Submit" value="Save Data as a Spreadsheet" ';
        PUT     ' style="background-color: rgb(192,192,192); color: rgb(0,0,0); ';
        PUT     ' font-size: 11pt; font-family: Arial Bold; font-weight: bolder; ';
        PUT     ' text-align: center; border: medium OUTSET; padding-TOp: 2px; padding-botTOm: 4px">';
        PUT     '</form>';

	%END;

        /*  Footer banner */

        PUT     '</td></tr>';
        PUT     '<TR align="right" HEIGHT="8%"><TD bgcolor="#003366">';
        LINE= '&nbsp;&nbsp;<A HREF="//'||SYMGET('_SERVER')||'/links/'||"&save_linkshome"||'.ASP"><font FACE=ARIAL color="#FFFFFF">LINKS Home</font></a>&nbsp&nbsp';
        PUT LINE;

                anchor1= '&nbsp;&nbsp;<A HREF="'|| "%superq(_THISSESSION)" ||
                                '&_program='||"LINKS.LRReport.sas"||
                                '&help=HELP"><font FACE=ARIAL color="#FFFFFF">LINKS Help</font></A>';
                PUT anchor1;

                line= '&nbsp;&nbsp;<A HREF="'|| "%SUPERQ(_THISSESSION)" ||
                                '&_program=LINKS.LRLogoff.sas"><font FACE=ARIAL color="#FFFFFF">Log off</font></A>';
                PUT line;
        PUT     '<td><tr></table>';
RUN;
%MEND;

*************************************************************************;
*                       MODULE HEADER                                   *;
*-----------------------------------------------------------------------*;
*       DESIGN COMPONENT:  See LINKS SDS    REQUIREMENT:  See LINKS FRS
*       INPUT:  SAVE_RPTTYPE.
*       PROCESSING:  Generate html to create Help screen.
                     Generates title and footer banner with hyperlinks.
*       OUTPUT:  LRReport help screen to web browser.
*************************************************************************;

%MACRO HELP;
        DATA _NULL_; LENGTH LINE $500; FILE _WEBOUT;
            RPTTYPE="&SAVE_RPTTYPE";
			%IF %SUPERQ(save_rpttype)=ST %THEN %DO;
                PUT '<title>LINKS Stability Module</title>';
                PUT     '<BODY BGCOLOR="#808080"><TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" border="0" cellpadding="0" cellspacing="0">';
                PUT     '<TR align="LEFT" HEIGHT="8%"><TD bgcolor="#003366">';
                line=   '<big><big><big><img src="http://'||"&_server"||'/links/images/gsklogo1.gif" width="141" height="62">'; put line;
                PUT     '<font FACE=ARIAL color="#FFFFFF"><em> LINKS </em> Stability Module</FONT>';
                PUT     '</big></big></BIG></TD></TR>';

                line = '<tr VALIGN="TOP"><td  HEIGHT="84%" BGCOLOR="#ffffdd" align=center>';    PUT line;				
                PUT     '</br></br><p align=center><font FACE=ARIAL color="#003366"><big><big><strong> Stability Menu Help </strong></big></big></font>';
                PUT     '</br></br><table align=center width=80% align=left><tr><td><p align=center><tr><td><font FACE=ARIAL>
                        This screen provides a menu of LINKS Stability report and analysis tools.';
                PUT             'Each button will perform the following functions:</br></font></td></tr>';
                PUT             '<tr><td></br><strong><font FACE=ARIAL>Stability Analysis Tools</strong> - Use this function to generate scatter plots, histograms, summary statistics,';
                PUT     ' correlation plots, etc. for the data that you have chosen.';
                PUT             '</br></BR><STRONG>Stability Study Reports</strong> - Use this function to generate a report in tabular format for the data that';
                PUT             ' you have chosen.';
                PUT     '</br></BR><STRONG>Save Data as a Spreadsheet</STRONG> - Use this function to create an CSV spreadsheet containing the data you have chosen.</font>';
				%END;

				/* Added V2 */
			%IF %SUPERQ(save_rpttype)=RE %THEN %DO;
				PUT '<title>LINKS Batch Trending Module</title>';
                PUT     '<BODY BGCOLOR="#808080"><TABLE ALIGN=CENTER WIDTH="100%" HEIGHT="100%" border="0" cellpadding="0" cellspacing="0">';
                PUT     '<TR align="LEFT" HEIGHT="8%"><TD bgcolor="#003366">';
                line=   '<big><big><big><img src="http://'||"&_server"||'/links/images/gsklogo1.gif" width="141" height="62">'; put line;
                PUT     '<font FACE=ARIAL color="#FFFFFF"><em> LINKS </em> Batch Trending Module</FONT>';
                PUT     '</big></big></BIG></TD></TR>';
				line = '<tr VALIGN="TOP"><td  HEIGHT="84%" BGCOLOR="#ffffdd" align=center>';    PUT line;	
                PUT     '</br></br><p align=center><font FACE=ARIAL color="#003366"><big><big><strong> Batch Trending Menu Help </strong></big></big></font>';
                PUT     '</br></br><table align=center width=80% align=left><tr><td><p align=center><tr><td><font FACE=ARIAL>
                        This screen provides a menu of LINKS Batch Trending report and analysis tools.';
                PUT             'Each button will perform the following functions:</br></font></td></tr>';
                PUT             '<tr><td></br><strong><font FACE=ARIAL>Batch Trending Tools</strong> - Use this function to generate control charts, histograms, summary statistics,';
                PUT     ' correlation plots, etc. for the data that you have chosen.';     
                PUT     '</br></BR><STRONG>Save Data as a Spreadsheet</STRONG> - Use this function to create a CSV spreadsheet containing the data you have chosen.</font>';
				%END;

				PUT     '</td></tr></table>';
				
                /*  Footer banner */

                PUT     '</td></tr>';
                PUT     '<TR align="right" HEIGHT="8%"><TD bgcolor="#003366">';
                LINE= '&nbsp;&nbsp;<A HREF="//'||SYMGET('_SERVER')||'/links/'||"&save_linkshome"||'.ASP"><font FACE=ARIAL color="#FFFFFF">LINKS Home</font></a>&nbsp&nbsp'; put line;

                line= '&nbsp;&nbsp;<A HREF="'|| "%SUPERQ(_THISSESSION)" ||
                                '&_program=LINKS.LRLogoff.sas"><font FACE=ARIAL color="#FFFFFF">Log off</font></A>';
                PUT line;
                PUT     '<td><tr></table>';
        RUN;
%MEND;

*************************************************************************;
*                       MODULE HEADER                                   *;
*-----------------------------------------------------------------------*;
*       DESIGN COMPONENT:  See LINKS SDS    REQUIREMENT:  See LINKS FRS
*       INPUT:  Macro variable: Help.
*       PROCESSING:  Controls execution of program.
*       OUTPUT:  LRReport help screen or Menu screen to web browser.
*************************************************************************;
%MACRO DECIDE;
        %IF %SUPERQ(HELP)=HELP %THEN %HELP;
        %ELSE %MENUSCREEN;
%MEND;
%DECIDE;
