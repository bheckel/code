options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_gplot_simple.sas
  *
  *  Summary: Demo of simple graphing
  *
  *  Created: Mon 06 Dec 2010 14:53:28 (Bob Heckel -- http://support.sas.com/kb/24/931.html)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* Set the graphics environment */
goptions reset=all device=png cback=white border htitle=12pt ctext=green; 

 /* Create the sample data set A */
data a;
  input Year Y;
  datalines;
90 40
91 85
92 80
93 57
94 90
95 80
;
run;

symbol i=join v=dot c=vibg h=1.5;

 /* Define axis characteristics, using the REFLABEL option on the AXIS1
  * statement.
  */
 /* X */
axis1 order=(0 to 100 by 25) minor=none 
      reflabel=(j=c h=9pt 'First Reference Line' 'Second Reference Line');
 /* Y */
axis2 offset=(4pct,4pct);  

title1 'IP21 MDI Line8 Filler';

 /* Produce the graph */
proc gplot data=a;
  where Year gt 92;
  /*                                         reflines */
  plot y*year / vaxis=axis1 haxis=axis2 vref=55 90;
run;
quit;
