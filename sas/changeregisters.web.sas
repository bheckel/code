options NOsource;
 /**********************************************************************
  * PROGRAM NAME: changeregisters.web.sas (adapted from FINALREG)
  *
  *  DESCRIPTION: Modify Register by hand.
  *
  *     CALLS TO: nothing
  *    CALLED BY: nothing
  *
  *  INPUT MVARS: nothing
  *
  *   PROGRAMMER: BQH0
  * DATE WRITTEN: 2005-03-16
  *
  *   UPDATE LOG:                                              
  *********************************************************************/
options source NOcenter mlogic mprint sgen;

 /****** Edit *******/
%let YYYY=2003;
%let EVENTS=MIC;
%let NOW=%str(2005-04-01 14:49);
 /****** Edit *******/


%macro LoopEvents(s);
  %local i e;

  %let i=1;
  %let e=%scan(&s, &i, ' ');

  %do %while ( &e ne  );
    %let i=%eval(&i+1);

    /*................................................*/
    libname L "/u/dwj2/register/&e./&YYYY.";

    title 'before';
    proc print data=L.register; run;

    data L.register;
      set L.register;
      if stabbrev eq 'CA' then mergefile='BF19.CAX0338.MICMER'; 
      ***if stabbrev eq 'WA' then revtype='NEW'; 
      ***if stabbrev eq 'CA' then processed_by='YrClosed'; 
      ***if stabbrev eq 'CA' then userid='BQH0'; 
      ***if stabbrev eq 'WA' then rec_count='21009'; 
    run;
    proc sort data=L.register;
      by stabbrev revtype;
    run;

    title 'after';
    proc print data=L.register; run;


    /* Refresh e.g. http://158.111.2.21/sasweb/nchs/daeb/med2003.html: */

    filename WEB HFS '/websrv/sasweb/nchs/daeb';
    proc format;
      picture SORTFMT other = '%Y-%0m-%0d %0H.%0M'(DATATYPE=DATETIME);
    run;

    ods noptitle;
    ods path SASHELP.tmplmst (read) newtemp.templat (read);
    ods listing close;
    ods HTML body="%lowcase(&e)&YYYY..html"(notop) path=WEB(url=none)
             style=statdoc;

    options center;
    title "<B><H3>&e &YYYY Register -- Updated &NOW</H3></B>";
    proc report data=L.register NOWD;
      column stabbrev stcode stname mergefile revising_status rec_count
             daebstat daebspec userid date_update processed_by;
      define stabbrev        / 'St Abb';
      define stcode          / 'St Code';
      define stname          / 'St Name';
      define mergefile       / 'Latest Merged File';
      define revising_status / 'Status';
      define rec_count       / 'Rec Cnt';
      define daebstat        / 'Stat';
      define daebspec        / 'Spec';
      define userid          / WIDTH=6 'User';
      define date_update     / F=SORTFMT. 'Updated';
      define processed_by    / 'Proc By';
    run;
    ods html close;
    ods listing;

    /*................................................*/

    %let e=%scan(&s, &i, ' ');
  %end;
%mend LoopEvents;
%LoopEvents(&EVENTS)

%put !!!SYSCC: (&SYSCC);
