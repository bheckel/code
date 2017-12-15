%macro qry_prx;
  %let cntobs=0;

  proc sql NOprint;
    select distinct storeid into :ITM1-:ITM%left(&cntobs) from subset_wc_npi where storeid ne .;
  quit;

  %macro buildprxlist;
    %do i=1 %to &cntobs;
      %if &i ne &cntobs %then %do;
%bquote(&&ITM&i,)
      %end;
      %else %do;
%bquote(&&ITM&i)
      %end;
    %end;
  %mend;

  data _null_; put "buildprxlist is %bquote(%buildprxlist)"; run; quit;

  %macro dsexists2;
    %if %sysfunc(fileexist(&OUTPATHCURR/prx.sas7bdat)) %then %do;
      %put &OUTPATHCURR/prx exists so skipping this query;
    %end;
    %else %do;
      %put &OUTPATHCURR/prx does not exist so running this query;

      %odbc_start(OMYA, prx, ajsper);

      select rxnum, storeid, clientid, atebpatientid
      from schem.e_patient_pat
      where storeid in( %buildprxlist ) and created > date('now') - interval '365 days'
      ;

     %odbc_end;
    %end;
  %mend;
  %dsexists2;
%mend qry_prx;
%qry_prx;

