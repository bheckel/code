options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: macrovar_list_compare.mcr.sas
  *
  *  Summary: Iterate over two lists to determine union between the two.
  *
  *  Created: Thu 24 Jan 2008 15:35:16 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

%let RETESTSAMPIDS=one two no;
%let SAMPLISTALL=one two three four five;

%macro ListCompare(sm, lg);
  %local i f;
  %global foundlist;

  %let i=1;
  %let f=%qscan(&sm, &i); 

  %do %while ( &f ne  );
    %if %index(&lg, &f) %then 
      %let foundlist=&foundlist &f;
    %let i=%eval(&i+1);
    %let f=%qscan(&sm, &i); 
  %end;
%mend;
%ListCompare(&RETESTSAMPIDS, &SAMPLISTALL);
%put &foundlist;
