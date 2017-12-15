options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: font_sasgraph_tester.sas
  *
  *  Summary: Demo SAS Graph fonts
  *
  *  Adapted: Fri 11 Dec 2009 11:23:25 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

goptions reset=global gunit=pct border cback=white
         colors=(black blue green red)
         ftext=swiss htitle=6 htext=3;

/***%let testfont = greek;***/
/***%let testfont = swiss;***/
%let testfont = qcfont1;

title "Testing the SAS/GRAPH &testfont Font";
footnote j=r 'my footnote';

 /* SASHELP.fonts has list of available fonts */
proc gfont name=&testfont
           nobuild
           height=3.7

/***           romcol=red***/
/***           romfont=swissl***/
/***           romht=2.7***/
/***           showroman***/
           ;
run;
quit;
