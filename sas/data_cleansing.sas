options mautosource sasautos=('/Drugs/RTS/Monthly/Macros' '/Drugs/Macros' sasautos) mrecall mprint mprintnest fmtsearch=(myfmtlib) NOQUOTELENMAX;

%macro qc_tmm_activation(clientid=,rx30=,npi=,pilot=);
  %is_redpoint(clid=&clientid);

  %if %length(&npi)>0 and (%upcase(&rx30)=Y) %then %do;
    %let npi=%str(or (clientid = 164 and npi in (%bquote(')&npi.%bquote('))));
  %end;
  %else %if %length(&npi)>0 and (%upcase(&rx30)=N) %then %do;
    %let npi= ;
  %end;
%put DEBUG: &=npi;

  %if &redpoint_client eq 1 %then %do;
    %let table=%str(sdfarchive);
    %let parent=%str(sdfarchive);
    %let rxnumber=%str(rxnum);
    %let storeidentifier=%str(clientstoreid);
    %let prescriptstatus=%str(rxstatus);
  %end;
  %else %do;
    %let table=%str(rxfilldata_parent);
    %let parent=%str(rxfilldata_parent);
    %let rxnumber=%str(rxnbr);
    %let storeidentifier=%str(storeid);
    %let prescriptstatus=%str(prescriptionstatus);
  %end;
%put DEBUG: &=table;
%put DEBUG: &=parent;

  libname BUILD '/Drugs/FunctionalData';

  /* also check if cgid exist in shortname ds */
  proc sql NOprint;
    select cgid, short_client_name into :cgid, :shortname from build.clients_shortname_lookup 
      where clientid =&clientid.;
  quit;

  proc sql NOprint;
    select strip(short_client_name)||'_'||"%sysfunc(putn("&SYSDATE"d, YYMMDDD10.))"||'.pdf' into :Cname from build.clients_shortname_lookup where clientid eq &clientid.;
    select short_client_name into :shortname from build.clients_shortname_lookup where clientid eq &clientid.;
  quit;

  /* Assign ODS PDF for QC file */ 
  /* 20160215: change folder location to TWA folder structure: /Drugs/TMMEligibility */ 
  %let clientfolder = %sysfunc(strip(&shortname.)); 
  %put &=shortname &=Cname &=clientfolder;

  options device=png;
  ods escapechar = "^"; 
  ods listing close;

  /* Check if pilot<clientid>.sas file exists and if so, assign pilot macro var; */
  /* %pilot<clientid> macro removes leading 0's from storeids                    */ 
  %let pilotfile = %str(pilot&clientid..sas); %put pilotfile= &pilotfile;
  %if (%upcase(&pilot)=Y and %sysfunc(fileexist(%str(/Drugs/Macros/&pilotfile.)))) %then %do;
    %let pilot = %str(and (trim(leading '0' from &storeidentifier) in (%pilot&clientid.))); 
  %end;
  %else %if %upcase(&pilot)=Y %then %do;
    %put YOU MUST CREATE A SAS MACRO CALLED pilot&clientid..sas AND;
    %put PLACE in M:\DRUGS\MACRO AUTOCALL LIBRARY THEN RERUN THIS STORED PROCESS.;
    endsas;
  %end;
  %else %do;
    %put All Store(s) will be used since no Pilot stores indicated.;
    %let pilot= ;
  %end;
  %put pilot= &pilot;

  %dbpassword;

  /* Make one pull of all columns for QC and filter by clientid and/or NPI */
  proc sql;
    connect to odbc as myconn (user=&user. password=&password. dsn='db5' readbuff=7000);
    create table work.qc_status as select * from connection to myconn 

      %if &redpoint_client eq 1 %then %do;
        (
         select pharmacypatientid, patientdateofbirth as patientdob, patientpostalcode, patientphonenum1 as patientphonenbr, clientstoreid as
                storeid, autofillprogram, ndc, prescriptionorigin, filldate, solddate, rxstatus as prescriptionstatus, paidamount, copayamount, bin, pcn, groupid, 
                personcode, patientgender, patientstateprov, productidqualifier, productid, maskedpatientkey as masked_patientkey,
                '' as masked_patient_phone_number, '' as masked_rx_number, longtermcarefacilityid as longtermcarefacilitycode, '' as autofilltype
         from &table
         where (clientid = &clientid &npi) &pilot and
               filldate >= date_trunc('MONTH', now())-'1 month'::interval and filldate < date_trunc('month', NOW())-'1 month'::interval+'1 month'::interval
        );
      %end;

      %else %do;
        (
         select pharmacypatientid, patientdob, patientpostalcode, patientphonenbr, storeid, autofillprogram, ndc, prescriptionorigin, filldate,
                solddate, prescriptionstatus, paidamount,  copayamount, bin, pcn, groupid, personcode, patientgender, patientstateprov,
                productidqualifier, productid, masked_patientkey, masked_patient_phone_number, masked_rx_number, longtermcarefacilitycode, autofilltype
         from &table
         where (clientid = &clientid &npi) &pilot and
               filldate >= date_trunc('MONTH', now())-'1 month'::interval and filldate < date_trunc('month', NOW())-'1 month'::interval+'1 month'::interval
         );
       %end;

    disconnect from myconn;
  quit;


  ods pdf file="/Drugs/TMMEligibility/&clientfolder./Imports/ClientQC_&Cname." startpage=no;

  proc sql; select patientgender,count(*) from work.qc_status group by 1 order by 1; quit;

  proc sql; select patientstateprov,count(*) from work.qc_status group by 1 order by 1; quit;

  proc sql; select lengthn(patientphonenbr) as patientphonenbr, count(*) from work.qc_status group by 1 order by 1; quit;

  proc sql; select storeid ,count(*) from work.qc_status group by 1 order by 1; quit;

  proc sql; select longtermcarefacilitycode ,count(*) from work.qc_status group by 1 order by 1; quit;

  proc sql; select count(pharmacypatientid) as 'null pharmacypatientid'n from work.qc_status where pharmacypatientid is null ; quit;

  proc sql; select lengthn(ndc) as ndc, count(*) from work.qc_status group by 1; quit;

  proc sql; select count(distinct pharmacypatientid) as pharmacypatientid from work.qc_status ; quit;

  proc sql; select count(distinct pharmacypatientid) as pharmacypatientid,count(distinct masked_patientkey) as masked from work.qc_status; quit;

  proc sql; select (year(today()) - year(patientdob)) as age, count(*) from work.qc_status group by 1 order by 1;  quit;


  proc sql;
      /* connect to postgres as myconn ( database=&db5db. authdomain=&db5authdom. server=&db5serv. readbuff=7000 ); */
    connect to odbc as myconn (user=&user. password=&password. dsn='db5' readbuff=7000);
      create table analyze_ps as select * from connection to myconn
         (select &rxnumber,pharmacypatientid,&storeidentifier,filldate,to_char(filldate,'YYYY-MM') as dates,
                 &prescriptstatus as prescriptionstatus from &table
          where (filldate >= (current_date - integer '365')) and (clientid = &clientid));
