
%macro zostexclude(db=, dsout=);
  /* All existing/previous Zostavax users to exclude */
  options sasautos=(SASAUTOS '/Drugs/Macros' '.') ls=180 ps=max mprint validvarname=any;
  %dbpassword;
    proc sql;
      connect to odbc as myconn (user=&user. password=&password. dsn='db5' readbuff=7000);

      create table l.&dsout as select * from connection to myconn (

        select masked_patientkey
        from public.&db
        where ndc in('00006496300','00006496341','54868570300','68258890801','68258890800')
        ;

      );
      disconnect from myconn;
    quit;
%mend zostexclude;
libname l '/Drugs/RFD/2015/11/AN-2013/Datasets';
/***%zostexclude(db=rxfilldata_parent, dsout=exclude1);***/
/***%zostexclude(db=rxfilldata2_parent, dsout=exclude2);***/



%macro zostcandidates(db=, dsout=, dsnum=);
  options sasautos=(SASAUTOS '/Drugs/Macros' '.') ls=180 ps=max mprint validvarname=any;
  %dbpassword;

    proc sql;
      connect to odbc as myconn (user=&user. password=&password. dsn='db5' readbuff=7000);

      /* All patients in the range */
      create table l.&dsout as select * from connection to myconn (

        select masked_patientkey, patientdob, clientid, storeid, filldate, patientphonenbr
        from public.&db
              where filldate > date('now') - interval '1 year'
              and patientdob < date('now') - interval '50 year'
        ;

      );
      disconnect from myconn;
    quit;

    proc sql;
      connect to odbc as myconn (user=&user. password=&password. dsn='db2ateb' readbuff=7000);

      create table l.stores as select * from connection to myconn (

        select name, storeid, stateprov, clients_fkid
        from amc.stores
        ;

      );

      disconnect from myconn;
    quit;

    proc sql;
      connect to odbc as myconn (user=&user. password=&password. dsn='db2ateb' readbuff=7000);

      create table l.clients as select * from connection to myconn (

        select name, id
        from amc.clients
        ;

      );

      disconnect from myconn;
    quit;
%mend zostcandidates;
/***%zostcandidates(db=rxfilldata_parent, dsout=potential1, dsnum=1);***/
/***%zostcandidates(db=rxfilldata2_parent, dsout=potential2, dsnum=2);***/


%macro m(dsnum=);
  options sasautos=(SASAUTOS '/Drugs/Macros' '.') ls=180 ps=max mprint validvarname=any;
  /* Eliminate existing/previous Zostavax users */
  proc sql;
    create table potentialx1 as
    select *
    from l.potential&dsnum where masked_patientkey not in (select * from l.exclude&dsnum)
    ;
  quit;

  proc sort data=potentialx1; by masked_patientkey patientphonenbr; run;

  data potentialx2;
    set potentialx1;
    by masked_patientkey patientphonenbr;
    if first.masked_patientkey and first.patientphonenbr;
  run;

/***  %let bigchains=20,12,164,7,118,137,10,33,19,17,21,329,37,22,355,314,408,227,16,595;***/
  proc sql;
    create table potentialx3 as
    select a.*, b.name, b.clients_fkid, %rml0(b.storeid) as sid, b.stateprov
    from potentialx2 a left join l.stores b on a.clientid=b.clients_fkid and a.storeid=b.storeid
    where stateprov in('IL','TX','CA')
    order by masked_patientkey, patientphonenbr
    ;
  quit;
/***title "ds:&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H; run;title;***/

  title '!!!check1_&dsnum';proc sql; create table l.check1_&dsnum as select * from potentialx3 group by masked_patientkey having count(*)>1; quit;title;

  proc sql;
    create table l.check2_&dsnum as
    select *
    from potentialx3
    where sid is null
    ;
  quit;

  proc format;
    value f_yr
          50-59='50-59'
          60-HIGH ='60+'
          ;
  run;

  data final0(keep= masked_patientkey clients_fkid name stateprov agerange storeid clientid);
    set potentialx3;
    age = int((intck('YEAR', today(), patientdob)))*-1;
    if age ge 50;
    agerange = put(age, f_yr.);
  run;

  proc sql;
    create table final00 as
    select stateprov, clientid, storeid, name, agerange, count(*) as Count
    from final0
    group by stateprov, clientid, storeid, name, agerange
    ;
  quit;

  proc sql;
    create table final(drop=clientid) as
    select a.*, b.name as cname
    from final00 a left join l.clients b on a.clientid=b.id
    order by stateprov, clientid, storeid, agerange, name
    ;
  quit;

  data l.final&dsnum;
    retain stateprov cname storeid name agerange Count;
    set final;
    rename  stateprov='State'n
            cname='Client Name'n
            storeid='Store ID'n
            name='Store Name'n
            agerange='Age'n 
            ;
  run;
%mend m;
%m(dsnum=1);
%m(dsnum=2);

%macro m2;
  data combined;
    set l.final1
        l.final2
        ;
  run;
  options nosource;
  proc export data=combined OUTFILE='/Drugs/RFD/2015/11/AN-2013/Reports/Merck Targeted Zostavax.csv' DBMS=csv REPLACE; run;
%mend m2;
%m2;
