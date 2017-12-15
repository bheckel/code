options nosource;
 /*---------------------------------------------------------------------------
  *     Name: tab.sas
  *
  *  Summary: Platform-independent use of the tab char.
  *
  *  Adapted: Mon 13 Jan 2003 14:39:43 (Bob Heckel SAS Programming Shortcuts
  *                                     Rick Aster p. 500)
  *---------------------------------------------------------------------------
  */
options source;

/* Handle the non-portable tab char. */
%macro TabTamer;
  %global TAB;
  %if &sysscp = OS %then
    /* Mainframe */
    %let TAB='05'x;
  %else
    %let TAB='09'x;

  %put testing the &TAB char;
%mend TabTamer;
%TabTamer
