options nosource;
 /*---------------------------------------------------------------------
  *     Name: sas_intrnet_pdf.sas
  *
  *  Summary: Demo pgm for SAS IntrNet.  Call via:
  *           http://localhost/cgi-sas/broker?_SERVICE=default&_PROGRAM=intrcode.sas_intrnet_pdf.sas&type=42&_DEBUG=131
  *           Make sure to cp from ~/code/sas/ to ~/public_html/cgi-sas/
  *           first.
  *
  *  Created: Sat 19 Oct 2002 12:18:18 (Bob Heckel)
  * Modified: Tue 05 Nov 2002 14:47:42 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options linesize=72 pagesize=32767 nocenter date nonumber noreplace
        source source2 notes obs=max errors=5 datastmtchk=allkeywords 
        symbolgen mprint mlogic merror serror
        ;


data work.sample1;
  input fname $1-10  lname $15-25  @30 storeno 3.;
  datalines;
mario         lemieux        123
ron           francis        123
jerry         garcia         123
larry         wall           345
richard       dawkins        345
richard       feynman        678
  ;
run;

***ods html body=_WEBOUT (dynamic title='HTML titlebar') style=brick rs=none;
ods pdf file='c:\cygwin\home\bqh0\public_html\sasweb\junk.pdf';
title "ok &type then";
%put this line goes to the <B>Log</B> and does not need quotes;
proc print; run;
***ods html close;
ods pdf close;

data _NULL_;
  /* Switch from Log writing. */
  file _WEBOUT;
  put '<H1><FONT COLOR="#FF0000">Your PDF doc is ready:</FONT></H1> 
       <A HREF="http://localhost/intrnet/junk.pdf">click here</a>';
run;
