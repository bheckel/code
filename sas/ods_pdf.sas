options NOsource;
 /*---------------------------------------------------------------------
  *     Name: ods_pdf.sas
  *
  *  Summary: Demo SAS's ability to convert procedure output into PDF.
  *
  *           See http://www.sas.com/service/techsup/faq/ods.html
  *
  *  Created: Tue 22 Oct 2002 10:48:12 (Bob Heckel)
  * Modified: Tue 29 Aug 2017 09:29:46 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options source;

 /* All on one page, no page breaks */
ods pdf file="/Drugs/TMMEligibility/&clientfolder./Imports/ClientQC_&Cname." startpage=no;

  ods pdf text = "^{newline 4}"; ods pdf text = "^{style [just=center] Gender}";
  proc sql; select patientgender,count(*) from work.qc_status group by 1 order by 1; quit;

  ods pdf text = "^{newline 4}"; ods pdf text = "^{style [just=center] State}";
  proc sql; select patientstateprov,count(*) from work.qc_status group by 1 order by 1; quit;

ods pdf close;



endsas;
/* ... */

/********* QC **********/
ods _ALL_ close;  /* keep this out of Log */
ods document name=qc2;
  title 'QC2';proc sql; select  atebpatientid, cardholderid from new_cardholders_to_insert_stage where atebpatientid is not null group by atebpatientid, externalpatientid having count(atebpatientid)>1; quit;title;
ods document close;
ods listing;
/***********************/

/* ... */

ods _ALL_ close;
ods PDF file="&OUTPATHCURR/QC_&FILEDT..pdf";
  proc document name=qc2; replay; run; quit;
ods PDF close;



endsas;
data work.sample1;
  input fname $1-10  lname $15-25  @30 revenue 3.;
  datalines;
mario         lemieux        123
jerry         garcia         123
jerry         jarcia         124
lola          rennt          345
charlton      heston         678
richard       feynman        678
  ;
run;


***ods PDF file='junk.pdf';
 /* Dir must already exist. */
***ods PDF file='/u/bqh0/public_html/bob/t.pdf';
 /* Multiple destinations are OK (and LISTING stays open by default) */
ods PDF file='c:/temp/t.pdf';
ods CSV file='c:/temp/t.csv';
***ods listing close;
proc tabulate data=work.sample1;
  class fname;
  var revenue;
  table fname*revenue*(mean max min);
  where fname like 'jer%';
run;

ods PDF close;
ods CSV close;
***ods listing;

proc print data=sashelp.shoes(obs=3) width=minimum; run;

ods PDF file='c:/temp/t.pdf';
proc print data=sashelp.shoes(obs=5) width=minimum; run;
ods PDF close;



 /* Turn a report into NCHS TSA formatted PDF. */
%macro bobh;
libname NEWTEMP 'DWJ2.TEMPLATE.LIB' DISP=SHR;
options ORIENTATION=LANDSCAPE ls=max;
ods NOPTITLE;
ods PATH SASHELP.TMPLMST (READ) NEWTEMP.TEMPLAT (READ);
ods PDF file='/u/bqh0/public_html/bob/t.pdf' STYLE=STYLES.TEST1 NOTOC;
title1 "&EYR ALL STATES &NUMCODES SELECTED CAUSES OF DEATH";
proc report data=work.combined split='*' headskip;
  column desc diff pYr_&YR3 pYr_&YR2 pYr_&YR1 pYr_&YR0
                   nYr_&YR3 nYr_&YR2 nYr_&YR1 nYr_&YR0;
  define desc     / width=75;
  define diff     / width=9 format=8.0;
  define pYr_&YR0 / width=9 format=8.2;
  define pYr_&YR1 / width=9 format=8.2;
  define pYr_&YR2 / width=9 format=8.2;
  define pYr_&YR3 / width=9 format=8.2;
  define nYr_&YR0 / width=9;
  define nYr_&YR1 / width=9;
  define nYr_&YR2 / width=9;
  define nYr_&YR3 / width=9;
run;
ods PDF close;
%mend;
