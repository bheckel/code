options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: subset_ds_into_chunks.mcr.sas
  *
  *  Summary: Demo of splitting a dataset based on an increment value
  *
  *  Created: Thu 28 Aug 2014 13:24:20 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

%macro chunk(incr=);
  proc sql noprint;
    select count(*) into :nrec
    from sashelp.shoes
    ;
  quit;

  %let maxi=%sysfunc(ceil(&nrec/&incr));

  %do i=1 %to &maxi;
    %let fo=%eval( (&i-1) * &incr+1 );
    %let ob=%sysfunc(min(&i * &incr, &nrec));

    data temps&i; 
      set sashelp.shoes(firstobs=&fo obs=&ob);
    run;
  %end;

  data useless_reassembly;
    set
      %do i=1 %to &maxi;
        temps&i
      %end;
    ;
  run;
%mend chunk;
%chunk(incr=150);
proc print data=useless_reassembly(obs=max) width=minimum; run;
/***proc print data=temps3(obs=max) width=minimum; run;***/
