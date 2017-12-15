%macro segment_publix(importony=);
  options NOsource mprintnest;
  /********************************************************************************
  *  SAVED AS:                segment_publix.sas
  *                                                                         
  *  CODED ON:                05-Dec-15 by Bob Heckel
  *                                                                         
  *  DESCRIPTION:             Split Publix dropbox submissions
  *
  *  PARAMETERS:              
  *
  *  MACROS CALLED:           
  *                                                                         
  *  INPUT GLOBAL VARIABLES:  NONE
  *                                                                         
  *  OUTPUT GLOBAL VARIABLES: NONE  
  *                                                                         
  *  LAST REVISED:                                                          
  *   05-Dec-15 (bheckel)    Initial version
  ********************************************************************************/
  options source mprint mprintnest symbolgen=no sasautos=(SASAUTOS '/Drugs/Macros')
          fmtsearch=(myfmtlib) validvarname=any
          ;

/*DEBUG******************************************************/
%let clid=256;
  %global maxdate months mon max mindate min location reportlocation filename storeid nobs 
          totalpatients censusmaxdate censusmindate clientfolder NPI CGID store_name 
          subfolder short_client_name
          ;

  %let maxdate=%sysfunc(intnx(day, "&SYSDATE9"D, -1, b), DATE9.);
  %let months=6;
  %let patid=pharmacypatientid;
  %let subfolder=Projections;
  %let mindrugs=3;
  %let minage=18;
  %let saveoriginalpull=Y;
  %let atebpatientid=;
  %let NPI=;
  %let cap=N;
  %let numcap=;
  %let nrx=%str(3,4,5);

  %dbpassword;

/***  %load_tmm_census_mvars(clientid=&clid);***/
/***  %options_tmm;***/
/***  %importst_TMM;***/
/***  %filter_tmm;***/
/***  %qc_tmm;***/
/***  %report_tmm;***/
/***  %census_tmm(var_patientid=pharmacypatientid);***/
/***  %put _USER_;***/
/***  %censusreport_tmm(var_patientid=pharmacypatientid);***/
/***  %censusreport_insight_tmm(var_patientid=pharmacypatientid);***/
/***  %additionalqc_tmm;***/
/***  %tmm_automail(el_submit=Y, mailto=%str('bob.heckel@taeb.com'));***/
/*DEBUG******************************************************/


%let path=/Drugs/Personnel/bob/TMM/Publix;
options ls=180 ps=max; libname data "&path";
/***data fnl_publix;set data.fnl_publix(obs=100005);run;***/
data fnl_publix;set data.fnl_publix;run;

  proc sql;
    select count(*) into :nrecs
/***    from data.fnl_publix ***/
    from fnl_publix 
    ;
  quit;
  proc sql NOprint;
    select count(distinct storeid) into :nstores
/***    from data.fnl_publix ***/
    from fnl_publix 
    ;
  quit;
  proc sql NOprint;
    select distinct storeid into :stores separated by ','
/***    from data.fnl_publix ***/
    from fnl_publix 
    ;
  quit;
  %put !!! &=stores;

  /*********** separate into store ds **************/
  %let i=1;
  %let f=%scan(%superq(stores), &i, ',');

  %do %while ( &f ne  );
    %let i=%eval(&i+1);

/***    %put DEBUG: &=f;***/
    data t_&f;
      set fnl_publix;
      if storeid eq "&f" then output;
    run;

    %let f=%scan(%superq(stores), &i, ',');
  %end;

  
  /************ count obs per store ds ************/
  %let i=1;
  %let f=%scan(%superq(stores), &i, ',');

  %do %while ( &f ne  );
    %let i=%eval(&i+1);

/***    %put DEBUG: &=f;***/
    proc sql NOprint;
      select count(*) into :cnt&f
      from t_&f
      ;
    quit;

    %let f=%scan(%superq(stores), &i, ',');
  %end;


  /*********** store / count *************/
  %let i=1;
  %let f=%scan(%superq(stores), &i, ',');

  %do %while ( &f ne  );
    %let i=%eval(&i+1);

    %put DEBUG: &f is &&cnt&f;

    %let f=%scan(%superq(stores), &i, ',');
  %end;


  /*********** Produce 10 output files *************/
  %let i=1;
  %let buildgrp=;
  %let f=%scan(%superq(stores), &i, ',');
  %let grouplist=;

  %do %while ( &f ne  );
    %let endofgrp=%sysfunc(mod(&i,100));
    %let i=%eval(&i+1);

    %if &endofgrp ne 0 %then %do;
      %put DEBUG: &f is &&cnt&f &=endofgrp &=buildgrp;
      /* Keep (or start) processing the list */
      %let buildgrp=&buildgrp &f;
    %end;
    %else %do;
      /* Add last store in this group of 10 */
      %let buildgrp=&buildgrp &f;
      %put DEBUG: grouping &buildgrp into one dataset &=i;
      %let grouplist=&grouplist grp_&i;
      data grp_&i;
        set fnl_publix;
        if storeid in(&buildgrp) then output;
      run;
      /* Reset for next group start */
      %let buildgrp=;
    %end;

    %put DEBUG: &=i &f is &&cnt&f &=endofgrp &=buildgrp;

    %let f=%scan(%superq(stores), &i, ',');
  %end;


  /**** Handle final ragged group, if any stores are still unprocessed ****/
  %if &buildgrp ne  %then %do;
    %put DEBUG: grouping final &buildgrp into one dataset &=i;
    %let grouplist=&grouplist grp_&i;
    data grp_&i;
      set fnl_publix;
      if storeid in(&buildgrp) then output;
    run;
  %end;
  proc datasets library=work;run;


  %let i=1;
  %let g=%scan(%superq(grouplist), &i, ' ');
  %do %while ( &g ne  );
    %put DEBUG: writing &=g to csv &=i;
    proc export data=&g OUTFILE="&path/PUPTMM_candidates_fdw_&i..csv" DBMS=CSV REPLACE; run; 
    %let i=%eval(&i+1);
    %let g=%scan(%superq(grouplist), &i, ' ');
  %end;
%put _user_;
%mend;
%segment_publix(importony=Y);
