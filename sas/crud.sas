%macro view_tmm_census_lookup_ds(clientid=);
  libname BUILD '/Drugs/Drugs/Build';

  proc print data=BUILD.tmm_census_lookup(obs=max) width=minimum; where clientid="&clientid"; run;  
%mend;
*%view_tmm_census_lookup_ds(clientid=408);
%macro edit_tmm_census_lookup_ds(clientid=, npi=, storeid=, clientfolder=, store_name=, cgid=, short_client_name=);
  libname BUILD '/Drugs/Drugs/Build';

  data BUILD.tmm_census_lookup(drop=x:);
    set BUILD.tmm_census_lookup;

    %if &clientid eq  %then %do;
      %put ERROR: clientid is mandatory;
    %end;

    %if &npi ne  %then %do;
      xclientid = strip("&clientid");
      xnpi = strip("&npi");
      if clientid eq xclientid then do;
        npi=xnpi;
      end;
    %end;

    %if &storeid ne  %then %do;
      xclientid = strip("&clientid");
      xstoreid = strip("&storeid");
      if clientid eq xclientid then do;
        storeid=xstoreid;
      end;
    %end;

    %if &clientfolder ne  %then %do;
      xclientid = strip("&clientid");
      xclientfolder = strip("&clientfolder");
      if clientid eq xclientid then do;
        clientfolder=xclientfolder;
      end;
    %end;

    %if &store_name ne  %then %do;
      xclientid = strip("&clientid");
      xstore_name = strip("&store_name");
      if clientid eq xclientid then do;
        store_name=xstore_name;
      end;
    %end;

    %if &cgid ne  %then %do;
      xclientid = strip("&clientid");
      xcgid = strip("&cgid");
      if clientid eq xclientid then do;
        cgid=xcgid;
      end;
    %end;

    %if &short_client_name ne  %then %do;
      xclientid = strip("&clientid");
      xshort_client_name = strip("&short_client_name");
      if clientid eq xclientid then do;
        short_client_name=xshort_client_name;
      end;
    %end;

    output;
  run;
  title 'Edit complete. You should see only one record, two or more indicates a problem';
  proc print data=_LAST_(obs=max) width=minimum; where clientid="&clientid"; run;  
%mend;
*%edit_tmm_census_lookup_ds(clientid=408, npi=123, storeid=, clientfolder=, store_name=, cgid=, short_client_name=);
*%edit_tmm_census_lookup_ds(clientid=408, npi=, storeid=123, clientfolder=, store_name=, cgid=, short_client_name=);
*%edit_tmm_census_lookup_ds(clientid=408, npi=, storeid=, clientfolder=%str(folder - 123), store_name=, cgid=, short_client_name=);
*%edit_tmm_census_lookup_ds(clientid=408, npi=, storeid=, clientfolder=, store_name=%str(my store), cgid=, short_client_name=);
*%edit_tmm_census_lookup_ds(clientid=408, npi=, storeid=, clientfolder=, store_name=, cgid=123, short_client_name=);
*%edit_tmm_census_lookup_ds(clientid=408, npi=, storeid=, clientfolder=, store_name=, cgid=, short_client_name=foo);
%macro append_tmm_census_lookup_ds(clientid=, npi=, storeid=, clientfolder=, store_name=, cgid=, short_client_name=);
  libname BUILD '/Drugs/Drugs/Build';

  data BUILD.tmm_census_lookup;
    set BUILD.tmm_census_lookup end=e;
    output;
    if e then do;
      clientfolder="&clientfolder";
      clientid="&clientid";
      npi="&npi";
      storeid=&storeid;
      store_name="&store_name";
      cgid=&cgid;
      short_client_name="&short_client_name";
      output;
    end;
  run;
  title 'Append complete. You should see only one record, two or more indicates a problem';
  proc print data=_LAST_(obs=max) width=minimum; where clientid="&clientid"; run;  
%mend;
*%append_tmm_census_lookup_ds(clientid=999, npi=1234567890, storeid=123, clientfolder=%nrstr(New Client - 123), store_name=NewstoreA, cgid=12345, short_client_name=NewA);
%macro delete_tmm_census_lookup_ds(clientid=);
  libname BUILD '/Drugs/Drugs/Build';

  title 'Deleting...';
  proc print data=BUILD.tmm_census_lookup(obs=max) width=minimum; where clientid="&clientid"; run;  
  data BUILD.tmm_census_lookup;
    set BUILD.tmm_census_lookup;
    if clientid eq &clientid then delete;
  run;
  title 'After delete:';
  proc print data=BUILD.tmm_census_lookup(obs=max) width=minimum; where clientid="&clientid"; run;  
%mend;
*%delete_tmm_census_lookup_ds(clientid=408);
