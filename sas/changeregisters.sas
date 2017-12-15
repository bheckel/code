options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: changeregisters.sas
  *
  *  Summary: Edit change fix modify Registers datasets.
  *
  *           May want to run cp.sas first to make a backup copy.
  *
  *  Created: Fri 12 Nov 2004 10:29:36 (Bob Heckel)
  * Modified: Fri 01 Jul 2005 14:13:20 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter mlogic mprint sgen;

%global DS;
%let DS=register;

%let YYYY=2005;  /* EDIT */

 /* Usually no need to rerun dlaaaa1 to update the webpage, it'll be done by
  * some other state's run.  Use changeregisters.web.sas if this is *not* the
  * case (e.g. the year is closed, etc.).
  */
%macro LoopEvents(s);
  %local i e;

  %let i=1;
  %let e=%scan(&s, &i, ' ');

  %do %while ( &e ne  );
    %let i=%eval(&i+1);

    /*................................................*/
    libname L "/u/dwj2/register/&e./&YYYY.";

    title 'before';
    proc print data=L.&DS; run;

    data L.&DS;
      set L.&DS end=e;
      /* Fix/edit an existing entry :*/  
      /* EDIT */
      ***if mergefile eq 'BF19.UTX0501.MORMER' then stcode='37'; 
      ***if mergefile eq 'BF19.UTX0501.MORMER' then stname='UTAH'; 
      ***if mergefile eq 'BF19.DCX0501.MORMERZ' then revising_status='OON'; 
      if mergefile eq 'BF19.DCX0501.MORMERZ' then delete; 
      ***if mergefile eq 'BF19.OKX0401.FETMER' then daebstat='VDJ2'; 
      ***if mergefile eq 'BF19.OKX0401.FETMER' then daebspec='CMC6'; 
      ***if stabbrev eq 'SD' then userid='BQH0'; 
      ***if stabbrev eq 'SD' then processed_by='MANUAL'; 
      ***if stabbrev eq 'UT' then rec_count='1'; 
      ***if stabbrev eq 'SD' then mergefile='BF19.SDX0465.MORMERZ'; 
      ***if stabbrev eq 'SD' then date_update=datetime(); 
      ***if stabbrev eq 'UT' then date_update="18MAR05:09:13:00"DT; 
      ***if mergefile eq 'BF19.UTX0501.MORMER' then delete; 

      /* Add a split state entry: */
      /***
      if e then 
        do;
          stabbrev='MI';
          stcode='23';
          stname='MICHIGAN';
          mergefile='';
          revising_status='OBN';
          rec_count='0';
          daebstat='BXJ9';
          daebspec='CMC6';
          userid='BQH0';
          date_update=datetime();
          processed_by='HAND';
          output;
        end;
      ***/
    run;
    proc sort data=L.&DS;
      by stabbrev revtype;
    run;

    title 'after';
    proc print data=L.&DS; run;
    /*................................................*/

    %let e=%scan(&s, &i, ' ');
  %end;
%mend LoopEvents;
 /*** %LoopEvents(NAT MOR FET MED MIC) ***/
%LoopEvents(MOR)  /* EDIT */
