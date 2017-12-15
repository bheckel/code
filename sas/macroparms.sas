options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: macroparms.sas
  *
  *  Summary: Passing parameters to macro
  *
  * Created: Wed 20 Apr 2016 11:13:04 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOsgen;

%macro m(ds=, title=, columncnt=, vars=, labels=);
  %put &=ds &=title &=columncnt;

  /* Parse comma-separated parameter list */
  %local i v;
  %let i=1;
  %let v=%scan(%superq(vars), &i, ',');
  %do %while ( &v ne  );
    %let i=%eval(&i+1);
    %put DEBUG: loop &v;
    %let v=%scan(%superq(vars), &i, ',');
  %end;
%mend;
%m(ds=report1_loc, title='Number of Patients', columncnt=4, vars=%str(store_stateprov,store_city,clientstoreid), labels=%str(Province,City,Store ID));



endsas;
 /* Require that parameters are passed to a macro. */
%macro Foo(bar);
  %if %length(&bar) = 0 %then
    %do;
      %put ERROR: bar is a required parameter;
      %goto ERRFINISH;
    %end;

  %put ok &bar is accepted;

  %ERRFINISH:
%mend;
%Foo();
%Foo(bob);
