options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_sgplot.sas
  *
  *  Summary: Demo of SG graph plot chart
  *
  *  Created: Thu 16 Jul 2015 15:33:35 (Bob Heckel--SAS Global Forum 2441 video)
  * Modified: Wed 21 Oct 2015 11:48:58 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

 /* For the line graph: */
ods output Summary=freqout;
ods trace on;
  proc means data=sashelp.shoes; class region; var sales; run;
ods output close;
title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H; run;title;


ods _ALL_ close;

ods pdf file='/Drugs/Personnel/bob/t.pdf' style=Pearl;

title "ds:&SYSDSN";proc print data=sashelp.shoes(obs=5) width=minimum; run;title;

proc sgplot data=sashelp.shoes;
  vbar region / group=Stores
                groupdisplay=cluster;
run;


proc sgplot data=sashelp.shoes;
  vbar region / response=Stores;
run;
proc sgplot data=sashelp.shoes;
  vbar region / response=Stores;
  yaxis label='Foo'
        values=(0 to 700 by 100);
  refline 300 / label=('my refline');
run;


proc sgplot data=sashelp.shoes;
  histogram Stores;
  density Stores;
run;


proc sgplot data=sashelp.shoes;
  scatter x=Sales y=Returns;
run;


proc sgpanel data=sashelp.shoes;
  panelby Region;
  scatter x=Sales y=Returns;
run;


 /* Line graph */
title 'line graph';
proc sgplot data=freqout(where=(region in('Asia','Canada','Africa')));
  series x=region y=Sales_Mean;
  xaxis values=('AFRICA' 'ASIA' 'CANADA');
  yaxis grid values=(10000 to 150000 by 10000.00);
run;
ods pdf close;
