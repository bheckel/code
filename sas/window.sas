options nosource;
 /*---------------------------------------------------------------------
  *     Name: window.sas
  *
  *  Summary: Demo of using a window that pops up during a run.
  *
  *           Can also use %window in macro
  *
  *  Adapted: Fri 27 Sep 2002 08:43:41 (Bob Heckel -- SAS Online Docs)
  * Modified: Fri 25 Apr 2003 12:43:40 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options linesize=72 pagesize=32767 nocenter date nonumber noreplace
        source source2 notes obs=max errors=5 datastmtchk=allkeywords 
        symbolgen mprint mlogic merror serror
        ;
title; footnote;

data _NULL_;
  length passwd $10;
  userid = sysget('USERNAME');

  window win1 IROW=1 ROWS=25
    #9  @26 'WELCOME TO THE MACHINE' COLOR=red
    #17 @19 'THIS PROGRAM DOES NOTHING'
    #18 @27 'Press ENTER to continue doing nothing'
    ;
  /* Won't open until win1 closes. */
  window win2 IROW=16 ROWS=30
    #2 @26 'More stuff'
    #4 @24 'to see'
    #5 @20 'ID: ' userid
    #6 @20 'Password: ' passwd required=yes
    #7 @02 'Type some password to quit';
    ;
  display win1;
  display win2;
  stop;
run;
