options nosource;
 /*---------------------------------------------------------------------
  *     Name: ods.sas
  *
  *  Summary: Demo of Output Delivery System (ODS).
  *
  *           See also ods_trace.sas
  *
  * ERROR: Template 'Tagsets.Msoffice2k_x' was unable to write to template store!
  * Use:
  * ods path(prepend) work.templat(update);
  *
  *           
  *  Adapted: Wed 20 Nov 2002 14:49:56 (Bob Heckel -- Rick Aster SAS
  *                                     Programming Shortcuts p. 400)
  * Modified: Mon 23 Nov 2015 10:59:19 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options replace;

options ps=max;

ods results;
ods _all_ close;
 /* IE only */
ods tagsets.style_popup path='~/bob/tmp' file='t.htm' style=Printer;

proc means data=sashelp.shoes;run;

ods tagsets.style_popup close;

 /* View style details */
proc template;
  source styles.Printer;
run; quit;




endsas;
libname l '~/tmp';
proc template; list styles; run;
ods path (prepend) l.tmplmst (update);
ods path show;

 /* By default, the ExcelXP tagset creates a new worksheet when a SAS procedure creates new tabular output */
filename tt '~/tmp/t.txt';
ods tagsets.ExcelXP file=tt options(doc='help');
ods tagsets.ExcelXP close;

proc template;
  source styles.BarrettsBlue;
run;


endsas;
libname bobh 'c:/temp';

data bobh.sample;
  input fname $1-10  lname $15-25  @30 revenue 3.;
  datalines;
mario         lemieux        123
jerry         garcia         123
richard       feynman        678
  ;
run;

ods path show;


 /* Determine what ODS output objects are available from proc contents (we
  * don't care about what proc contents is spewing). 
  */
ods trace on / listing;
  proc contents data=bobh.sample; 
  run;
ods trace off;
 /* Run to here on the first iteration to determine desired output object 
  * (e.g Name: ...)
  */
***endsas;

 /* Based on the above trace you decide to only HTMLify VariablesAlpha: */
ods listing close;
 /* Toggle */
***ods select VariablesAlpha;
 /* Toggle */
***ods select EngineHost;
 /* Toggle */
ods exclude Attributes;
  ***ods html body='junk.html' style=D3D;
  ods html body='junk.html' style=BarrettsBlue;
  /* To eliminate the "The Proc Contents Procedure" title from the html. */
  ods NOptitle;
    proc contents data=bobh.sample; 
    run;
  ods html close;  /* can say ODS _ALL_ CLOSE more safely to get all open destinations */
ods select all;
ods listing;


 /* TODO not working */
 /* Output to a dataset instead of a destination: */
%macro bobh;
ods output data=work.tmp;
  proc contents data=bobh.sample; 
  run;
ods output close;
proc print; run;
%mend bobh;


 /* View available ODS templates: */
proc template;
  list styles;
run
