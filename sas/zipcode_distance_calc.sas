%macro rfd(clid, oldds, shortname, clientname, sidlen);
  /* 17-Jun-16 (bheckel) */
  options sasautos=(SASAUTOS '/Drugs/Macros' '.') ls=max ps=max mprint mprintnest NOcenter validvarname=any sgen;
  %let y=2016;
  %let m=06;
  %let j=AN-4258;

  %let RFDPATH=/Drugs/RFD/&y/&m/&j;
  %let RFDNUM=%sysfunc(prxchange(s/(.*)\/(.*)$/$2/, 1, &RFDPATH));

  libname RFD "&RFDPATH/Datasets";
  libname TMMBUILD "/Drugs/TMMEligibility/&shortname/HPTasks/20160521/Data" access=readonly;
  libname OLDRFD '/Drugs/RFD/2016/05/AN-3803/Datasets' access=readonly;

  %let sidlenplus=%eval(&sidlen+1);
  
  /* This request wasn't imagined when the key was sidppid in the previous RFD */
  data fin2;
    set OLDRFD.&oldds;
    sid=substr(sidppid, 1, &sidlen);
    ppid=substr(sidppid, &sidlenplus);
    clid=&clid;
  run;
/***title "&SYSDSN";proc print data=OLDRFD.&oldds(obs=10) width=minimum heading=H;run;title;  ***/
/***title "&SYSDSN";proc print data=_LAST_(where=(sidppid='0010005167952')) width=minimum heading=H;run;title;  ***/
/***title "&SYSDSN";proc print data=_LAST_(where=(sidppid='0070000090778')) width=minimum heading=H;run;title;  ***/
/***title "&SYSDSN";proc print data=_LAST_(where=(sidppid='0560001180461')) width=minimum heading=H;run;title;  ***/

  proc sql;
    create table t as
    select distinct a.*, b.storecity, b.storestate
    from fin2 a left join TMMBUILD.rxfilldata b on a.sid=b.storeid and a.ppid=b.pharmacypatientid and a.ndc=b.ndc and a.filldate=b.filldate
    ;
  quit;
/***title "&SYSDSN";proc print data=_LAST_(where=(sid='001' and ppid='0005167952')) width=minimum heading=H;run;title;  ***/
/***title "&SYSDSN";proc print data=_LAST_(where=(sid='007' and ppid='0000090778')) width=minimum heading=H;run;title;  ***/
/***title "&SYSDSN";proc print data=_LAST_(where=(sid='056' and ppid='0001180461')) width=minimum heading=H;run;title;  ***/

  %dbpassword;
  proc sql;
    connect to odbc as myconn (user=&usr_tableau password=&psw_tableau. dsn='db3' readbuff=7000);

    create table RFD.stores_&clid as select * from connection to myconn (

      select distinct lpad(clientstoreid::text, &sidlen, '0') as clientstoreid, displayname, storeid, city, stateprov, postalcode
      from client.store as st join client.chain as ch on ch.chainid=st.chainid
      where ch.clientid=&clid
      ;

    );

    disconnect from myconn;
  quit;
  %put !!!&SQLRC &SQLOBS;

  proc sql;
    create table final1 as
    select distinct a.*, b.*
    from t a left join RFD.stores_&clid b on a.sid=b.clientstoreid
    ;
  quit;
/***title "&SYSDSN";proc print data=_LAST_(where=(sid='007')) width=minimum heading=H;run;title;  ***/
/***title "&SYSDSN";proc print data=_LAST_(where=(sid='056')) width=minimum heading=H;run;title;  ***/

  /* Calculate the distance between zipcode centroids.  Adapted from SUGI 31 paper. */
  %macro geodist(lat1, long1, lat2, long2);
    %let pi180=0.0174532925199433;
    7921.6623*arsin(sqrt((sin((&pi180*&lat2-&pi180*&lat1)/2))**2+cos(&pi180*&lat1)*cos(&pi180*&lat2)*(sin((&pi180*&long2-&pi180*&long1)/2))**2));
  %mend;

  %macro dist(check, givenlist);
    options nomprint nomprintnest nosgen;
    %local i;
    %let i=1;
    %do %until (%qscan(&givenlist, &i)=  );
      %let given=%qscan(&givenlist, &i);

      %let i=%eval(&i+1);

      data t1(keep=long1 lat1 city1);
        set sashelp.zipcode (where=(zip in(&check)));
        rename x=long1 y=lat1 city=city1;
      run;

      data t2(keep=long2 lat2 city2);
        set sashelp.zipcode(where=(zip in(&given)));
        rename x=long2 y=lat2 city=city2;
      run;

      data temp;
        merge t1 t2;
        zipdist=%geodist(lat1,long1,lat2,long2);
        given=&given;
        check=&check;
      run;

      proc append base=RFD.distances_&clid data=temp;
    %end;
    options mprint mprintnest sgen;
  %mend;

  %local i;

  proc sql NOprint;
    select distinct substr(postalcode, 1, 5) into :ziplist separated by ' ' from final1;
  quit;

  %if not %sysfunc(exist(RFD.distances_&clid)) %then %do;
    %let i=1;
    %do %until (%qscan(&ziplist, &i)=  );
      %let zip=%qscan(&ziplist, &i);
      %let i=%eval(&i+1);
      /* Specified in Jira */
      %dist(&zip, 75093 32218 45005 83646 73069 73069 46131 78229 35235 36542 63303 60631 78228 46140 10461 28557 72204 34601 33169 89148 80220 75230 91606 46123 38103 78231 63141 77066 10016 33175);
    %end;
  %end;

  proc sql NOprint;
    select distinct put(check,z5.) as check into :ziplist2 separated by ','
    from RFD.distances_&clid
    /* Avoid bad incoming zips like 123-4 */
    where zipdist > 0 and zipdist <= 50 
    ;
  quit;
  %put &=ziplist2;

  %if &sqlobs > 0 %then %do;
    data final2;
      set final1;
      if postalcode in ( &ziplist2 );
    run;
  /***title "&SYSDSN";proc print data=_LAST_(where=(sid='056' and ppid='0001180461')) width=minimum heading=H;run;title;  ***/

    proc sql;
      create table final_&clid as
      select "&clientname" as client, count(distinct sidppid) as count
      from final2
      ;
    quit;

    title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;run;
  %end;
%mend rfd;
%rfd(7, final_ahold, Ahold, Ahold, 4);
%rfd(355, final_discountdrugmart, DiscDrugMart, DiscountDrugMart, 3);
%rfd(137, final_freds, Freds, Freds, 4);
%rfd(2, final_gianteagle, GiantEagle, GiantEagle, 4);
%rfd(10, final_kmart, Kmart, Kmart, 4);
%rfd(19, final_shopko, Shopko, Shopko, 3);
%rfd(22, final_weis, Weis, Weis, 3);
