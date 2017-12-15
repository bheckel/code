/*----------------------------------------------------------------------------
 * Program Name: rpt_to_web.sas
 *
 *      Summary: Dumps SAS proc print output to an HTML page.
 *               ALSO SEE htmlize.sas
 *
 *      Created: Fri Mar 26 1999 11:08:41 (Charles Partridge/Bob Heckel)
 *     Modified: Fri Mar 26 1999 14:30:50 (Bob Heckel) 
 *----------------------------------------------------------------------------
 */
options linesize=80 pagesize=40 nodate source source2 notes mprint
       symbolgen mlogic obs=max errors=3 nostimer nonumber serror merror;

title 'html dump';
footnote;

libname master '/disc/data/master/';

proc printto file="output.html" new; run;

/*Place HTML tags at beginning of output file. */
data _null_;
  file print noprint notitles;
  put  " <html>" / " <body bgcolor=000000 text=00FF00>" / " <bold>" " <pre>";
run;

/* Dummy query. */
data work.webit;
  set master.jobcost (keep=distcode job_id i_cost);
    where job_id like "H2A%";
run;          

proc print data=work.webit; run;

/*Place Closing HTML tags at end of output file. */
data _null_;
  file print noprint notitles;
  put / " </pre>" / " </body>" / " </html>" ; 
run; 

proc printto; run;

/* TODO Send sashtml.htm from DART to Triweb. */
/***X 'ftp -n -s:sashtml_ul.txt 47.143.17.107';***/