/* fake a 2nd store */
/* where (filldate >= (current_date - integer '365')) and (clientid in( &clientid, 880))); */
    disconnect from myconn;

    /* Prescriptionstatus */
      create table work.analyze_ps1 as
        select dates,Prescriptionstatus,count(*) as counts
        from analyze_ps 
        group by 1,2 order by 1,2;
     
    /* non-deduped Filldate */
     create table analyze_ps2 as
       select filldate, count(*) as counts 
       from analyze_ps 
       group by 1 order by 1;

    /* deduped Filldate */
     create table analyze_ps3 as 
       select count(distinct cats(&rxnumber, pharmacypatientid, filldate)) as counts, filldate 
       from analyze_ps 
       group by 2 order by 2,1;

    /* Stores Activating */
      create table analyze_storesActivating as 
        select count(distinct &storeidentifier) as counts, dates
        from analyze_ps
        where filldate >= '01JAN2013'd group by 2 order by 2,1;
  quit;

  SYMBOL1 INTERPOL=JOIN HEIGHT=10pt VALUE=NONE LINE=1 WIDTH=2 C=red;
  SYMBOL2 INTERPOL=JOIN HEIGHT=10pt VALUE=NONE LINE=1 WIDTH=2 C=blue;
  SYMBOL3 INTERPOL=JOIN HEIGHT=10pt VALUE=NONE LINE=1 WIDTH=2 C=green;

  Axis1 STYLE=1 WIDTH=1 MINOR=NONE LABEL=("prescriptionstatus");
  Axis2 STYLE=1 WIDTH=1 MINOR=NONE;
  TITLE;
  TITLE1 "Line Plot";
  FOOTNOTE;

  PROC GPLOT DATA = work.analyze_ps1;
      PLOT counts * dates=prescriptionstatus / VAXIS=AXIS1 HAXIS=AXIS2 FRAME;
  RUN; QUIT;

  SYMBOL1 INTERPOL=JOIN HEIGHT=10pt VALUE=NONE LINE=1 WIDTH=2 C=red;
  Axis1 STYLE=1 WIDTH=1 MINOR=NONE LABEL=("Fill Date not Deduped");
  Axis2 STYLE=1 WIDTH=1 MINOR=NONE;
  TITLE;
  TITLE1 "Line Plot";
  FOOTNOTE;

  PROC GPLOT DATA = work.analyze_ps2;
      PLOT counts * filldate / VAXIS=AXIS1 HAXIS=AXIS2 FRAME;
  RUN; QUIT;

  SYMBOL1 INTERPOL=JOIN HEIGHT=10pt VALUE=NONE LINE=1 WIDTH=2 C=red;
  Axis1 STYLE=1 WIDTH=1 MINOR=NONE LABEL=("Fill Date - DEDUPED!!");
  Axis2 STYLE=1 WIDTH=1 MINOR=NONE;
  TITLE;
  TITLE1 "Line Plot";
  FOOTNOTE;

  PROC GPLOT DATA = work.analyze_ps3;
      PLOT counts * filldate / VAXIS=AXIS1 HAXIS=AXIS2 FRAME;
  RUN; QUIT;

  /* create SAS data to plot unique store activations */
  PROC SGPLOT DATA = work.analyze_storesActivating;
    xaxis label = "Stores Active";
      series x=dates y=counts  / name="series" datalabel;
  RUN; QUIT;

  
  ods pdf close;

  ods listing;
  /* header details */
  proc sql NOprint;
    select quote(cats('%',substr(long_client_name,1,5),'%'),"'") into :longname from build.clients_shortname_lookup where clientid=&clientid;
  quit;

  %odbc_start(lib=work, ds=t, db=db3);
    SELECT description, groupname FROM amc.campaigngroups WHERE description ilike &longname and campaigntype = 'TMM';
  %odbc_end;
  /* title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title; */

  %odbc_start(lib=work, ds=t, db=db6);
    SELECT clientid, pms FROM analytics.vtmmclient where clientid=&clientid;
  %odbc_end;
  %let d=%sysfunc(putn("&sysdate"d, YYMMDDN8.));



  title "qc_status";proc print data=qc_status(obs=10) width=minimum heading=H;run;title;  

  /* If we fail ANY of these conditions, we must abort the process */

   /* Patient gender criterion: "At least 99% must be present and valid" */
  proc sql;
    create table _err_patientgender as
    select distinct (select count(*) from qc_status where patientgender not in ('M','F')) / (select count(*) from qc_status) as pct, '_err_patientgender' as ds
    from qc_status
    having pct gt 0.05
    ;
  quit;


   /* Patient state criterion: "Must be a U.S. state or territory - if not, they will be excluded - note the percentage" */
  proc sql;
    create table _err_patientstate as
    select patientstateprov, '_err_patientstate' as ds
    from qc_status
    where patientstateprov not in ('AL','AK','AS','AZ','AR','CA','CO','CT','DE','DC','FM','FL','GA','GU','HI','ID','IL','IN','IA','KS','KY','LA','ME','MH','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','MP','OH','OK','OR','PW','PA','PR','RI','SC','SD','TN','TX','UT','VT','VI','VA','WA','WV','WI','WY') 
    ;
  quit;


   /* Patient phone number criterion: "Note the percentage of phone numbers that are valid (10 digits) - We will not be able to call any phone number with more or less digits" */
  proc sql;
    create table _err_patientphonenbr as
    select distinct (select count(*) from qc_status where length(patientphonenbr) ne 10) / (select count(*) from qc_status) as pct, '_err_patientphonenbr' as ds
    from qc_status
    having pct gt 0.05
    ;
  quit;
  title "_err_patientphonenbr";proc print data=_err_patientphonenbr width=minimum heading=H;run;title;


  /* "Describe any large discrepancies in store volume in the 'Investigation' box. Type 'See Investigation' in the 'Observed' box (this applies to multi-store chains only - if only a single-store, type 'N/A')" */
