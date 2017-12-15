 /* Created: Fri 04 Dec 2015 13:42:33 (Bob Heckel) */
 /* See AN-2266 for ndc dataset creation */
options sasautos=(SASAUTOS '/Drugs/Macros' '.') ls=max ps=max mprint mprintnest NOcenter validvarname=any;
libname l '/Drugs/RFD/2015/12/AN-2340/Datasets';
%dbpassword;

%macro m;
  /* Almost all of the 10 NDC lists overflow macrovariable limits */
  proc sql NOprint;
    select left(put(count(distinct ndc),8.)) into :nndc
    from l.ndc
    where ndc is not null
    ;

    select left(put(count(distinct ndc),8.)) into :nndcalz
    from l.ndc
    where ndc is not null and medgroup='alzheime'
    ;

    select left(put(count(distinct ndc),8.)) into :nndcbph
    from l.ndc
    where ndc is not null and medgroup='bphgpime'
    ;

    select left(put(count(distinct ndc),8.)) into :nndccar
    from l.ndc
    where ndc is not null and medgroup='cardiova'
    ;

    select left(put(count(distinct ndc),8.)) into :nndccho
    from l.ndc
    where ndc is not null and medgroup='choleste'
    ;

    select left(put(count(distinct ndc),8.)) into :nndcdep
    from l.ndc
    where ndc is not null and medgroup='depressi'
    ;

    select left(put(count(distinct ndc),8.)) into :nndcdia
    from l.ndc
    where ndc is not null and medgroup='diabetes'
    ;

    select left(put(count(distinct ndc),8.)) into :nndchyp
    from l.ndc
    where ndc is not null and medgroup='hyperten'
    ;

    select left(put(count(distinct ndc),8.)) into :nndcost
    from l.ndc
    where ndc is not null and medgroup='osteopor'
    ;

    select left(put(count(distinct ndc),8.)) into :nndcres
    from l.ndc
    where ndc is not null and medgroup='respirat'
    ;

    select left(put(count(distinct ndc),8.)) into :nndcthy
    from l.ndc
    where ndc is not null and medgroup='thyroidd'
    ;
  quit;

  %do i=1 %to &nndc;
    %global ndc&i;
    %let ncd&i=;
  %end;

  %do i=1 %to &nndcalz;
    %global ndcalz&i;
    %let ncdalz&i=;
  %end;

  %do i=1 %to &nndcbph;
    %global ndcbph&i;
    %let ncdbph&i=;
  %end;

  %do i=1 %to &nndccar;
    %global ndccar&i;
    %let ncdcar&i=;
  %end;

  %do i=1 %to &nndccho;
    %global ndccho&i;
    %let ncdcho&i=;
  %end;

  %do i=1 %to &nndcdep;
    %global ndcdep&i;
    %let ncddep&i=;
  %end;

  %do i=1 %to &nndcdia;
    %global ndcdia&i;
    %let ncddia&i=;
  %end;

  %do i=1 %to &nndchyp;
    %global ndchyp&i;
    %let ncdhyp&i=;
  %end;

  %do i=1 %to &nndcost;
    %global ndcost&i;
    %let ncdost&i=;
  %end;

  %do i=1 %to &nndcres;
    %global ndcres&i;
    %let ncdres&i=;
  %end;

  %do i=1 %to &nndcthy;
    %global ndcthy&i;
    %let ncdthy&i=;
  %end;

  proc sql NOprint;
    select distinct cats("'", left(trim(ndc)), "'") into :ndc1 - :ndc&nndc
    from l.ndc
    where ndc is not null
    ;

    select distinct cats("'", left(trim(ndc)), "'") into :ndcalz1 - :ndcalz&nndcalz
    from l.ndc
    where ndc is not null and medgroup='alzheime'
    ;

    select distinct cats("'", left(trim(ndc)), "'") into :ndcbph1 - :ndcbph&nndcbph
    from l.ndc
    where ndc is not null and medgroup='bphgpime'
    ;

    select distinct cats("'", left(trim(ndc)), "'") into :ndccar1 - :ndccar&nndccar
    from l.ndc
    where ndc is not null and medgroup='cardiova'
    ;

    select distinct cats("'", left(trim(ndc)), "'") into :ndccho1 - :ndccho&nndccho
    from l.ndc
    where ndc is not null and medgroup='choleste'
    ;

    select distinct cats("'", left(trim(ndc)), "'") into :ndcdep1 - :ndcdep&nndcdep
    from l.ndc
    where ndc is not null and medgroup='depressi'
    ;

    select distinct cats("'", left(trim(ndc)), "'") into :ndcdia1 - :ndcdia&nndcdia
    from l.ndc
    where ndc is not null and medgroup='diabetes'
    ;

    select distinct cats("'", left(trim(ndc)), "'") into :ndchyp1 - :ndchyp&nndchyp
    from l.ndc
    where ndc is not null and medgroup='hyperten'
    ;

    select distinct cats("'", left(trim(ndc)), "'") into :ndcost1 - :ndcost&nndcost
    from l.ndc
    where ndc is not null and medgroup='osteopor'
    ;

    select distinct cats("'", left(trim(ndc)), "'") into :ndcres1 - :ndcres&nndcres
    from l.ndc
    where ndc is not null and medgroup='respirat'
    ;

    select distinct cats("'", left(trim(ndc)), "'") into :ndcthy1 - :ndcthy&nndcthy
    from l.ndc
    where ndc is not null and medgroup='thyroidd'
    ;
  quit;


  %let ndc0='00000000000';  /* placeholder for first element */
  %macro ndclist(start=, end=);
