options mprint nosgen;
options sasautos=(SASAUTOS '/Drugs/Macros' '.') ls=180 ps=max mprint validvarname=any;
libname l '/Drugs/RFD/2015/11/AN-2237/Datasets';
%dbpassword;

%macro m;
  /* Manual import of l.ndcgpi was from "Copy of Independent rfr list 20150801.xlsx" */
  data ndcgpi;
/***    set l.ndcgpi(obs=111);***/
    set l.ndcgpi;
    ndc=compress(ndc_upc_hri, '-');
  run;

  proc sql;
    select left(put(count(distinct ndc),8.)) into :nndc
    from ndcgpi
    where ndc is not null
    ;
  quit;

  %do i=1 %to &nndc;
    %global ndc&i;
    %let ncd&i=;
  %end;

  proc sql NOprint;
    select distinct cats("'",left(trim(ndc)),"'") into :ndc1 - :ndc&nndc
    from ndcgpi
    where ndc is not null
    ;
  quit;

  %let ndc0='00000000000';  /* placeholder for first element */
%put !!!!&ndc1;%put;
%put  !!!!&ndc2;%put;
%put  !!!!&ndc3;%put;
%put  !!!!&ndc4;%put;
%put  !!!!&ndc5;%put;
%put  !!!!&ndc6;%put;
%put  !!!!&ndc7;%put;
%put  !!!!&ndc8;%put;
%put  !!!!&ndc9;%put;
%put  !!!!&ndc10;%put;
%put  !!!!&ndc11;%put;
%put  !!!!&ndc12;%put;
%put  !!!!&ndc13;%put;
%put  !!!!&ndc14;%put;
%put  !!!!&ndc15;%put;
%put  !!!!&ndc16;%put;
%put  !!!!&ndc17;%put;
%put  !!!!&ndc18;%put;
%put  !!!!&ndc19;%put;
%put  !!!!&ndc20;%put;
%put  !!!!&ndc21;%put;
%put  !!!!&ndc109;%put;
%put  !!!!&ndc110;%put;
%put  !!!!&ndc111;%put;

  /* Query in groups of 1000 */
/***  %let kgroup=%eval((&nndc/10)+1);***/
  %let kgroup=%eval((&nndc/1000)+1);
  %put DEBUG: &=nndc &=kgroup;

  %macro ndclist(start=, end=);
    &ndc0
    %do j=&start %to &end;
,&&ndc&j
    %end;
  %mend;
  
  proc datasets library=l; delete rxfilldata_all final; run;
  %do k=1 %to &kgroup;
    /* Query 25K NDCs in groups of 1000 */

    /* k:1 so iter=1000, k:2 so iter=2000, k:3 so iter=3000 ... */
/***    %let iter=%eval(&k*10);***/
    %let iter=%eval(&k*1000);

    /* iter:1000-999 so start=1, iter:2000-999 so start=1001, iter:3000-999 so start=2001 ... */
/***    %let start=%eval(&iter-9);***/
    %let start=%eval(&iter-999);
    /* iter:1000 so end=1000, iter:2000 so end=2000, iter:3000 so end=3000 ... */
    %let end=&iter;

    /* Don't overflow available macrovariables */
    %if &end gt &nndc %then %do;
      %let end=&nndc;
    %end;

    %put DEBUG: ndclist call  &=k &=iter &=start &=end;

    proc sql;
      connect to odbc as myconn (user=&user. password=&password. dsn='db5' readbuff=7000);

      create table rxfilldata&k as select * from connection to myconn (

        select masked_patientkey, patientdob, clientid, storeid, ndc
        from public.rxfilldata_201510
              where patientdob < date('now') - interval '18 year'
                    and autofillprogram = false
                    /* From Independent List - 20Nov15.xlsx */
                    and clientid in ('4','44','55','56','113','123','142','165','186','187','188','189','190','192','193','201','209','256','395','400','424','434','445','449','450','468','515','516','519','532','551','574','583','589','599','604','605','606','612','615','623','627','628','635','636','641','646','647','648','650','651','652','654','655','656','657','662','664','665','668','670','675','677','678','680','683','684','685','686','687','688','689','690','691','692','694','697','698','699','700','701','702','704','708','712','713','714','715','717','718','719','752','754','755','756','757','758','760','761','762','763','764','767','768','769','770','771','772','776','777','778','780','782','783','784','785','787','788','791','792','793','794','797','805','806','807','808','809','812','813','815','818','820','821','825','826','828','829','832','833','834','836','838','840','841','842','845','847','850','853','854','855','857','858','866','870','871','872','873','874','875','876','877','878','879','880','882','883','885','886','888','889','891','893','895','901','902','905','909','910','911','916','921','922','923','924','926','929','930','931','935')
                    and ndc in(%ndclist(start=&start, end=&end))
/***                    limit 200***/
        ;

      );
      disconnect from myconn;
    quit;

    proc append base=l.rxfilldata_all data=rxfilldata&k FORCE; run;
    proc datasets NOlist; delete rxfilldata&k; run;
  %end;

  proc sql;
    create table t as
    select clientid, storeid, ndc, count(distinct masked_patientkey) as patientcount
    from l.rxfilldata_all(where=(ndc ne '00000000000'))
    group by clientid, storeid, ndc
    ;
  quit;

  proc sql;
    create table l.final as
    select a.*, b.gpi
    from t a left join ndcgpi b on a.ndc=b.ndc
    ;
  quit;

  options nobyline;
  ODS EXCEL FILE="/Drugs/RFD/2015/11/AN-2237/Reports/Independents RFR RFD.xml" options(sheet_name="#BYVAL(gpi)" autofilter='all');
  proc sort data=l.final; by gpi; run;
  proc print data=l.final NOobs;
    by gpi;
    pageby gpi;
  run;
  ODS EXCEL close;

  ODS EXCEL FILE="/Drugs/RFD/2015/11/AN-2237/Reports/Independents RFR RFD2.xml";
  proc sort data=l.final; by clientid storeid gpi ndc; run;
  proc print data=l.final NOobs style(Header)=[just=center];
  run;
  ODS EXCEL close;
%mend m;
%m;
