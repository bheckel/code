options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: ods_excel.sas
  *
  *  Summary: Demo of building Excel spreadsheet outputs
  *
  *           See also:
  *           http://support.sas.com/rnd/base/ods/odsmarkup/excelxp_help.html
  *           http://www.msdn.microsoft.com/library/default.asp?url=/library/en-us/dnoffxml/html/ofxml2k.asp
  *
  *  Adapted: Wed 21 May 2003 14:48:01 (Bob Heckel -- 
  *                                     Phil Mason tips #18 /Chevell Parker)
  * Adapted: Mon 06 Apr 2015 14:30:42 (Bob Heckel--http://www2.sas.com/proceedings/sugi31/263-31.pdf)
  * Modified: Mon 23 Nov 2015 14:47:18 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

options nobyline;
ODS EXCEL FILE="/Drugs/RD/015/11/N-2237/Reports/Independents RFR RFD.xml" options(sheet_name="#BYVAL(gpi)" autofilter='all');
proc print data=l.final NOobs;
  by gpi;
  pageby gpi;
run;
ODS EXCEL close;



 /* Detail of all options */
ODS tagsets.excelxp file="test.xml" options(doc="help");

 /* Produce mult-worksheet workbook.  No customizations, ugly */
ods tagsets.excelxp file="/Drugs/Personnel/bob/test.xls";
proc reg data=sashelp.class;
  model Weight = Height Age;
run;
ods _all_ close; 


 /* Better */
ODS EXCEL FILE="/Drugs/Personnel/bob/test2.xls";
proc reg data=sashelp.class;
  model Weight = Height Age;
run;
ODS EXCEL close;


ODS LISTING close;
ODS EXCEL file="Merck Targeted Zostavax.xlsx" options(sheet_name="Zostavax Opportunities" embedded_titles='yes');
  proc print NOobs data=final LABEL; run;
ODS EXCEL close;

endsas;
 /* Some of this might be obsolete in 2015 */
title 'Excel output via ODS';

data work.sample1;
  input fname $1-10  lname $15-25  @30 revenue 3.;
  datalines;
mario         lemieux        123
jerry         garcia         123
jerry         jarcia         024
lola          rennt          345
richard       feynman        678
  ;
run;

 /* No formatting, smaller filesize. */
ods CSVALL file='junk.csv';
 /* No formatting, no title, etc. */
***ods CSV file='junk.csv';
proc print; run;
ods CSVALL close;
***ods CSV close;

ods listing close;

 /* Ugly formatting. */
***ods HTML file='junk.xls';
 /* Better */
ods HTML file='junk.xls' style=barretsblue;
proc print; run;
ods HTML close;

 /* Better formatting.  junk.xls and junk.css are created here. */
ods HTMLCSS file='junk2.xls'
            stylesheet="junk.css"
            headtext='<style> @Page {mso-header-data:"Rage &P of &N";
                      mso-footer-data:"&Lleft text &Cpage &P&R&D&T"} ;
                      </style>'
            ;
proc print; run;
ods HTMLCSS close;

ods listing;


 /* Better? demo */

/* Set path to read only sashelp.tmplmst but update sasuser.templat */
ods path sasuser.templat(update) sashelp.tmplmst(read);

/* Create new override style called NoBorder in sasuser.templat */
proc template;                                                         
  define style Styles.NoBorder;                                            
    parent=styles.minimal;                                            
      style Table /                                                
        rules = NONE                                                    
        frame = VOID                                                    
        cellpadding = 0                                                 
        cellspacing = 0                                                 
        borderwidth = 0;                                                
   end;                                                                
run;                                                                   

/* Apply the new noborder style to the ODS output */
ODS HTML FILE='junk2.xls'  STYLE=Styles.NoBorder; 
proc print data=sashelp.class noobs; run;
ODS HTML CLOSE;


 /* Compare output with: */
%include 'tabdelim.sas';
%Tabdelim(sashelp.class, 'junk3.xls');
