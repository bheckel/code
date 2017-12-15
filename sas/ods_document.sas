 /* http://support.sas.com/resources/papers/proceedings12/273-2012.pdf */

ods document name=odt;
  title 'Records received from HP';
  proc print data=sashelp.shoes(obs=9) width=minimum heading=H; run;title;  
  proc contents data=sashelp.shoes; run;
ods document close;

 
  /* Default is append, use write to override */
ods document name=odt;
/***ods document name=odt(write);***/
  title 'more Records received from HP';
  proc print data=sashelp.shoes(obs=1) width=minimum heading=H; run;title;  
ods document close;

ods document name=odt2;
  title 'Records not received from HP';
  proc print data=sashelp.class(obs=9) width=minimum heading=H; run;title;  
  proc contents data=sashelp.class; run;
  proc sql; select count(region) from sashelp.shoes; quit;
ods document close;

 /* ... */

ods _ALL_ close;
ods PDF file='/Drugs/Personnel/bob/junk.pdf' style=plateau;
  proc document name=odt; replay; run; quit;
  proc document name=odt2; replay; run; quit;
ods PDF close;
ods listing;

proc document name=odt2; list / details levels=all; run;
