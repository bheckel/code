 /* Created: Wed 02 Dec 2015 09:02:29 (Bob Heckel) */
options mprint nosgen validvarname=any;
options sasautos=(SASAUTOS '/Drugs/Macros' '.') ls=180 ps=max mprint validvarname=any;
libname l '/Drugs/RFD/2015/11/AN-2266/Datasets';
libname build '/Drugs/FunctionalData' access=readonly;
%dbpassword;

%macro m;
  /* Almost all 10 NDC lists overflow macrovariable limits */
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

  /* Query in groups of 1000 */
  %let kgroup=%eval((&nndc/1000)+1);
  %put DEBUG: &=nndc &=kgroup;

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

%macro bobh0112150600; /* {{{ */
  proc sql NOprint;
    select distinct ndc into :ndcalz separated by ','
    from l.ndc
    where ndc is not null and medgroup='alzheime'
    ;
    select distinct ndc into :ndcbph separated by ','
    from l.ndc
    where ndc is not null and medgroup='bphgpime'
    ;
    select distinct ndc into :ndccar separated by ','
    from l.ndc
    where ndc is not null and medgroup='cardiova'
    ;
    select distinct ndc into :ndccho separated by ','
    from l.ndc
    where ndc is not null and medgroup='choleste'
    ;
    select distinct ndc into :ndcdep separated by ','
    from l.ndc
    where ndc is not null and medgroup='depressi'
    ;
    select distinct ndc into :ndcdia separated by ','
    from l.ndc
    where ndc is not null and medgroup='diabetes'
    ;
    select distinct ndc into :ndchyp separated by ','
    from l.ndc
    where ndc is not null and medgroup='hyperten'
    ;
    select distinct ndc into :ndcost separated by ','
    from l.ndc
    where ndc is not null and medgroup='osteopor'
    ;
    select distinct ndc into :ndcres separated by ','
    from l.ndc
    where ndc is not null and medgroup='respirat'
    ;
    select distinct ndc into :ndcthy separated by ','
    from l.ndc
    where ndc is not null and medgroup='thyroidd'
    ;
  quit;

  data _null_;
    call symput('ndclistq', catq('1AC', &ndclist));

    call symput('ndcalzq', catq('1AC', &ndcalz));
    call symput('ndcbphq', catq('1AC', &ndcbph));
    call symput('ndccarq', catq('1AC', &ndccar));
    call symput('ndcchoq', catq('1AC', &ndccho));
    call symput('ndcdepq', catq('1AC', &ndcdep));
    call symput('ndcdiaq', catq('1AC', &ndcdia));
    call symput('ndchypq', catq('1AC', &ndchyp));
    call symput('ndcostq', catq('1AC', &ndcost));
    call symput('ndcresq', catq('1AC', &ndcres));
    call symput('ndcthyq', catq('1AC', &ndcthy));
  run;
%mend bobh0112150600; /* }}} */

/*DEBUG*/
%put %ndclist(start=1, end=5);
%put %ndcalzlist(start=1, end=5);
%put %ndcbphlist(start=1, end=5);
%put %ndccarlist(start=1, end=5);
%put %ndccholist(start=1, end=5);
%put %ndcdeplist(start=1, end=5);
%put %ndcdialist(start=1, end=5);
%put %ndchyplist(start=1, end=5);
%put %ndcostlist(start=1, end=5);
%put %ndcreslist(start=1, end=5);
%put %ndcthylist(start=1, end=5);

  proc sql;
    connect to odbc as myconn (user=&user. password=&password. dsn='db2ateb' readbuff=7000);

    create table storescnt as select * from connection to myconn (

      select clients_fkid, count(*) as nstores
      from amc.stores
      group by clients_fkid
      ;

    );

    disconnect from myconn;
  quit;
  
  proc sql;
    connect to odbc as myconn (user=&user. password=&password. dsn='db2ateb' readbuff=7000);

    create table stores as select * from connection to myconn (

      select clients_fkid, id, stateprov, storeid, name
      from amc.stores
      ;

    );

    disconnect from myconn;
  quit;
  
  data stores;
    length sid $12;
    set stores;
    sid=%rml0(storeid);
  run;
   
  proc sql noprint;
    select distinct clients_fkid into :clientid_ind separated by ',' from storescnt where nstores=1;
  quit;
/***  %put &=clientid_ind;***/
/*DEBUG*/
/***%let clientid_ind=9,14;***/

  proc sql noprint;
    select distinct clients_fkid into :clientid_cha separated by ',' from storescnt where nstores>1;
  quit;
/***  %put &=clientid_cha;***/
/*DEBUG*/
/***%let clientid_cha=408;***/
%let clientid_cha=118;

  proc datasets library=l; delete rxfilldata_all rxfilldata_all2; run;
  /* INDEPENDENTS - Pull */
  /*TODO*/

  /* CHAINS - Pull */
  /* For each month--- */
  %let months=201412 201501 201502 201503 201504 201505 201506 201507 201508 201509 201510 201511;