/* data analyze_ps; */
/* set analyze_ps end=e; */
/* if mod(_n_,3) eq 0 then storeid='999'; */
/* if e then storeid='000'; */
/* run; */
  proc sql;
    create table storevol as
    select storeid, pharmacypatientid, count(*) as cnt
    from analyze_ps
    group by 1, 2
    ;
  quit;

  proc means data=storevol;
    output out=storevol2 std=;
    class storeid;
    var cnt;
  run;

  /* If stddev of volume is wider than 10% then flag an error */
  proc sql;
    create table _err_storevol as
    select storeid, '_err_storevol' as ds
    from storevol2
    where cnt < (select cnt*0.10 from storevol2 where _TYPE_ eq 0)
    ;
  quit;


  /* "Note any values that appear in the 'longtermcarefacilitycode' field as well as the corresponding number of records for each" */
/* data qc_status; */
/* set qc_status; */
/* if _n_ in (1,3,6,9,11,13,15) then longtermcarefacilitycode=1; */
/* run; */
  proc sql;
    create table _err_longtermcarefacility as
    select distinct (select count(longtermcarefacilitycode) from qc_status) / (select count(*) from qc_status) as pct, '_err_longtermcarefacility' as ds
    from qc_status
    having pct gt 0.05
    ;
  quit;


  /* "If pharmacypatientid is null it must be investigated" */
  proc sql;
    create table _err_pharmacypatientid as
    select pharmacypatientid, '_err_pharmacypatientid' as ds
    from qc_status
    where pharmacypatientid is null
    ;
  quit;


  /* "At least 99% NDC must be present and valid (11 digits)" */
  proc sql;
    create table _err_ndc as
    select distinct (select count(*) from qc_status where length(ndc) ne 11) / (select count(*) from qc_status) as pct, '_err_ndc' as ds
    from qc_status
    having pct gt 0.05
    ;
  quit;


  /* "What percentage of pharmacypatientid matches to maskedpatientkey? This should be as close to a 100% match as possible - if the difference is 5% or more, it must be investigated" */
  proc sql;
    create table _err_ppidmask as
    select distinct (select count(distinct pharmacypatientid) from qc_status) / (select count(distinct masked_patientkey) from qc_status) as pct, '_err_ppidmask' as ds
    from qc_status
    having pct lt 0.95
    ;
  quit;


  /* Age - at least 99% must be present and valid" */
  proc sql;
    create table _err_age as
    select distinct (select count(year(today())-year(patientdob))
                     from qc_status
                     where year(today())-year(patientdob) ge 0 and year(today())-year(patientdob) le 120)
                     /
                     (select count(year(today())-year(patientdob))
                      from qc_status)
                     as pct, '_err_age' as ds
    from qc_status
    having pct lt 0.95
    ;
  quit;


  /* "prescription statuses '2' and '3' as the primary statuses" */
  proc sql;
    create table _err_prescriptionstatus as
    select distinct (select count(prescriptionstatus) from qc_status where prescriptionstatus in(2,3))
                    / (select count(prescriptionstatus) from qc_status)
                    as pct, '_err_prescriptionstatus' as ds
    from qc_status
    having pct lt 0.7
    ;
  quit;


  /* "at least six months of data (preferably one year)" */
  proc sql; select min(filldate) format=date., max(filldate) format=date., today()-min(filldate) as days from analyze_ps;quit;
  proc sql;
    create table _err_sixmodata as
    select min(filldate) format=date. as 'less than 6 months data'n, '_err_sixmodata' as ds
    from analyze_ps
    having today() - min(filldate) < 180
    ;
  quit;


  data error_count;
    length ds $40;
    set _err:;
  run;
  title "&SYSDSN";proc print data=error_count width=minimum heading=H;run;title;  

  %put _user_;

  %if %sysfunc(attrn(%sysfunc(open(error_count)), NLOBSF)) gt 0 %then %do;
    %put ERROR: QC fail;
    /*DEBUG*/
    /* data _null_; to='bob.heckel@taeb.com'; file DUMMY email filevar=to subject="Error during &SYSPROCESSNAME execution" attach=("/Drugs/TMMEligibility/&clientfolder./Imports/ClientQC_&Cname"); run; */
    data _NULL_; abort abend 008; run;
  %end;
  %else %do;
    %put NOTE: QC clean;
  %end;
%mend qc_tmm_activation;
