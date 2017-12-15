options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: quote_and_commaseparate.sas
  *
  *  Summary: Double-quote and comma separate a macrovariable.
  *           Good for use in IN() statements.
  *
  *           NOTE: can't handle a very long string (256 char?) or mvar
  *           overflows.
  *
  *  Created: Tue 23 Nov 2004 10:22:07 (Bob Heckel)
  * Modified: Thu 03 Apr 2008 10:44:52 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

proc sql NOprint;
  select distinct stores into :STOR separated by '","'
  from SASHELP.shoes
  where stores lt 15;
  ;
quit;

 /* Enquote the first and last elements */
%let STOR=%quote(")&STOR%quote(");
%put !!!&STOR;



 /* Better but won't work for Oracle unless quote(left(trim(region), "'") */
proc sql NOPRINT;
  /* quote() adds doublequotes around each. */
  select distinct quote(left(trim(region))) into :region separated by ', '
  from SASHELP.shoes
  ;
quit;
%put &region;


 
 /* Pure macro solution: */
%macro QuoteAndCommaSeparateList(s);
  %local i f;

  %let i=1;
  %let f=%qscan(&s, &i, ' '); 
  %let csv=;

  %do %while ( &f ne  );
    /*...........................................................*/
    %let csv=&csv,"&f";
    /*...........................................................*/
    %let i=%eval(&i+1);
    %let f=%qscan(&s, &i, ' '); 
  %end;

  /* Remove leading comma */
  %let csv=%substr(%bquote(&csv), 2);
  %put !!!&csv;
%mend;
%QuoteAndCommaSeparateList(my list of parms here);