/***  %let months=201510 201511;***/
  %let i=1;
  %let mo=%scan(%superq(months), &i, ' ');
  %do %while ( &mo ne  );
    /* For each NDC group of 1K--- */
    %do k=1 %to &kgroup;
      %let iter=%eval(&k*1000);

      %let start=%eval(&iter-999);
      %let end=&iter;

      /* Don't overflow available macrovariables */
      %if &end gt &nndc %then %do;
        %let end=&nndc;
      %end;

      %put DEBUG: &=i &=mo &=k &=iter &=start &=end;

      proc sql;
        connect to odbc as myconn (user=&user. password=&password. dsn='db5' readbuff=7000);

        create table rxfilldata_&mo._&k as select * from connection to myconn (

          select masked_patientkey, clientid, storeid, ndc
          from public.rxfilldata_&mo
          where clientid in(&clientid_cha) and patientdob < date('now')-interval '65 year' and ndc in(%ndclist(start=&start, end=&end))
          ;

        );
        disconnect from myconn;
      quit;
      proc append base=l.rxfilldata_all data=rxfilldata_&mo._&k FORCE; run;
      proc datasets NOlist; delete rxfilldata_&mo._&k; run;
    %end;

    %let i=%eval(&i+1);
    %let mo=%scan(%superq(months), &i, ' ');
  %end;


  /* INDEPENDENTS - Process */
  /*TODO*/

  /* CHAINS - Process */
  %let i=1;
  %let cid=%scan(%superq(clientid_cha), &i, %str(,));

  %do %while ( &cid ne  );
    %put DEBUG: &=i &=cid;

    data rxfilldata_&cid;
      set l.rxfilldata_all;
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
    run;
/***    title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title; data;file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~';put;run;***/

    /* Patients with 2 or more of the target meds in all clientid/storeid   2- 039194b2bb00211b12be7fed150234c45f11fb886834cce2bd22cc8b860f4084*/
    proc sql;
      create table t0_&cid as
      select distinct a.masked_patientkey, a.ndc, a.clientid, a.storeid, a.medgroup
      from rxfilldata_&cid a, rxfilldata_&cid b
      where (a.masked_patientkey=b.masked_patientkey) and (a.medgroup<>b.medgroup)
      ;
    quit;
  /***title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;where masked_patientkey='2cd62a5e5326bd48d51b6c9972506d791f1c3ac6712b04d986986fd631e8b0a6';run;title; data;file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~';put;run;***/
  /***title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;where masked_patientkey='039194b2bb00211b12be7fed150234c45f11fb886834cce2bd22cc8b860f4084';run;title; data;file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~';put;run;***/

    /* Patients with 2 or more of the target groups in the same clientid/storeid */
    proc sql;
      create table t1_&cid as
      select masked_patientkey, clientid, storeid, count(*) as cnt_target_meds
      from t0_&cid
      group by masked_patientkey, clientid, storeid
      having count(*)>1
      ;
    quit;
    /***title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;where masked_patientkey='02d4e680205dc30dc101f94b3ab0c76c720f62210c4e3aa734e2a4c96f2fb550';run;title; data;file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~';put;run;  ***/

    proc append base=l.rxfilldata_all2 data=t1_&cid FORCE; run;
    proc datasets NOlist; delete t1_&cid; run;

    %let i=%eval(&i+1);
    %let cid=%scan(%superq(clientid_cha), &i, ',');
  %end;

  data l.rxfilldata_all2;
    length sid $12;
    set l.rxfilldata_all2;
    sid=%rml0(storeid);
  run;

  proc sql;
    create table final0 as
    select a.*, b.stateprov, b.name
    from l.rxfilldata_all2 a left join stores b on a.clientid=b.clients_fkid and a.sid=b.sid
    ;
  quit;

  proc format;
    value f_chron
      2='2 Chronic Diseases'
      3='3 Chronic Diseases'
      4='4 Chronic Diseases'
      5='5 Chronic Diseases'
      6='6 Chronic Diseases'
      7='7 Chronic Diseases'
      8='8 Chronic Diseases'
      9='9 Chronic Diseases'
      10='10 Chronic Diseases'
      11='11 Chronic Diseases'
      12='12 Chronic Diseases'
      13-HIGH='13+ Chronic Diseases'
      OTHER='ERROR'
      ;
    run;
      
  data final0;
    set final0(drop=masked_patientkey storeid);
    chrongroup=put(cnt_target_meds, f_chron.);
  run;

  proc sql;
    create table final1 as
    select sid, name, stateprov, chrongroup, count(*) as cntchron
    from final0
    group by sid, name, stateprov, chrongroup
    ;
  quit;
  
  proc sort data=final1;  by sid name stateprov; run;
  proc transpose data=final1 out=final2;
    by sid name stateprov;
    id chrongroup;
    var cntchron;
  run;

  options nobyline;
  ODS EXCEL FILE="/Drugs/RFD/2015/11/AN-2266/Reports/Publix_Chronic_AN-2266.xml" options(sheet_name="AN-2266" embedded_titles='no');
  proc print data=final2(drop=_NAME_) NOobs LABEL;
    var sid name stateprov '2 Chronic Diseases'n '3 Chronic Diseases'n '4 Chronic Diseases'n '5 Chronic Diseases'n '6 Chronic Diseases'n 
        '7 Chronic Diseases'n '8 Chronic Diseases'n '9 Chronic Diseases'n '10 Chronic Diseases'n '11 Chronic Diseases'n '12 Chronic Diseases'n
        '13+ Chronic Diseases'n
        ;
  run;
  ODS EXCEL close;
%mend m;
%m;
