%macro m;
  %let storeids=;
  libname data '/Drugs/TMMEligibility/Rexall/WeeklyTargetPatientReportITR/20170414/Data';
    proc sql NOprint;
    select distinct clientstoreid into: storeids separated by ','
    from data.fnl
    ;
  quit;
%put _user_;

  %local i;
  %let i=1;
  %let store=%scan(%bquote(&storeids), &i, ',');
  %do %while (&store ne  );
    %put DEBUG: &store;
    %let i=%eval(&i+1);
    %let store=%scan(%bquote(&storeids), &i, ',');
  %end;
%mend; %m;


%macro dsloop(ds);
  %local i f;
  %let i=1;
  %let f=%scan(%superq(ds), &i, ',');

  %do %while ( &f ne  );
    %let i=%eval(&i+1);

    %put DEBUG: dsloop &f;

    %let f=%scan(%superq(ds), &i, ',');
  %end;
%mend;
%dsloop(%str(pqa_bar,pqa_foo));


%macro dsloop2(ds);
  %local i f;
  %let i=1;
  %let f=%scan(&ds, &i, ',');

  %do %while ( &f ne  );
    %let i=%eval(&i+1);

    %put DEBUG: dsloop2 &f;

    %let f=%scan(&ds, &i, ',');
  %end;
%mend;
%dsloop2(%str(pqa_bar,pqa_foo));


%macro dsloop3(ds);
  %local i f;
  %let i=1;
  %let f=%scan(%superq(ds), &i, ',');

  %do %while ( &f ne  );
    %let i=%eval(&i+1);

    %put DEBUG: dsloop3 &f;

    %let f=%scan(%superq(ds), &i, ',');
  %end;
%mend;
%dsloop3(%str(pqa_bar,pqa_foo));
