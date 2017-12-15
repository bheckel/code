options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: ods_html_tabulate.sas
  *
  *  Summary: HTML without SAS IntrNet
  *
  *  Adapted: Wed 27 Sep 2006 14:42:13 (Bob Heckel --
  *                                      http://meta-x.com/sugi27_paper.pdf)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

PROC FORMAT;
  VALUE $image
  'P' = 'C:\images\pecanpie.jpg'
  'B' = 'C:\images\bananabash.jpg '
  'A' = 'C:\images\applespice.jpg'
  'M' = 'C:\images\mango.jpg '
  'C' = 'C:\images\chocomint.jpg';
run;

proc format;
  VALUE $link
  'P' = 'C:\sugi\pecanpie.html'
  'B' = 'C:\sugi\bananabash.html'
  'A' = 'C:\sugi\applespice.html'
  'M' = 'C:\sugi\mango.html'
  'C' = 'C:\sugi\chocomint.html';
run;


ODS HTML BODY='c:\temp\jellybean8.html';

data production;
  input Flavor $ Factory $ Date MMDDYY8. MPounds;
  cards;
M A 12/17/01 0
M A 12/18/01 1
P A 12/19/01 2
P B 01/02/01 3
P B 01/06/01 4
C B 01/07/01 5
M B 01/08/01 6
  ;
run;

PROC TABULATE DATA=production FORMAT=4.1;
  CLASS Factory Flavor;
  CLASSLEV Flavor / STYLE={PREIMAGE=$image. URL=$link.};
  VAR MPounds;
/***  FORMAT Flavor $flav.;***/
  TABLE Flavor ALL,Factory*SUM=''*MPounds='' ALL*SUM=''*MPounds='';
RUN;

ODS HTML CLOSE;
