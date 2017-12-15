options nosource;
 /*---------------------------------------------------------------------
  *     Name: ods_html.sas
  *
  *  Summary: Demo SAS's ability to convert procedure output into static
  *           HTML.
  *
  *           See http://www.sas.com/service/techsup/faq/ods.html
  *
  *           See ~/code/sas/htmlize.sas for non-ODS approach
  *
  *  Adapted: Thu 17 Oct 2002 09:18:17 (Bob Heckel -- WebTools class
  *                                     Jobaid handout)
  * Modified: Thu 07 Feb 2013 12:27:02 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options source ls=180;

%let DPPATH=c:/datapost/;
filename MAP "&DPPATH\cfg\DataPost_Configuration.map";
libname XLIB XML "&DPPATH\cfg\DataPost_Configuration.xml" xmlmap=MAP access=READONLY;

data xextract; set XLIB.extract; run;

 /* extractstring is too wide for proc print even with ls=max so use ods html */
ods html body='t.htm';
  proc print data=_LAST_(keep= extractid extractdescription extractstring) width=minimum; run;
ods html close;



data work.sample1;
 input acc_no code;
 cards;
0111 023560
0121 2.3560
0113 213560
0333 023334
 ;
run;

 /* Use zero pad left in Excel (actually the '\@' says 'format as text'). */
ods html file='junk2.xls' headtext='<STYLE>
                                      TD {mso-number-format:\@}
                                    </STYLE>';
  proc print;
    format acc_no Z8.;
  run;
ods html close;


 /*******************************************/

 /* Comment out during debugging; eliminates the 'traditional' LST output */
***ods listing close;
 /* body= is the only mandatory parameter. */

 /* More complex HTML using frames.  Open t_frame.html to view all. */

/***ods html body='t_body.html' frame='t_frame.html' contents='t_cont.html';***/
 /* Better, more portable, makes relative paths: */
 /***
ods html body='c:/temp/t_body.html'(URL='t_body.html')
         contents='c:/temp/t_cont.html'(URL='t_cont.html')
         frame='c:/temp/t_frame.html'
         style=BRICK
         ;
 ***/
 /*** does NOT work
ods html path='c:/temp'
         body='t_body.html'(URL='t_body.html')
         contents='t_cont.html'(URL='t_cont.html')
         frame='t_frame.html'
         ;
 ***/
 /* Best, relative */
ods html path='c:/temp' (URL=none)
         body='t_body.html'
         contents='t_cont.html'
         frame='t_frame.html'
         ;
 /* Verbose debugging.  E.g. Output Added: sections write to Log. */
ods trace output;
  proc print data=sashelp.shoes(obs=max) width=minimum; run;

***ods proclabel 'I have overriden the Tbl of Cont "The Print Procedure" lines';
  proc tabulate data=sashelp.shoes;
    class region;
    var sales;
    table region*sales*(mean max min);
  run;
ods html close;
