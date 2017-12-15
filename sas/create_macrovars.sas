 /*---------------------------------------------------------------------------
  *     Name: create_macrovars.sas
  *
  *  Summary: Create a separate macro variable for each value of a string.
  *
  *  Adapted: Sat May 18 13:53:37 2002 (Bob Heckel -- SAS.com tech pages)
  *---------------------------------------------------------------------------
  */
options linesize=72 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=5 nostimer number serror merror
        noreplace datastmtchk=allkeywords;

title; footnote;

 /* Loop through the string and assign each value to separate macro variable. */
%macro multivar(string);
  %local count word;

  %let count = 1;

   /* Finds the first value. */
  %let var&count = %qscan(&string, &count, %str( ));

   /* This loop will continue to loop as long as var&i has a value */
  %do %while( &&var&count ne );
    /* Increases the value of count for each iteration of the do loop. */
    %let count = %eval(&count+1);
    /* Creates a variable for each value in the string. */
    %let var&count = %qscan(&string, &count, %str(  ));
  %end;

   /* Captures the final value. */
  %let count = %eval(&count-1);

   /* Write the values of the newly created variables. */
  %do i=1 %to &count;
    %put &&var&i;
  %end;
%mend multivar;


data _NULL_;
  %multivar(foo bar baz ka boom)
  put 'macro ended';
  ***put %var5;
run;
