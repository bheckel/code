 /* TODO not working */
 /* NOTE: commas are a bitch to %SCAN */
%let samplist=256122|323432|344321|123456|78901|999999;

%macro s;
  %do i=1 %to 10 %by 3;
    %do j=1 %to 10;
      %let item = %scan(&samplist, &i, %str(|));
      %put !!!&item;
    %end;
  %end;
%mend; %s



endsas;
%macro s;
  %local i item;

  %let i=1;
  %let j=0;
  %let item = %scan(&samplist, &i, %str(|));
  %let clump0 =;

  %do %while (&item ne  );
    %let item = %scan(&samplist, &i, %str(|));
    %let clump&i = &item &clump&j;

    %let i=%eval(&i+1);

    %if &i = 3 %then %do;
      %put !!!&item;
      %let j=%eval(&i-1);
      %put !!!&&clump&i;
    %end;
  %end;
%mend;
%s
%put _ALL_;



endsas;
%let x=AKNEW ALNEW AZNEW;

%macro MVarSplit(s, dlm=' ') ;
  %local i item;

  %let i=1;
  %let item = %scan(&s, &i, &dlm);

  %do %while (&item ne  );
    %put &item;
    %let i=%eval(&i+1);
    %let item = %scan(&s, &i, &dlm);
  %end;
%mend MVarSplit;
%MVarSplit(&x);
