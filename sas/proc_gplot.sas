options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_gplot.sas
  *
  *  Summary: Demo of SAS/GRAPH capabilities.
  *
  *           See also readin_multiple_IIS_logfiles.sas, 0_MAIN_Valtrex_Caplets_plots.sas
  *
  *           or
  *
  *           http://support.sas.com/sassamples/graphgallery/PROC_GPLOT.html
  *
  *  Created: Wed 25 Jun 2008 15:55:02 (Bob Heckel -- SUGI paper 239-31) 
  * Modified: Tue 03 Feb 2009 14:17:14 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
 /*                          title           */
options source NOcenter;

data t;
  input sales numb yr;
  cards;
1000 1234 1970
1025 1342 1980
2000 1324 1990
2039 1400 2000
  ;
run;

%macro simple; /* {{{ */
 /*                                       text height                */
 /*                                    _________________             */
goptions reset=all ftext='Andale Mono' htext=3 gunit=pct ctext=green;
 /*          connect the dots                      */
 /*          _________________                     */
symbol value=dot interpol=join color=cyan height=3;
 /* Y axis.  proc must be told to use this statement */
axis1 label=(angle=90 'Amt (in billions)') minor=(n=2);
 /* X axis */
 /*                        tick marks between majors    */
 /*                             ___________             */
axis2 order=(1960 to 2010 by 5) minor=(n=4);
title j=left height=4 'title SAS/GRAPH';
footnote justify=right 'source: footer SAS/GRAPH';
proc gplot data=t;
  /*    Y by X */
  plot sales*yr / vaxis=axis1 haxis=axis2 caxis=purple;
  format sales COMMA.;
run;
%mend; /* }}} */
%simple;

%macro complex; /* {{{ */
options validvarname=upcase;
goptions ftext='Andale Mono' htext=3 gunit=pct ctext=green;
symbol1 value=dot interpol=join color=cyan h=3;
symbol2 v=dot i=join h=2.5 line=3;
 /* Y axis.  But proc must be told to use this */
axis1 label=(angle=90 'Amt (in billions)') minor=(n=1) color=red;
 /* X axis */
axis2 order=(1960 to 2010 by 5) minor=(n=9) color=blue;
 /* Get default legend if use bare LEGEND in PLOT statement below */
legend1 label=none value=(j=left "Tot" j=left "Fed Govt") mode=protect
        position=(top inside left) cborder=blue cshadow=purple across=1
        shape=line(10)
        ;
title f='Arial' h=4 'title SAS/GRAPH';
footnote j=right 'footer SAS/GRAPH';
proc gplot data=t;
  plot (sales numb)*yr / overlay vaxis=axis1 haxis=axis2 legend=legend1;
  format sales COMMA.;
run;
%mend; /* }}} */
***%complex;

%macro outputGIF; /* {{{ */
filename GOUT './junk.gif';
goptions device=gif gsfname=GOUT xpixels=1024 ypixels=768
         ftext='Andale Mono' htext=3 gunit=pct ctext=green
         ;
symbol1 v=dot i=join c=cyan h=3;
symbol2 v=dot i=join h=2.5 l=3;
 /* Y axis in this example.  But proc must be told to use this */
axis1 label=(angle=90 'Amt (in billions)') minor=(n=1) color=red;
 /* X axis in this example                             ___________            */
axis2 order=(1960 to 2010 by 5) minor=(n=9) color=blue offset=(0,0);
 /*                                                    from left,right Y axis */
 /* Get default legend if use bare LEGEND in PLOT statement below */
legend1 label=none value=(j=left "Tot" j=left "Fed Govt") mode=protect
        position=(top inside left) cborder=blue cshadow=purple across=1
        shape=line(10)
        ;
proc gplot data=t;
  plot (sales numb)*yr / overlay vaxis=axis1 haxis=axis2 legend=legend1 noframe;
  format sales COMMA.;
run;
%mend; /* }}} */
***%outputGIF;

%macro outputPDF; /* {{{ */
options orientation=landscape;
ods listing close;
ods pdf file='./junk.pdf' NOtoc;
  goptions ftext='Helvetica' htext=3 gunit=pct ctext=green rotate=landscape;
  symbol value=dot interpol=join color=cyan height=3;
  axis1 label=(angle=90 'Amt (in billions)') minor=(n=1) color=red;
  axis2 order=(1960 to 2010 by 5) minor=(n=9) color=blue;
  proc gplot data=t;
    plot sales*yr / vaxis=axis1 haxis=axis2;
  run;
ods pdf close;
ods listing;
%mend; /* }}} */
***%outputPDF;

%macro annotation; /* {{{ */
options validvarname=upcase;
 /* Like CNTLIN for proc format, build a dataset that can be understood by
  * SAS' ANNOTATE facility.  The two obs contain enough info to place labels
  * on the plot.
  */
data my_labels;
  retain xsys ysys '2' 
         function 'label'
         position '1' 
         style "'Arial/bo'"
         color cborder 'purple' 
         ;
  set t end=last;
  if last then do;
    text='Look here'; x=yr; y=sales; output;
    text='and here'; x=yr; y=numb; output;
  end;
run;
/***proc print data=_LAST_(obs=max) width=minimum; run;***/

goptions ftext='Andale Mono' htext=3 gunit=pct ctext=green;
symbol1 f=marker v='C' i=join h=1.25;;
symbol2 f=marker v='U' i=join h=1.25;;
 /* Y axis.  But proc must be told to use this */
axis1 label=(angle=90 'Amt (in billions)') minor=(n=1) color=red;
 /* X axis */
axis2 order=(1960 to 2010 by 5) minor=(n=9) color=blue;
title height=4 'title SAS/GRAPH';
footnote justify=right 'footer SAS/GRAPH';
proc gplot data=t;
  plot (sales numb)*yr /
       overlay vaxis=axis1 haxis=axis2 caxis=yellow annotate=my_labels
       ;
  format sales COMMA.;
run;
%mend; /* }}} */
***%annotation;



endsas;
proc gplot data=sashelp.shoes;
	title 'Ventolin HFA: [LEAK RATE %]';
	axis1 label=(a=90 r=0 "LEAK Rate Percent");* order = (21 to 30 by 0.5);
	axis2 label=("Sorted by Test Date") value=(height=0.5);
	symbol1 i=none w=1.25 h=1.25 v=dot  c=green interpol=join;
	symbol2 i=none w=0.25 h=0.25 v=dot  c=blue;
	plot sales*region /overlay vaxis=axis1 haxis=axis2 frame
                           vref=2 2.5 lvref=(3 2) cvref=(green,blue);
run;



/* vim: set foldmethod=marker: */ 
