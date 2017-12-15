options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: amortsched.sas
  *
  *  Summary: Print an amortization schedule.
  *
  *  Adapted: Tue 17 Jun 2003 15:54:46 (Bob Heckel -- Rick Aster Shortcuts
  *             p. 401  http://www.globalstatements.com/shortcuts/59a.html
  *---------------------------------------------------------------------------
  */
options source;

data _NULL_;
  /* Define table columns. */
  file PRINT ODS= (variables= (month (format=F5.)
                               principal (format=COMMA10.2)
                               payment (format=COMMA8.2) 
                               ratepermo (format=F8.6)
                               interest (format=COMMA8.2)));
  principal = 98000;
  ratepermo = 0.0399/12;
  n = 360;
  payment = mort(principal, ., ratepermo, n);
  do month = 1 to n;
    interest = principal*ratepermo;
    /* Define table rows. */
    put _ODS_;
    principal = principal - payment + interest;
  end;
run;