&ndc0
    %do j=&start %to &end;
,&&ndc&j
    %end;
  %mend;

  %let ndcalz0='00000000000';  /* placeholder for first element */
  %macro ndcalzlist(start=, end=);
&ndcalz0
    %do j=&start %to &end;
,&&ndcalz&j
    %end;
  %mend;

  %let ndcbph0='00000000000';  /* placeholder for first element */
  %macro ndcbphlist(start=, end=);
&ndcbph0
    %do j=&start %to &end;
,&&ndcbph&j
    %end;
  %mend;

  %let ndccar0='00000000000';  /* placeholder for first element */
  %macro ndccarlist(start=, end=);
&ndccar0
    %do j=&start %to &end;
,&&ndccar&j
    %end;
  %mend;

  %let ndccho0='00000000000';  /* placeholder for first element */
  %macro ndccholist(start=, end=);
&ndccho0
    %do j=&start %to &end;
,&&ndccho&j
    %end;
  %mend;

  %let ndcdep0='00000000000';  /* placeholder for first element */
  %macro ndcdeplist(start=, end=);
&ndcdep0
    %do j=&start %to &end;
,&&ndcdep&j
    %end;
  %mend;

  %let ndcdia0='00000000000';  /* placeholder for first element */
  %macro ndcdialist(start=, end=);
&ndcdia0
    %do j=&start %to &end;
,&&ndcdia&j
    %end;
  %mend;

  %let ndchyp0='00000000000';  /* placeholder for first element */
  %macro ndchyplist(start=, end=);
&ndchyp0
    %do j=&start %to &end;
,&&ndchyp&j
    %end;
  %mend;

  %let ndcost0='00000000000';  /* placeholder for first element */
  %macro ndcostlist(start=, end=);
&ndcost0
    %do j=&start %to &end;
,&&ndcost&j
    %end;
  %mend;

  %let ndcres0='00000000000';  /* placeholder for first element */
  %macro ndcreslist(start=, end=);
&ndcres0
    %do j=&start %to &end;
,&&ndcres&j
    %end;
  %mend;

  %let ndcthy0='00000000000';  /* placeholder for first element */
  %macro ndcthylist(start=, end=);
&ndcthy0
    %do j=&start %to &end;
,&&ndcthy&j
    %end;
  %mend;

