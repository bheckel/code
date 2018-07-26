options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_report.sas
  *
  *  Summary: Demo of proc report (a supercharged proc print).
  *
  *           Also see proc_transpose.sas.
  *           Also see proc_report_using_order.sas
  *
  *           To repeat header after a break use ID in the DEFINE
  *
  *           Use style={cellwidth=40pt ...} for ODS (see TSAAAZAC)
  *
  *           DEFINE / 
  *             DISPLAY (char) or ANALYSIS (num)
  *             ORDER (list by fmtd value) or GROUP (summary) or ACROSS
  *             COMPUTED
  *
  *  Created: Thu 22 May 2003 13:18:25 (Bob Heckel)
  * Modified: Tue 24 Apr 2012 13:34:14 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

title 'proc print';
proc print data=sashelp.shoes;
  var region sales;
run;

title 'proc report - SAME';
proc report data=sashelp.shoes HEADLINE;
  column region sales;
run;



title 'simple group mean';
proc report data=sashelp.shoes HEADLINE;
  column region sales;
  define region / group;
  define sales  / MEAN format=DOLLAR11.3 'total/mean sales' center;
run;



data tmp;
  input vcause $  vtot  vtot2  vyr $;
  label vcause='my*long*cause';
  cards;
A04 5 9 2003
A049 6 0 2003
A048 3  1 2003
B048 1 0 2002
  ;
run;

title '1-Compare raw proc print';
proc print; run;
title '1-Compare raw proc report';
proc report; run;
title;

title '2-Compare proc print';
proc print; 
  var vcause vtot vtot2;
run;
title '2-Compare proc report';
proc report; 
  columns vcause vtot vtot2;
run;
title;

title '1st full proc rpt demo';
 /* '/' is the default SPLIT char */
proc report data=tmp SPLIT='*' COLWIDTH=20 HEADSKIP BOX LIST;
  /* Display or create these variables (like proc print's VAR statement) or
   * statistical/computed columns.  You can use DEFINE below to refine these.
   * The order of appearance is important, see TSAAAAM.sas for examples.
   */
  ***columns vtot ('_my group_' vcause vyr mypct);
  columns vcause vtot vyr mypct;

  /* Must be numeric to be ANALYSIS.                */
  /*     ____                                       */
  define vtot   / display 'Total' analysis pctn width=7 spacing=10;
  define vcause / display width=5 right;
  /*                           item not in orig ds  */
  /*                                   ________     */
  define mypct  / order   'Percentage' computed format=PERCENT10.2;

  rbreak AFTER / summarize DUL;

  /* Compute block */
  compute mypct;
    mypct = vtot.PCTN / 10;
  endcomp;
run;



 /* New (best?) demo: */
title '2nd full proc rpt demo';
data grocery;
  input Sector $  Manager $  Department $  Sales  @@;
  datalines;
se 1 np1 50    se 1 p1 100   se 1 np2 120   se 1 p2 80
se 2 np1 40    se 2 p1 300   se 2 np2 220   se 2 p2 70
nw 3 np1 60    nw 3 p1 600   nw 3 np2 420   nw 3 p2 30
nw 4 np1 45    nw 4 p1 250   nw 4 np2 230   nw 4 p2 73
nw 9 np1 45    nw 9 p1 205   nw 9 np2 420   nw 9 p2 76
sw 5 np1 53    sw 5 p1 130   sw 5 np2 120   sw 5 p2 50
sw 6 np1 40    sw 6 p1 350   sw 6 np2 225   sw 6 p2 80
ne 7 np1 90    ne 7 p1 190   ne 7 np2 420   ne 7 p2 86
ne 8 np1 200   ne 8 p1 300   ne 8 np2 420   ne 8 p2 125
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

proc format;
  value $f_sector
    'se' = 'south east'
    ;
run;

ods pdf file='junk.pdf';
proc report data=grocery(where=(sector in('ne','se','nw'))) nowd headline headskip split='*' out=for_debugging_only;
  ***where sector ne 'ne';
  ***column sector manager department,sales perishtot;
  ***column sector department,sales perishtot;
  column sector department,sales perishtot (n);

  /* DEFINE how to use COLUMNs */
  define sector     / group 'The Sector' '';
  define department / across '_Department_' ;  /* underscores expand */
  /* 'Style' is for ODS */
  define sales      / analysis MEAN format=dollar11.2 ' '
                      Style(column)={font_weight=bold just=dec} ;
  define perishtot  / COMPUTED format=dollar11.2 'Perishable*Total';

  ***break AFTER sector / page;

  /* Display a descriptive title above the codes like 'se' etc.  Does NOT
   * replace the codes.
   */
  compute BEFORE sector;
    /* Like using put() */
    line @3 sector $f_sector.;
  endcomp;
 
  compute perishtot;
     perishtot=_c4_+_c5_;
  endcomp;

  compute AFTER sector;
    line ' ';  /* insert blank line after ne, nw, ... */
  endcomp;

  compute AFTER;
    line ' ';
    dashes = repeat('-', 29);
    line dashes $30.;
    line @29 '29 palms';
  endcomp;
run;
proc print data=for_debugging_only(obs=max) width=minimum; run;
/*
  The       ____________________Department____________________                        
  Sector            np1          np2           p1           p2   Perishable           
                                                                      Total          n
  ------------------------------------------------------------------------------------
                                                                                      
  ne                                                                                            
  ne            $290.00      $840.00      $490.00      $211.00      $701.00          8
                                                                                                
  nw                                                                                            
  nw            $150.00    $1,070.00    $1,055.00      $179.00    $1,234.00         12
                                                                                                
  south east                                                                                    
  se             $90.00      $340.00      $400.00      $150.00      $550.00          8
                                                                                                
                                                                                                
                            ------------------------------                                     
                            29 palms                                                           
*/



ods html body=_WEBOUT (dynamic title='Register History Query Results') style=statdoc rs=none;
proc report data=WORK.qryresults nowd;
 column stabbrev mergefile rec_count userid date_update;

 define stabbrev    / order;
 define date_update / order descending format=f_date.;
 define rec_count   / format=COMMA8.;
 define userid      / width=8;

 /* Stripe for readability. */
 compute rec_count;
   row+1;
   if mod(row, 2) then do;
     call define(_ROW_, "style", "style=[background=#eeeeee]");
   end;
 endcomp;
run;
ods html close;
