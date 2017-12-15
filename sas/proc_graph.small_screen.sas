options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_graph.small_screen.sas
  *
  *  Summary: Demo of simple, small smartphone oriented graphs.
  *
  *  Adapted: Tue 24 Mar 2009 14:45:01 (Bob Heckel -- SUGI 034-2008)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

goptions reset=all;
goptions device=GIF;
 /* Default size for a GIF image is 800 X 600 */
goptions ypixels=320 xpixels=320;
/***goptions ypixels=129 xpixels=172;***/
goptions border; /* put the graph in a box */
goptions cback=CXFFFF00; /* use RGB Yellow for background */
goptions htext=10pt ftext='Verdana';
/* Specify height and font used for those parts of the graph for which you do
 * not make an explicit assignment, or for which no direct controls are
 * available in SAS/GRAPH
 */
goptions gsfmode=replace gsfname=thegif;

filename thegif "junk.gif";
title1 font='Verdana'
  color=CX000000 /* RGB black */
  height=3 PCT ' ' /* insert space at the top */
  height=10pt
  justify=CENTER /* force a new line */
  "Ranked Age Distribution of"
  justify=CENTER /* force a new line */
  "Students in sashelp.class"
  ;

footnote1 angle=+90 font=none height=1 ' ';

/* This "footnote" is a blank "right-side-note" to increase space at the side of the image. */
/* Use angle=-90 to create a "left-side-note" if needed. */
pattern1 v=solid color= CX006600; /* use an RGB Medium Dark Green for the bars */
/* Remove all axis paraphernalia */
axis1 label=none major=none minor=none style=0;
axis2 label=none major=none minor=none style=0 value=none offset=(5 PCT,5 PCT);

/* Offset the horizontal axis to insert extra space between bar midpoint label
 * and bar start, and between bar end and bar response value.
 */
proc gchart data=sashelp.class;
  hbar Age /
  discrete /* use Ages, not Age subranges */
  freq
  freqlabel=' ' /* suppress the Frequency column heading */
  descending
  maxis=axis1 raxis=axis2
  width=2.5 space=2.5 /* bar width and spacing */
  ;
run;
quit;



endsas;
filename anyname2 email to="robert.heckel@gsk.com" subject="Graph for Your BlackBerry" attach="C:\temp\FileName.GIF";
data _null_;
  file anyname2;
  put 'Please see the attached graph.';
run;