/*DEBUG*/
%put DEBUG: %ndclist(start=1, end=5);
%put DEBUG: %ndcalzlist(start=1, end=5);
/***%put DEBUG: %ndcbphlist(start=1, end=5);***/
/***%put DEBUG: %ndccarlist(start=1, end=5);***/
/***%put DEBUG: %ndccholist(start=1, end=5);***/
/***%put DEBUG: %ndcdeplist(start=1, end=5);***/
/***%put DEBUG: %ndcdialist(start=1, end=5);***/
/***%put DEBUG: %ndchyplist(start=1, end=5);***/
/***%put DEBUG: %ndcostlist(start=1, end=5);***/
/***%put DEBUG: %ndcreslist(start=1, end=5);***/
/***%put DEBUG: %ndcthylist(start=1, end=5);***/

  proc sql;
    connect to odbc as myconn (user=&user. password=&password. dsn='db2ateb' readbuff=7000);

    create table clients as select * from connection to myconn (

      select id as clientid, name as clientname
      from amc.clients
      ;

    );

    disconnect from myconn;
  quit;
  

  proc sql;
    connect to odbc as myconn (user=&user. password=&password. dsn='db2ateb' readbuff=7000);

    create table storescnt as select * from connection to myconn (

      select clients_fkid, count(*) as nstores
      from amc.stores
      where stateprov = 'FL' and status = 'OPEN'
      group by clients_fkid
      ;

    );

    disconnect from myconn;
  quit;
  proc sql noprint;
    select distinct clients_fkid into :clientid_ind separated by ',' from storescnt where nstores=1;
  quit;
%put !!! &=clientid_ind;
  proc sql noprint;
    select distinct clients_fkid into :clientid_cha separated by ',' from storescnt where nstores>1;
  quit;
%put !!! &=clientid_cha;


  proc sql;
    connect to odbc as myconn (user=&user. password=&password. dsn='db2ateb' readbuff=7000);

    create table stores as select * from connection to myconn (

      select clients_fkid, id, stateprov, storeid, name, city, postalcode
      from amc.stores
      where stateprov = 'FL' and status = 'OPEN'
      ;

    );

    disconnect from myconn;
  quit;
  
  data stores;
    length sid $12;
    set stores;
    sid=%rml0(storeid);
  run;
   
/***CLIENTID_CHA=10,17,20,30,39,40,118,164,626,649,671,672,673***/
/***CLIENTID_IND=1,49,88,106,133,137,173,196,212,215,216,226,250,303,304,357,365,381,382,383,384,385,386,387,396,438,464,467,473,476,481,482,485,492,495,514,522,529,530,543,544,545,546,564,567,569,572,598,599,605,619,632,667,681,692,699,752,849,854,928***/
/*DEBUG*/
/***%let clientid_cha=17;***/
/***%let clientid_ind=304,49;***/


  %macro buildds(type=, clids=);
    proc datasets NOlist; delete rxfilldata_all rxfilldata_all2 ; run;
    proc datasets NOlist library=l; delete rxfilldata_all2_&type; run;
    /* For each month--- */
    %let months=201412 201501 201502 201503 201504 201505 201506 201507 201508 201509 201510 201511;
    /*DEBUG*/
