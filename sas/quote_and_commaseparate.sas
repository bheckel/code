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
  * Modified: 06-Feb-2024 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

%global quoted_list;
%let request_status = item1+item2+item3;

%macro parselist(s);
  data work.tmplist;
    %do i = 1 %to %sysfunc(countw(&s,"+"));
      %let word = %scan(&s,&i,"+");
      x="&word";
      output;
    %end;
  run;

  proc sql NOprint;
    select quote(trim(x),"'") into :quoted_list separated by ', ' from tmplist;
  quit;
%mend;

%macro main();
  %if "X&request_status." ne "X" %then %do;
    %parselist(&request_status.);
    %put &quoted_list;
  %end;
%mend;
%main;

/***************/

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