/***    %let months=201510;***/
    %let i=1;
    %let mo=%scan(%superq(months), &i, ' ');
    %do %while ( &mo ne  );
        %put DEBUG: &=i &=mo;

        proc sql;
          connect to odbc as myconn (user=&user. password=&password. dsn='db5' readbuff=7000);

          create table rxfilldata_&mo as select * from connection to myconn (

            select masked_patientkey, clientid, storeid, ndc
            from public.rxfilldata_&mo
            where clientid in(&clids) and patientdob < date('now')-interval '65 year'
            ;

          );
          disconnect from myconn;
        quit;
        proc append base=rxfilldata_all data=rxfilldata_&mo FORCE; run;
        proc datasets NOlist; delete rxfilldata_&mo; run;

      %let i=%eval(&i+1);
      %let mo=%scan(%superq(months), &i, ' ');
    %end;

    %let i=1;
    %let cid=%scan(%superq(clids), &i, %str(,));

    %do %while ( &cid ne  );
      %put DEBUG: &=i &=cid;

      options NOmprint NOmprintnest;
      data rxfilldata_&cid;
        set rxfilldata_all;
        if clientid eq &cid;

        if ndc in(%ndcalzlist(start=1, end=&nndcalz)) then medgroup='alzheime';
        else if ndc in(%ndcbphlist(start=1, end=&nndcbph)) then medgroup='bphgpime';
        else if ndc in(%ndccarlist(start=1, end=&nndccar)) then medgroup='cargpime';
        else if ndc in(%ndccholist(start=1, end=&nndccho)) then medgroup='chogpime';
        else if ndc in(%ndcdeplist(start=1, end=&nndcdep)) then medgroup='depgpime';
        else if ndc in(%ndcdialist(start=1, end=&nndcdia)) then medgroup='diagpime';
        else if ndc in(%ndchyplist(start=1, end=&nndchyp)) then medgroup='hypgpime';
        else if ndc in(%ndcostlist(start=1, end=&nndcost)) then medgroup='ostgpime';
        else if ndc in(%ndcreslist(start=1, end=&nndcres)) then medgroup='resgpime';
        else if ndc in(%ndcthylist(start=1, end=&nndcthy)) then medgroup='thygpime';

        if medgroup eq '' then delete;
      run;
      options mprint mprintnest;
  /***title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;where masked_patientkey='49a8d247ddf4ee7a16d0dd8889e212cf533ab24458b565930cf5669ca5e7eaad';run;title; data;file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~';put;run;  ***/
  /***title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;where masked_patientkey='93bce1f6b35083c6410233e097f924bd197b40cf9f0b6a7b22210c5428ae196c';run;title; data;file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~';put;run;  ***/

      /* Patients with 2 or more of the target medgroups in ALL clientid/storeid */
      proc sql;
        create table t0_&cid as
        select distinct a.masked_patientkey, a.ndc, a.clientid, a.storeid, a.medgroup
        from rxfilldata_&cid a, rxfilldata_&cid b
        where (a.masked_patientkey=b.masked_patientkey) and (a.medgroup<>b.medgroup)
        ;
      quit;
  /***title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;where masked_patientkey='49a8d247ddf4ee7a16d0dd8889e212cf533ab24458b565930cf5669ca5e7eaad';run;title; data;file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~';put;run;  ***/
  /***title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;where masked_patientkey='93bce1f6b35083c6410233e097f924bd197b40cf9f0b6a7b22210c5428ae196c';run;title; data;file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~';put;run;  ***/
  /***title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;where masked_patientkey='2eba7b1d149352f3c82edd400204383bedc61c3bb04971b55e31a345a0aeb7bc';run;title; data;file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~';put;run;  ***/

      /* Collapse into single counts of each medgroup */
      proc sql;
        create table t1_&cid as
        select masked_patientkey, clientid, storeid, medgroup, count(*) as cnt_target_meds
        from t0_&cid
        group by masked_patientkey, clientid, storeid, medgroup
        ;
      quit;
  /***title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;where masked_patientkey='49a8d247ddf4ee7a16d0dd8889e212cf533ab24458b565930cf5669ca5e7eaad';run;title; data;file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~';put;run;  ***/
  /***title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;where masked_patientkey='93bce1f6b35083c6410233e097f924bd197b40cf9f0b6a7b22210c5428ae196c';run;title; data;file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~';put;run;  ***/
  /***title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;where masked_patientkey='2eba7b1d149352f3c82edd400204383bedc61c3bb04971b55e31a345a0aeb7bc';run;title; data;file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~';put;run;  ***/

      /* Collapse into single counts of all medgroups */
      proc sql;
        create table t1a_&cid as
        select masked_patientkey, clientid, storeid, count(*) as cnt_medgroups
        from t1_&cid
        group by masked_patientkey, clientid, storeid
        ;
      quit;

  /***title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;where masked_patientkey='49a8d247ddf4ee7a16d0dd8889e212cf533ab24458b565930cf5669ca5e7eaad';run;title; data;file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~';put;run;  ***/
  /***title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;where masked_patientkey='93bce1f6b35083c6410233e097f924bd197b40cf9f0b6a7b22210c5428ae196c';run;title; data;file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~';put;run;  ***/
  /***title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;where masked_patientkey='2eba7b1d149352f3c82edd400204383bedc61c3bb04971b55e31a345a0aeb7bc';run;title; data;file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~';put;run;  ***/

      /* Exclude patients who shopped 2+ different stores.  If they had not shopped different stores they would have cnt_medgroups of at least 2 here */
      proc append base=rxfilldata_all2 data=t1a_&cid(where=(cnt_medgroups>1)) FORCE; run;
      proc datasets NOlist; delete t1a_&cid; run;

      %let i=%eval(&i+1);
      %let cid=%scan(%superq(clids), &i, ',');
    %end;  /* cid */

    data l.rxfilldata_all2_&type;
      length sid $12;
      set rxfilldata_all2;
      sid=%rml0(storeid);
    run;
  %mend buildds;
  %buildds(type=cha, clids=%bquote(&clientid_cha));
  %buildds(type=ind, clids=%bquote(&clientid_ind));


  %macro process;
    /* Get store name */
    proc sql;
      create table final0_cha as
      select a.*, b.stateprov, b.name
      from l.rxfilldata_all2_cha a left join stores b on a.clientid=b.clients_fkid and a.sid=b.sid
      where b.stateprov = 'FL'
      ;
    quit;
    proc sql;
      create table final0_ind as
      select a.*, b.stateprov, b.name
      from l.rxfilldata_all2_ind a left join stores b on a.clientid=b.clients_fkid
      where b.stateprov = 'FL'
      ;
    quit;
    data final0;
      set final0_cha final0_ind;
    run;
  /***title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;where masked_patientkey='49a8d247ddf4ee7a16d0dd8889e212cf533ab24458b565930cf5669ca5e7eaad';run;title; data;file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~';put;run;  ***/
  /***title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;where masked_patientkey='2eba7b1d149352f3c82edd400204383bedc61c3bb04971b55e31a345a0aeb7bc';run;title; data;file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~';put;run;  ***/


    proc format;
      value f_chron
        2='2 of 10 Chronic Diseases'
        3='3 of 10 Chronic Diseases'
        4='4 of 10 Chronic Diseases'
        5='5 of 10 Chronic Diseases'
        6='6 of 10 Chronic Diseases'
        7='7 of 10 Chronic Diseases'
        8='8 of 10 Chronic Diseases'
        9='9 of 10 Chronic Diseases'
        10='10 of 10 Chronic Diseases'
        OTHER='ERROR'
        ;
      run;
        
    data final0;
      set final0(drop=masked_patientkey storeid);
      chrongroup=put(cnt_medgroups, f_chron.);
    run;

    proc sql;
      create table final1 as
      select clientid, sid, name, stateprov, chrongroup, count(*) as cntchron
      from final0
      group by clientid, sid, name, stateprov, chrongroup
      ;
    quit;

    
    proc sort data=final1;  by clientid  sid name stateprov; run;
    proc transpose data=final1 out=final2;
      by clientid sid name stateprov;
      id chrongroup;
      var cntchron;
    run;

    /* Get client name */
    proc sql;
      create table l.compiled as
      select a.*, b.clientname
      from final2 a left join clients b on a.clientid=b.clientid
      ;
    quit;
    proc print data=l.compiled(obs=max) width=minimum heading=H label;run;

    options nobyline;
    ODS EXCEL FILE="/Drugs/RFD/2015/12/AN-2340/Reports/FL_TwoPlus_Chronic_Groups_AN-2340.xml" options(sheet_name="AN-2340" embedded_titles='no');
    proc print data=l.compiled(drop=_NAME_) NOobs LABEL;
      var clientid clientname sid name stateprov '2 of 10 Chronic Diseases'n '3 of 10 Chronic Diseases'n '4 of 10 Chronic Diseases'n '5 of 10 Chronic Diseases'n '6 of 10 Chronic Diseases'n 
          '7 of 10 Chronic Diseases'n '8 of 10 Chronic Diseases'n '9 of 10 Chronic Diseases'n '10 of 10 Chronic Diseases'n
          ;
    run;
    ODS EXCEL close;
  %mend process;
  %process;
%mend m;
%m;
